const std = @import("std");
const ptx = @import("ptx_zig");

pub fn main() !void {
    // The "Auto-Scan" style: Each public function in the struct is a kernel.
    const kernel_ptx = comptime ptx.build(.{
        .version = .v9_3,
        .target = .sm_90,
        .address_size = 64,
    }, struct {
        pub fn hello_ptx(k: *ptx.KernelBuilder) void {
            k.params(.{
                ".u64 out",
                ".u32 n",
            });

            const tid = k.movSpecial(.u32, ptx.sreg.tid.x);
            const n = k.ldParam(.u32, "n");

            const p0 = k.setp(.ge, .u32, tid, n);
            k.retIf(p0);

            _ = k.ldParam(.u64, "out");
            k.ret();
        }
    });

    std.debug.print("{s}", .{kernel_ptx});
}
