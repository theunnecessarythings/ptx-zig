const std = @import("std");
const cuda = @import("cuda.zig");
const ptx = @import("ptx_zig");

const kernel_name =
    "dense_gemm";
const kernel_ptx = ptx.build(.{
    .version = .v9_1,
    .target = .sm_100a,
    .address_size = 64,
    .entry_visibility = .visible,
}, struct {
    pub fn emit(module: *ptx.Module) void {
        const shmem = module.externShared("__dynamic_shmem__0", 1024);
        const kernel = module.entry(kernel_name, .{});
        kernel.reqntid(128, 1, 1);
        const flags = kernel.paramBytes(kernel_name ++ "_param_0", 3, 1);
        const tma_a = kernel.paramBytes(kernel_name ++ "_param_1", 128, 64);
        const shape_a = kernel.paramBytes(kernel_name ++ "_param_2", 12, 4);
        const tma_b = kernel.paramBytes(kernel_name ++ "_param_3", 128, 64);
        _ = kernel.paramBytes(kernel_name ++ "_param_4", 12, 4);
        const output = kernel.paramBytes(kernel_name ++ "_param_5", 40, 8);

        // Keep the reference register file while typed sections are migrated
        // incrementally. Later raw sections still address these fixed names.
        kernel.instructionBlock(
            "\t.reg .pred \t%p<78>;\n" ++
                "\t.reg .b16 \t%rs<135>;\n" ++
                "\t.reg .b32 \t%r<352>;\n" ++
                "\t.reg .b64 \t%rd<36>;\n\n",
        );

        const rs1 = ptx.Reg(.b16){ .data = .{ .name = "rs1" } };
        const rs2 = ptx.Reg(.b16){ .data = .{ .name = "rs2" } };
        const rs3 = ptx.Reg(.b16){ .data = .{ .name = "rs3" } };
        const rs4 = ptx.Reg(.b16){ .data = .{ .name = "rs4" } };
        const rs5 = ptx.Reg(.b16){ .data = .{ .name = "rs5" } };
        const rs6 = ptx.Reg(.b16){ .data = .{ .name = "rs6" } };
        const p19 = ptx.Reg(.pred){ .data = .{ .name = "p19" } };
        const p20 = ptx.Reg(.pred){ .data = .{ .name = "p20" } };
        const p21 = ptx.Reg(.pred){ .data = .{ .name = "p21" } };
        const p73 = ptx.Reg(.pred){ .data = .{ .name = "p73" } };
        const r1 = ptx.Reg(.b32){ .data = .{ .name = "r1" } };
        const r2 = ptx.Reg(.b32){ .data = .{ .name = "r2" } };
        const r3 = ptx.Reg(.b32){ .data = .{ .name = "r3" } };
        const r4 = ptx.Reg(.b32){ .data = .{ .name = "r4" } };
        const r73 = ptx.Reg(.b32){ .data = .{ .name = "r73" } };
        const rd1 = ptx.Reg(.b64){ .data = .{ .name = "rd1" } };
        const rd2 = ptx.Reg(.b64){ .data = .{ .name = "rd2" } };
        const rd4 = ptx.Reg(.b64){ .data = .{ .name = "rd4" } };
        const rd5 = ptx.Reg(.b64){ .data = .{ .name = "rd5" } };
        const rd6 = ptx.Reg(.b64){ .data = .{ .name = "rd6" } };
        const rd9 = ptx.Reg(.b64){ .data = .{ .name = "rd9" } };
        const rd10 = ptx.Reg(.b64){ .data = .{ .name = "rd10" } };

        kernel.ld_ex(.param).ty(.b8).callInto(rs1, flags.at(2));
        kernel.andInto(.b16, rs2, rs1, 1);
        kernel.setpInto(.ne, .b16, p20, rs2, 0);
        kernel.ld_ex(.param).ty(.b8).callInto(rs3, flags.at(1));
        kernel.andInto(.b16, rs4, rs3, 1);
        kernel.setpInto(.ne, .b16, p19, rs4, 0);
        kernel.ld_ex(.param).ty(.b8).callInto(rs5, flags.at(0));
        kernel.andInto(.b16, rs6, rs5, 1);
        kernel.setpInto(.ne, .b16, p73, rs6, 0);
        kernel.movInto(.b64, rd9, tma_a);
        kernel.ld_ex(.param).ty(.b32).callInto(r73, shape_a.at(4));
        kernel.movInto(.b64, rd10, tma_b);
        kernel.ld_ex(.param).ty(.b64).callInto(rd6, output.at(32));
        kernel.ld_ex(.param).ty(.b64).callInto(rd5, output.at(24));
        kernel.ld_ex(.param).ty(.b64).callInto(rd4, output.at(0));
        kernel.cvta().from().space(.param).ty(.u64).callInto(rd1, rd9);
        kernel.prefetch().tensormap().call(rd1);
        kernel.cvta().from().space(.param).ty(.u64).callInto(rd2, rd10);
        kernel.prefetch().tensormap().call(rd2);
        kernel.movInto(.u32, r1, ptx.sreg.tid.x);

        const r78 = ptx.Reg(.b32){ .data = .{ .name = "r78" } };
        const r79 = ptx.Reg(.b32){ .data = .{ .name = "r79" } };
        const r80 = ptx.Reg(.b32){ .data = .{ .name = "r80" } };
        const r81 = ptx.Reg(.b32){ .data = .{ .name = "r81" } };
        const r82 = ptx.Reg(.b32){ .data = .{ .name = "r82" } };
        const r83 = ptx.Reg(.b32){ .data = .{ .name = "r83" } };
        const r84 = ptx.Reg(.b32){ .data = .{ .name = "r84" } };
        kernel.movInto(.u32, r78, ptx.sreg.tid.y);
        kernel.movInto(.u32, r79, ptx.sreg.tid.z);
        kernel.movInto(.u32, r80, ptx.sreg.ntid.x);
        kernel.movInto(.u32, r81, ptx.sreg.ntid.y);
        kernel.mad().ty(.s32).callInto(r82, .{ r81, r79, r78 });
        kernel.mad().ty(.s32).callInto(r83, .{ r82, r80, r1 });
        kernel.shr().ty(.u32).callInto(r84, .{ r83, 5 });
        kernel.shfl(.idx).ty(.b32).callInto(r2, .{ r84, 0, 31, -1 });
        kernel.setpInto(.ne, .s32, p21, r2, 0);
        kernel.movInto(.u32, r3, ptx.sreg.ctaid.x);
        kernel.movInto(.u32, r4, ptx.sreg.ctaid.z);

        const p22 = ptx.Reg(.pred){ .data = .{ .name = "p22" } };
        const p23 = ptx.Reg(.pred){ .data = .{ .name = "p23" } };
        const p24 = ptx.Reg(.pred){ .data = .{ .name = "p24" } };
        const p25 = ptx.Reg(.pred){ .data = .{ .name = "p25" } };
        const p26 = ptx.Reg(.pred){ .data = .{ .name = "p26" } };
        const r5 = ptx.Reg(.b32){ .data = .{ .name = "r5" } };
        const r6 = ptx.Reg(.b32){ .data = .{ .name = "r6" } };
        const r7 = ptx.Reg(.b32){ .data = .{ .name = "r7" } };
        const r8 = ptx.Reg(.b32){ .data = .{ .name = "r8" } };
        const r9 = ptx.Reg(.b32){ .data = .{ .name = "r9" } };
        const r10 = ptx.Reg(.b32){ .data = .{ .name = "r10" } };
        const r85 = ptx.Reg(.b32){ .data = .{ .name = "r85" } };
        const r86 = ptx.Reg(.b32){ .data = .{ .name = "r86" } };
        const r87 = ptx.Reg(.b32){ .data = .{ .name = "r87" } };
        const r88 = ptx.Reg(.b32){ .data = .{ .name = "r88" } };
        const r89 = ptx.Reg(.b32){ .data = .{ .name = "r89" } };
        const r90 = ptx.Reg(.b32){ .data = .{ .name = "r90" } };
        const r91 = ptx.Reg(.b32){ .data = .{ .name = "r91" } };
        const r92 = ptx.Reg(.b32){ .data = .{ .name = "r92" } };
        const r93 = ptx.Reg(.b32){ .data = .{ .name = "r93" } };
        const r94 = ptx.Reg(.b32){ .data = .{ .name = "r94" } };
        const r95 = ptx.Reg(.b32){ .data = .{ .name = "r95" } };
        const r98 = ptx.Reg(.b32){ .data = .{ .name = "r98" } };

        kernel.braIf(p21, false, "$L__BB0_2");
        kernel.movInto(.b32, r85, 1);
        inline for (0..15) |i| {
            kernel.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(i * 8)), r85 });
        }
        kernel.movInto(.b32, r86, 128);
        kernel.mbarrier(.init).space(.shared).call(.{ ptx.addr(shmem.at(120)), r86 });
        kernel.label("$L__BB0_2");
        kernel.setpInto(.ne, .s32, p22, r2, 0);
        kernel.fence().op(.mbarrier_init).order(.release).scope(.cluster).call();
        kernel.movInto(.b32, r87, shmem);
        kernel.addInto(.s32, r88, r87, 271);
        kernel.andInto(.b32, r5, r88, -768);
        kernel.shr().ty(.s32).callInto(r89, .{ r73, 31 });
        kernel.shr().ty(.u32).callInto(r90, .{ r89, 26 });
        kernel.addInto(.s32, r91, r73, r90);
        kernel.shr().ty(.s32).callInto(r92, .{ r91, 6 });
        kernel.andInto(.b32, r93, r91, -64);
        kernel.setpInto(.ne, .s32, p23, r73, r93);
        kernel.setpInto(.gt, .s32, p24, r73, -1);
        kernel.andInto(.pred, p25, p24, p23);
        kernel.selpInto(.b32, r94, 1, 0, p25);
        kernel.addInto(.s32, r6, r92, r94);
        kernel.bar_sync(0);
        kernel.braIf(p22, false, "$L__BB0_4");
        kernel.movInto(.b32, r95, 128);
        kernel.tcgen05(.alloc).call(.{ ptx.addr(shmem.at(136)), r95 });
        kernel.label("$L__BB0_4");
        kernel.setpInto(.ne, .s32, p26, r2, 0);
        kernel.barSyncCount(0, 128);
        kernel.ld_ex(.shared).ty(.b32).callInto(
            r7,
            ptx.Shared(.b32){ .name = shmem.name, .offset = 136 },
        );
        kernel.shl().ty(.b32).callInto(r8, .{ r3, 7 });
        kernel.movInto(.u32, r98, ptx.sreg.ctaid.y);
        kernel.shl().ty(.b32).callInto(r9, .{ r98, 7 });
        kernel.minInto(.s32, r10, r6, 5);
    }
});

const m: usize = 128;
const n: usize = 128;
const k_dim: usize = 64;
const output_len = m * n;
const dynamic_shared_bytes = 230400;

fn halfBits(value: f32) u16 {
    return @bitCast(@as(f16, @floatCast(value)));
}

fn halfValue(bits: u16) f32 {
    return @floatCast(@as(f16, @bitCast(bits)));
}

fn fillInputs(a: []u16, b: []u16) void {
    for (0..m) |row| {
        for (0..k_dim) |col| {
            const value: f32 = @floatFromInt(@as(i32, @intCast((row * 3 + col * 5) % 11)) - 5);
            a[row * k_dim + col] = halfBits(value / 4.0);
        }
    }
    for (0..n) |row| {
        for (0..k_dim) |col| {
            const value: f32 = @floatFromInt(@as(i32, @intCast((row * 7 + col * 2) % 13)) - 6);
            b[row * k_dim + col] = halfBits(value / 4.0);
        }
    }
}

fn cpuReference(a: []const u16, b: []const u16, expected: []u16) void {
    for (0..m) |row| {
        for (0..n) |col| {
            var sum: f32 = 0;
            for (0..k_dim) |kk| {
                sum += halfValue(a[row * k_dim + kk]) * halfValue(b[col * k_dim + kk]);
            }
            expected[row * n + col] = halfBits(sum);
        }
    }
}

fn compare(got: []const u16, expected: []const u16) usize {
    var mismatches: usize = 0;
    var max_error: f32 = 0;
    for (got, expected, 0..) |actual_bits, expected_bits, i| {
        const actual = halfValue(actual_bits);
        const wanted = halfValue(expected_bits);
        const error_value = @abs(actual - wanted);
        max_error = @max(max_error, error_value);
        if (error_value > 0.01) {
            if (mismatches < 8) {
                std.debug.print(
                    "Mismatch [{d}, {d}]: GPU={d:.5}, CPU={d:.5}\n",
                    .{ i / n, i % n, actual, wanted },
                );
            }
            mismatches += 1;
        }
    }
    std.debug.print("Maximum absolute error: {d:.6}\n", .{max_error});
    return mismatches;
}

fn encodeTensorMap(map: *cuda.c.CUtensorMap, device_ptr: usize, rows: usize) !void {
    const global_dims = [_]u64{ k_dim, rows, 1 };
    const global_strides = [_]u64{ k_dim * @sizeOf(u16), rows * k_dim * @sizeOf(u16) };
    const box_dims = [_]u32{ 64, 128, 1 };
    const element_strides = [_]u32{ 1, 1, 1 };
    try cuda.check(cuda.cuTensorMapEncodeTiled(
        map,
        cuda.c.CU_TENSOR_MAP_DATA_TYPE_FLOAT16,
        3,
        @ptrFromInt(device_ptr),
        &global_dims,
        &global_strides,
        &box_dims,
        &element_strides,
        cuda.c.CU_TENSOR_MAP_INTERLEAVE_NONE,
        cuda.c.CU_TENSOR_MAP_SWIZZLE_128B,
        cuda.c.CU_TENSOR_MAP_L2_PROMOTION_NONE,
        cuda.c.CU_TENSOR_MAP_FLOAT_OOB_FILL_NONE,
    ));
}

pub fn main() !void {
    try cuda.init();
    defer cuda.deinit();

    var module: cuda.c.CUmodule = undefined;
    var info_log = [_]u8{0} ** 8192;
    var error_log = [_]u8{0} ** 8192;
    var jit_options = [_]c_uint{
        cuda.c.CU_JIT_INFO_LOG_BUFFER,
        cuda.c.CU_JIT_INFO_LOG_BUFFER_SIZE_BYTES,
        cuda.c.CU_JIT_ERROR_LOG_BUFFER,
        cuda.c.CU_JIT_ERROR_LOG_BUFFER_SIZE_BYTES,
        cuda.c.CU_JIT_LOG_VERBOSE,
    };
    var jit_values = [_]*anyopaque{
        @ptrCast(&info_log[0]),
        @ptrFromInt(info_log.len),
        @ptrCast(&error_log[0]),
        @ptrFromInt(error_log.len),
        @ptrFromInt(1),
    };
    const load_result = cuda.cuModuleLoadDataEx(
        &module,
        kernel_ptx.ptr,
        jit_options.len,
        jit_options[0..].ptr,
        jit_values[0..].ptr,
    );
    if (error_log[0] != 0) std.debug.print("CUDA JIT error:\n{s}\n", .{std.mem.sliceTo(&error_log, 0)});
    try cuda.check(load_result);
    defer _ = cuda.cuModuleUnload(module);

    var function: cuda.c.CUfunction = undefined;
    try cuda.check(cuda.cuModuleGetFunction(&function, module, kernel_name));
    try cuda.check(cuda.cuFuncSetAttribute(
        function,
        cuda.c.CU_FUNC_ATTRIBUTE_MAX_DYNAMIC_SHARED_SIZE_BYTES,
        dynamic_shared_bytes,
    ));

    const allocator = std.heap.page_allocator;
    const host_a = try allocator.alloc(u16, m * k_dim);
    defer allocator.free(host_a);
    const host_b = try allocator.alloc(u16, n * k_dim);
    defer allocator.free(host_b);
    const host_c = try allocator.alloc(u16, output_len);
    defer allocator.free(host_c);
    const expected = try allocator.alloc(u16, output_len);
    defer allocator.free(expected);
    fillInputs(host_a, host_b);
    cpuReference(host_a, host_b, expected);

    var device_a: usize = 0;
    var device_b: usize = 0;
    var device_c: usize = 0;
    try cuda.check(cuda.cuMemAlloc(&device_a, host_a.len * @sizeOf(u16)));
    defer _ = cuda.cuMemFree(device_a);
    try cuda.check(cuda.cuMemAlloc(&device_b, host_b.len * @sizeOf(u16)));
    defer _ = cuda.cuMemFree(device_b);
    try cuda.check(cuda.cuMemAlloc(&device_c, host_c.len * @sizeOf(u16)));
    defer _ = cuda.cuMemFree(device_c);
    try cuda.check(cuda.cuMemcpyHtoD(device_a, host_a.ptr, host_a.len * @sizeOf(u16)));
    try cuda.check(cuda.cuMemcpyHtoD(device_b, host_b.ptr, host_b.len * @sizeOf(u16)));

    var tma_a: cuda.c.CUtensorMap align(64) = undefined;
    var tma_b: cuda.c.CUtensorMap align(64) = undefined;
    try encodeTensorMap(&tma_a, device_a, m);
    try encodeTensorMap(&tma_b, device_b, n);

    var shape_a: [3]u32 = .{ m, k_dim, 1 };
    var shape_b: [3]u32 = .{ n, k_dim, 1 };
    var out_desc: [5]u64 = .{ device_c, 0, 0, n, m * n };

    var found_match = false;
    for (0..4) |layout_flags| {
        @memset(host_c, halfBits(std.math.nan(f32)));
        try cuda.check(cuda.cuMemcpyHtoD(device_c, host_c.ptr, host_c.len * @sizeOf(u16)));
        var flags: [3]u8 = .{
            0,
            @intCast(layout_flags & 1),
            @intCast((layout_flags >> 1) & 1),
        };
        var args = [_]?*anyopaque{
            &flags,
            &tma_a,
            &shape_a,
            &tma_b,
            &shape_b,
            &out_desc,
        };
        std.debug.print("Testing layout flags A={d}, B={d}\n", .{ flags[1], flags[2] });
        try cuda.check(cuda.cuLaunchKernel(function, 1, 1, 1, 128, 1, 1, dynamic_shared_bytes, null, &args, null));
        const sync_result = cuda.cuCtxSynchronize();
        if (sync_result != cuda.c.CUDA_SUCCESS) {
            cuda.check(sync_result) catch {};
            continue;
        }
        try cuda.check(cuda.cuMemcpyDtoH(host_c.ptr, device_c, host_c.len * @sizeOf(u16)));
        const mismatches = compare(host_c, expected);
        std.debug.print("Mismatches: {d}/{d}\n", .{ mismatches, output_len });
        if (mismatches == 0) {
            found_match = true;
            std.debug.print("CORRECTNESS PASS with flags A={d}, B={d}\n", .{ flags[1], flags[2] });
            break;
        }
    }
    if (!found_match) return error.CorrectnessMismatch;
}
