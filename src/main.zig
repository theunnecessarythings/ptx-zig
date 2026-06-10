const std = @import("std");
const ptx = @import("ptx_zig");

pub fn main() !void {
    const kernel_ptx = comptime ptx.build(.{
        .version = .v9_1,
        .target = .sm_100a,
        .address_size = 64,
        .entry_visibility = .visible,
    }, struct {
        pub fn emit(m: *ptx.Module) void {
            const shmem = m.externShared("__dynamic_shmem__0", 1024);

            const k = m.entry("blackwell_cutlass_smoke", .{});
            k.reqntid(128, 1, 1);

            // Shape borrowed from the uploaded NVVM/CUTLASS-style PTX:
            // byte-array kernel params with explicit alignment.
            const flags = k.paramBytes("flags", 3, 1);
            const tma_a = k.paramBytes("tma_a_desc", 128, 64);
            const shape_a = k.paramBytes("shape_a", 12, 4);
            const tma_b = k.paramBytes("tma_b_desc", 128, 64);
            const shape_b = k.paramBytes("shape_b", 12, 4);
            const out_desc = k.paramBytes("out_desc", 40, 8);

            // Normal builder usage: param offsets, predicates, sregs, arithmetic.
            const flag = k.ld(.param, ptx.PtxType.b16, flags.at(2));
            const masked = k.@"and"(ptx.PtxType.b16, flag, 1);
            const enable = k.setp(.ne, ptx.PtxType.u16, masked, 0);

            const tid = k.movSpecial(ptx.PtxType.u32, ptx.sreg.tid.x);
            const cta_m = k.movSpecial(ptx.PtxType.u32, ptx.sreg.ctaid.x);
            const cta_n = k.movSpecial(ptx.PtxType.u32, ptx.sreg.ctaid.y);
            const warp = k.shr(ptx.PtxType.b32, tid, 5);
            const is_producer = k.setp(.eq, ptx.PtxType.u32, warp, 0);

            const problem_k = k.ld(.param, ptx.PtxType.s32, shape_a.at(4));
            const out_base = k.ld(.param, ptx.PtxType.b64, out_desc.at(0));
            const stride_n = k.ld(.param, ptx.PtxType.b64, out_desc.at(24));

            const row = k.shl(ptx.PtxType.b32, cta_m, 7);
            const col = k.shl(ptx.PtxType.b32, cta_n, 7);
            const row64 = k.cvt(ptx.PtxType.u64, ptx.PtxType.u32, row, .none);
            const col64 = k.cvt(ptx.PtxType.u64, ptx.PtxType.u32, col, .none);
            const row_offset = k.mul(ptx.PtxType.u64, row64, stride_n);
            const elem_offset = k.add(ptx.PtxType.u64, row_offset, col64);
            const byte_offset = k.shl(ptx.PtxType.b64, elem_offset, 1);
            const out_ptr = k.add(ptx.PtxType.u64, out_base, byte_offset);

            // Named registers make raw PTX snippets readable and stable.
            _ = k.declReg(ptx.PtxType.u64, "tma_a_param");
            _ = k.declReg(ptx.PtxType.u64, "tma_b_param");
            _ = k.declReg(ptx.PtxType.u64, "tma_a_generic");
            _ = k.declReg(ptx.PtxType.u64, "tma_b_generic");
            _ = k.declReg(ptx.PtxType.b32, "smem_base");
            _ = k.declReg(ptx.PtxType.b32, "barrier_count");
            _ = k.declReg(ptx.PtxType.b32, "tile_bytes");
            _ = k.declReg(ptx.PtxType.b64, "cache_hint");
            _ = k.declReg(ptx.PtxType.pred, "leader");

            // Raw snippets for features the library does not model yet.
            // This is intentional: this example is meant to reveal the next API gaps.
            k.raw(
                \\
                \\    // ---- raw Blackwell/CUTLASS-shape setup ----
                \\    mov.u64     %tma_a_param, tma_a_desc;
                \\    mov.u64     %tma_b_param, tma_b_desc;
                \\    cvta.param.u64     %tma_a_generic, %tma_a_param;
                \\    cvta.param.u64     %tma_b_generic, %tma_b_param;
                \\    prefetch.tensormap [%tma_a_generic];
                \\    prefetch.tensormap [%tma_b_generic];
                \\
            );

            k.predicated(is_producer, false, struct {
                fn body(inner: *ptx.KernelBuilder) void {
                    inner.raw(
                        \\
                        \\    mov.b32     %barrier_count, 1;
                        \\    mbarrier.init.shared.b64     [__dynamic_shmem__0], %barrier_count;
                        \\    mbarrier.init.shared.b64     [__dynamic_shmem__0+8], %barrier_count;
                        \\    mbarrier.init.shared.b64     [__dynamic_shmem__0+16], %barrier_count;
                        \\    mov.b32     %barrier_count, 128;
                        \\    mbarrier.init.shared.b64     [__dynamic_shmem__0+24], %barrier_count;
                        \\
                    );
                }
            }.body);

            k.raw(
                \\
                \\    fence.mbarrier_init.release.cluster;
                \\    bar.sync 0;
                \\    mov.b32     %smem_base, __dynamic_shmem__0;
                \\    mov.b32     %tile_bytes, 32768;
                \\    mov.b64     %cache_hint, 0;
                \\
                \\    // ---- representative unsupported tensor-memory ops ----
                \\    elect.sync     %smem_base|%leader, -1;
                \\    @!%leader bra     $L_after_tma;
                \\    mbarrier.arrive.expect_tx.release.cta.shared::cta.b64 _, [__dynamic_shmem__0], %tile_bytes;
                \\    cp.async.bulk.tensor.3d.shared::cta.global.tile.mbarrier::complete_tx::bytes.L2::cache_hint [__dynamic_shmem__0+256], [%tma_a_generic, {0, 0, 0}], [__dynamic_shmem__0], %cache_hint;
                \\    cp.async.bulk.tensor.3d.shared::cta.global.tile.mbarrier::complete_tx::bytes.L2::cache_hint [__dynamic_shmem__0+16640], [%tma_b_generic, {0, 0, 0}], [__dynamic_shmem__0], %cache_hint;
                \\$L_after_tma:
                \\    mbarrier.try_wait.parity.acquire.cta.shared::cta.b64 %leader, [__dynamic_shmem__0], 0;
                \\    tcgen05.alloc.cta_group::1.sync.aligned.shared::cta.b32 [__dynamic_shmem__0+136], 128;
                \\    tcgen05.mma.cta_group::1.kind::f16 [__dynamic_shmem__0+136], %tma_a_generic, %tma_b_generic, 0, {0, 0, 0, 0}, %leader;
                \\    tcgen05.commit.cta_group::1.mbarrier::arrive::one.shared::cluster.b64 [__dynamic_shmem__0+112];
                \\    tcgen05.dealloc.cta_group::1.sync.aligned.b32 __dynamic_shmem__0, 128;
                \\
            );

            // Finish with normal builder instructions so this still exercises typed operands.
            const guard = k.setp(.gt, ptx.PtxType.s32, problem_k, 0);
            k.predicated(guard, false, struct {
                fn body(inner: *ptx.KernelBuilder) void {
                    const value = inner.mov(ptx.PtxType.b16, 0);
                    const out_ptr_b64 = ptx.Reg(ptx.PtxType.b64){ .data = out_ptr.data };
                    inner.st(.global, ptx.PtxType.b16, ptx.Ptr(.global, ptx.PtxType.b16){ .reg = out_ptr_b64 }, value);
                }
            }.body);

            k.predicated(enable, false, struct {
                fn body(inner: *ptx.KernelBuilder) void {
                    inner.bar_sync(0);
                }
            }.body);

            _ = shmem;
            _ = tma_a;
            _ = tma_b;
            _ = shape_b;

            k.ret();
        }
    });

    comptime {
        if (std.mem.indexOf(u8, kernel_ptx, ".version 9.1") == null) @compileError("missing PTX 9.1");
        if (std.mem.indexOf(u8, kernel_ptx, ".target sm_100a") == null) @compileError("missing sm_100a target");
        if (std.mem.indexOf(u8, kernel_ptx, ".extern .shared .align 1024 .b8 __dynamic_shmem__0[];") == null) {
            @compileError("missing extern dynamic shared memory declaration");
        }
        if (std.mem.indexOf(u8, kernel_ptx, "cp.async.bulk.tensor.3d") == null) @compileError("missing tensor async copy smoke op");
        if (std.mem.indexOf(u8, kernel_ptx, "tcgen05.mma.cta_group::1.kind::f16") == null) @compileError("missing tcgen05 mma smoke op");
    }

    std.debug.print("{s}", .{kernel_ptx});
}
