const std = @import("std");
const ptx = @import("ptx_zig");
const cu = @import("cuda.zig");

pub fn main() !void {
    const kernel_ptx = comptime ptx.build(.{
        .version = .v8_4,
        .target = .sm_75,
        .address_size = 64,
    }, struct {
        pub fn vector_add(k: *ptx.KernelBuilder) void {
            const ps = k.params(.{
                .A = .b64,
                .B = .b64,
                .C = .b64,
                .n = .u32,
            });

            const tid = k.movSpecial(.u32, ptx.sreg.tid.x);
            const ctaid = k.movSpecial(.u32, ptx.sreg.ctaid.x);
            const ntid = k.movSpecial(.u32, ptx.sreg.ntid.x);
            
            const block_offset = k.mul(.u32, ctaid, ntid);
            const global_tid = k.add(.u32, block_offset, tid);

            const n = k.ldParam(ps.n);

            const p0 = k.setp(.ge, .u32, global_tid, n);
            k.retIf(p0);

            // Calculate address: A + tid * 4 (for float32)
            const tid64 = k.cvt(.u64, .u32, global_tid);
            const offset = k.mul(.u64, tid64, @as(u64, 4));

            const addrA = k.add(.u64, k.ldParam(ps.A), offset);
            const addrB = k.add(.u64, k.ldParam(ps.B), offset);
            const addrC = k.add(.u64, k.ldParam(ps.C), offset);

            const valA = k.ld(.global, .f32, addrA);
            const valB = k.ld(.global, .f32, addrB);
            const valC = k.add(.f32, valA, valB);

            k.st(.global, .f32, addrC, valC);
            k.ret();
        }
    });

    std.debug.print("{s}", .{kernel_ptx});

    // --- CUDA Runner ---
    try cu.init();
    defer cu.deinit();

    const module = try cu.Module.loadData(kernel_ptx.ptr);
    defer module.unload();

    const function = try module.getFunction("vector_add");

    const n: u32 = 1024;

    const h_A = try std.heap.page_allocator.alloc(f32, n);
    const h_B = try std.heap.page_allocator.alloc(f32, n);
    const h_C = try std.heap.page_allocator.alloc(f32, n);
    defer std.heap.page_allocator.free(h_A);
    defer std.heap.page_allocator.free(h_B);
    defer std.heap.page_allocator.free(h_C);

    for (0..n) |i| {
        h_A[i] = @floatFromInt(i);
        h_B[i] = @floatFromInt(i * 2);
    }

    const d_A = try cu.malloc(f32, n);
    const d_B = try cu.malloc(f32, n);
    const d_C = try cu.malloc(f32, n);
    defer cu.free(d_A);
    defer cu.free(d_B);
    defer cu.free(d_C);

    try cu.memcpy(f32, d_A, h_A, .host_to_device);
    try cu.memcpy(f32, d_B, h_B, .host_to_device);

    try function.launch(.{
        .grid_dim = .{ .x = (n + 255) / 256 },
        .block_dim = .{ .x = 256 },
    }, .{ d_A.ptr, d_B.ptr, d_C.ptr, n });

    try cu.memcpy(f32, h_C, d_C, .device_to_host);

    // Verify
    for (0..n) |i| {
        const expected = h_A[i] + h_B[i];
        if (@abs(h_C[i] - expected) > 1e-5) {
            std.debug.print("Verification failed at index {}: got {}, expected {}\n", .{ i, h_C[i], expected });
            return error.VerificationFailed;
        }
    }

    std.debug.print("Success! Vector addition completed and verified on GPU.\n", .{});
}
