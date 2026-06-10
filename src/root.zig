const std = @import("std");

// --- Types & Handles ---

pub const ScalarType = enum {
    pred,
    b8,
    b16,
    b32,
    b64,
    b128,
    u8,
    u16,
    u32,
    u64,
    s8,
    s16,
    s32,
    s64,
    f16,
    f32,
    f64,
    f16x2,
    bf16,
    bf16x2,
    tf32,
    e4m3,
    e5m2,
    u16x2,
    u8x4,
    s16x2,
    s8x4,

    pub fn suffix(self: ScalarType) []const u8 {
        return switch (self) {
            .pred => ".pred",
            .b8 => ".b8",
            .b16 => ".b16",
            .b32 => ".b32",
            .b64 => ".b64",
            .b128 => ".b128",
            .u8 => ".u8",
            .u16 => ".u16",
            .u32 => ".u32",
            .u64 => ".u64",
            .s8 => ".s8",
            .s16 => ".s16",
            .s32 => ".s32",
            .s64 => ".s64",
            .f16 => ".f16",
            .f32 => ".f32",
            .f64 => ".f64",
            .f16x2 => ".f16x2",
            .bf16 => ".bf16",
            .bf16x2 => ".bf16x2",
            .tf32 => ".tf32",
            .e4m3 => ".e4m3",
            .e5m2 => ".e5m2",
            .u16x2 => ".u16x2",
            .u8x4 => ".u8x4",
            .s16x2 => ".s16x2",
            .s8x4 => ".s8x4",
        };
    }

    pub fn prefix(self: ScalarType) []const u8 {
        return switch (self) {
            .pred => "%p",
            .b8, .u8, .s8 => "%b",
            .b16, .u16, .s16 => "%h",
            .b32, .u32, .s32 => "%r",
            .b64, .u64, .s64 => "%rd",
            .b128 => "%q",
            .f16, .bf16 => "%hf",
            .f32, .tf32 => "%f",
            .f64 => "%fd",
            else => "%v",
        };
    }
};

pub const VectorSize = enum(u8) {
    s1 = 1,
    v2 = 2,
    v4 = 4,
    v8 = 8,

    pub fn suffix(self: VectorSize) []const u8 {
        return switch (self) {
            .s1 => "",
            .v2 => ".v2",
            .v4 => ".v4",
            .v8 => ".v8",
        };
    }
};

pub const PtxType = struct {
    scalar: ScalarType,
    vec: VectorSize = .s1,

    pub fn suffix(self: PtxType) []const u8 {
        return self.vec.suffix() ++ self.scalar.suffix();
    }

    pub fn prefix(self: PtxType) []const u8 {
        return self.scalar.prefix();
    }

    pub fn format(
        self: PtxType,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.writeAll(self.suffix());
    }

    // Convenience constants
    pub const pred = PtxType{ .scalar = .pred };
    pub const b8 = PtxType{ .scalar = .b8 };
    pub const b16 = PtxType{ .scalar = .b16 };
    pub const b32 = PtxType{ .scalar = .b32 };
    pub const b64 = PtxType{ .scalar = .b64 };
    pub const @"u32" = PtxType{ .scalar = .u32 };
    pub const @"u64" = PtxType{ .scalar = .u64 };
    pub const s32 = PtxType{ .scalar = .s32 };
    pub const s64 = PtxType{ .scalar = .s64 };
    pub const @"f16" = PtxType{ .scalar = .f16 };
    pub const @"f32" = PtxType{ .scalar = .f32 };
    pub const @"f64" = PtxType{ .scalar = .f64 };
};

pub const CacheLoad = enum {
    none,
    ca,
    cg,
    cs,
    lu,
    cv,
    @"volatile",
    nc,
    pub fn suffix(self: CacheLoad) []const u8 {
        if (self == .none) return "";
        return "." ++ @tagName(self);
    }
};

pub const CacheStore = enum {
    none,
    wb,
    cg,
    cs,
    wt,
    @"volatile",
    pub fn suffix(self: CacheStore) []const u8 {
        if (self == .none) return "";
        return "." ++ @tagName(self);
    }
};

pub const RoundingMode = enum {
    none,
    rn,
    rz,
    rm,
    rp,
    rni,
    rzi,
    rmi,
    rpi,
    pub fn suffix(self: RoundingMode) []const u8 {
        if (self == .none) return "";
        return "." ++ @tagName(self);
    }
};

pub const Scope = enum {
    none,
    cta,
    gpu,
    sys,
    cluster,
    pub fn suffix(self: Scope) []const u8 {
        if (self == .none) return "";
        return "." ++ @tagName(self);
    }
};

pub const MemOrder = enum {
    none,
    relaxed,
    acquire,
    release,
    acq_rel,
    pub fn suffix(self: MemOrder) []const u8 {
        if (self == .none) return "";
        return "." ++ @tagName(self);
    }
};

pub const CompareOp = enum {
    eq,
    ne,
    lt,
    le,
    gt,
    ge,
    num,
    nan,
    equ,
    neu,
    ltu,
    leu,
    gtu,
    geu,
    pub fn suffix(self: CompareOp) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const SimdMode = enum {
    add,
    min,
    max,
    pub fn suffix(self: SimdMode) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const ShflMode = enum {
    up,
    down,
    bfly,
    idx,
    pub fn suffix(self: ShflMode) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const PrmtMode = enum {
    f4e,
    b4e,
    rc8,
    ecl,
    ecr,
    pub fn suffix(self: PrmtMode) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const Direction = enum {
    l,
    r,
    pub fn suffix(self: Direction) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const ShiftMode = enum {
    clamp,
    wrap,
    pub fn suffix(self: ShiftMode) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const SimdIntMode = enum {
    lo,
    hi,
    pub fn suffix(self: SimdIntMode) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const TexGeom = enum {
    @"1d",
    @"2d",
    @"3d",
    a1d,
    a2d,
    cube,
    acube,
    @"2dms",
    a2dms,
    pub fn suffix(self: TexGeom) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const SurfaceMode = enum {
    none,
    trap,
    clamp,
    zero,
    pub fn suffix(self: SurfaceMode) []const u8 {
        if (self == .none) return "";
        return "." ++ @tagName(self);
    }
};

pub const VoteMode = enum {
    all,
    any,
    uni,
    ballot,
    pub fn suffix(self: VoteMode) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const AtomOp = enum {
    add,
    sub,
    inc,
    dec,
    min,
    max,
    @"and",
    @"or",
    xor,
    cas,
    exch,
    pub fn suffix(self: AtomOp) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const TexQuery = enum {
    width,
    height,
    depth,
    array_size,
    num_samples,
    num_mipmaps,
    pub fn suffix(self: TexQuery) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const SurfQuery = enum {
    width,
    height,
    depth,
    array_size,
    channel_data_type,
    channel_order,
    pub fn suffix(self: SurfQuery) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const MbarrierOp = enum {
    init,
    arrive,
    test_wait,
    pending_count,
    pub fn suffix(self: MbarrierOp) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const MmaShape = enum {
    m16n8k8,
    m16n8k16,
    m16n8k32,
    m64n128k16,
    m64n64k16,
    m8n8k4,
    pub fn suffix(self: MmaShape) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const MmaLayout = enum {
    row,
    col,
    pub fn suffix(self: MmaLayout) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const CacheLevel = enum {
    L1,
    L2,
    pub fn suffix(self: CacheLevel) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const CvtDirection = enum {
    to,
    from,
    pub fn suffix(self: CvtDirection) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const BarrierOp = enum {
    arrive,
    wait,
    pub fn suffix(self: BarrierOp) []const u8 {
        return "." ++ @tagName(self);
    }
};

pub const StateSpace = enum {
    reg,
    sreg,
    const_space,
    global,
    local,
    param,
    shared,
    tex,

    pub fn suffix(self: StateSpace) []const u8 {
        return switch (self) {
            .const_space => ".const",
            else => "." ++ @tagName(self),
        };
    }

    pub fn format(
        self: StateSpace,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.writeAll(self.suffix());
    }
};

pub const Target = enum {
    sm_50,
    sm_52,
    sm_53,
    sm_60,
    sm_61,
    sm_62,
    sm_70,
    sm_72,
    sm_75,
    sm_80,
    sm_86,
    sm_87,
    sm_89,
    sm_90,
    sm_90a,
    sm_100a,

    pub fn computeCapability(self: Target) struct { major: u32, minor: u32 } {
        return switch (self) {
            .sm_50 => .{ .major = 5, .minor = 0 },
            .sm_52 => .{ .major = 5, .minor = 2 },
            .sm_53 => .{ .major = 5, .minor = 3 },
            .sm_60 => .{ .major = 6, .minor = 0 },
            .sm_61 => .{ .major = 6, .minor = 1 },
            .sm_62 => .{ .major = 6, .minor = 2 },
            .sm_70 => .{ .major = 7, .minor = 0 },
            .sm_72 => .{ .major = 7, .minor = 2 },
            .sm_75 => .{ .major = 7, .minor = 5 },
            .sm_80 => .{ .major = 8, .minor = 0 },
            .sm_86 => .{ .major = 8, .minor = 6 },
            .sm_87 => .{ .major = 8, .minor = 7 },
            .sm_89 => .{ .major = 8, .minor = 9 },
            .sm_90 => .{ .major = 9, .minor = 0 },
            .sm_90a => .{ .major = 9, .minor = 0 },
            .sm_100a => .{ .major = 10, .minor = 0 },
        };
    }

    pub fn supportsAtLeast(self: Target, comptime major: u32, comptime minor: u32) bool {
        const cc = self.computeCapability();
        return cc.major > major or (cc.major == major and cc.minor >= minor);
    }

    pub fn isAccelerated(self: Target) bool {
        return switch (self) {
            .sm_90a, .sm_100a => true,
            else => false,
        };
    }
};

pub const Version = struct {
    major: u32,
    minor: u32,

    pub const v8_3 = Version{ .major = 8, .minor = 3 };
    pub const v8_4 = Version{ .major = 8, .minor = 4 };
    pub const v8_5 = Version{ .major = 8, .minor = 5 };
    pub const v9_0 = Version{ .major = 9, .minor = 0 };
    pub const v9_3 = Version{ .major = 9, .minor = 3 };

    pub fn supportsAtLeast(self: Version, comptime major: u32, comptime minor: u32) bool {
        return self.major > major or (self.major == major and self.minor >= minor);
    }
};

pub const ParamHandle = struct {
    name: []const u8,
    ty: PtxType,
};

pub fn ParamsResult(comptime T: type) type {
    const info = @typeInfo(T);
    if (info != .@"struct") return void;
    if (info.@"struct".is_tuple) {
        const fields = info.@"struct".fields;
        var field_types: [fields.len]type = undefined;
        inline for (0..fields.len) |i| field_types[i] = ParamHandle;
        return std.meta.Tuple(&field_types);
    }
    const fields = info.@"struct".fields;
    var field_names: [fields.len][:0]const u8 = undefined;
    var field_types: [fields.len]type = undefined;
    var field_attrs: [fields.len]std.builtin.Type.StructField.Attributes = undefined;
    inline for (fields, 0..) |field, i| {
        field_names[i] = field.name;
        field_types[i] = ParamHandle;
        field_attrs[i] = .{};
    }
    return @Struct(.auto, null, &field_names, &field_types, &field_attrs);
}

pub fn Reg(comptime ty_: PtxType) type {
    return struct {
        pub const ty = ty_;
        data: union(enum) {
            id: u32,
            name: []const u8,
            imm: union(enum) {
                u: u64,
                s: i64,
                f: f64,
            },
        },
    };
}

pub fn Ptr(comptime space_: StateSpace, comptime ty_: PtxType) type {
    return struct {
        pub const space = space_;
        pub const ty = ty_;
        reg: Reg(PtxType.b64),
        offset: i32 = 0,
    };
}

pub fn Shared(comptime ty_: PtxType) type {
    return struct {
        pub const space = StateSpace.shared;
        pub const ty = ty_;
        name: []const u8,
        offset: i32 = 0,
    };
}

pub const sreg = struct {
    pub const tid = struct {
        pub const x = "%tid.x";
        pub const y = "%tid.y";
        pub const z = "%tid.z";
    };
    pub const ntid = struct {
        pub const x = "%ntid.x";
        pub const y = "%ntid.y";
        pub const z = "%ntid.z";
    };
    pub const ctaid = struct {
        pub const x = "%ctaid.x";
        pub const y = "%ctaid.y";
        pub const z = "%ctaid.z";
    };
    pub const nctaid = struct {
        pub const x = "%nctaid.x";
        pub const y = "%nctaid.y";
        pub const z = "%nctaid.z";
    };
};

// --- Specification & Validation (Generated) ---

// [GEN_START]
pub const Opcode = enum {
    abs,
    add,
    add_cc,
    addc,
    alloca,
    @"and",
    atom,
    bar,
    barrier,
    bfe,
    bfi,
    bfind,
    bmsk,
    bra,
    brev,
    brkpt,
    call,
    clmad,
    clz,
    cnot,
    copysign,
    cos,
    cp_async,
    cp_async_bulk,
    cvt,
    cvt_pack,
    cvta,
    discard,
    div,
    dp2a,
    dp4a,
    ex2,
    exit,
    fabric_submit,
    fabric_try_get,
    fma,
    fns,
    grpbarrier,
    isspacep,
    ld,
    ldu,
    lg2,
    lop3,
    mad,
    mad_cc,
    mad24,
    madc,
    match,
    max,
    mbarrier,
    membar,
    min,
    mma,
    mov,
    mul,
    mul24,
    neg,
    not,
    @"or",
    pmevent,
    popc,
    prefetch,
    prefetchu,
    prmt,
    rcp,
    red,
    redux,
    rem,
    ret,
    rsqrt,
    sad,
    selp,
    set,
    setmaxhreg,
    setmaxnreg,
    setp,
    shf,
    shfl_sync,
    shl,
    shr,
    sin,
    slct,
    sqrt,
    st,
    stackrestore,
    stacksave,
    sub,
    sub_cc,
    subc,
    suld,
    suq,
    sured,
    sust,
    szext,
    tanh,
    tcgen05,
    testp,
    tex,
    tld4,
    trap,
    txq,
    vabsdiff,
    vabsdiff2,
    vabsdiff4,
    vadd,
    vadd2,
    vadd4,
    vavrg2,
    vavrg4,
    vmad,
    vmax,
    vmax2,
    vmax4,
    vmin,
    vmin2,
    vmin4,
    vote,
    vset,
    vset2,
    vset4,
    vshl,
    vshr,
    vsub,
    vsub2,
    vsub4,
    wgmma_mma_async,
    xor,
};

pub const Modifier = enum {
    m1d,
    m2d,
    m2dms,
    m3d,
    L1,
    L2,
    a,
    a1d,
    a2d,
    a2dms,
    acube,
    add,
    aligned,
    all,
    @"and",
    any,
    approx,
    array_size,
    arrive,
    b,
    b4e,
    ballot,
    bf16,
    bfly,
    bulk,
    ca,
    cas,
    cc,
    cg,
    channel_data_type,
    channel_order,
    clamp,
    cluster,
    col,
    commit,
    @"const",
    cs,
    cta,
    cta_group,
    cube,
    cv,
    dec,
    depth,
    down,
    ecl,
    ecr,
    eq,
    exch,
    f16,
    f32,
    f4e,
    finite,
    from,
    ftz,
    full,
    g,
    ge,
    global,
    gpu,
    gt,
    height,
    hi,
    idx,
    inc,
    infinite,
    init,
    l,
    le,
    lo,
    local,
    lt,
    lu,
    m16n8k16,
    m16n8k32,
    m16n8k8,
    m64n128k16,
    m64n64k16,
    m8n8k4,
    max,
    min,
    nan_,
    ne,
    normal,
    notanumber,
    num,
    num_mipmaps,
    num_samples,
    number,
    @"or",
    param,
    pending_count,
    popc,
    r,
    rc8,
    red,
    rm,
    rmi,
    rn,
    rnd_,
    rni,
    row,
    rp,
    rpi,
    rz,
    rzi,
    s32,
    sat,
    satfinite,
    shared,
    shiftamt,
    sub,
    subnormal,
    sync,
    sys,
    test_wait,
    to,
    trap,
    u32,
    uni,
    up,
    wait,
    wb,
    wide,
    width,
    wrap,
    wt,
    xor,
    zero,
};

pub fn isValid(comptime op: Opcode, comptime ty: ScalarType) bool {
    return switch (op) {
        .abs => switch (ty) {
            .bf16, .bf16x2, .f16, .f16x2, .f32, .f64, .s16, .s32, .s64 => true,
            else => false,
        },
        .add => switch (ty) {
            .bf16, .bf16x2, .f16, .f16x2, .f32, .f64, .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .add_cc => switch (ty) {
            .s32, .s64, .u32, .u64 => true,
            else => false,
        },
        .addc => switch (ty) {
            .s32, .s64, .u32, .u64 => true,
            else => false,
        },
        .alloca => switch (ty) {
            .u32, .u64 => true,
            else => false,
        },
        .@"and" => switch (ty) {
            .b16, .b32, .b64, .pred => true,
            else => false,
        },
        .atom => switch (ty) {
            .f32, .f64, .s32, .s64, .u32, .u64 => true,
            else => false,
        },
        .bar => switch (ty) {
            .u32 => true,
            else => false,
        },
        .barrier => true,
        .bfe => switch (ty) {
            .s32, .s64, .u32, .u64 => true,
            else => false,
        },
        .bfi => switch (ty) {
            .b32 => true,
            else => false,
        },
        .bfind => switch (ty) {
            .s32, .s64, .u32, .u64 => true,
            else => false,
        },
        .bmsk => switch (ty) {
            .b32, .b64 => true,
            else => false,
        },
        .bra => true,
        .brev => switch (ty) {
            .b32, .b64 => true,
            else => false,
        },
        .brkpt => true,
        .call => true,
        .clmad => switch (ty) {
            .b32, .b64 => true,
            else => false,
        },
        .clz => switch (ty) {
            .b32, .b64 => true,
            else => false,
        },
        .cnot => switch (ty) {
            .b16, .b32, .b64 => true,
            else => false,
        },
        .copysign => switch (ty) {
            .f32, .f64 => true,
            else => false,
        },
        .cos => switch (ty) {
            .f32 => true,
            else => false,
        },
        .cp_async => true,
        .cp_async_bulk => true,
        .cvt => switch (ty) {
            .b128, .b16, .b32, .b64, .b8, .f16, .f32, .f64, .s16, .s32, .s64, .s8, .u16, .u32, .u64, .u8 => true,
            else => false,
        },
        .cvt_pack => switch (ty) {
            .bf16x2, .f16x2, .s8x4, .u8x4 => true,
            else => false,
        },
        .cvta => switch (ty) {
            .u32, .u64 => true,
            else => false,
        },
        .discard => true,
        .div => switch (ty) {
            .f32, .f64, .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .dp2a => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .dp4a => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .ex2 => switch (ty) {
            .f16, .f16x2, .f32 => true,
            else => false,
        },
        .exit => true,
        .fabric_submit => true,
        .fabric_try_get => switch (ty) {
            .b32, .b64 => true,
            else => false,
        },
        .fma => switch (ty) {
            .bf16, .bf16x2, .f16, .f16x2, .f32, .f64 => true,
            else => false,
        },
        .fns => switch (ty) {
            .b32 => true,
            else => false,
        },
        .grpbarrier => switch (ty) {
            .b64 => true,
            else => false,
        },
        .isspacep => true,
        .ld => switch (ty) {
            .b128, .b16, .b32, .b64, .b8, .f16, .f32, .f64, .s16, .s32, .s64, .s8, .u16, .u32, .u64, .u8 => true,
            else => false,
        },
        .ldu => switch (ty) {
            .b128, .b16, .b32, .b64, .b8, .f16, .f32, .f64, .s16, .s32, .s64, .s8, .u16, .u32, .u64, .u8 => true,
            else => false,
        },
        .lg2 => switch (ty) {
            .f32 => true,
            else => false,
        },
        .lop3 => switch (ty) {
            .b32 => true,
            else => false,
        },
        .mad => switch (ty) {
            .f32, .f64, .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .mad_cc => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .mad24 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .madc => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .match => switch (ty) {
            .b32, .b64 => true,
            else => false,
        },
        .max => switch (ty) {
            .bf16, .bf16x2, .f16, .f16x2, .f32, .f64, .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .mbarrier => switch (ty) {
            .b64 => true,
            else => false,
        },
        .membar => true,
        .min => switch (ty) {
            .bf16, .bf16x2, .f16, .f16x2, .f32, .f64, .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .mma => switch (ty) {
            .bf16, .f16, .f32, .s8, .tf32, .u8 => true,
            else => false,
        },
        .mov => switch (ty) {
            .b128, .b16, .b32, .b64, .b8, .f16, .f32, .f64, .s16, .s32, .s64, .s8, .u16, .u32, .u64, .u8 => true,
            else => false,
        },
        .mul => switch (ty) {
            .bf16, .bf16x2, .f16, .f16x2, .f32, .f64, .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .mul24 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .neg => switch (ty) {
            .bf16, .bf16x2, .f16, .f16x2, .f32, .f64, .s16, .s32, .s64 => true,
            else => false,
        },
        .not => switch (ty) {
            .b16, .b32, .b64, .pred => true,
            else => false,
        },
        .@"or" => switch (ty) {
            .b16, .b32, .b64, .pred => true,
            else => false,
        },
        .pmevent => switch (ty) {
            .u32 => true,
            else => false,
        },
        .popc => switch (ty) {
            .b32, .b64 => true,
            else => false,
        },
        .prefetch => true,
        .prefetchu => true,
        .prmt => switch (ty) {
            .b32 => true,
            else => false,
        },
        .rcp => switch (ty) {
            .f32, .f64 => true,
            else => false,
        },
        .red => switch (ty) {
            .f32, .f64, .s32, .s64, .u32, .u64 => true,
            else => false,
        },
        .redux => switch (ty) {
            .b32, .s32, .u32 => true,
            else => false,
        },
        .rem => switch (ty) {
            .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .ret => true,
        .rsqrt => switch (ty) {
            .f32, .f64 => true,
            else => false,
        },
        .sad => switch (ty) {
            .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .selp => switch (ty) {
            .b16, .b32, .b64, .f32, .f64, .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .set => switch (ty) {
            .f32, .f64, .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .setmaxhreg => switch (ty) {
            .u32 => true,
            else => false,
        },
        .setmaxnreg => switch (ty) {
            .u32 => true,
            else => false,
        },
        .setp => switch (ty) {
            .f32, .f64, .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .shf => switch (ty) {
            .b32 => true,
            else => false,
        },
        .shfl_sync => switch (ty) {
            .b32 => true,
            else => false,
        },
        .shl => switch (ty) {
            .b16, .b32, .b64 => true,
            else => false,
        },
        .shr => switch (ty) {
            .b16, .b32, .b64, .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .sin => switch (ty) {
            .f32 => true,
            else => false,
        },
        .slct => switch (ty) {
            .b16, .b32, .b64, .f32, .f64, .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .sqrt => switch (ty) {
            .f32, .f64 => true,
            else => false,
        },
        .st => switch (ty) {
            .b128, .b16, .b32, .b64, .b8, .f16, .f32, .f64, .s16, .s32, .s64, .s8, .u16, .u32, .u64, .u8 => true,
            else => false,
        },
        .stackrestore => switch (ty) {
            .u32, .u64 => true,
            else => false,
        },
        .stacksave => switch (ty) {
            .u32, .u64 => true,
            else => false,
        },
        .sub => switch (ty) {
            .bf16, .bf16x2, .f16, .f16x2, .f32, .f64, .s16, .s32, .s64, .u16, .u32, .u64 => true,
            else => false,
        },
        .sub_cc => switch (ty) {
            .s32, .s64, .u32, .u64 => true,
            else => false,
        },
        .subc => switch (ty) {
            .s32, .s64, .u32, .u64 => true,
            else => false,
        },
        .suld => switch (ty) {
            .b16, .b32, .b64, .b8 => true,
            else => false,
        },
        .suq => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .sured => switch (ty) {
            .b32, .s32, .u32, .u64 => true,
            else => false,
        },
        .sust => switch (ty) {
            .b16, .b32, .b64, .b8 => true,
            else => false,
        },
        .szext => switch (ty) {
            .s32, .s64, .u32, .u64 => true,
            else => false,
        },
        .tanh => switch (ty) {
            .f32 => true,
            else => false,
        },
        .tcgen05 => switch (ty) {
            .b64 => true,
            else => false,
        },
        .testp => switch (ty) {
            .f32, .f64 => true,
            else => false,
        },
        .tex => switch (ty) {
            .f16, .f32, .s32, .u32 => true,
            else => false,
        },
        .tld4 => switch (ty) {
            .f16, .f32, .s32, .u32 => true,
            else => false,
        },
        .trap => true,
        .txq => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vabsdiff => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vabsdiff2 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vabsdiff4 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vadd => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vadd2 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vadd4 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vavrg2 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vavrg4 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vmad => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vmax => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vmax2 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vmax4 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vmin => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vmin2 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vmin4 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vote => switch (ty) {
            .b32 => true,
            else => false,
        },
        .vset => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vset2 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vset4 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vshl => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vshr => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vsub => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vsub2 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .vsub4 => switch (ty) {
            .s32, .u32 => true,
            else => false,
        },
        .wgmma_mma_async => switch (ty) {
            .bf16, .f16, .f32, .s8, .tf32, .u8 => true,
            else => false,
        },
        .xor => switch (ty) {
            .b16, .b32, .b64, .pred => true,
            else => false,
        },
    };
}
// [GEN_END]

// --- Internal Helpers ---

fn fmtOp(comptime op: anytype) []const u8 {
    const T = @TypeOf(op);
    const ti = @typeInfo(T);
    switch (ti) {
        .pointer => |p| {
            if (p.size == .slice and p.child == u8) return op;
            if (p.size == .one) {
                switch (@typeInfo(p.child)) {
                    .array => |arr| if (arr.child == u8) return op,
                    else => {},
                }
            }
        },
        .@"struct" => {
            if (T == ParamHandle) {
                return std.fmt.comptimePrint("{s}", .{op.name});
            }
            if (@hasDecl(T, "space") and @hasDecl(T, "ty") and @hasField(T, "name")) {
                if (T.space == .shared) {
                    if (op.offset == 0) {
                        return std.fmt.comptimePrint("{s}", .{op.name});
                    } else if (op.offset > 0) {
                        return std.fmt.comptimePrint("{s}+{d}", .{ op.name, op.offset });
                    } else {
                        return std.fmt.comptimePrint("{s}{d}", .{ op.name, op.offset });
                    }
                }
            }
            if (@hasDecl(T, "ty") and @hasField(T, "data")) {
                switch (op.data) {
                    .id => |id| {
                        const ty = T.ty;
                        if (ty.vec == .s1) {
                            return std.fmt.comptimePrint("{s}{d}", .{ ty.prefix(), id });
                        } else {
                            var res: []const u8 = "{";
                            inline for (0..@intFromEnum(ty.vec)) |i| {
                                if (i > 0) res = res ++ ", ";
                                res = res ++ std.fmt.comptimePrint("{s}{d}", .{ ty.prefix(), id + i });
                            }
                            res = res ++ "}";
                            return res;
                        }
                    },
                    .name => |name| return std.fmt.comptimePrint("%{s}", .{name}),
                    .imm => |imm| {
                        return switch (imm) {
                            .u => |v| std.fmt.comptimePrint("{d}", .{v}),
                            .s => |v| std.fmt.comptimePrint("{d}", .{v}),
                            .f => |v| std.fmt.comptimePrint("{d}", .{v}),
                        };
                    },
                }
            }
            if (@hasDecl(T, "space") and @hasDecl(T, "ty") and @hasField(T, "reg")) {
                const r_str = fmtOp(op.reg);
                if (op.offset == 0) {
                    return std.fmt.comptimePrint("[{s}]", .{r_str});
                } else {
                    return std.fmt.comptimePrint("[{s}+{d}]", .{ r_str, op.offset });
                }
            }
        },
        else => {},
    }
    return std.fmt.comptimePrint("{}", .{op});
}

fn validate(comptime op: Opcode, comptime ty: PtxType) void {
    if (!isValid(op, ty.scalar)) {
        @compileError("Illegal PTX instruction form: " ++ @tagName(op) ++ ty.suffix());
    }
}

fn targetSupports(comptime target: Target, comptime op: Opcode) bool {
    return switch (op) {
        .cp_async => target.supportsAtLeast(8, 0),
        .mma => target.supportsAtLeast(8, 0),
        .barrier, .grpbarrier, .cp_async_bulk, .mbarrier, .wgmma_mma_async => target.supportsAtLeast(9, 0),
        .tcgen05 => target == .sm_100a,
        else => true,
    };
}

pub const InstructionForm = struct {
    op: Opcode,
    min_version: ?Version = null,
    allowed_spaces: []const StateSpace = &.{},
    allowed_vecs: []const VectorSize = &.{},
    allowed_scalars: []const ScalarType = &.{},
    allowed_copy_sizes: []const u32 = &.{},
};

pub const InstructionContext = struct {
    op: Opcode,
    ty: PtxType = PtxType.b32,
    target: Target = .sm_75,
    version: Version = .v8_4,
    space: ?StateSpace = null,
    atom_op: ?AtomOp = null,
    copy_size: ?u32 = null,
};

fn containsScalar(comptime xs: []const ScalarType, comptime x: ScalarType) bool {
    inline for (xs) |item| {
        if (item == x) return true;
    }
    return false;
}

fn containsVectorSize(comptime xs: []const VectorSize, comptime x: VectorSize) bool {
    inline for (xs) |item| {
        if (item == x) return true;
    }
    return false;
}

fn containsStateSpace(comptime xs: []const StateSpace, comptime x: StateSpace) bool {
    inline for (xs) |item| {
        if (item == x) return true;
    }
    return false;
}

fn containsU32(comptime xs: []const u32, comptime x: u32) bool {
    inline for (xs) |item| {
        if (item == x) return true;
    }
    return false;
}

fn instructionForm(comptime op: Opcode) InstructionForm {
    return switch (op) {
        .ld => .{
            .op = .ld,
            .allowed_spaces = &.{ .global, .local, .param, .shared, .const_space },
            .allowed_vecs = &.{ .s1, .v2, .v4 },
        },
        .ldu => .{
            .op = .ldu,
            .allowed_spaces = &.{.global},
            .allowed_vecs = &.{.s1},
        },
        .st => .{
            .op = .st,
            .allowed_spaces = &.{ .global, .local, .shared },
            .allowed_vecs = &.{ .s1, .v2, .v4 },
        },
        .cvta => .{
            .op = .cvta,
            .allowed_spaces = &.{ .global, .local, .shared, .const_space },
            .allowed_vecs = &.{.s1},
            .allowed_scalars = &.{ .u32, .u64 },
        },
        .isspacep => .{
            .op = .isspacep,
            .allowed_spaces = &.{ .global, .local, .shared, .const_space },
            .allowed_vecs = &.{.s1},
            .allowed_scalars = &.{.pred},
        },
        .atom, .red => .{
            .op = op,
            .allowed_spaces = &.{ .global, .shared },
            .allowed_vecs = &.{.s1},
        },
        .prefetch, .prefetchu => .{
            .op = op,
            .allowed_spaces = &.{.global},
            .allowed_vecs = &.{.s1},
        },
        .cp_async => .{
            .op = .cp_async,
            .allowed_spaces = &.{.shared},
            .allowed_vecs = &.{.s1},
            .allowed_copy_sizes = &.{ 4, 8, 16 },
        },
        .cp_async_bulk => .{
            .op = .cp_async_bulk,
            .allowed_spaces = &.{.shared},
            .allowed_vecs = &.{.s1},
        },
        else => .{ .op = op },
    };
}

fn isAtomicOpTypeValid(comptime instruction: Opcode, comptime op: AtomOp, comptime ty: PtxType) bool {
    if (ty.vec != .s1) return false;

    const is_red = instruction == .red;
    return switch (op) {
        .add => switch (ty.scalar) {
            .u32, .u64, .s32, .s64, .f32, .f64 => true,
            else => false,
        },
        .sub => switch (ty.scalar) {
            .u32, .s32 => true,
            else => false,
        },
        .inc, .dec => switch (ty.scalar) {
            .u32 => true,
            else => false,
        },
        .min, .max => switch (ty.scalar) {
            .u32, .u64, .s32, .s64 => true,
            else => false,
        },
        .@"and", .@"or", .xor => switch (ty.scalar) {
            .b32, .b64, .u32, .u64 => true,
            else => false,
        },
        .cas => !is_red and switch (ty.scalar) {
            .b32, .b64, .u32, .u64 => true,
            else => false,
        },
        .exch => !is_red and switch (ty.scalar) {
            .b32, .b64, .u32, .u64, .s32, .s64, .f32 => true,
            else => false,
        },
    };
}

fn validateInstructionForm(comptime ctx: InstructionContext) void {
    const form = instructionForm(ctx.op);

    if (ctx.op == .atom or ctx.op == .red) {
        const atom_op = ctx.atom_op orelse @compileError("Atomic/reduction validation requires atom_op");
        if (!isAtomicOpTypeValid(ctx.op, atom_op, ctx.ty)) {
            @compileError("Illegal PTX atomic/reduction form: " ++ @tagName(ctx.op) ++ atom_op.suffix() ++ ctx.ty.suffix());
        }
    } else {
        validate(ctx.op, ctx.ty);
    }

    if (!targetSupports(ctx.target, ctx.op)) {
        @compileError("PTX opcode " ++ @tagName(ctx.op) ++ " is not supported by target " ++ @tagName(ctx.target));
    }

    if (form.min_version) |min_version| {
        if (!ctx.version.supportsAtLeast(min_version.major, min_version.minor)) {
            @compileError(std.fmt.comptimePrint(
                "PTX opcode {s} requires PTX version {d}.{d} or newer",
                .{ @tagName(ctx.op), min_version.major, min_version.minor },
            ));
        }
    }

    if (form.allowed_spaces.len > 0) {
        const space = ctx.space orelse @compileError("PTX opcode " ++ @tagName(ctx.op) ++ " requires a state space");
        if (!containsStateSpace(form.allowed_spaces, space)) {
            @compileError("Illegal PTX state space for " ++ @tagName(ctx.op) ++ ": " ++ @tagName(space));
        }
    }

    if (form.allowed_vecs.len > 0 and !containsVectorSize(form.allowed_vecs, ctx.ty.vec)) {
        @compileError("Illegal vector size for PTX opcode " ++ @tagName(ctx.op) ++ ctx.ty.suffix());
    }

    if (form.allowed_scalars.len > 0 and !containsScalar(form.allowed_scalars, ctx.ty.scalar)) {
        @compileError("Illegal scalar type for PTX opcode " ++ @tagName(ctx.op) ++ ctx.ty.suffix());
    }

    if (form.allowed_copy_sizes.len > 0) {
        if (ctx.copy_size) |copy_size| {
            if (!containsU32(form.allowed_copy_sizes, copy_size)) {
                @compileError(std.fmt.comptimePrint("Illegal copy size for {s}: {d}", .{ @tagName(ctx.op), copy_size }));
            }
        }
    }
}

fn validateOperandStateSpace(comptime operand: anytype, comptime expected: StateSpace, comptime role: []const u8) void {
    const T = @TypeOf(operand);
    switch (@typeInfo(T)) {
        .@"struct" => {
            if (@hasDecl(T, "space") and T.space != expected) {
                @compileError(role ++ " must be in " ++ @tagName(expected) ++ " state space, got " ++ @tagName(T.space));
            }
        },
        else => {},
    }
}

fn comptimeImmediateU32(comptime value: anytype) ?u32 {
    const T = @TypeOf(value);
    return switch (@typeInfo(T)) {
        .comptime_int => if (value >= 0 and value <= std.math.maxInt(u32)) @as(u32, value) else null,
        .int => |info| blk: {
            if (info.signedness == .signed and value < 0) break :blk null;
            if (value > std.math.maxInt(u32)) break :blk null;
            break :blk @as(u32, @intCast(value));
        },
        else => null,
    };
}

// --- Kernel Builder ---

pub const KernelBuilder = struct {
    name: []const u8 = "",
    version: Version = .v8_4,
    target: Target = .sm_75,
    max_virtual_registers: ?u32 = null,
    params_text: []const u8 = "",
    active_predicate: ?[]const u8 = null,
    counts: struct {
        p: u32 = 0,   // %p (.pred)
        b: u32 = 0,   // %b (.b8)
        h: u32 = 0,   // %h (.b16)
        r: u32 = 0,   // %r (.b32)
        rd: u32 = 0,  // %rd (.b64)
        q: u32 = 0,   // %q (.b128)
        hf: u32 = 0,  // %hf (.f16)
        f: u32 = 0,   // %f (.f32)
        fd: u32 = 0,  // %fd (.f64)
        v: u32 = 0,   // %v (others)
    } = .{},
    shared_decls: []const u8 = "",
    body: []const u8 = "",

    pub fn params(comptime self: *KernelBuilder, comptime ps: anytype) ParamsResult(@TypeOf(ps)) {
        const T = @TypeOf(ps);
        const info = @typeInfo(T);
        if (info.@"struct".is_tuple) {
            var res: ParamsResult(T) = undefined;
            inline for (ps, 0..) |p, i| {
                const ty: PtxType = blk: {
                    if (@TypeOf(p) == PtxType) break :blk p;
                    if (@TypeOf(p) == ScalarType) break :blk PtxType{ .scalar = p };
                    if (@typeInfo(@TypeOf(p)) == .enum_literal) break :blk PtxType{ .scalar = @field(ScalarType, @tagName(p)) };
                    @compileError("Invalid parameter type for tuple index " ++ std.fmt.comptimePrint("{}", .{i}));
                };
                const name = std.fmt.comptimePrint("p{d}", .{i});
                if (i > 0 or self.params_text.len > 0) self.params_text = self.params_text ++ ",\n";
                self.params_text = self.params_text ++ std.fmt.comptimePrint("\t.param {s} {s}", .{ ty.suffix(), name });
                res[i] = .{ .name = name, .ty = ty };
            }
            return res;
        } else {
            var res: ParamsResult(T) = undefined;
            inline for (info.@"struct".fields) |field| {
                const val = @field(ps, field.name);
                const ty: PtxType = blk: {
                    if (@TypeOf(val) == PtxType) break :blk val;
                    if (@TypeOf(val) == ScalarType) break :blk PtxType{ .scalar = val };
                    if (@typeInfo(@TypeOf(val)) == .enum_literal) break :blk PtxType{ .scalar = @field(ScalarType, @tagName(val)) };
                    @compileError("Invalid parameter type for " ++ field.name);
                };
                if (self.params_text.len > 0) self.params_text = self.params_text ++ ",\n";
                self.params_text = self.params_text ++ std.fmt.comptimePrint("\t.param {s} {s}", .{ ty.suffix(), field.name });
                @field(res, field.name) = .{ .name = field.name, .ty = ty };
            }
            return res;
        }
    }

    pub fn raw(comptime self: *KernelBuilder, comptime s: []const u8) void {
        self.body = self.body ++ s;
    }

    pub fn line(comptime self: *KernelBuilder, comptime s: []const u8) void {
        if (self.active_predicate) |p| {
            if (s[0] == '@') {
                @compileError("Nested predicates not supported: " ++ p ++ " and " ++ s);
            }
            self.raw("\t" ++ p ++ " " ++ s ++ "\n");
        } else {
            self.raw("\t" ++ s ++ "\n");
        }
    }

    pub fn setPredicate(comptime self: *KernelBuilder, p: anytype, is_neg: bool) void {
        const p_str = if (is_neg) "@!" else "@";
        self.active_predicate = p_str ++ fmtOp(p);
    }

    pub fn clearPredicate(comptime self: *KernelBuilder) void {
        self.active_predicate = null;
    }

    pub fn predicated(comptime self: *KernelBuilder, p: anytype, is_neg: bool, comptime body_fn: anytype) void {
        const old = self.active_predicate;
        self.setPredicate(p, is_neg);
        body_fn(self);
        self.active_predicate = old;
    }

    fn validateForm(comptime self: *KernelBuilder, comptime ctx: InstructionContext) void {
        validateInstructionForm(.{
            .op = ctx.op,
            .ty = ctx.ty,
            .target = self.target,
            .version = self.version,
            .space = ctx.space,
            .atom_op = ctx.atom_op,
            .copy_size = ctx.copy_size,
        });
    }

    fn validateTarget(comptime self: *KernelBuilder, comptime op: Opcode) void {
        if (!targetSupports(self.target, op)) {
            @compileError("PTX opcode " ++ @tagName(op) ++ " is not supported by target " ++ @tagName(self.target));
        }
    }

    fn virtualRegisterCount(comptime self: *KernelBuilder) u32 {
        var total: u32 = 0;
        inline for (std.meta.fields(@TypeOf(self.counts))) |field| {
            total += @field(self.counts, field.name);
        }
        return total;
    }

    fn checkRegisterLimit(comptime self: *KernelBuilder) void {
        if (self.max_virtual_registers) |limit| {
            const used = self.virtualRegisterCount();
            if (used > limit) {
                @compileError(std.fmt.comptimePrint("Kernel {s} uses {d} virtual registers, exceeding configured limit {d}", .{ self.name, used, limit }));
            }
        }
    }

    pub fn tmp(comptime self: *KernelBuilder, comptime ty: PtxType) Reg(ty) {
        const field_name = switch (ty.scalar) {
            .pred => "p",
            .b8, .u8, .s8 => "b",
            .b16, .u16, .s16 => "h",
            .b32, .u32, .s32 => "r",
            .b64, .u64, .s64 => "rd",
            .b128 => "q",
            .f16, .bf16 => "hf",
            .f32, .tf32 => "f",
            .f64 => "fd",
            else => "v",
        };
        const id = @field(self.counts, field_name);
        @field(self.counts, field_name) += @intFromEnum(ty.vec);
        self.checkRegisterLimit();
        return .{ .data = .{ .id = id } };
    }

    pub fn named(comptime _: *KernelBuilder, comptime ty: PtxType, comptime name: []const u8) Reg(ty) {
        return .{ .data = .{ .name = name } };
    }

    pub fn declReg(comptime self: *KernelBuilder, comptime ty: PtxType, comptime name: []const u8) Reg(ty) {
        self.line(".reg " ++ ty.suffix() ++ " %" ++ name ++ ";");
        return .{ .data = .{ .name = name } };
    }

    pub fn allocShared(
        comptime self: *KernelBuilder,
        comptime ty: PtxType,
        comptime name: []const u8,
        comptime len: u32,
        comptime alignment: u32,
    ) Shared(ty) {
        if (len == 0) @compileError("Shared memory allocation length must be greater than zero");
        if (alignment == 0 or (alignment & (alignment - 1)) != 0) {
            @compileError("Shared memory alignment must be a non-zero power of two");
        }
        if (ty.scalar == .pred) @compileError("Cannot allocate .pred shared memory");

        self.shared_decls = self.shared_decls ++ std.fmt.comptimePrint("\t.shared .align {d} {s} {s}[{d}];\n", .{ alignment, ty.suffix(), name, len });
        return .{ .name = name };
    }

    pub fn abs(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.abs, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("abs{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn add(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.add, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("add{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn add_cc(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.add_cc, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("add.cc{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn addc(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.addc, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("addc{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn @"and"(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.@"and", ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("and{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn bfe(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.bfe, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("bfe{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn bfi(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype, d: anytype) Reg(ty) {
        validate(.bfi, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("bfi{s} {s}, {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c), fmtOp(d) }));
        return dst;
    }
    pub fn bfind(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.bfind, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("bfind{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn bmsk(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.bmsk, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("bmsk{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn brev(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.brev, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("brev{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn clz(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.clz, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("clz{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn cnot(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.cnot, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("cnot{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn copysign(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.copysign, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("copysign{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn cos(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.cos, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("cos.approx{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn div(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.div, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("div.approx{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn ex2(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.ex2, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("ex2.approx{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn fma(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.fma, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("fma.rn{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn lg2(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.lg2, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("lg2.approx{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn lop3(comptime self: *KernelBuilder, a: anytype, b: anytype, c: anytype, comptime imm: u8) Reg(PtxType.b32) {
        const dst = self.tmp(PtxType.b32);
        self.line(std.fmt.comptimePrint("lop3.b32 {s}, {s}, {s}, {s}, 0x{x:0>2};", .{ fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c), imm }));
        return dst;
    }
    pub fn clmad(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.clmad, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("clmad{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn redux(comptime self: *KernelBuilder, comptime op: AtomOp, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.redux, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("redux.sync{s}{s} {s}, {s}, 0xFFFFFFFF;", .{ op.suffix(), ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn szext(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.szext, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("szext{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn mad(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.mad, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("mad{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn mad_cc(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.mad_cc, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("mad.cc{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn mad24(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.mad24, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("mad24.lo{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn madc(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.madc, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("madc{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn max(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.max, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("max{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn min(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.min, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("min{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn mov(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.mov, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("mov{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn movSpecial(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        return self.mov(ty, a);
    }
    pub fn mul(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.mul, ty);
        const dst = self.tmp(ty);
        const mod = switch (ty.scalar) {
            .f16, .f16x2, .f32, .f64, .bf16, .bf16x2 => "",
            else => ".lo",
        };
        self.line(std.fmt.comptimePrint("mul{s}{s} {s}, {s}, {s};", .{ mod, ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn mul24(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.mul24, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("mul24.lo{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn neg(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.neg, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("neg{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn not(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.not, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("not{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn @"or"(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.@"or", ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("or{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn popc(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.popc, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("popc{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn fns(comptime self: *KernelBuilder, a: anytype, b: anytype, c: anytype) Reg(PtxType.b32) {
        const dst = self.tmp(PtxType.b32);
        self.line(std.fmt.comptimePrint("fns.b32 {s}, {s}, {s}, {s};", .{ fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn rcp(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.rcp, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("rcp.approx{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn rem(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.rem, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("rem{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn rsqrt(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.rsqrt, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("rsqrt.approx{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn sad(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.sad, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("sad{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn selp(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.selp, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("selp{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn set(comptime self: *KernelBuilder, comptime op: CompareOp, comptime ty: PtxType, comptime src_ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.set, src_ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("set{s}{s}{s} {s}, {s}, {s};", .{ op.suffix(), ty.suffix(), src_ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn setp(comptime self: *KernelBuilder, comptime op: CompareOp, comptime ty: PtxType, a: anytype, b: anytype) Reg(PtxType.pred) {
        validate(.setp, ty);
        const dst = self.tmp(PtxType.pred);
        self.line(std.fmt.comptimePrint("setp{s}{s} {s}, {s}, {s};", .{ op.suffix(), ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn shf(comptime self: *KernelBuilder, comptime dir: Direction, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.shf, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("shf{s}.clamp{s} {s}, {s}, {s}, {s};", .{ dir.suffix(), ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn shl(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.shl, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("shl{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn label(comptime self: *KernelBuilder, comptime name: []const u8) void {
        self.raw(name ++ ":\n");
    }
    pub fn shr(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.shr, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("shr{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn sin(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.sin, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("sin.approx{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn slct(comptime self: *KernelBuilder, comptime ty: PtxType, comptime src_ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.slct, src_ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("slct{s}{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), src_ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn sqrt(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.sqrt, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("sqrt.approx{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn sub(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.sub, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("sub{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn sub_cc(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.sub_cc, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("sub.cc{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn subc(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.subc, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("subc{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn tanh(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.tanh, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("tanh.approx{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn testp(comptime self: *KernelBuilder, comptime op: CompareOp, comptime ty: PtxType, a: anytype) Reg(PtxType.pred) {
        validate(.testp, ty);
        const dst = self.tmp(PtxType.pred);
        self.line(std.fmt.comptimePrint("testp{s}{s} {s}, {s};", .{ op.suffix(), ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn xor(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        validate(.xor, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("xor{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn cvt(comptime self: *KernelBuilder, comptime dst_ty: PtxType, comptime src_ty: PtxType, a: anytype, comptime rnd: RoundingMode) Reg(dst_ty) {
        validate(.cvt, dst_ty);
        const dst = self.tmp(dst_ty);
        self.line(std.fmt.comptimePrint("cvt{s}{s}{s} {s}, {s};", .{ rnd.suffix(), dst_ty.suffix(), src_ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn cvta(comptime self: *KernelBuilder, comptime dir: CvtDirection, comptime space: StateSpace, comptime ty: PtxType, a: anytype) Reg(ty) {
        self.validateForm(.{ .op = .cvta, .space = space, .ty = ty });
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("cvta{s}{s}{s} {s}, {s};", .{ dir.suffix(), space.suffix(), ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn ld(comptime self: *KernelBuilder, comptime space: StateSpace, comptime ty: PtxType, a: anytype) Reg(ty) {
        self.validateForm(.{ .op = .ld, .space = space, .ty = ty });
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("ld{s}{s} {s}, [{s}];", .{ space.suffix(), ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn st(comptime self: *KernelBuilder, comptime space: StateSpace, comptime ty: PtxType, a: anytype, b: anytype) void {
        self.validateForm(.{ .op = .st, .space = space, .ty = ty });
        self.line(std.fmt.comptimePrint("st{s}{s} [{s}], {s};", .{ space.suffix(), ty.suffix(), fmtOp(a), fmtOp(b) }));
    }
    pub fn ldParam(comptime self: *KernelBuilder, p: ParamHandle) Reg(p.ty) {
        self.validateForm(.{ .op = .ld, .space = .param, .ty = p.ty });
        const dst = self.tmp(p.ty);
        self.line(std.fmt.comptimePrint("ld.param{s} {s}, [{s}];", .{ p.ty.suffix(), fmtOp(dst), fmtOp(p) }));
        return dst;
    }
    pub fn stGlobal(comptime self: *KernelBuilder, comptime ty: PtxType, addr: anytype, val: anytype) void {
        self.validateForm(.{ .op = .st, .space = .global, .ty = ty });
        self.line(std.fmt.comptimePrint("st.global{s} [{s}], {s};", .{ ty.suffix(), fmtOp(addr), fmtOp(val) }));
    }
    pub fn ret(comptime self: *KernelBuilder) void {
        self.line("ret;");
    }
    pub fn retIf(comptime self: *KernelBuilder, p: anytype) void {
        self.line(std.fmt.comptimePrint("@{s} ret;", .{fmtOp(p)}));
    }
    pub fn exit(comptime self: *KernelBuilder) void {
        self.line("exit;");
    }
    pub fn trap(comptime self: *KernelBuilder) void {
        self.line("trap;");
    }
    pub fn brkpt(comptime self: *KernelBuilder) void {
        self.line("brkpt;");
    }
    pub fn bar_sync(comptime self: *KernelBuilder, a: anytype) void {
        self.line(std.fmt.comptimePrint("bar.sync {s};", .{fmtOp(a)}));
    }
    pub fn barrier(comptime self: *KernelBuilder, comptime op: BarrierOp) void {
        self.validateTarget(.barrier);
        self.line(std.fmt.comptimePrint("barrier.cluster{s};", .{op.suffix()}));
    }
    pub fn grpbarrier(comptime self: *KernelBuilder) void {
        self.validateTarget(.grpbarrier);
        self.line("grpbarrier.cluster;");
    }
    pub fn membar(comptime self: *KernelBuilder, comptime level: Scope) void {
        self.line(std.fmt.comptimePrint("membar{s};", .{level.suffix()}));
    }
    pub fn cp_async(comptime self: *KernelBuilder, dst: anytype, src: anytype, comptime size: anytype) void {
        validateOperandStateSpace(dst, .shared, "cp.async destination");
        validateOperandStateSpace(src, .global, "cp.async source");
        self.validateForm(.{ .op = .cp_async, .space = .shared, .copy_size = comptimeImmediateU32(size) });
        self.line(std.fmt.comptimePrint("cp.async.ca.shared.global [{s}], [{s}], {s};", .{ fmtOp(dst), fmtOp(src), fmtOp(size) }));
    }
    pub fn discard(comptime self: *KernelBuilder, addr: anytype, size: anytype) void {
        self.line(std.fmt.comptimePrint("discard.global.b64 [{s}], {s};", .{ fmtOp(addr), fmtOp(size) }));
    }
    pub fn bra(comptime self: *KernelBuilder, comptime target: []const u8) void {
        self.line("bra " ++ target ++ ";");
    }
    pub fn call(comptime self: *KernelBuilder, comptime name: []const u8, args: anytype) void {
        var s: []const u8 = "call " ++ name ++ ", (";
        inline for (args, 0..) |arg, i| {
            if (i > 0) s = s ++ ", ";
            s = s ++ fmtOp(arg);
        }
        self.line(s ++ ");");
    }
    pub fn atom(comptime self: *KernelBuilder, comptime op: AtomOp, comptime space: StateSpace, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        self.validateForm(.{ .op = .atom, .space = space, .ty = ty, .atom_op = op });
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("atom{s}{s}{s} {s}, [{s}], {s};", .{ space.suffix(), op.suffix(), ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn red(comptime self: *KernelBuilder, comptime op: AtomOp, comptime space: StateSpace, comptime ty: PtxType, a: anytype, b: anytype) void {
        self.validateForm(.{ .op = .red, .space = space, .ty = ty, .atom_op = op });
        self.line(std.fmt.comptimePrint("red{s}{s}{s} [{s}], {s};", .{ space.suffix(), op.suffix(), ty.suffix(), fmtOp(a), fmtOp(b) }));
    }
    pub fn vote(comptime self: *KernelBuilder, comptime mode: VoteMode, a: anytype) Reg(PtxType.b32) {
        const dst = self.tmp(PtxType.b32);
        self.line(std.fmt.comptimePrint("vote{s}.b32 {s}, {s};", .{ mode.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn match_any(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) Reg(PtxType.b32) {
        validate(.match, ty);
        const dst = self.tmp(PtxType.b32);
        self.line(std.fmt.comptimePrint("match.any{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn match_all(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) struct { Reg(PtxType.b32), Reg(PtxType.pred) } {
        validate(.match, ty);
        const dst = self.tmp(PtxType.b32);
        const p = self.tmp(PtxType.pred);
        self.line(std.fmt.comptimePrint("match.all{s} {s}|{s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(p), fmtOp(a) }));
        return .{ dst, p };
    }
    pub fn shfl_sync(comptime self: *KernelBuilder, comptime mode: ShflMode, a: anytype, b: anytype, c: anytype, d: anytype) Reg(PtxType.b32) {
        const dst = self.tmp(PtxType.b32);
        self.line(std.fmt.comptimePrint("shfl.sync{s}.b32 {s}, {s}, {s}, {s}, {s};", .{ mode.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c), fmtOp(d) }));
        return dst;
    }
    pub fn prmt(comptime self: *KernelBuilder, comptime mode: PrmtMode, a: anytype, b: anytype, c: anytype) Reg(PtxType.b32) {
        const dst = self.tmp(PtxType.b32);
        self.line(std.fmt.comptimePrint("prmt.b32{s} {s}, {s}, {s}, {s};", .{ mode.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vadd(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vadd, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vadd{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vsub(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vsub, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vsub{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vmin(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vmin, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vmin{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vmax(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vmax, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vmax{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vmax2(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vmax2, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vmax2{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vmax4(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vmax4, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vmax4{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vmin2(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vmin2, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vmin2{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vmin4(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vmin4, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vmin4{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vabsdiff(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vabsdiff, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vabsdiff{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vabsdiff2(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vabsdiff2, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vabsdiff2{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vabsdiff4(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vabsdiff4, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vabsdiff4{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vavrg2(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vavrg2, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vavrg2{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vavrg4(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vavrg4, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vavrg4{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vshl(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vshl, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vshl{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vshr(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vshr, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vshr{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vmad(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vmad, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vmad{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vset(comptime self: *KernelBuilder, comptime op: CompareOp, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vset, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vset{s}{s} {s}, {s}, {s}, {s};", .{ op.suffix(), ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vset2(comptime self: *KernelBuilder, comptime op: CompareOp, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vset2, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vset2{s}{s} {s}, {s}, {s}, {s};", .{ op.suffix(), ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vset4(comptime self: *KernelBuilder, comptime op: CompareOp, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vset4, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vset4{s}{s} {s}, {s}, {s}, {s};", .{ op.suffix(), ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vsub2(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vsub2, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vsub2{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vsub4(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vsub4, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vsub4{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn tex(comptime self: *KernelBuilder, comptime geom: TexGeom, comptime dtype: PtxType, comptime ctype: PtxType, a: anytype, c: anytype) Reg(dtype) {
        validate(.tex, dtype);
        const dst = self.tmp(dtype);
        self.line(std.fmt.comptimePrint("tex{s}{s}{s} {s}, [{s}, {s}];", .{ geom.suffix(), dtype.suffix(), ctype.suffix(), fmtOp(dst), fmtOp(a), fmtOp(c) }));
        return dst;
    }
    pub fn tld4(comptime self: *KernelBuilder, comptime geom: TexGeom, comptime dtype: PtxType, comptime ctype: PtxType, a: anytype, c: anytype, b: anytype) Reg(dtype) {
        validate(.tld4, dtype);
        const dst = self.tmp(dtype);
        self.line(std.fmt.comptimePrint("tld4.r{s}{s}{s} {s}, [{s}, {s}], {s};", .{ geom.suffix(), dtype.suffix(), ctype.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn txq(comptime self: *KernelBuilder, comptime query: TexQuery, a: anytype) Reg(PtxType.b32) {
        validate(.txq, PtxType.b32);
        const dst = self.tmp(PtxType.b32);
        self.line(std.fmt.comptimePrint("txq{s}.b32 {s}, [{s}];", .{ query.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn suld(comptime self: *KernelBuilder, comptime geom: TexGeom, comptime mode: SurfaceMode, comptime dtype: PtxType, comptime ctype: PtxType, a: anytype, c: anytype) Reg(dtype) {
        validate(.suld, dtype);
        const dst = self.tmp(dtype);
        self.line(std.fmt.comptimePrint("suld.b{s}{s}{s}{s} {s}, [{s}, {s}];", .{ geom.suffix(), dtype.suffix(), ctype.suffix(), mode.suffix(), fmtOp(dst), fmtOp(a), fmtOp(c) }));
        return dst;
    }
    pub fn sust(comptime self: *KernelBuilder, comptime geom: TexGeom, comptime mode: SurfaceMode, comptime dtype: PtxType, comptime ctype: PtxType, a: anytype, c: anytype, r: anytype) void {
        validate(.sust, dtype);
        self.line(std.fmt.comptimePrint("sust{s}{s}{s}{s} [{s}, {s}], {s};", .{ geom.suffix(), mode.suffix(), dtype.suffix(), ctype.suffix(), fmtOp(a), fmtOp(c), fmtOp(r) }));
    }
    pub fn suq(comptime self: *KernelBuilder, comptime query: SurfQuery, a: anytype) Reg(PtxType.b32) {
        validate(.suq, PtxType.b32);
        const dst = self.tmp(PtxType.b32);
        self.line(std.fmt.comptimePrint("suq{s}.b32 {s}, [{s}];", .{ query.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn sured(comptime self: *KernelBuilder, comptime op: AtomOp, comptime geom: TexGeom, comptime dtype: PtxType, comptime ctype: PtxType, a: anytype, c: anytype, r: anytype) void {
        validate(.sured, dtype);
        self.line(std.fmt.comptimePrint("sured{s}{s}{s}{s} [{s}, {s}], {s};", .{ op.suffix(), geom.suffix(), dtype.suffix(), ctype.suffix(), fmtOp(a), fmtOp(c), fmtOp(r) }));
    }
    pub fn vadd2(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vadd2, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vadd2{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn vadd4(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.vadd4, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("vadd4{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn alloca(comptime self: *KernelBuilder, comptime ty: PtxType, size: anytype) Reg(ty) {
        validate(.alloca, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("alloca{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(size) }));
        return dst;
    }
    pub fn stacksave(comptime self: *KernelBuilder, comptime ty: PtxType) Reg(ty) {
        validate(.stacksave, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("stacksave{s} {s};", .{ ty.suffix(), fmtOp(dst) }));
        return dst;
    }
    pub fn stackrestore(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype) void {
        validate(.stackrestore, ty);
        self.line(std.fmt.comptimePrint("stackrestore{s} {s};", .{ ty.suffix(), fmtOp(a) }));
    }
    pub fn dp2a(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.dp2a, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("dp2a.lo.u32.u32 {s}, {s}, {s}, {s};", .{ fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn dp4a(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(ty) {
        validate(.dp4a, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("dp4a{s} {s}, {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn bar(comptime self: *KernelBuilder, id: anytype, n: anytype) void {
        self.line(std.fmt.comptimePrint("bar.sync {s}, {s};", .{ fmtOp(id), fmtOp(n) }));
    }
    pub fn setmaxhreg(comptime self: *KernelBuilder, reg_count: anytype) void {
        self.line(std.fmt.comptimePrint("setmaxhreg.u32 {s};", .{fmtOp(reg_count)}));
    }
    pub fn setmaxnreg(comptime self: *KernelBuilder, reg_count: anytype) void {
        self.line(std.fmt.comptimePrint("setmaxnreg.u32 {s};", .{fmtOp(reg_count)}));
    }
    pub fn tcgen05(comptime self: *KernelBuilder, comptime op: MbarrierOp, addr_op: anytype, size: anytype) void {
        self.validateTarget(.tcgen05);
        self.line(std.fmt.comptimePrint("tcgen05{s}.shared::cluster.b64 [{s}], {s};", .{ op.suffix(), fmtOp(addr_op), fmtOp(size) }));
    }
    pub fn mma(comptime self: *KernelBuilder, comptime shape: MmaShape, comptime layout: MmaLayout, comptime d_ty: PtxType, comptime a_ty: PtxType, comptime b_ty: PtxType, comptime c_ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(d_ty) {
        self.validateForm(.{ .op = .mma, .ty = d_ty });
        const dst = self.tmp(d_ty);
        self.line(std.fmt.comptimePrint("mma.sync.aligned{s}{s}{s}{s}{s}{s} {s}, {s}, {s}, {s};", .{ shape.suffix(), layout.suffix(), d_ty.suffix(), a_ty.suffix(), b_ty.suffix(), c_ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn wgmma_mma_async(comptime self: *KernelBuilder, comptime shape: MmaShape, comptime layout: MmaLayout, comptime d_ty: PtxType, comptime a_ty: PtxType, comptime b_ty: PtxType, comptime c_ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(d_ty) {
        self.validateForm(.{ .op = .wgmma_mma_async, .ty = d_ty });
        const dst = self.tmp(d_ty);
        self.line(std.fmt.comptimePrint("wgmma.mma_async.sync.aligned{s}{s}{s}{s}{s}{s} {s}, {s}, {s}, {s};", .{ shape.suffix(), layout.suffix(), d_ty.suffix(), a_ty.suffix(), b_ty.suffix(), c_ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn pmevent(comptime self: *KernelBuilder, a: anytype) void {
        validate(.pmevent, PtxType.u32);
        self.line(std.fmt.comptimePrint("pmevent {s};", .{fmtOp(a)}));
    }
    pub fn ldu(comptime self: *KernelBuilder, comptime ty: PtxType, addr_op: anytype) Reg(ty) {
        self.validateForm(.{ .op = .ldu, .space = .global, .ty = ty });
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("ldu.global{s} {s}, [{s}];", .{ ty.suffix(), fmtOp(dst), fmtOp(addr_op) }));
        return dst;
    }
    pub fn prefetch(comptime self: *KernelBuilder, comptime level: CacheLevel, addr_op: anytype) void {
        self.validateForm(.{ .op = .prefetch, .space = .global, .ty = PtxType.b8 });
        self.line(std.fmt.comptimePrint("prefetch.global{s} [{s}];", .{ level.suffix(), fmtOp(addr_op) }));
    }
    pub fn prefetchu(comptime self: *KernelBuilder, comptime level: CacheLevel, addr_op: anytype) void {
        self.validateForm(.{ .op = .prefetchu, .space = .global, .ty = PtxType.b8 });
        self.line(std.fmt.comptimePrint("prefetchu{s} [{s}];", .{ level.suffix(), fmtOp(addr_op) }));
    }
    pub fn isspacep(comptime self: *KernelBuilder, comptime space: StateSpace, a: anytype) Reg(PtxType.pred) {
        self.validateForm(.{ .op = .isspacep, .space = space, .ty = PtxType.pred });
        const dst = self.tmp(PtxType.pred);
        self.line(std.fmt.comptimePrint("isspacep{s} {s}, {s};", .{ space.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn cvt_pack(comptime self: *KernelBuilder, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("cvt.pack{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn cp_async_bulk(comptime self: *KernelBuilder, dst: anytype, src: anytype, size: anytype, flag: anytype) void {
        validateOperandStateSpace(dst, .shared, "cp.async.bulk destination");
        validateOperandStateSpace(src, .global, "cp.async.bulk source");
        self.validateForm(.{ .op = .cp_async_bulk, .space = .shared, .ty = PtxType.b8 });
        self.line(std.fmt.comptimePrint("cp.async.bulk.shared::cluster.global.mbarrier::complete_tx::flag [{s}], [{s}], {s}, [{s}];", .{ fmtOp(dst), fmtOp(src), fmtOp(size), fmtOp(flag) }));
    }
    pub fn mbarrier(comptime self: *KernelBuilder, comptime op: MbarrierOp, addr_op: anytype) void {
        self.validateTarget(.mbarrier);
        self.line(std.fmt.comptimePrint("mbarrier{s}.shared.b64 [{s}];", .{ op.suffix(), fmtOp(addr_op) }));
    }

    pub fn fabric_submit(comptime self: *KernelBuilder, comptime scope: Scope, a: anytype, b: anytype) Reg(PtxType.b32) {
        const dst = self.tmp(PtxType.b32);
        self.line(std.fmt.comptimePrint("fabric.submit{s} {s}, {s}, {s};", .{ scope.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn fabric_try_get(comptime self: *KernelBuilder, comptime scope: Scope, a: anytype) Reg(PtxType.b32) {
        const dst = self.tmp(PtxType.b32);
        self.line(std.fmt.comptimePrint("fabric.try_get{s} {s}, {s};", .{ scope.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn generate(comptime self: *KernelBuilder) []const u8 {
        var res: []const u8 = "";
        res = res ++ ".entry " ++ self.name ++ "(\n";
        if (self.params_text.len > 0) res = res ++ self.params_text ++ "\n";
        res = res ++ ") {\n";
        if (self.shared_decls.len > 0) res = res ++ self.shared_decls;
        inline for (std.meta.fields(@TypeOf(self.counts))) |field| {
            const count = @field(self.counts, field.name);
            if (count > 0) {
                const p_ty: PtxType = blk: {
                    if (std.mem.eql(u8, field.name, "p")) break :blk .pred;
                    if (std.mem.eql(u8, field.name, "b")) break :blk .b8;
                    if (std.mem.eql(u8, field.name, "h")) break :blk .b16;
                    if (std.mem.eql(u8, field.name, "r")) break :blk .b32;
                    if (std.mem.eql(u8, field.name, "rd")) break :blk .b64;
                    if (std.mem.eql(u8, field.name, "q")) break :blk .b128;
                    if (std.mem.eql(u8, field.name, "hf")) break :blk PtxType{ .scalar = .f16 };
                    if (std.mem.eql(u8, field.name, "f")) break :blk PtxType{ .scalar = .f32 };
                    if (std.mem.eql(u8, field.name, "fd")) break :blk PtxType{ .scalar = .f64 };
                    break :blk .b32;
                };
                res = res ++ std.fmt.comptimePrint("\t.reg {s} {s}<{d}>;\n", .{ p_ty.suffix(), p_ty.prefix(), count });
            }
        }
        res = res ++ self.body;
        res = res ++ "}\n";
        return res;
    }
};

// --- Module Orchestration ---

pub const ModuleOptions = struct {
    version: Version = .v8_4,
    target: Target = .sm_75,
    address_size: u32 = 64,
    max_virtual_registers_per_kernel: ?u32 = null,
};

pub const Module = struct {
    options: ModuleOptions,
    kernels: [256]KernelBuilder = undefined,
    kernel_count: usize = 0,

    pub fn entry(comptime self: *Module, comptime name: []const u8, comptime ps: anytype) *KernelBuilder {
        const k = &self.kernels[self.kernel_count];
        k.* = .{
            .name = name,
            .version = self.options.version,
            .target = self.options.target,
            .max_virtual_registers = self.options.max_virtual_registers_per_kernel,
        };
        _ = k.params(ps);
        self.kernel_count += 1;
        return k;
    }

    pub fn generate(comptime self: *Module) [:0]const u8 {
        var res: [:0]const u8 = "";
        res = res ++ std.fmt.comptimePrint(".version {d}.{d}\n", .{ self.options.version.major, self.options.version.minor });
        res = res ++ ".target " ++ @tagName(self.options.target) ++ "\n";
        res = res ++ std.fmt.comptimePrint(".address_size {d}\n\n", .{self.options.address_size});
        inline for (self.kernels[0..self.kernel_count]) |*k| res = res ++ k.generate() ++ "\n";
        return res ++ "\x00";
    }
};

pub fn build(comptime opt: ModuleOptions, comptime definition: anytype) [:0]const u8 {
    comptime var m = Module{ .options = opt };
    const T = @TypeOf(definition);
    if (T == type) {
        if (@hasDecl(definition, "emit")) {
            definition.emit(&m);
        } else {
            inline for (std.meta.declarations(definition)) |decl| {
                const decl_name = comptime blk: {
                    const DeclType = @TypeOf(decl);
                    break :blk if (DeclType == [:0]const u8 or DeclType == []const u8) decl else decl.name;
                };
                const item = @field(definition, decl_name);
                if (@typeInfo(@TypeOf(item)) == .@"fn") {
                    const k = m.entry(decl_name, .{});
                    item(k);
                }
            }
        }
    } else {
        definition(&m);
    }
    return m.generate();
}

// --- Tests ---

test "unified library verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn vector_add(k: *ptx.KernelBuilder) void {
            const ps = k.params(.{
                .A = .b64,
                .B = .b64,
                .C = .b64,
            });
            const rA = k.ldParam(ps.A);
            const rB = k.ldParam(ps.B);
            const rC = k.add(PtxType.f32, rA, rB);
            k.stGlobal(PtxType.b64, "C", rC);
            k.ret();
        }
    });
    try std.testing.expect(std.mem.indexOf(u8, result, "vector_add") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "add.f32") != null);
}

test "typed modifiers verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn test_setp(k: *ptx.KernelBuilder) void {
            const r0 = k.tmp(PtxType.u32);
            const p0 = k.setp(.ge, PtxType.u32, r0, r0);
            k.retIf(p0);
        }
    });
    try std.testing.expect(std.mem.indexOf(u8, result, "setp.ge.u32") != null);
}

test "label and branch verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn test_loop(k: *ptx.KernelBuilder) void {
            const r0 = k.tmp(PtxType.u32);
            k.label("START");
            const p0 = k.setp(.eq, PtxType.u32, r0, 0);
            k.predicated(p0, false, struct {
                fn body(inner_k: *ptx.KernelBuilder) void {
                    inner_k.bra("START");
                }
            }.body);
            k.ret();
        }
    });
    try std.testing.expect(std.mem.indexOf(u8, result, "START:") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "bra START;") != null);
}

test "tuple params verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn test_tuple(k: *ptx.KernelBuilder) void {
            const ps = k.params(.{ .b64, .u32 });
            _ = k.ldParam(ps[0]);
            _ = k.ldParam(ps[1]);
            k.ret();
        }
    });
    try std.testing.expect(std.mem.indexOf(u8, result, ".param .b64 p0") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, ".param .u32 p1") != null);
}

test "shared memory declarations verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn test_shared(k: *ptx.KernelBuilder) void {
            const scratch = k.allocShared(PtxType.b32, "scratch", 256, 16);
            const r0 = k.tmp(PtxType.b32);
            k.st(.shared, PtxType.b32, scratch, r0);
            _ = k.ld(.shared, PtxType.b32, scratch);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".shared .align 16 .b32 scratch[256];") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "st.shared.b32 [scratch]") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "ld.shared.b32") != null);
}

test "target propagated into kernel builder verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{ .target = .sm_80 }, struct {
        pub fn async_copy(k: *ptx.KernelBuilder) void {
            const dst = k.allocShared(PtxType.b8, "dst", 16, 16);
            const src = k.tmp(PtxType.b64);
            k.cp_async(dst, src, 16);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".target sm_80") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "cp.async.ca.shared.global [dst]") != null);
}

test "register limit tracking verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{ .max_virtual_registers_per_kernel = 4 }, struct {
        pub fn reg_budget(k: *ptx.KernelBuilder) void {
            _ = k.tmp(PtxType.u32);
            _ = k.tmp(PtxType.u32);
            _ = k.tmp(PtxType.pred);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".reg .pred %p<1>;") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, ".reg .b32 %r<2>;") != null);
}

test "shared handle offset formatting verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn shared_offset(k: *ptx.KernelBuilder) void {
            const scratch = k.allocShared(PtxType.b32, "scratch", 8, 16);
            const r0 = k.tmp(PtxType.b32);
            k.st(.shared, PtxType.b32, ptx.Shared(PtxType.b32){ .name = scratch.name, .offset = 4 }, r0);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, "st.shared.b32 [scratch+4]") != null);
}

test "instruction form validation allows vector memory forms" {
    const ptx = @This();
    const vec4_b32 = PtxType{ .scalar = .b32, .vec = .v4 };
    const result = comptime ptx.build(.{}, struct {
        pub fn vec_shared(k: *ptx.KernelBuilder) void {
            const scratch = k.allocShared(PtxType.b32, "scratch4", 16, 16);
            const r0 = k.tmp(vec4_b32);
            k.st(.shared, vec4_b32, scratch, r0);
            _ = k.ld(.shared, vec4_b32, scratch);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, "st.shared.v4.b32 [scratch4]") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "ld.shared.v4.b32") != null);
}

test "instruction form validation allows atomic add forms" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn atom_add(k: *ptx.KernelBuilder) void {
            const addr = k.tmp(PtxType.b64);
            const val = k.tmp(PtxType.u32);
            _ = k.atom(.add, .global, PtxType.u32, addr, val);
            k.red(.add, .global, PtxType.u32, addr, val);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, "atom.global.add.u32") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "red.global.add.u32") != null);
}

test "instruction form validation carries ptx version into kernels" {
    const ptx = @This();
    const result = comptime ptx.build(.{ .version = .v9_0, .target = .sm_90 }, struct {
        pub fn versioned(k: *ptx.KernelBuilder) void {
            const scratch = k.allocShared(PtxType.b8, "bulk_dst", 16, 16);
            const src = k.tmp(PtxType.b64);
            const flag = k.tmp(PtxType.b64);
            k.cp_async_bulk(scratch, src, 16, flag);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".version 9.0") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "cp.async.bulk.shared::cluster.global") != null);
}
