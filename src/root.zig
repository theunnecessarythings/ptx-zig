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
};

pub const Version = struct {
    major: u32,
    minor: u32,

    pub const v8_3 = Version{ .major = 8, .minor = 3 };
    pub const v8_4 = Version{ .major = 8, .minor = 4 };
    pub const v8_5 = Version{ .major = 8, .minor = 5 };
    pub const v9_0 = Version{ .major = 9, .minor = 0 };
    pub const v9_3 = Version{ .major = 9, .minor = 3 };
};

pub const ParamHandle = struct {
    name: []const u8,
    ty: PtxType,
};

pub fn ParamsResult(comptime T: type) type {
    const info = @typeInfo(T);
    if (info != .@"struct" or info.@"struct".is_tuple) return void;
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
                return std.fmt.comptimePrint("%{s}", .{op.name});
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

// --- Kernel Builder ---

pub const KernelBuilder = struct {
    name: []const u8 = "",
    params_text: []const u8 = "",
    counts: struct {
        pred: u32 = 0,
        b8: u32 = 0,
        b16: u32 = 0,
        b32: u32 = 0,
        b64: u32 = 0,
        b128: u32 = 0,
        u8: u32 = 0,
        u16: u32 = 0,
        u32: u32 = 0,
        u64: u32 = 0,
        s8: u32 = 0,
        s16: u32 = 0,
        s32: u32 = 0,
        s64: u32 = 0,
        f16: u32 = 0,
        f32: u32 = 0,
        f64: u32 = 0,
        f16x2: u32 = 0,
        bf16: u32 = 0,
        bf16x2: u32 = 0,
        tf32: u32 = 0,
        e4m3: u32 = 0,
        e5m2: u32 = 0,
        u16x2: u32 = 0,
        u8x4: u32 = 0,
        s16x2: u32 = 0,
        s8x4: u32 = 0,
    } = .{},
    body: []const u8 = "",

    pub fn params(comptime self: *KernelBuilder, comptime ps: anytype) ParamsResult(@TypeOf(ps)) {
        const T = @TypeOf(ps);
        const info = @typeInfo(T);
        if (info.@"struct".is_tuple) {
            inline for (ps, 0..) |p, i| {
                if (i > 0 or self.params_text.len > 0) self.params_text = self.params_text ++ ",\n";
                self.params_text = self.params_text ++ "\t.param " ++ p;
            }
            return {};
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
        self.raw("\t" ++ s ++ "\n");
    }

    pub fn tmp(comptime self: *KernelBuilder, comptime ty: PtxType) Reg(ty) {
        const id = @field(self.counts, @tagName(ty.scalar));
        @field(self.counts, @tagName(ty.scalar)) += @intFromEnum(ty.vec);
        return .{ .data = .{ .id = id } };
    }

    pub fn named(comptime _: *KernelBuilder, comptime ty: PtxType, comptime name: []const u8) Reg(ty) {
        return .{ .data = .{ .name = name } };
    }

    pub fn declReg(comptime self: *KernelBuilder, comptime ty: PtxType, comptime name: []const u8) Reg(ty) {
        self.line(".reg " ++ ty.suffix() ++ " %" ++ name ++ ";");
        return .{ .data = .{ .name = name } };
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
        self.line(std.fmt.comptimePrint("mul{s} {s}, {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
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
        self.line(std.fmt.comptimePrint("shl.b32 {s}, {s}, {s};", .{ fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
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
    pub fn cvt(comptime self: *KernelBuilder, comptime dst_ty: PtxType, comptime src_ty: PtxType, a: anytype) Reg(dst_ty) {
        validate(.cvt, dst_ty);
        const dst = self.tmp(dst_ty);
        self.line(std.fmt.comptimePrint("cvt{s}{s} {s}, {s};", .{ dst_ty.suffix(), src_ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn cvta(comptime self: *KernelBuilder, comptime dir: CvtDirection, comptime space: StateSpace, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.cvta, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("cvta{s}{s}{s} {s}, {s};", .{ dir.suffix(), space.suffix(), ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn ld(comptime self: *KernelBuilder, comptime space: StateSpace, comptime ty: PtxType, a: anytype) Reg(ty) {
        validate(.ld, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("ld{s}{s} {s}, [{s}];", .{ space.suffix(), ty.suffix(), fmtOp(dst), fmtOp(a) }));
        return dst;
    }
    pub fn st(comptime self: *KernelBuilder, comptime space: StateSpace, comptime ty: PtxType, a: anytype, b: anytype) void {
        validate(.st, ty);
        self.line(std.fmt.comptimePrint("st{s}{s} [{s}], {s};", .{ space.suffix(), ty.suffix(), fmtOp(a), fmtOp(b) }));
    }
    pub fn ldParam(comptime self: *KernelBuilder, p: ParamHandle) Reg(p.ty) {
        const dst = self.tmp(p.ty);
        self.line(std.fmt.comptimePrint("ld.param{s} {s}, [{s}];", .{ p.ty.suffix(), fmtOp(dst), fmtOp(p) }));
        return dst;
    }
    pub fn stGlobal(comptime self: *KernelBuilder, comptime ty: PtxType, name: []const u8, val: anytype) void {
        self.line(std.fmt.comptimePrint("st.global{s} [%{s}], {s};", .{ ty.suffix(), name, fmtOp(val) }));
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
        self.line(std.fmt.comptimePrint("barrier.cluster{s};", .{op.suffix()}));
    }
    pub fn grpbarrier(comptime self: *KernelBuilder) void {
        self.line("grpbarrier.cluster;");
    }
    pub fn membar(comptime self: *KernelBuilder, comptime level: Scope) void {
        self.line(std.fmt.comptimePrint("membar{s};", .{level.suffix()}));
    }
    pub fn cp_async(comptime self: *KernelBuilder, dst: anytype, src: anytype, size: anytype) void {
        self.line(std.fmt.comptimePrint("cp.async.ca.shared.global [{s}], [{s}], {s};", .{ fmtOp(dst), fmtOp(src), fmtOp(size) }));
    }
    pub fn discard(comptime self: *KernelBuilder, addr: anytype, size: anytype) void {
        self.line(std.fmt.comptimePrint("discard.global.b64 [{s}], {s};", .{ fmtOp(addr), fmtOp(size) }));
    }
    pub fn bra(comptime self: *KernelBuilder, comptime label: []const u8) void {
        self.line("bra " ++ label ++ ";");
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
        validate(.atom, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("atom{s}{s}{s} {s}, [{s}], {s};", .{ space.suffix(), op.suffix(), ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b) }));
        return dst;
    }
    pub fn red(comptime self: *KernelBuilder, comptime op: AtomOp, comptime space: StateSpace, comptime ty: PtxType, a: anytype, b: anytype) void {
        validate(.red, ty);
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
        self.line(std.fmt.comptimePrint("tcgen05{s}.shared::cluster.b64 [{s}], {s};", .{ op.suffix(), fmtOp(addr_op), fmtOp(size) }));
    }
    pub fn mma(comptime self: *KernelBuilder, comptime shape: MmaShape, comptime layout: MmaLayout, comptime d_ty: PtxType, comptime a_ty: PtxType, comptime b_ty: PtxType, comptime c_ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(d_ty) {
        validate(.mma, d_ty);
        const dst = self.tmp(d_ty);
        self.line(std.fmt.comptimePrint("mma.sync.aligned{s}{s}{s}{s}{s}{s} {s}, {s}, {s}, {s};", .{ shape.suffix(), layout.suffix(), d_ty.suffix(), a_ty.suffix(), b_ty.suffix(), c_ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn wgmma_mma_async(comptime self: *KernelBuilder, comptime shape: MmaShape, comptime layout: MmaLayout, comptime d_ty: PtxType, comptime a_ty: PtxType, comptime b_ty: PtxType, comptime c_ty: PtxType, a: anytype, b: anytype, c: anytype) Reg(d_ty) {
        validate(.wgmma_mma_async, d_ty);
        const dst = self.tmp(d_ty);
        self.line(std.fmt.comptimePrint("wgmma.mma_async.sync.aligned{s}{s}{s}{s}{s}{s} {s}, {s}, {s}, {s};", .{ shape.suffix(), layout.suffix(), d_ty.suffix(), a_ty.suffix(), b_ty.suffix(), c_ty.suffix(), fmtOp(dst), fmtOp(a), fmtOp(b), fmtOp(c) }));
        return dst;
    }
    pub fn pmevent(comptime self: *KernelBuilder, a: anytype) void {
        validate(.pmevent, ScalarType.u32);
        self.line(std.fmt.comptimePrint("pmevent {s};", .{fmtOp(a)}));
    }
    pub fn ldu(comptime self: *KernelBuilder, comptime ty: PtxType, addr_op: anytype) Reg(ty) {
        validate(.ldu, ty);
        const dst = self.tmp(ty);
        self.line(std.fmt.comptimePrint("ldu.global{s} {s}, {s};", .{ ty.suffix(), fmtOp(dst), fmtOp(addr_op) }));
        return dst;
    }
    pub fn prefetch(comptime self: *KernelBuilder, comptime level: CacheLevel, addr_op: anytype) void {
        self.line(std.fmt.comptimePrint("prefetch.global{s} {s};", .{ level.suffix(), fmtOp(addr_op) }));
    }
    pub fn prefetchu(comptime self: *KernelBuilder, comptime level: CacheLevel, addr_op: anytype) void {
        self.line(std.fmt.comptimePrint("prefetchu{s} {s};", .{ level.suffix(), fmtOp(addr_op) }));
    }
    pub fn isspacep(comptime self: *KernelBuilder, comptime space: StateSpace, a: anytype) Reg(PtxType.pred) {
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
        self.line(std.fmt.comptimePrint("cp.async.bulk.shared::cluster.global.mbarrier::complete_tx::flag [{s}], [{s}], {s}, [{s}];", .{ fmtOp(dst), fmtOp(src), fmtOp(size), fmtOp(flag) }));
    }
    pub fn mbarrier(comptime self: *KernelBuilder, comptime op: MbarrierOp, addr_op: anytype) void {
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
        res = res ++ ".visible .entry " ++ self.name ++ "(\n";
        if (self.params_text.len > 0) res = res ++ self.params_text ++ "\n";
        res = res ++ ") {\n";
        inline for (std.meta.fields(@TypeOf(self.counts))) |field| {
            const count = @field(self.counts, field.name);
            if (count > 0) {
                const s_ty = @field(ScalarType, field.name);
                res = res ++ std.fmt.comptimePrint("\t.reg {s} {s}<{d}>;\n", .{ s_ty.suffix(), s_ty.prefix(), count });
            }
        }
        res = res ++ self.body;
        res = res ++ "}\n";
        return res;
    }
};

// --- Module Orchestration ---

pub const ModuleOptions = struct {
    version: Version = .v9_3,
    target: Target = .sm_90,
    address_size: u32 = 64,
};

pub const Module = struct {
    options: ModuleOptions,
    kernels: [32]KernelBuilder = undefined,
    kernel_count: usize = 0,

    pub fn entry(comptime self: *Module, comptime name: []const u8, comptime ps: anytype) *KernelBuilder {
        const k = &self.kernels[self.kernel_count];
        k.* = .{ .name = name };
        k.params(ps);
        self.kernel_count += 1;
        return k;
    }

    pub fn generate(comptime self: *Module) []const u8 {
        var res: []const u8 = "";
        res = res ++ std.fmt.comptimePrint(".version {d}.{d}\n", .{ self.options.version.major, self.options.version.minor });
        res = res ++ ".target " ++ @tagName(self.options.target) ++ "\n";
        res = res ++ std.fmt.comptimePrint(".address_size {d}\n\n", .{self.options.address_size});
        inline for (self.kernels[0..self.kernel_count]) |*k| res = res ++ k.generate() ++ "\n";
        return res;
    }
};

pub fn build(comptime opt: ModuleOptions, comptime definition: anytype) []const u8 {
    comptime var m = Module{ .options = opt };
    const T = @TypeOf(definition);
    if (T == type) {
        if (@hasDecl(definition, "emit")) {
            definition.emit(&m);
        } else {
            inline for (std.meta.declarations(definition)) |decl| {
                const item = @field(definition, decl.name);
                if (@typeInfo(@TypeOf(item)) == .@"fn") {
                    const k = m.entry(decl.name, .{});
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
