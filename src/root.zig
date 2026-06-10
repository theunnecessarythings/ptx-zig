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
    pub const @"u8" = PtxType{ .scalar = .u8 };
    pub const @"u16" = PtxType{ .scalar = .u16 };
    pub const @"u32" = PtxType{ .scalar = .u32 };
    pub const @"u64" = PtxType{ .scalar = .u64 };
    pub const @"s8" = PtxType{ .scalar = .s8 };
    pub const @"s16" = PtxType{ .scalar = .s16 };
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
    pub const v9_1 = Version{ .major = 9, .minor = 1 };
    pub const v9_3 = Version{ .major = 9, .minor = 3 };

    pub fn supportsAtLeast(self: Version, comptime major: u32, comptime minor: u32) bool {
        return self.major > major or (self.major == major and self.minor >= minor);
    }
};

pub const EntryVisibility = enum {
    none,
    visible,
    @"extern",
    weak,

    pub fn prefix(self: EntryVisibility) []const u8 {
        return switch (self) {
            .none => "",
            .visible => ".visible ",
            .@"extern" => ".extern ",
            .weak => ".weak ",
        };
    }
};

pub const ParamHandle = struct {
    name: []const u8,
    ty: PtxType,
    offset: i32 = 0,

    pub fn at(comptime self: ParamHandle, comptime byte_offset: i32) ParamHandle {
        return .{
            .name = self.name,
            .ty = self.ty,
            .offset = self.offset + byte_offset,
        };
    }
};

pub const CallableKind = enum {
    entry,
    func,
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

pub fn Global(comptime ty_: PtxType) type {
    return struct {
        pub const space = StateSpace.global;
        pub const ty = ty_;
        name: []const u8,
        offset: i32 = 0,
    };
}

pub fn Const(comptime ty_: PtxType) type {
    return struct {
        pub const space = StateSpace.const_space;
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
                if (op.offset == 0) {
                    return std.fmt.comptimePrint("{s}", .{op.name});
                } else if (op.offset > 0) {
                    return std.fmt.comptimePrint("{s}+{d}", .{ op.name, op.offset });
                } else {
                    return std.fmt.comptimePrint("{s}{d}", .{ op.name, op.offset });
                }
            }
            if (@hasDecl(T, "space") and @hasDecl(T, "ty") and @hasField(T, "name")) {
                switch (T.space) {
                    .shared, .global, .const_space => {
                        if (op.offset == 0) {
                            return std.fmt.comptimePrint("{s}", .{op.name});
                        } else if (op.offset > 0) {
                            return std.fmt.comptimePrint("{s}+{d}", .{ op.name, op.offset });
                        } else {
                            return std.fmt.comptimePrint("{s}{d}", .{ op.name, op.offset });
                        }
                    },
                    else => {},
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
                } else if (op.offset > 0) {
                    return std.fmt.comptimePrint("[{s}+{d}]", .{ r_str, op.offset });
                } else {
                    return std.fmt.comptimePrint("[{s}{d}]", .{ r_str, op.offset });
                }
            }
        },
        else => {},
    }
    return std.fmt.comptimePrint("{}", .{op});
}

fn fmtAddr(comptime op: anytype) []const u8 {
    const T = @TypeOf(op);
    switch (@typeInfo(T)) {
        .@"struct" => {
            if (@hasDecl(T, "space") and @hasDecl(T, "ty") and @hasField(T, "reg")) {
                return fmtOp(op);
            }
        },
        else => {},
    }

    return "[" ++ fmtOp(op) ++ "]";
}

fn fmtOperandList(comptime args: anytype) []const u8 {
    const info = @typeInfo(@TypeOf(args));
    if (info != .@"struct") {
        @compileError("Operand list must be a tuple or struct");
    }

    var res: []const u8 = "";
    inline for (info.@"struct".fields, 0..) |field, i| {
        if (i > 0) res = res ++ ", ";
        res = res ++ fmtOp(@field(args, field.name));
    }
    return res;
}

fn operandCount(comptime args: anytype) usize {
    const info = @typeInfo(@TypeOf(args));
    if (info != .@"struct") {
        @compileError("Operand list must be a tuple or struct");
    }
    return info.@"struct".fields.len;
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
        } else {
            @compileError("Copy size for " ++ @tagName(ctx.op) ++ " must be a comptime u32 immediate");
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

fn scalarByteSize(comptime scalar: ScalarType) u32 {
    return switch (scalar) {
        .pred => 1,
        .b8, .u8, .s8, .e4m3, .e5m2 => 1,
        .b16, .u16, .s16, .f16, .bf16 => 2,
        .b32, .u32, .s32, .f32, .tf32, .f16x2, .bf16x2, .u16x2, .u8x4, .s16x2, .s8x4 => 4,
        .b64, .u64, .s64, .f64 => 8,
        .b128 => 16,
    };
}

fn ptxTypeByteSize(comptime ty: PtxType) u32 {
    return scalarByteSize(ty.scalar) * @intFromEnum(ty.vec);
}

fn operandPtxType(comptime operand: anytype) ?PtxType {
    const T = @TypeOf(operand);
    switch (@typeInfo(T)) {
        .@"struct" => {
            if (T == ParamHandle) return operand.ty;
            if (@hasDecl(T, "ty")) return T.ty;
        },
        else => {},
    }
    return null;
}

fn validateOperandWidth(comptime operand: anytype, comptime expected: PtxType, comptime role: []const u8) void {
    if (operandPtxType(operand)) |actual| {
        if (ptxTypeByteSize(actual) != ptxTypeByteSize(expected)) {
            @compileError(role ++ " width mismatch: expected " ++ expected.suffix() ++ ", got " ++ actual.suffix());
        }
    }
}

fn validateMemoryAddressOperand(
    comptime operand: anytype,
    comptime expected: StateSpace,
    comptime ty: PtxType,
    comptime role: []const u8,
) void {
    validateOperandStateSpace(operand, expected, role);

    const T = @TypeOf(operand);
    switch (@typeInfo(T)) {
        .@"struct" => {
            if (@hasDecl(T, "space") and @hasDecl(T, "ty")) {
                if (scalarByteSize(T.ty.scalar) != scalarByteSize(ty.scalar)) {
                    @compileError(
                        role ++ " element width mismatch: expected " ++
                            ty.suffix() ++
                            ", got " ++
                            T.ty.suffix(),
                    );
                }
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

fn validateMemoryDeclaration(comptime label: []const u8, comptime ty: PtxType, comptime len: u32, comptime alignment: u32) void {
    if (len == 0) {
        @compileError(label ++ " memory allocation length must be greater than zero");
    }
    if (alignment == 0 or (alignment & (alignment - 1)) != 0) {
        @compileError(label ++ " memory alignment must be a non-zero power of two");
    }
    if (ty.scalar == .pred) {
        @compileError("Cannot allocate .pred " ++ label ++ " memory");
    }
}

fn memoryDeclarationLine(comptime space: StateSpace, comptime ty: PtxType, comptime name: []const u8, comptime len: u32, comptime alignment: u32) []const u8 {
    return std.fmt.comptimePrint("\t{s} .align {d} {s} {s}[{d}];\n", .{ space.suffix(), alignment, ty.suffix(), name, len });
}

fn validatePositiveU32(comptime label: []const u8, comptime value: u32) void {
    if (value == 0) {
        @compileError(label ++ " must be greater than zero");
    }
}

fn validateEntryDim3(comptime label: []const u8, comptime x: u32, comptime y: u32, comptime z: u32) void {
    if (x == 0 or y == 0 or z == 0) {
        @compileError(label ++ " dimensions must be greater than zero");
    }
}

fn entryDim3Directive(comptime name: []const u8, comptime x: u32, comptime y: u32, comptime z: u32) []const u8 {
    return std.fmt.comptimePrint("{s} {d}, {d}, {d}\n", .{ name, x, y, z });
}

fn entryU32Directive(comptime name: []const u8, comptime value: u32) []const u8 {
    return std.fmt.comptimePrint("{s} {d}\n", .{ name, value });
}

// --- Kernel Builder ---

pub const KernelBuilder = struct {
    name: []const u8 = "",
    kind: CallableKind = .entry,
    return_ty: ?PtxType = null,
    return_param_name: []const u8 = "__ret",
    entry_visibility: EntryVisibility = .none,
    entry_directives: []const u8 = "",
    version: Version = .v8_4,
    target: Target = .sm_75,
    max_virtual_registers: ?u32 = null,
    param_count: usize = 0,
    param_types: [256]PtxType = undefined,
    param_names: [256][]const u8 = undefined,
    local_param_count: u32 = 0,
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
    param_decls: []const u8 = "",
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
                self.param_types[self.param_count] = ty;
                self.param_names[self.param_count] = name;
                self.param_count += 1;
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
                self.param_types[self.param_count] = ty;
                self.param_names[self.param_count] = field.name;
                self.param_count += 1;
            }
            return res;
        }
    }

    pub fn paramArray(
        comptime self: *KernelBuilder,
        comptime ty: PtxType,
        comptime name: []const u8,
        comptime len: u32,
        comptime alignment: u32,
    ) ParamHandle {
        validateMemoryDeclaration("parameter", ty, len, alignment);
        if (self.params_text.len > 0) self.params_text = self.params_text ++ ",\n";
        self.params_text = self.params_text ++ std.fmt.comptimePrint(
            "\t.param .align {d} {s} {s}[{d}]",
            .{ alignment, ty.suffix(), name, len },
        );
        self.param_types[self.param_count] = ty;
        self.param_names[self.param_count] = name;
        self.param_count += 1;
        return .{ .name = name, .ty = ty };
    }

    pub fn paramBytes(
        comptime self: *KernelBuilder,
        comptime name: []const u8,
        comptime len: u32,
        comptime alignment: u32,
    ) ParamHandle {
        return self.paramArray(PtxType.b8, name, len, alignment);
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

    pub fn setVisibility(comptime self: *KernelBuilder, comptime visibility: EntryVisibility) void {
        self.entry_visibility = visibility;
    }

    fn addEntryDirective(comptime self: *KernelBuilder, comptime directive: []const u8) void {
        self.entry_directives = self.entry_directives ++ directive;
    }

    pub fn maxntid(comptime self: *KernelBuilder, comptime x: u32, comptime y: u32, comptime z: u32) void {
        validateEntryDim3("maxntid", x, y, z);
        self.addEntryDirective(entryDim3Directive(".maxntid", x, y, z));
    }

    pub fn reqntid(comptime self: *KernelBuilder, comptime x: u32, comptime y: u32, comptime z: u32) void {
        validateEntryDim3("reqntid", x, y, z);
        self.addEntryDirective(entryDim3Directive(".reqntid", x, y, z));
    }

    pub fn minnctapersm(comptime self: *KernelBuilder, comptime value: u32) void {
        validatePositiveU32("minnctapersm", value);
        self.addEntryDirective(entryU32Directive(".minnctapersm", value));
    }

    pub fn maxnctapersm(comptime self: *KernelBuilder, comptime value: u32) void {
        validatePositiveU32("maxnctapersm", value);
        self.addEntryDirective(entryU32Directive(".maxnctapersm", value));
    }

    pub fn maxclusterrank(comptime self: *KernelBuilder, comptime value: u32) void {
        validatePositiveU32("maxclusterrank", value);
        self.addEntryDirective(entryU32Directive(".maxclusterrank", value));
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

    fn validateCallTarget(comptime _: *KernelBuilder, comptime callee: *const KernelBuilder) void {
        if (callee.kind != .func) {
            @compileError("Call target " ++ callee.name ++ " is not a .func");
        }
    }

    fn validateCallArgCount(comptime _: *KernelBuilder, comptime callee: *const KernelBuilder, comptime args: anytype) void {
        const actual = operandCount(args);
        if (actual != callee.param_count) {
            @compileError(std.fmt.comptimePrint(
                "Call to {s} expects {d} arguments, got {d}",
                .{ callee.name, callee.param_count, actual },
            ));
        }
    }

    fn validateCallArgWidths(comptime _: *KernelBuilder, comptime callee: *const KernelBuilder, args: anytype) void {
        const info = @typeInfo(@TypeOf(args));
        if (info != .@"struct") {
            @compileError("Call arguments must be a tuple or struct");
        }

        inline for (info.@"struct".fields, 0..) |field, i| {
            const expected = callee.param_types[i];
            const actual_arg = @field(args, field.name);
            if (operandPtxType(actual_arg)) |actual| {
                if (ptxTypeByteSize(actual) != ptxTypeByteSize(expected)) {
                    @compileError(std.fmt.comptimePrint(
                        "Call argument {d} width mismatch for {s}: expected {s}, got {s}",
                        .{ i, callee.name, expected.suffix(), actual.suffix() },
                    ));
                }
            }
        }
    }

    fn paramTypeAt(comptime self: *const KernelBuilder, comptime index: usize) PtxType {
        if (index >= self.param_count) {
            @compileError(std.fmt.comptimePrint(
                "Parameter index {d} out of bounds for {s}; parameter count is {d}",
                .{ index, self.name, self.param_count },
            ));
        }
        return self.param_types[index];
    }

    fn paramNameAt(comptime self: *const KernelBuilder, comptime index: usize) []const u8 {
        if (index >= self.param_count) {
            @compileError(std.fmt.comptimePrint(
                "Parameter index {d} out of bounds for {s}; parameter count is {d}",
                .{ index, self.name, self.param_count },
            ));
        }
        return self.param_names[index];
    }

    fn paramIndex(comptime self: *const KernelBuilder, comptime name: []const u8) usize {
        inline for (0..self.param_count) |i| {
            if (std.mem.eql(u8, self.param_names[i], name)) return i;
        }
        @compileError("No parameter named " ++ name ++ " in " ++ self.name);
    }

    fn paramType(comptime self: *const KernelBuilder, comptime name: []const u8) PtxType {
        return self.param_types[self.paramIndex(name)];
    }

    pub fn argAt(comptime self: *KernelBuilder, comptime index: usize) ParamHandle {
        return .{
            .name = self.paramNameAt(index),
            .ty = self.paramTypeAt(index),
        };
    }

    pub fn arg(comptime self: *KernelBuilder, comptime name: []const u8) ParamHandle {
        return self.argAt(self.paramIndex(name));
    }

    pub fn ldArgAt(comptime self: *KernelBuilder, comptime index: usize) Reg(self.paramTypeAt(index)) {
        return self.ldParam(self.argAt(index));
    }

    pub fn ldArg(comptime self: *KernelBuilder, comptime name: []const u8) Reg(self.paramType(name)) {
        return self.ldParam(self.arg(name));
    }

    fn marshalCallArgs(comptime self: *KernelBuilder, comptime callee: *const KernelBuilder, args: anytype) []const u8 {
        self.validateCallArgCount(callee, args);
        self.validateCallArgWidths(callee, args);

        const info = @typeInfo(@TypeOf(args));
        var res: []const u8 = "";
        inline for (info.@"struct".fields, 0..) |field, i| {
            const slot = self.tmpParam(callee.param_types[i]);
            self.stParam(slot, @field(args, field.name));
            if (i > 0) res = res ++ ", ";
            res = res ++ fmtOp(slot);
        }
        return res;
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

    pub fn declParam(comptime self: *KernelBuilder, comptime ty: PtxType, comptime name: []const u8) ParamHandle {
        self.param_decls = self.param_decls ++ std.fmt.comptimePrint("\t.param {s} {s};\n", .{ ty.suffix(), name });
        return .{ .name = name, .ty = ty };
    }

    pub fn tmpParam(comptime self: *KernelBuilder, comptime ty: PtxType) ParamHandle {
        const name = std.fmt.comptimePrint("__param{d}", .{self.local_param_count});
        self.local_param_count += 1;
        return self.declParam(ty, name);
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
        validateMemoryDeclaration("shared", ty, len, alignment);
        self.shared_decls = self.shared_decls ++ memoryDeclarationLine(.shared, ty, name, len, alignment);
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
        validateMemoryAddressOperand(a, space, ty, "ld address");
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("ld{s}{s} {s}, {s};", .{ space.suffix(), ty.suffix(), fmtOp(dst), fmtAddr(a) }));
        return dst;
    }
    pub fn st(comptime self: *KernelBuilder, comptime space: StateSpace, comptime ty: PtxType, a: anytype, b: anytype) void {
        self.validateForm(.{ .op = .st, .space = space, .ty = ty });
        validateMemoryAddressOperand(a, space, ty, "st address");
        self.line(std.fmt.comptimePrint("st{s}{s} {s}, {s};", .{ space.suffix(), ty.suffix(), fmtAddr(a), fmtOp(b) }));
    }
    pub fn ldParam(comptime self: *KernelBuilder, p: ParamHandle) Reg(p.ty) {
        self.validateForm(.{ .op = .ld, .space = .param, .ty = p.ty });
        const dst = self.tmp(p.ty);
        self.line(std.fmt.comptimePrint("ld.param{s} {s}, {s};", .{ p.ty.suffix(), fmtOp(dst), fmtAddr(p) }));
        return dst;
    }
    pub fn stGlobal(comptime self: *KernelBuilder, comptime ty: PtxType, addr: anytype, val: anytype) void {
        self.validateForm(.{ .op = .st, .space = .global, .ty = ty });
        validateMemoryAddressOperand(addr, .global, ty, "st.global address");
        self.line(std.fmt.comptimePrint("st.global{s} {s}, {s};", .{ ty.suffix(), fmtAddr(addr), fmtOp(val) }));
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
        self.line(std.fmt.comptimePrint("cp.async.ca.shared.global {s}, {s}, {s};", .{ fmtAddr(dst), fmtAddr(src), fmtOp(size) }));
    }
    pub fn discard(comptime self: *KernelBuilder, addr: anytype, size: anytype) void {
        validateOperandStateSpace(addr, .global, "discard address");
        self.line(std.fmt.comptimePrint("discard.global.b64 {s}, {s};", .{ fmtAddr(addr), fmtOp(size) }));
    }
    pub fn bra(comptime self: *KernelBuilder, comptime target: []const u8) void {
        self.line("bra " ++ target ++ ";");
    }

    pub fn call(comptime self: *KernelBuilder, comptime name: []const u8, args: anytype) void {
        self.line("call " ++ name ++ ", (" ++ fmtOperandList(args) ++ ");");
    }

    pub fn callVoid(comptime self: *KernelBuilder, comptime callee: *const KernelBuilder, args: anytype) void {
        self.validateCallTarget(callee);
        self.validateCallArgCount(callee, args);
        if (callee.return_ty != null) {
            @compileError("Function " ++ callee.name ++ " returns a value; use callRet");
        }
        self.line("call.uni " ++ callee.name ++ ", (" ++ fmtOperandList(args) ++ ");");
    }

    pub fn callRet(comptime self: *KernelBuilder, comptime ret_ty: PtxType, comptime callee: *const KernelBuilder, args: anytype) Reg(ret_ty) {
        self.validateCallTarget(callee);
        self.validateCallArgCount(callee, args);
        const callee_ret_ty = callee.return_ty orelse @compileError("Function " ++ callee.name ++ " does not return a value");
        if (scalarByteSize(ret_ty.scalar) != scalarByteSize(callee_ret_ty.scalar)) {
            @compileError(
                "Call return width mismatch for " ++
                    callee.name ++
                    ": expected " ++
                    ret_ty.suffix() ++
                    ", got " ++
                    callee_ret_ty.suffix(),
            );
        }

        const dst = self.tmp(ret_ty);
        self.line("call.uni (" ++ fmtOp(dst) ++ "), " ++ callee.name ++ ", (" ++ fmtOperandList(args) ++ ");");
        return dst;
    }

    pub fn callVoidMarshalled(comptime self: *KernelBuilder, comptime callee: *const KernelBuilder, args: anytype) void {
        self.validateCallTarget(callee);
        if (callee.return_ty != null) {
            @compileError("Function " ++ callee.name ++ " returns a value; use callRetMarshalled");
        }
        const marshalled_args = self.marshalCallArgs(callee, args);
        self.line("call.uni " ++ callee.name ++ ", (" ++ marshalled_args ++ ");");
    }

    pub fn callRetMarshalled(comptime self: *KernelBuilder, comptime ret_ty: PtxType, comptime callee: *const KernelBuilder, args: anytype) Reg(ret_ty) {
        self.validateCallTarget(callee);
        const callee_ret_ty = callee.return_ty orelse @compileError("Function " ++ callee.name ++ " does not return a value");
        if (ptxTypeByteSize(ret_ty) != ptxTypeByteSize(callee_ret_ty)) {
            @compileError("Call return width mismatch for " ++ callee.name ++ ": expected " ++ ret_ty.suffix() ++ ", got " ++ callee_ret_ty.suffix());
        }

        const ret_slot = self.tmpParam(ret_ty);
        const marshalled_args = self.marshalCallArgs(callee, args);
        self.line("call.uni (" ++ fmtOp(ret_slot) ++ "), " ++ callee.name ++ ", (" ++ marshalled_args ++ ");");
        return self.ldParam(ret_slot);
    }

    pub fn returnParam(comptime self: *KernelBuilder) ParamHandle {
        const ty = self.return_ty orelse @compileError("Function " ++ self.name ++ " does not return a value");
        return .{ .name = self.return_param_name, .ty = ty };
    }

    pub fn stParam(comptime self: *KernelBuilder, comptime p: ParamHandle, val: anytype) void {
        validateOperandWidth(val, p.ty, "st.param value");
        self.line("st.param" ++ p.ty.suffix() ++ " " ++ fmtAddr(p) ++ ", " ++ fmtOp(val) ++ ";");
    }

    pub fn retVal(comptime self: *KernelBuilder, val: anytype) void {
        self.stParam(self.returnParam(), val);
        self.ret();
    }
    pub fn atom(comptime self: *KernelBuilder, comptime op: AtomOp, comptime space: StateSpace, comptime ty: PtxType, a: anytype, b: anytype) Reg(ty) {
        self.validateForm(.{ .op = .atom, .space = space, .ty = ty, .atom_op = op });
        validateMemoryAddressOperand(a, space, ty, "atom address");
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("atom{s}{s}{s} {s}, {s}, {s};", .{ space.suffix(), op.suffix(), ty.suffix(), fmtOp(dst), fmtAddr(a), fmtOp(b) }));
        return dst;
    }
    pub fn red(comptime self: *KernelBuilder, comptime op: AtomOp, comptime space: StateSpace, comptime ty: PtxType, a: anytype, b: anytype) void {
        self.validateForm(.{ .op = .red, .space = space, .ty = ty, .atom_op = op });
        validateMemoryAddressOperand(a, space, ty, "red address");
        self.line(std.fmt.comptimePrint("red{s}{s}{s} {s}, {s};", .{ space.suffix(), op.suffix(), ty.suffix(), fmtAddr(a), fmtOp(b) }));
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
        validateOperandStateSpace(addr_op, .shared, "tcgen05 address");
        self.line(std.fmt.comptimePrint("tcgen05{s}.shared::cluster.b64 {s}, {s};", .{ op.suffix(), fmtAddr(addr_op), fmtOp(size) }));
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
        validateMemoryAddressOperand(addr_op, .global, ty, "ldu address");
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("ldu.global{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtAddr(addr_op) }));
        return dst;
    }
    pub fn prefetch(comptime self: *KernelBuilder, comptime level: CacheLevel, addr_op: anytype) void {
        self.validateForm(.{ .op = .prefetch, .space = .global, .ty = PtxType.b8 });
        validateOperandStateSpace(addr_op, .global, "prefetch address");
        self.line(std.fmt.comptimePrint("prefetch.global{s} {s};", .{ level.suffix(), fmtAddr(addr_op) }));
    }
    pub fn prefetchu(comptime self: *KernelBuilder, comptime level: CacheLevel, addr_op: anytype) void {
        self.validateForm(.{ .op = .prefetchu, .space = .global, .ty = PtxType.b8 });
        validateOperandStateSpace(addr_op, .global, "prefetchu address");
        self.line(std.fmt.comptimePrint("prefetchu{s} {s};", .{ level.suffix(), fmtAddr(addr_op) }));
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
        validateOperandStateSpace(flag, .shared, "cp.async.bulk barrier flag");
        self.validateForm(.{ .op = .cp_async_bulk, .space = .shared, .ty = PtxType.b8 });
        self.line(std.fmt.comptimePrint("cp.async.bulk.shared::cluster.global.mbarrier::complete_tx::flag {s}, {s}, {s}, {s};", .{ fmtAddr(dst), fmtAddr(src), fmtOp(size), fmtAddr(flag) }));
    }
    pub fn mbarrier(comptime self: *KernelBuilder, comptime op: MbarrierOp, addr_op: anytype) void {
        self.validateTarget(.mbarrier);
        validateOperandStateSpace(addr_op, .shared, "mbarrier address");
        self.line(std.fmt.comptimePrint("mbarrier{s}.shared.b64 {s};", .{ op.suffix(), fmtAddr(addr_op) }));
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
        switch (self.kind) {
            .entry => res = res ++ self.entry_visibility.prefix() ++ ".entry " ++ self.name ++ "(\n",
            .func => {
                res = res ++ ".func ";
                if (self.return_ty) |ty| {
                    res = res ++ "(.param " ++ ty.suffix() ++ " " ++ self.return_param_name ++ ") ";
                }
                res = res ++ self.name ++ "(\n";
            },
        }
        if (self.params_text.len > 0) res = res ++ self.params_text ++ "\n";
        res = res ++ ")\n";
        if (self.entry_directives.len > 0) res = res ++ self.entry_directives;
        res = res ++ "{\n";
        if (self.shared_decls.len > 0) res = res ++ self.shared_decls;
        if (self.param_decls.len > 0) res = res ++ self.param_decls;
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
    entry_visibility: EntryVisibility = .none,
};

pub const Module = struct {
    options: ModuleOptions,
    kernels: [256]KernelBuilder = undefined,
    functions: [256]KernelBuilder = undefined,
    function_count: usize = 0,
    extern_shared_decls: []const u8 = "",
    const_decls: []const u8 = "",
    global_decls: []const u8 = "",
    kernel_count: usize = 0,

    pub fn allocConst(
        comptime self: *Module,
        comptime ty: PtxType,
        comptime name: []const u8,
        comptime len: u32,
        comptime alignment: u32,
    ) Const(ty) {
        validateMemoryDeclaration("const", ty, len, alignment);
        self.const_decls = self.const_decls ++ memoryDeclarationLine(.const_space, ty, name, len, alignment);
        return .{ .name = name };
    }

    pub fn allocGlobal(
        comptime self: *Module,
        comptime ty: PtxType,
        comptime name: []const u8,
        comptime len: u32,
        comptime alignment: u32,
    ) Global(ty) {
        validateMemoryDeclaration("global", ty, len, alignment);
        self.global_decls = self.global_decls ++ memoryDeclarationLine(.global, ty, name, len, alignment);
        return .{ .name = name };
    }

    pub fn externShared(
        comptime self: *Module,
        comptime name: []const u8,
        comptime alignment: u32,
    ) Shared(PtxType.b8) {
        if (alignment == 0 or (alignment & (alignment - 1)) != 0) {
            @compileError("extern shared alignment must be a non-zero power of two");
        }
        self.extern_shared_decls = self.extern_shared_decls ++ std.fmt.comptimePrint(
            ".extern .shared .align {d} .b8 {s}[];\n",
            .{ alignment, name },
        );
        return .{ .name = name };
    }

    fn createFunc(
        comptime self: *Module,
        comptime name: []const u8,
        comptime return_ty: ?PtxType,
        comptime ps: anytype,
    ) *KernelBuilder {
        const f = &self.functions[self.function_count];
        f.* = .{
            .name = name,
            .kind = .func,
            .return_ty = return_ty,
            .version = self.options.version,
            .target = self.options.target,
            .max_virtual_registers = self.options.max_virtual_registers_per_kernel,
        };
        _ = f.params(ps);
        self.function_count += 1;
        return f;
    }

    pub fn func(comptime self: *Module, comptime name: []const u8, comptime ps: anytype) *KernelBuilder {
        return self.createFunc(name, null, ps);
    }

    pub fn funcRet(
        comptime self: *Module,
        comptime name: []const u8,
        comptime return_ty: PtxType,
        comptime ps: anytype,
    ) *KernelBuilder {
        return self.createFunc(name, return_ty, ps);
    }

    pub fn entry(comptime self: *Module, comptime name: []const u8, comptime ps: anytype) *KernelBuilder {
        const k = &self.kernels[self.kernel_count];
        k.* = .{
            .name = name,
            .entry_visibility = self.options.entry_visibility,
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
        if (self.extern_shared_decls.len > 0) res = res ++ self.extern_shared_decls;
        if (self.const_decls.len > 0) res = res ++ self.const_decls;
        if (self.global_decls.len > 0) res = res ++ self.global_decls;
        if (self.extern_shared_decls.len > 0 or self.const_decls.len > 0 or self.global_decls.len > 0) {
            res = res ++ "\n";
        }
        inline for (self.functions[0..self.function_count]) |*f| res = res ++ f.generate() ++ "\n";
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

fn expectCompileFail(
    comptime name: []const u8,
    comptime snippet: []const u8,
    comptime expected_error: []const u8,
) !void {
    const allocator = std.testing.allocator;
    const file_name = ".ptx_zig_compile_fail_" ++ name ++ ".zig";
    const source =
        "const ptx = @import(\"src/root.zig\");\n" ++
        "test \"compile fail " ++ name ++ "\" {\n" ++
        "    comptime {\n" ++
        snippet ++
        "    }\n" ++
        "}\n";

    const cwd = std.Io.Dir.cwd();
    const io = std.testing.io;

    cwd.access(io, "src/root.zig", .{}) catch |err| switch (err) {
        error.FileNotFound => return error.SkipZigTest,
        else => return err,
    };

    try cwd.writeFile(io, .{
        .sub_path = file_name,
        .data = source,
    });
    defer cwd.deleteFile(io, file_name) catch {};

    const result = std.process.run(allocator, io, .{
        .argv = &.{ "zig", "test", file_name, "--test-no-exec" },
    }) catch |err| switch (err) {
        error.FileNotFound => return error.SkipZigTest,
        else => return err,
    };
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    switch (result.term) {
        .exited => |code| try std.testing.expect(code != 0),
        else => return error.UnexpectedChildExit,
    }

    if (std.mem.indexOf(u8, result.stderr, expected_error) == null) {
        std.debug.print(
            "\nexpected compile error substring:\n{s}\n\nstdout:\n{s}\n\nstderr:\n{s}\n",
            .{ expected_error, result.stdout, result.stderr },
        );
        return error.ExpectedCompileErrorSubstringNotFound;
    }
}

test "module const declaration verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            const coeffs = m.allocConst(PtxType.b32, "coeffs", 64, 16);
            const k = m.entry("use_const", .{});
            _ = k.ld(.const_space, PtxType.b32, coeffs);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".const .align 16 .b32 coeffs[64];") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "ld.const.b32") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "[coeffs]") != null);
}

test "module global declaration verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            const state = m.allocGlobal(PtxType.b32, "state", 1024, 16);
            const k = m.entry("use_global", .{});
            const r0 = k.tmp(PtxType.b32);
            k.st(.global, PtxType.b32, state, r0);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".global .align 16 .b32 state[1024];") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "st.global.b32 [state]") != null);
}

test "module symbols can use offsets" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            const coeffs = m.allocConst(PtxType.b32, "coeffs", 64, 16);
            const state = m.allocGlobal(PtxType.b32, "state", 1024, 16);
            const k = m.entry("use_offsets", .{});
            const c1 = ptx.Const(PtxType.b32){ .name = coeffs.name, .offset = 4 };
            const s1 = ptx.Global(PtxType.b32){ .name = state.name, .offset = 8 };
            const r0 = k.ld(.const_space, PtxType.b32, c1);
            k.st(.global, PtxType.b32, s1, r0);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, "ld.const.b32") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "[coeffs+4]") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "st.global.b32 [state+8]") != null);
}

test "module const and global declarations emit before entries" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            _ = m.allocConst(PtxType.b16, "table", 8, 8);
            _ = m.allocGlobal(PtxType.b64, "counter", 1, 8);
            const k = m.entry("ordering", .{});
            k.ret();
        }
    });

    const const_pos = std.mem.indexOf(u8, result, ".const .align 8 .b16 table[8];").?;
    const global_pos = std.mem.indexOf(u8, result, ".global .align 8 .b64 counter[1];").?;
    const entry_pos = std.mem.indexOf(u8, result, ".entry ordering").?;
    try std.testing.expect(const_pos < entry_pos);
    try std.testing.expect(global_pos < entry_pos);
}

test "typed pointer address formatting verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn ptr_format(k: *ptx.KernelBuilder) void {
            const addr = k.tmp(PtxType.b64);
            const ptr = ptx.Ptr(.global, PtxType.b32){ .reg = addr, .offset = 4 };
            const r0 = k.tmp(PtxType.b32);
            k.st(.global, PtxType.b32, ptr, r0);
            _ = k.ld(.global, PtxType.b32, ptr);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, "st.global.b32 [%rd0+4]") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "ld.global.b32") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "[[%rd0+4]]") == null);
}

test "typed pointer negative offset formatting verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn ptr_negative_offset(k: *ptx.KernelBuilder) void {
            const addr = k.tmp(PtxType.b64);
            const ptr = ptx.Ptr(.global, PtxType.b32){ .reg = addr, .offset = -4 };
            _ = k.ld(.global, PtxType.b32, ptr);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, "[%rd0-4]") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "[%rd0+-4]") == null);
}

test "typed pointer validation accepts same-width aliases" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            const state = m.allocGlobal(PtxType.b32, "state_alias", 1, 4);
            const k = m.entry("same_width_alias", .{});
            _ = k.ld(.global, PtxType.u32, state);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, "ld.global.u32") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "[state_alias]") != null);
}

test "compile-fail validation rejects typed pointer state mismatch" {
    try expectCompileFail(
        "typed_pointer_state_mismatch",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn invalid(k: *ptx.KernelBuilder) void {
        \\                const addr = k.tmp(ptx.PtxType.b64);
        \\                const ptr = ptx.Ptr(.local, ptx.PtxType.b32){ .reg = addr };
        \\                _ = k.ld(.global, ptx.PtxType.b32, ptr);
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "ld address must be in global state space, got local",
    );
}

test "compile-fail validation rejects typed pointer width mismatch" {
    try expectCompileFail(
        "typed_pointer_width_mismatch",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn invalid(k: *ptx.KernelBuilder) void {
        \\                const addr = k.tmp(ptx.PtxType.b64);
        \\                const ptr = ptx.Ptr(.global, ptx.PtxType.b64){ .reg = addr };
        \\                _ = k.ld(.global, ptx.PtxType.b32, ptr);
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "ld address element width mismatch: expected .b32, got .b64",
    );
}

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

test "compile-fail validation rejects invalid load state space" {
    try expectCompileFail(
        "invalid_ld_space",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn invalid(k: *ptx.KernelBuilder) void {
        \\                _ = k.ld(.tex, ptx.PtxType.b32, "addr");
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "Illegal PTX state space for ld: tex",
    );
}

test "compile-fail validation rejects invalid memory vector size" {
    try expectCompileFail(
        "invalid_memory_vector_size",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn invalid(k: *ptx.KernelBuilder) void {
        \\                const ty = ptx.PtxType{ .scalar = .b32, .vec = .v8 };
        \\                _ = k.ld(.global, ty, "addr");
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "Illegal vector size for PTX opcode ld.v8.b32",
    );
}

test "compile-fail validation rejects invalid cp.async copy size" {
    try expectCompileFail(
        "invalid_cp_async_size",
        \\        _ = ptx.build(.{ .target = .sm_80 }, struct {
        \\            pub fn invalid(k: *ptx.KernelBuilder) void {
        \\                const dst = k.allocShared(ptx.PtxType.b8, "dst", 16, 16);
        \\                const src = k.tmp(ptx.PtxType.b64);
        \\                k.cp_async(dst, src, 12);
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "Illegal copy size for cp_async: 12",
    );
}

test "compile-fail validation rejects non-immediate cp.async copy size" {
    try expectCompileFail(
        "non_immediate_cp_async_size",
        \\        _ = ptx.build(.{ .target = .sm_80 }, struct {
        \\            pub fn invalid(k: *ptx.KernelBuilder) void {
        \\                const dst = k.allocShared(ptx.PtxType.b8, "dst", 16, 16);
        \\                const src = k.tmp(ptx.PtxType.b64);
        \\                const n = k.tmp(ptx.PtxType.u32);
        \\                k.cp_async(dst, src, n);
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "Copy size for cp_async must be a comptime u32 immediate",
    );
}

test "compile-fail validation rejects cp.async typed source state space" {
    try expectCompileFail(
        "invalid_cp_async_source_space",
        \\        _ = ptx.build(.{ .target = .sm_80 }, struct {
        \\            pub fn invalid(k: *ptx.KernelBuilder) void {
        \\                const dst = k.allocShared(ptx.PtxType.b8, "dst", 16, 16);
        \\                const src = ptx.Ptr(.local, ptx.PtxType.b8){ .reg = k.tmp(ptx.PtxType.b64) };
        \\                k.cp_async(dst, src, 16);
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "cp.async source must be in global state space, got local",
    );
}

test "compile-fail validation rejects target gated cp.async" {
    try expectCompileFail(
        "target_gated_cp_async",
        \\        _ = ptx.build(.{ .target = .sm_75 }, struct {
        \\            pub fn invalid(k: *ptx.KernelBuilder) void {
        \\                const dst = k.allocShared(ptx.PtxType.b8, "dst", 16, 16);
        \\                const src = k.tmp(ptx.PtxType.b64);
        \\                k.cp_async(dst, src, 16);
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "PTX opcode cp_async is not supported by target sm_75",
    );
}

test "compile-fail validation rejects invalid red cas form" {
    try expectCompileFail(
        "invalid_red_cas",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn invalid(k: *ptx.KernelBuilder) void {
        \\                const addr = k.tmp(ptx.PtxType.b64);
        \\                const val = k.tmp(ptx.PtxType.u32);
        \\                k.red(.cas, .global, ptx.PtxType.u32, addr, val);
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "Illegal PTX atomic/reduction form: red.cas.u32",
    );
}

test "entry launch directives verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn launch_bounds(k: *ptx.KernelBuilder) void {
            k.maxntid(256, 1, 1);
            k.reqntid(128, 2, 1);
            k.minnctapersm(2);
            k.maxnctapersm(4);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".maxntid 256, 1, 1") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, ".reqntid 128, 2, 1") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, ".minnctapersm 2") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, ".maxnctapersm 4") != null);

    const entry_pos = std.mem.indexOf(u8, result, ".entry launch_bounds").?;
    const directive_pos = std.mem.indexOf(u8, result, ".maxntid 256, 1, 1").?;
    const body_pos = std.mem.indexOf(u8, result, "ret;").?;
    try std.testing.expect(entry_pos < directive_pos);
    try std.testing.expect(directive_pos < body_pos);
}

test "entry visibility option verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{ .entry_visibility = .visible }, struct {
        pub fn visible_kernel(k: *ptx.KernelBuilder) void {
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".visible .entry visible_kernel") != null);
}

test "per-kernel entry visibility override verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn exported(k: *ptx.KernelBuilder) void {
            k.setVisibility(.visible);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".visible .entry exported") != null);
}

test "cluster launch directive verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{ .target = .sm_90 }, struct {
        pub fn clustered(k: *ptx.KernelBuilder) void {
            k.maxclusterrank(8);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".maxclusterrank 8") != null);
}

test "compile-fail validation rejects invalid maxntid dimensions" {
    try expectCompileFail(
        "invalid_maxntid_dimensions",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn invalid(k: *ptx.KernelBuilder) void {
        \\                k.maxntid(0, 1, 1);
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "maxntid dimensions must be greater than zero",
    );
}

test "compile-fail validation rejects invalid reqntid dimensions" {
    try expectCompileFail(
        "invalid_reqntid_dimensions",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn invalid(k: *ptx.KernelBuilder) void {
        \\                k.reqntid(128, 0, 1);
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "reqntid dimensions must be greater than zero",
    );
}

test "compile-fail validation rejects invalid cta occupancy directive" {
    try expectCompileFail(
        "invalid_minnctapersm",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn invalid(k: *ptx.KernelBuilder) void {
        \\                k.minnctapersm(0);
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "minnctapersm must be greater than zero",
    );
}

test "void function emission and call verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            const helper = m.func("helper", .{});
            helper.ret();

            const k = m.entry("caller", .{});
            k.callVoid(helper, .{});
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".func helper(") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "call.uni helper, ();") != null);

    const func_pos = std.mem.indexOf(u8, result, ".func helper(").?;
    const entry_pos = std.mem.indexOf(u8, result, ".entry caller").?;
    try std.testing.expect(func_pos < entry_pos);
}

test "function return value call verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            const answer = m.funcRet("answer", PtxType.u32, .{});
            answer.retVal(42);

            const k = m.entry("use_answer", .{});
            const r0 = k.callRet(PtxType.u32, answer, .{});
            k.stGlobal(PtxType.u32, "out", r0);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".func (.param .u32 __ret) answer(") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "st.param.u32 [__ret], 42;") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "call.uni (%r0), answer, ();") != null);
}

test "function parameter call verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            const sink = m.func("sink", .{ .x = .u32, .y = .u32 });
            sink.ret();

            const k = m.entry("call_sink", .{});
            const x = k.tmp(PtxType.u32);
            const y = k.tmp(PtxType.u32);
            k.callVoid(sink, .{ x, y });
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".param .u32 x") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, ".param .u32 y") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "call.uni sink, (%r0, %r1);") != null);
}

test "compile-fail validation rejects void call to returning function" {
    try expectCompileFail(
        "void_call_to_returning_function",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn emit(m: *ptx.Module) void {
        \\                const answer = m.funcRet("answer", ptx.PtxType.u32, .{});
        \\                answer.retVal(1);
        \\                const k = m.entry("invalid", .{});
        \\                k.callVoid(answer, .{});
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "Function answer returns a value; use callRet",
    );
}

test "compile-fail validation rejects return call to void function" {
    try expectCompileFail(
        "return_call_to_void_function",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn emit(m: *ptx.Module) void {
        \\                const helper = m.func("helper", .{});
        \\                helper.ret();
        \\                const k = m.entry("invalid", .{});
        \\                _ = k.callRet(ptx.PtxType.u32, helper, .{});
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "Function helper does not return a value",
    );
}

test "compile-fail validation rejects function argument count mismatch" {
    try expectCompileFail(
        "function_argument_count_mismatch",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn emit(m: *ptx.Module) void {
        \\                const sink = m.func("sink", .{ .x = .u32, .y = .u32 });
        \\                sink.ret();
        \\                const k = m.entry("invalid", .{});
        \\                const x = k.tmp(ptx.PtxType.u32);
        \\                k.callVoid(sink, .{x});
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "Call to sink expects 2 arguments, got 1",
    );
}

test "compile-fail validation rejects return width mismatch" {
    try expectCompileFail(
        "function_return_width_mismatch",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn emit(m: *ptx.Module) void {
        \\                const answer = m.funcRet("answer", ptx.PtxType.u64, .{});
        \\                answer.retVal(1);
        \\                const k = m.entry("invalid", .{});
        \\                _ = k.callRet(ptx.PtxType.u32, answer, .{});
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "Call return width mismatch for answer: expected .u32, got .u64",
    );
}

test "marshalled void function call verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            const sink = m.func("sink_marshalled", .{ .x = .u32, .y = .u64 });
            sink.ret();

            const k = m.entry("call_sink_marshalled", .{});
            const x = k.tmp(PtxType.u32);
            const y = k.tmp(PtxType.u64);
            k.callVoidMarshalled(sink, .{ x, y });
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".param .u32 __param0;") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, ".param .u64 __param1;") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "st.param.u32 [__param0], %r0;") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "st.param.u64 [__param1], %rd0;") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "call.uni sink_marshalled, (__param0, __param1);") != null);
}

test "marshalled function return call verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            const answer = m.funcRet("answer_marshalled", PtxType.u32, .{});
            answer.retVal(42);

            const k = m.entry("use_answer_marshalled", .{});
            const r0 = k.callRetMarshalled(PtxType.u32, answer, .{});
            k.stGlobal(PtxType.u32, "out", r0);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".param .u32 __param0;") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "call.uni (__param0), answer_marshalled, ();") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "ld.param.u32 %r0, [__param0];") != null);
}

test "function named argument loading helper verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            const inc = m.funcRet("inc_arg", PtxType.u32, .{ .x = .u32 });
            const x = inc.ldArg("x");
            const y = inc.add(PtxType.u32, x, 1);
            inc.retVal(y);

            const k = m.entry("use_inc_arg", .{});
            const a = k.tmp(PtxType.u32);
            _ = k.callRetMarshalled(PtxType.u32, inc, .{a});
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".func (.param .u32 __ret) inc_arg(") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, ".param .u32 x") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "ld.param.u32 %r0, [x];") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "add.u32 %r1, %r0, 1;") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "st.param.u32 [__ret], %r1;") != null);
}

test "function tuple argument loading helper verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            const tuple_loader = m.func("tuple_loader", .{ .u32, .u64 });
            _ = tuple_loader.ldArgAt(0);
            _ = tuple_loader.ldArgAt(1);
            tuple_loader.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".param .u32 p0") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, ".param .u64 p1") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "ld.param.u32 %r0, [p0];") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "ld.param.u64 %rd0, [p1];") != null);
}

test "entry named argument loading helper verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            const k = m.entry("entry_args", .{ .A = .b64, .N = .u32 });
            _ = k.ldArg("A");
            _ = k.ldArg("N");
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".entry entry_args") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, ".param .b64 A") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, ".param .u32 N") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "ld.param.b64 %rd0, [A];") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "ld.param.u32 %r0, [N];") != null);
}

test "dynamic shared memory verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            _ = m.externShared("dynamic_scratch", 1024);
            const k = m.entry("use_dynamic", .{});
            k.raw("\tmov.u32 %r0, dynamic_scratch;\n");
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".extern .shared .align 1024 .b8 dynamic_scratch[];") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "mov.u32 %r0, dynamic_scratch;") != null);
}

test "parameter array verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn emit(m: *ptx.Module) void {
            const k = m.entry("array_params", .{});
            const bytes = k.paramBytes("buffer", 64, 64);
            const ints = k.paramArray(PtxType.u32, "table", 8, 4);
            _ = k.ld(.param, PtxType.u32, ints.at(4));
            _ = k.ld(.param, PtxType.b8, bytes.at(7));
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".param .align 64 .b8 buffer[64]") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, ".param .align 4 .u32 table[8]") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "ld.param.u32 %r0, [table+4]") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "ld.param.b8 %b0, [buffer+7]") != null);
}

test "compile-fail validation rejects missing named parameter" {
    try expectCompileFail(
        "missing_named_parameter",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn emit(m: *ptx.Module) void {
        \\                const f = m.func("has_x", .{ .x = .u32 });
        \\                _ = f.ldArg("y");
        \\                f.ret();
        \\            }
        \\        });
        \\
        ,
        "No parameter named y in has_x",
    );
}

test "compile-fail validation rejects parameter index out of bounds" {
    try expectCompileFail(
        "parameter_index_out_of_bounds",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn emit(m: *ptx.Module) void {
        \\                const f = m.func("one_param", .{ .u32 });
        \\                _ = f.ldArgAt(1);
        \\                f.ret();
        \\            }
        \\        });
        \\
        ,
        "Parameter index 1 out of bounds for one_param; parameter count is 1",
    );
}

test "declared param slot helper verification" {
    const ptx = @This();
    const result = comptime ptx.build(.{}, struct {
        pub fn explicit_param_slot(k: *ptx.KernelBuilder) void {
            const slot = k.declParam(PtxType.u32, "slot0");
            const r0 = k.tmp(PtxType.u32);
            k.stParam(slot, r0);
            _ = k.ldParam(slot);
            k.ret();
        }
    });

    try std.testing.expect(std.mem.indexOf(u8, result, ".param .u32 slot0;") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "st.param.u32 [slot0], %r0;") != null);
    try std.testing.expect(std.mem.indexOf(u8, result, "ld.param.u32 %r1, [slot0];") != null);
}

test "compile-fail validation rejects marshalled argument width mismatch" {
    try expectCompileFail(
        "marshalled_argument_width_mismatch",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn emit(m: *ptx.Module) void {
        \\                const sink = m.func("sink", .{ .x = .u64 });
        \\                sink.ret();
        \\                const k = m.entry("invalid", .{});
        \\                const x = k.tmp(ptx.PtxType.u32);
        \\                k.callVoidMarshalled(sink, .{x});
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "Call argument 0 width mismatch for sink: expected .u64, got .u32",
    );
}

test "compile-fail validation rejects marshalled void call to returning function" {
    try expectCompileFail(
        "marshalled_void_call_to_returning_function",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn emit(m: *ptx.Module) void {
        \\                const answer = m.funcRet("answer", ptx.PtxType.u32, .{});
        \\                answer.retVal(1);
        \\                const k = m.entry("invalid", .{});
        \\                k.callVoidMarshalled(answer, .{});
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "Function answer returns a value; use callRetMarshalled",
    );
}

test "compile-fail validation rejects st.param width mismatch" {
    try expectCompileFail(
        "st_param_width_mismatch",
        \\        _ = ptx.build(.{}, struct {
        \\            pub fn invalid(k: *ptx.KernelBuilder) void {
        \\                const slot = k.declParam(ptx.PtxType.u64, "slot0");
        \\                const x = k.tmp(ptx.PtxType.u32);
        \\                k.stParam(slot, x);
        \\                k.ret();
        \\            }
        \\        });
        \\
        ,
        "st.param value width mismatch: expected .u64, got .u32",
    );
}
