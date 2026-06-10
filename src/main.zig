const std = @import("std");
const ptx = @import("ptx_zig");

pub fn main() !void {
    // The "Auto-Scan" style: Each public function in the struct is a kernel.
    const kernel_ptx = comptime ptx.build(.{
        .version = .v9_3,
        .target = .sm_90,
        .address_size = 64,
    }, struct {
        pub fn test_enums(k: *ptx.KernelBuilder) void {
            const ps = k.params(.{
                .ptr = .u64,
            });
            const p = k.ldParam(ps.ptr);

            // Test cvta
            const p_global = k.cvta(.to, .global, .u64, p);

            // Test barrier
            k.barrier(.arrive);

            // Test prefetch
            k.prefetch(.L1, p_global);

            k.ret();
        }
        pub fn hello_ptx(k: *ptx.KernelBuilder) void {
            const ps = k.params(.{
                .out = .u64,
                .n = .u32,
            });

            const tid = k.movSpecial(.u32, ptx.sreg.tid.x);
            const n = k.ldParam(ps.n);

            const p0 = k.setp(.ge, .u32, tid, n);
            k.retIf(p0);

            _ = k.ldParam(ps.out);
            k.ret();
        }
    });

    std.debug.print("{s}", .{kernel_ptx});
}
