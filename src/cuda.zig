const std = @import("std");
pub const c = struct {
    pub const CUDA_SUCCESS = 0;
    pub const CUDA_ERROR_INVALID_VALUE = 1;
    pub const CUDA_ERROR_OUT_OF_MEMORY = 2;
    pub const CUDA_ERROR_NOT_INITIALIZED = 3;
    pub const CUDA_ERROR_DEINITIALIZED = 4;
    pub const CUDA_ERROR_PROFILER_DISABLED = 5;
    pub const CUDA_ERROR_PROFILER_NOT_INITIALIZED = 6;
    pub const CUDA_ERROR_PROFILER_ALREADY_STARTED = 7;
    pub const CUDA_ERROR_PROFILER_ALREADY_STOPPED = 8;
    pub const CUDA_ERROR_NO_DEVICE = 100;
    pub const CUDA_ERROR_INVALID_DEVICE = 101;
    pub const CUDA_ERROR_INVALID_IMAGE = 200;
    pub const CUDA_ERROR_INVALID_CONTEXT = 201;
    pub const CUDA_ERROR_CONTEXT_ALREADY_CURRENT = 202;
    pub const CUDA_ERROR_MAP_FAILED = 205;
    pub const CUDA_ERROR_UNMAP_FAILED = 206;
    pub const CUDA_ERROR_ARRAY_IS_MAPPED = 207;
    pub const CUDA_ERROR_ALREADY_MAPPED = 208;
    pub const CUDA_ERROR_NO_BINARY_FOR_GPU = 209;
    pub const CUDA_ERROR_ALREADY_ACQUIRED = 210;
    pub const CUDA_ERROR_NOT_MAPPED = 211;
    pub const CUDA_ERROR_NOT_MAPPED_AS_ARRAY = 212;
    pub const CUDA_ERROR_NOT_MAPPED_AS_POINTER = 213;
    pub const CUDA_ERROR_ECC_UNCORRECTABLE = 214;
    pub const CUDA_ERROR_UNSUPPORTED_LIMIT = 215;
    pub const CUDA_ERROR_CONTEXT_ALREADY_IN_USE = 216;
    pub const CUDA_ERROR_PEER_ACCESS_UNSUPPORTED = 217;
    pub const CUDA_ERROR_INVALID_PTX = 218;
    pub const CUDA_ERROR_INVALID_GRAPHICS_CONTEXT = 219;
    pub const CUDA_ERROR_NVLINK_UNCORRECTABLE = 220;
    pub const CUDA_ERROR_JIT_COMPILER_NOT_FOUND = 221;
    pub const CUDA_ERROR_INVALID_SOURCE = 300;
    pub const CUDA_ERROR_FILE_NOT_FOUND = 301;
    pub const CUDA_ERROR_SHARED_OBJECT_SYMBOL_NOT_FOUND = 302;
    pub const CUDA_ERROR_SHARED_OBJECT_INIT_FAILED = 303;
    pub const CUDA_ERROR_OPERATING_SYSTEM = 304;
    pub const CUDA_ERROR_INVALID_HANDLE = 400;
    pub const CUDA_ERROR_NOT_FOUND = 500;
    pub const CUDA_ERROR_NOT_READY = 600;
    pub const CUDA_ERROR_ILLEGAL_ADDRESS = 700;
    pub const CUDA_ERROR_LAUNCH_OUT_OF_RESOURCES = 701;
    pub const CUDA_ERROR_LAUNCH_TIMEOUT = 702;
    pub const CUDA_ERROR_LAUNCH_INCOMPATIBLE_TEXTURING = 703;
    pub const CUDA_ERROR_PEER_ACCESS_ALREADY_ENABLED = 704;
    pub const CUDA_ERROR_PEER_ACCESS_NOT_ENABLED = 705;
    pub const CUDA_ERROR_PRIMARY_CONTEXT_ACTIVE = 708;
    pub const CUDA_ERROR_CONTEXT_IS_DESTROYED = 709;
    pub const CUDA_ERROR_ASSERT = 710;
    pub const CUDA_ERROR_TOO_MANY_PEERS = 711;
    pub const CUDA_ERROR_HOST_MEMORY_ALREADY_REGISTERED = 712;
    pub const CUDA_ERROR_HOST_MEMORY_NOT_REGISTERED = 713;
    pub const CUDA_ERROR_HARDWARE_STACK_ERROR = 714;
    pub const CUDA_ERROR_ILLEGAL_INSTRUCTION = 715;
    pub const CUDA_ERROR_MISALIGNED_ADDRESS = 716;
    pub const CUDA_ERROR_INVALID_ADDRESS_SPACE = 717;
    pub const CUDA_ERROR_INVALID_PC = 718;
    pub const CUDA_ERROR_LAUNCH_FAILED = 719;
    pub const CUDA_ERROR_UNKNOWN = 999;

    pub const CUresult = c_uint;
    pub const CUmodule = *opaque {};
    pub const CUfunction = *opaque {};
    pub const CUstream = *opaque {};
    pub const CUevent = *opaque {};
    pub const CUdevice = c_int;
    pub const CUcontext = *opaque {};

    pub const CUdevice_attribute = c_uint;
    pub const CU_DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK = 1;
    pub const CU_DEVICE_ATTRIBUTE_MAX_BLOCK_DIM_X = 2;
    pub const CU_DEVICE_ATTRIBUTE_MAX_BLOCK_DIM_Y = 3;
    pub const CU_DEVICE_ATTRIBUTE_MAX_BLOCK_DIM_Z = 4;
    pub const CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_X = 5;
    pub const CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_Y = 6;
    pub const CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_Z = 7;
    pub const CU_DEVICE_ATTRIBUTE_MAX_SHARED_MEMORY_PER_BLOCK = 8;
    pub const CU_DEVICE_ATTRIBUTE_WARP_SIZE = 10;
    pub const CU_DEVICE_ATTRIBUTE_MULTIPROCESSOR_COUNT = 16;
    pub const CU_DEVICE_ATTRIBUTE_MAX_REGISTERS_PER_BLOCK = 12;
    pub const CU_DEVICE_ATTRIBUTE_MAX_THREADS_PER_MULTIPROCESSOR = 39;
    pub const CU_DEVICE_ATTRIBUTE_MAX_REGISTERS_PER_MULTIPROCESSOR = 82;

    pub const CUfunction_attribute = c_uint;
    pub const CU_FUNC_ATTRIBUTE_MAX_THREADS_PER_BLOCK = 0;
    pub const CU_FUNC_ATTRIBUTE_SHARED_SIZE_BYTES = 1;
    pub const CU_FUNC_ATTRIBUTE_CONST_SIZE_BYTES = 2;
    pub const CU_FUNC_ATTRIBUTE_LOCAL_SIZE_BYTES = 3;
    pub const CU_FUNC_ATTRIBUTE_NUM_REGS = 4;
    pub const CU_FUNC_ATTRIBUTE_PTX_VERSION = 5;
    pub const CU_FUNC_ATTRIBUTE_BINARY_VERSION = 6;
    pub const CU_FUNC_ATTRIBUTE_CACHE_MODE_CA = 7;
    pub const CU_FUNC_ATTRIBUTE_MAX_DYNAMIC_SHARED_SIZE_BYTES = 8;
    pub const CU_JIT_INFO_LOG_BUFFER = 3;
    pub const CU_JIT_INFO_LOG_BUFFER_SIZE_BYTES = 4;
    pub const CU_JIT_ERROR_LOG_BUFFER = 5;
    pub const CU_JIT_ERROR_LOG_BUFFER_SIZE_BYTES = 6;
    pub const CU_JIT_LOG_VERBOSE = 12;

    pub const CUtensorMap = extern struct {
        data: [16]u64,
    };
    pub const CUtensorMapDataType = c_uint;
    pub const CU_TENSOR_MAP_DATA_TYPE_FLOAT16 = 6;
    pub const CUtensorMapInterleave = c_uint;
    pub const CU_TENSOR_MAP_INTERLEAVE_NONE = 0;
    pub const CUtensorMapSwizzle = c_uint;
    pub const CU_TENSOR_MAP_SWIZZLE_128B = 3;
    pub const CUtensorMapL2promotion = c_uint;
    pub const CU_TENSOR_MAP_L2_PROMOTION_NONE = 0;
    pub const CUtensorMapFloatOOBfill = c_uint;
    pub const CU_TENSOR_MAP_FLOAT_OOB_FILL_NONE = 0;
};

pub extern "c" fn cuGetErrorName(err: c.CUresult, msg: *[*:0]const u8) c.CUresult;
pub extern "c" fn cuInit(flags: c_uint) c.CUresult;
pub extern "c" fn cuDeviceGetCount(count: *c_int) c.CUresult;
pub extern "c" fn cuDeviceGet(device: *c.CUdevice, ordinal: c_int) c.CUresult;
pub extern "c" fn cuDeviceGetAttribute(pi: *c_int, attrib: c.CUdevice_attribute, dev: c.CUdevice) c.CUresult;
pub extern "c" fn cuCtxCreate(context: *c.CUcontext, flags: c_uint, device: c.CUdevice) c.CUresult;
pub extern "c" fn cuCtxDestroy(context: c.CUcontext) c.CUresult;
pub extern "c" fn cuCtxSynchronize() c.CUresult;
pub extern "c" fn cuStreamCreate(stream: *c.CUstream, flags: c_uint) c.CUresult;
pub extern "c" fn cuStreamDestroy(stream: c.CUstream) c.CUresult;
pub extern "c" fn cuStreamSynchronize(stream: c.CUstream) c.CUresult;
pub extern "c" fn cuMemAlloc(ptr: *usize, size: usize) c.CUresult;
pub extern "c" fn cuMemFree(ptr: usize) c.CUresult;
pub extern "c" fn cuMemcpyHtoD(dst_dev: usize, src_host: *const anyopaque, size: usize) c.CUresult;
pub extern "c" fn cuMemcpyDtoH(dst_host: *anyopaque, src_dev: usize, size: usize) c.CUresult;
pub extern "c" fn cuEventCreate(event: *c.CUevent, flags: c_uint) c.CUresult;
pub extern "c" fn cuEventDestroy(event: c.CUevent) c.CUresult;
pub extern "c" fn cuEventRecord(event: c.CUevent, stream: ?c.CUstream) c.CUresult;
pub extern "c" fn cuEventSynchronize(event: c.CUevent) c.CUresult;
pub extern "c" fn cuEventElapsedTime(result: *f32, a: c.CUevent, b: c.CUevent) c.CUresult;
pub extern "c" fn cuModuleLoadDataEx(
    module: *c.CUmodule,
    image: *const anyopaque,
    numOptions: c_uint,
    options: ?[*]c_uint,
    optionValues: ?[*]*anyopaque,
) c.CUresult;

pub extern "c" fn cuModuleLoadData(module: *c.CUmodule, image: *const anyopaque) c.CUresult;
pub extern "c" fn cuModuleUnload(module: c.CUmodule) c.CUresult;
pub extern "c" fn cuModuleGetFunction(function: *c.CUfunction, module: c.CUmodule, name: [*:0]const u8) c.CUresult;
pub extern "c" fn cuFuncGetAttribute(pi: *c_int, attrib: c.CUfunction_attribute, hfunc: c.CUfunction) c.CUresult;
pub extern "c" fn cuFuncSetAttribute(hfunc: c.CUfunction, attrib: c.CUfunction_attribute, value: c_int) c.CUresult;
pub extern "c" fn cuTensorMapEncodeTiled(
    tensor_map: *c.CUtensorMap,
    tensor_data_type: c.CUtensorMapDataType,
    tensor_rank: c_uint,
    global_address: *anyopaque,
    global_dim: [*]const u64,
    global_strides: [*]const u64,
    box_dim: [*]const u32,
    element_strides: [*]const u32,
    interleave: c.CUtensorMapInterleave,
    swizzle: c.CUtensorMapSwizzle,
    l2_promotion: c.CUtensorMapL2promotion,
    oob_fill: c.CUtensorMapFloatOOBfill,
) c.CUresult;
pub extern "c" fn cuLaunchKernel(
    function: c.CUfunction,
    gdx: c_uint,
    gdy: c_uint,
    gdz: c_uint,
    bdx: c_uint,
    bdy: c_uint,
    bdz: c_uint,
    shmem: c_uint,
    stream: ?c.CUstream,
    params: ?[*]?*anyopaque,
    extra: ?[*]?*anyopaque,
) c.CUresult;

/// High-level Zig error set mapped to CUDA driver API errors.
pub const CudaError = error{
    OutOfMemory,
    Overflow,
    SharedObjectInitFailed,
    NotFound,
    InvalidValue,
    InvalidContext,
    InvalidDevice,
    InvalidImage,
    ContextIsDestroyed,
    LaunchFailed,
    LaunchOutOfResources,
    LaunchTimeout,
    IllegalAddress,
    NoDevice,
    NotInitialized,
    UnknownError,
};

var current_context: ?c.CUcontext = null;

/// Validates a CUDA result code and maps it to a standard Zig CudaError.
pub fn check(err: c.CUresult) CudaError!void {
    if (err == c.CUDA_SUCCESS) return;
    var msg: [*:0]const u8 = "Unknown error";
    _ = cuGetErrorName(err, &msg);
    std.log.err("CUDA error: {s} ({})", .{ msg, err });
    return switch (err) {
        c.CUDA_ERROR_OUT_OF_MEMORY => error.OutOfMemory,
        c.CUDA_ERROR_SHARED_OBJECT_INIT_FAILED => error.SharedObjectInitFailed,
        c.CUDA_ERROR_NOT_FOUND => error.NotFound,
        c.CUDA_ERROR_INVALID_VALUE => error.InvalidValue,
        c.CUDA_ERROR_INVALID_CONTEXT => error.InvalidContext,
        c.CUDA_ERROR_INVALID_DEVICE => error.InvalidDevice,
        c.CUDA_ERROR_INVALID_IMAGE => error.InvalidImage,
        c.CUDA_ERROR_CONTEXT_IS_DESTROYED => error.ContextIsDestroyed,
        c.CUDA_ERROR_LAUNCH_FAILED => error.LaunchFailed,
        c.CUDA_ERROR_LAUNCH_OUT_OF_RESOURCES => error.LaunchOutOfResources,
        c.CUDA_ERROR_LAUNCH_TIMEOUT => error.LaunchTimeout,
        c.CUDA_ERROR_ILLEGAL_ADDRESS => error.IllegalAddress,
        c.CUDA_ERROR_NO_DEVICE => error.NoDevice,
        c.CUDA_ERROR_NOT_INITIALIZED => error.NotInitialized,
        else => error.UnknownError,
    };
}

/// Initializes the CUDA driver API. Must be called before any other CUDA functions.
pub fn init() !void {
    if (current_context != null) return;
    const res = cuInit(0);
    try check(res);

    var count: c_int = 0;
    try check(cuDeviceGetCount(&count));
    std.debug.print("Found {} CUDA devices\n", .{count});
    if (count <= 0) return error.NoDevice;

    var device: c.CUdevice = 0;
    try check(cuDeviceGet(&device, 0));
    std.debug.print("Using device 0: {}\n", .{device});

    var context: c.CUcontext = undefined;
    try check(cuCtxCreate(&context, 0, device));
    current_context = context;
    std.debug.print("Created CUDA context\n", .{});
}

/// Destroys the context created by `init`.
pub fn deinit() void {
    if (current_context) |context| {
        check(cuCtxDestroy(context)) catch |err| {
            std.log.warn("Failed to destroy CUDA context: {}", .{err});
        };
        current_context = null;
    }
}

/// Synchronizes the current context.
pub fn synchronize() !void {
    try check(cuCtxSynchronize());
}

/// Retrieves the currently initialized device. (Assuming ordinal 0 for this demo)
pub fn getDevice() !c.CUdevice {
    var device: c.CUdevice = undefined;
    try check(cuDeviceGet(&device, 0));
    return device;
}

/// Retrieves an attribute of the given device.
pub fn deviceGetAttribute(attr: c.CUdevice_attribute, dev: c.CUdevice) !i32 {
    var val: c_int = 0;
    try check(cuDeviceGetAttribute(&val, attr, dev));
    return val;
}

/// Calculates theoretical occupancy and block dimensions based on device limits.
pub const OccupancyCalculator = struct {
    max_threads_per_block: i32,
    max_shared_memory_per_block: i32,
    max_registers_per_sm: i32,
    max_threads_per_sm: i32,
    sm_count: i32,
    warp_size: i32,

    pub fn init(dev: c.CUdevice) !OccupancyCalculator {
        return .{
            .max_threads_per_block = try deviceGetAttribute(c.CU_DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK, dev),
            .max_shared_memory_per_block = try deviceGetAttribute(c.CU_DEVICE_ATTRIBUTE_MAX_SHARED_MEMORY_PER_BLOCK, dev),
            .max_registers_per_sm = try deviceGetAttribute(c.CU_DEVICE_ATTRIBUTE_MAX_REGISTERS_PER_MULTIPROCESSOR, dev),
            .max_threads_per_sm = try deviceGetAttribute(c.CU_DEVICE_ATTRIBUTE_MAX_THREADS_PER_MULTIPROCESSOR, dev),
            .sm_count = try deviceGetAttribute(c.CU_DEVICE_ATTRIBUTE_MULTIPROCESSOR_COUNT, dev),
            .warp_size = try deviceGetAttribute(c.CU_DEVICE_ATTRIBUTE_WARP_SIZE, dev),
        };
    }

    pub fn printInfo(self: OccupancyCalculator) void {
        std.log.info("--- Device Properties ---", .{});
        std.log.info("  SM Count: {}", .{self.sm_count});
        std.log.info("  Max Threads/SM: {}", .{self.max_threads_per_sm});
        std.log.info("  Max Threads/Block: {}", .{self.max_threads_per_block});
        std.log.info("  Max Shared Mem/Block: {} KB", .{@divTrunc(self.max_shared_memory_per_block, 1024)});
        std.log.info("  Max Registers/SM: {}", .{self.max_registers_per_sm});
        std.log.info("  Warp Size: {}", .{self.warp_size});
    }
};

/// Allocates `n` elements of type `T` on the device.
pub fn malloc(comptime T: type, n: usize) ![]T {
    const bytes = std.math.mul(usize, n, @sizeOf(T)) catch return error.Overflow;
    var result: usize = 0; // cuda driver does not write to the upper bytes, so initialize as zero!
    try check(cuMemAlloc(&result, bytes));
    return @as([*]T, @ptrFromInt(result))[0..n];
}

/// Frees memory allocated on the device.
pub fn free(ptr: anytype) void {
    const actual_ptr = switch (@typeInfo(@TypeOf(ptr)).pointer.size) {
        .slice => ptr.ptr,
        else => ptr,
    };
    check(cuMemFree(@intFromPtr(actual_ptr))) catch |err| {
        std.log.warn("Failed to free CUDA memory: {}", .{err});
    };
}

pub const CopyDir = enum {
    host_to_device,
    device_to_host,
};

/// Copies memory between host and device.
pub fn memcpy(comptime T: type, dst: []T, src: []const T, direction: CopyDir) !void {
    if (dst.len < src.len) return error.InvalidValue;
    const bytes = std.math.mul(usize, src.len, @sizeOf(T)) catch return error.Overflow;
    switch (direction) {
        .host_to_device => try check(cuMemcpyHtoD(@intFromPtr(dst.ptr), src.ptr, bytes)),
        .device_to_host => try check(cuMemcpyDtoH(dst.ptr, @intFromPtr(src.ptr), bytes)),
    }
}

/// Represents a loaded CUDA module (typically a PTX or cubin file).
pub const Module = struct {
    handle: c.CUmodule,

    /// Loads a CUDA module from a data buffer (e.g., embedded PTX).
    pub fn loadData(image: *const anyopaque) !Module {
        var module: Module = undefined;
        try check(cuModuleLoadData(&module.handle, image));
        return module;
    }

    /// Unloads a loaded CUDA module.
    pub fn unload(self: Module) void {
        check(cuModuleUnload(self.handle)) catch |err| {
            std.log.warn("Failed to unload CUDA module: {}", .{err});
        };
    }

    /// Retrieves a kernel function by name.
    pub fn getFunction(self: Module, name: [:0]const u8) !Function {
        var function: c.CUfunction = undefined;
        try check(cuModuleGetFunction(&function, self.handle, name));
        return .{ .handle = function };
    }
};

/// CUDA Stream for concurrent execution.
pub const Stream = struct {
    handle: c.CUstream,

    /// Creates a new asynchronous stream.
    pub fn create() !Stream {
        var stream: Stream = undefined;
        // CUDA_STREAM_NON_BLOCKING = 1
        try check(cuStreamCreate(&stream.handle, 1));
        return stream;
    }

    /// Destroys a stream.
    pub fn destroy(self: Stream) void {
        check(cuStreamDestroy(self.handle)) catch |err| {
            std.log.warn("Failed to destroy CUDA stream: {}", .{err});
        };
    }

    /// Blocks the host until the stream has completed all operations.
    pub fn synchronize(self: Stream) !void {
        try check(cuStreamSynchronize(self.handle));
    }
};

/// Configuration for launching a CUDA kernel.
pub const LaunchConfig = struct {
    grid_dim: Dim3 = .{},
    block_dim: Dim3 = .{},
    shared_mem_per_block: u32 = 0,
    stream: ?c.CUstream = null,
};

/// Represents 3D dimensions for thread blocks and grids.
pub const Dim3 = struct {
    x: u32 = 1,
    y: u32 = 1,
    z: u32 = 1,
};

/// Represents a CUDA kernel function.
pub const Function = struct {
    handle: c.CUfunction,

    pub const Attributes = struct {
        max_threads_per_block: i32,
        shared_size_bytes: i32,
        const_size_bytes: i32,
        local_size_bytes: i32,
        num_regs: i32,
        ptx_version: i32,
        binary_version: i32,
    };

    pub fn getAttributes(self: Function) !Attributes {
        return .{
            .max_threads_per_block = try self.getAttribute(c.CU_FUNC_ATTRIBUTE_MAX_THREADS_PER_BLOCK),
            .shared_size_bytes = try self.getAttribute(c.CU_FUNC_ATTRIBUTE_SHARED_SIZE_BYTES),
            .const_size_bytes = try self.getAttribute(c.CU_FUNC_ATTRIBUTE_CONST_SIZE_BYTES),
            .local_size_bytes = try self.getAttribute(c.CU_FUNC_ATTRIBUTE_LOCAL_SIZE_BYTES),
            .num_regs = try self.getAttribute(c.CU_FUNC_ATTRIBUTE_NUM_REGS),
            .ptx_version = try self.getAttribute(c.CU_FUNC_ATTRIBUTE_PTX_VERSION),
            .binary_version = try self.getAttribute(c.CU_FUNC_ATTRIBUTE_BINARY_VERSION),
        };
    }

    fn getAttribute(self: Function, attr: c.CUfunction_attribute) !i32 {
        var value: c_int = 0;
        try check(cuFuncGetAttribute(&value, attr, self.handle));
        return value;
    }

    /// Launches the kernel with the specified configuration and arguments.
    pub fn launch(self: Function, cfg: LaunchConfig, args: anytype) !void {
        const Args = blk: {
            comptime var fields: [args.len]type = undefined;
            inline for (&fields, 0..) |*field, i| {
                field.* = switch (@typeInfo(@TypeOf(args[i]))) {
                    .comptime_int => usize,
                    .comptime_float => f64,
                    else => @TypeOf(args[i]),
                };
            }
            break :blk std.meta.Tuple(&fields);
        };

        var kernel_args: Args = args;
        var args_buf: [args.len]?*anyopaque = undefined;
        inline for (&args_buf, 0..) |*arg_buf, i| {
            arg_buf.* = @ptrCast(&kernel_args[i]);
        }

        try check(cuLaunchKernel(
            self.handle,
            cfg.grid_dim.x,
            cfg.grid_dim.y,
            cfg.grid_dim.z,
            cfg.block_dim.x,
            cfg.block_dim.y,
            cfg.block_dim.z,
            cfg.shared_mem_per_block,
            cfg.stream,
            &args_buf,
            null,
        ));
    }
};

/// CUDA Event for timing and synchronization.
pub const Event = struct {
    handle: c.CUevent,

    /// Creates a new CUDA event.
    pub fn create() !Event {
        var event: Event = undefined;
        try check(cuEventCreate(&event.handle, 0));
        return event;
    }

    /// Destroys a CUDA event.
    pub fn destroy(self: Event) void {
        check(cuEventDestroy(self.handle)) catch |err| {
            std.log.warn("Failed to destroy CUDA event: {}", .{err});
        };
    }

    /// Records the event in the specified stream (or default stream if null).
    pub fn record(self: Event, stream: ?c.CUstream) !void {
        try check(cuEventRecord(self.handle, stream));
    }

    /// Blocks until the event has completed.
    pub fn synchronize(self: Event) !void {
        try check(cuEventSynchronize(self.handle));
    }

    /// Calculates the elapsed time in milliseconds between two events.
    pub fn elapsed(start: Event, stop: Event) !f32 {
        var result: f32 = undefined;
        try check(cuEventElapsedTime(&result, start.handle, stop.handle));
        return result;
    }
};
