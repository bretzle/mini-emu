pub fn dataProcessing(comptime Handler: type, comptime I: bool, comptime S: bool, comptime kind: u4) Handler {
    _ = kind;
    _ = S;
    _ = I;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm dataProcessing", .{});
        }
    }.impl;
}
