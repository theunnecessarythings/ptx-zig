const std = @import("std");
const ptx = @import("ptx_zig");

const kernel_name =
    "kernel_cutlass_kernel___main__DenseGemmKernel_object_at__TiledMMA_ThrLayoutVMNK11110000_PermutationMNK____MMAAtom_ThrID10_ShapeMNK12812816_TVLayoutA1128161281128_TVLayoutB1128161281128_TV_0";

pub fn main() !void {
    const kernel_ptx = comptime ptx.build(.{
        .version = .v9_1,
        .target = .sm_100a,
        .address_size = 64,
        .entry_visibility = .visible,
    }, struct {
        pub fn emit(m: *ptx.Module) void {
            @setEvalBranchQuota(100000);
            const shmem = m.externShared("__dynamic_shmem__0", 1024);

            const k = m.entry(kernel_name, .{});
            k.reqntid(128, 1, 1);

            const flags = k.paramBytes(kernel_name ++ "_param_0", 3, 1);
            const tma_a = k.paramBytes(kernel_name ++ "_param_1", 128, 64);
            const shape_a = k.paramBytes(kernel_name ++ "_param_2", 12, 4);
            const tma_b = k.paramBytes(kernel_name ++ "_param_3", 128, 64);
            const shape_b = k.paramBytes(kernel_name ++ "_param_4", 12, 4);
            const out_desc = k.paramBytes(kernel_name ++ "_param_5", 40, 8);

            // Concise positional math + short helpers for common ld/st
            const flag2 = k.ld(.param, .b16, flags.at(2));
            const flag2_masked = k.@"and"(.b16, flag2, 1);
            const p_flag2 = k.setp(.ne, .u16, flag2_masked, 0);

            const flag1 = k.ld(.param, .b16, flags.at(1));
            const flag1_masked = k.@"and"(.b16, flag1, 1);
            _ = k.setp(.ne, .u16, flag1_masked, 0);

            const flag0 = k.ld(.param, .b16, flags.at(0));
            const flag0_masked = k.@"and"(.b16, flag0, 1);
            _ = k.setp(.ne, .u16, flag0_masked, 0);

            const tma_a_param = k.declReg(.u64, "tma_a_param");
            const tma_b_param = k.declReg(.u64, "tma_b_param");
            const tma_a_generic = k.declReg(.u64, "tma_a_generic");
            const tma_b_generic = k.declReg(.u64, "tma_b_generic");
            const smem_base = k.declReg(.b32, "smem_base");
            const barrier_count = k.declReg(.b32, "barrier_count");
            const tile_bytes = k.declReg(.b32, "tile_bytes");
            const cache_hint = k.declReg(.b64, "cache_hint");
            const leader = k.declReg(.pred, "leader");

            k.movInto(.u64, tma_a_param, tma_a);
            k.movInto(.u64, tma_b_param, tma_b);

            const problem_k = k.ld(.param, .s32, shape_a.at(4));
            const out_base = k.ld(.param, .b64, out_desc.at(0));
            const stride_n = k.ld(.param, .b64, out_desc.at(24));
            _ = k.ld(.param, .b64, out_desc.at(32));

            k.cvta().from().space(.param).ty(.u64).callInto(tma_a_generic, tma_a_param);
            k.prefetch().tensormap().call(tma_a_generic);

            k.cvta().from().space(.param).ty(.u64).callInto(tma_b_generic, tma_b_param);
            k.prefetch().tensormap().call(tma_b_generic);

            const tid = k.movSpecial(.u32, ptx.sreg.tid.x);
            const cta_x = k.movSpecial(.u32, ptx.sreg.ctaid.x);
            const cta_z = k.movSpecial(.u32, ptx.sreg.ctaid.z);
            const ntid_x = k.movSpecial(.u32, ptx.sreg.ntid.x);
            const tid_y = k.movSpecial(.u32, ptx.sreg.tid.y);
            const tid_z = k.movSpecial(.u32, ptx.sreg.tid.z);
            const ntid_y = k.movSpecial(.u32, ptx.sreg.ntid.y);

            const lane_linear_yz = k.mad().ty(.s32).call(.{ ntid_y, tid_z, tid_y });
            const tid_linear = k.mad().ty(.s32).call(.{ lane_linear_yz, ntid_x, tid });
            const warp = k.shr().ty(.b32).call(.{ tid_linear, 5 });
            const non_producer = k.setp(.ne, .s32, warp, 0);

            k.braIf(non_producer, false, "$L_after_mbarrier_init");
            k.movInto(.b32, barrier_count, 1);
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(0)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(8)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(16)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(24)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(32)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(40)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(48)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(56)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(64)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(72)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(80)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(88)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(96)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(104)), barrier_count });
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(112)), barrier_count });
            k.movInto(.b32, barrier_count, 128);
            k.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(120)), barrier_count });
            k.label("$L_after_mbarrier_init");

            k.fence().op(.mbarrier_init).order(.release).scope(.cluster).call();

            k.movInto(.b32, smem_base, shmem);
            k.movInto(.b32, tile_bytes, 32768);
            k.movInto(.b64, cache_hint, 0);

            k.bar_sync(0);

            k.braIf(non_producer, false, "$L_after_tcgen_alloc");
            k.tcgen05(.alloc).call(.{ ptx.addr(shmem.at(136)), 128 });
            k.label("$L_after_tcgen_alloc");

            const cta_m_offset = k.shl().ty(.b32).call(.{ cta_x, 7 });
            const cta_n = k.movSpecial(.u32, ptx.sreg.ctaid.y);
            const cta_n_offset = k.shl().ty(.b32).call(.{ cta_n, 7 });

            const problem_nonzero = k.setp(.gt, .s32, problem_k, 0);
            k.braIf(problem_nonzero, true, "$L_after_tma");

            k.elect().sync().call(.{ smem_base, leader, -1 });
            k.braIf(leader, true, "$L_after_tma_copy");

            k.mbarrier(.arrive).expect_tx().release().scope(.cta).space(.shared).shared_scope(.cta).call(.{ ptx.addr(shmem.at(0)), tile_bytes });

            k.cp_async(.bulk_tensor).dims(3).mbarrier("complete_tx::bytes").cache_hint(.L2).call(.{
                ptx.addr(shmem.at(256)),
                tma_a_generic,
                ptx.brace(.{ 0, cta_m_offset, cta_z }),
                ptx.addr(shmem.at(0)),
                cache_hint,
            });

            k.cp_async(.bulk_tensor).dims(3).mbarrier("complete_tx::bytes").cache_hint(.L2).call(.{
                ptx.addr(shmem.at(16640)),
                tma_b_generic,
                ptx.brace(.{ 0, cta_n_offset, cta_z }),
                ptx.addr(shmem.at(0)),
                cache_hint,
            });

            k.label("$L_after_tma_copy");

            k.mbarrier(.try_wait).parity().acquire().scope(.cta).space(.shared).shared_scope(.cta).call(.{ leader, ptx.addr(shmem.at(0)), 0 });
            k.tcgen05(.mma).kind(.f16).call(.{
                ptx.addr(shmem.at(136)),
                tma_a_generic,
                tma_b_generic,
                0,
                ptx.brace(.{ 0, 0, 0, 0 }),
                leader,
            });
            k.tcgen05(.commit).call(.{ptx.addr(shmem.at(112))});

            k.label("$L_after_tma");

            const row64 = k.cvt().ty(.u64).src(.u32).call(cta_m_offset);
            const col64 = k.cvt().ty(.u64).src(.u32).call(cta_n_offset);
            const row_offset = k.mul().ty(.u64).call(.{ row64, stride_n });
            const elem_offset = k.add(.u64, row_offset, col64);
            const byte_offset = k.shl().ty(.b64).call(.{ elem_offset, 1 });
            const out_ptr = k.add(.u64, out_base, byte_offset);

            const store_guard = k.setp(.gt, .s32, problem_k, 0);
            k.predicated(store_guard, false, struct {
                fn body(inner: *ptx.KernelBuilder) void {
                    const value = inner.mov(.b16, 0);
                    const out_ptr_b64 = ptx.Reg(.b64){ .data = out_ptr.data };
                    inner.st(.global, .b16, ptx.Ptr(.global, .b16){ .reg = out_ptr_b64 }, value);
                }
            }.body);

            k.tcgen05(.dealloc).call(.{ ptx.addr(shmem), 128 });

            k.predicated(p_flag2, false, struct {
                fn body(inner: *ptx.KernelBuilder) void {
                    inner.bar_sync(0);
                }
            }.body);

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
        if (std.mem.indexOf(u8, kernel_ptx, "prefetch.tensormap") == null) @compileError("missing tensormap prefetch");
        if (std.mem.indexOf(u8, kernel_ptx, "cp.async.bulk.tensor.3d") == null) @compileError("missing tensor async copy");
        if (std.mem.indexOf(u8, kernel_ptx, "tcgen05.mma.cta_group::1.kind::f16") == null) @compileError("missing tcgen05 mma");
    }

    std.debug.print("{s}", .{kernel_ptx});
}
