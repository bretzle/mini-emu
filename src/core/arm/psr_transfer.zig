pub fn control(comptime Handler: type, comptime I: bool, comptime op: u6) Handler {
    _ = op;
    _ = I;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm control", .{});
        }
    }.impl;
}
