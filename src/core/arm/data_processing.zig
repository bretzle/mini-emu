pub const DataOp = enum(u4) {
    AND = 0,
    EOR = 1,
    SUB = 2,
    RSB = 3,
    ADD = 4,
    ADC = 5,
    SBC = 6,
    RSC = 7,
    TST = 8,
    TEQ = 9,
    CMP = 10,
    CMN = 11,
    ORR = 12,
    MOV = 13,
    BIC = 14,
    MVN = 15,
};

pub fn dataProcessing(comptime Handler: type, comptime immediate: bool, comptime op: DataOp, comptime set_flags: bool, comptime field4: u4) Handler {
    _ = field4;
    _ = set_flags;
    _ = op;
    _ = immediate;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm dataProcessing", .{});
        }
    }.impl;
}
