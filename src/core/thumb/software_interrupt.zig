pub fn fmt17(comptime Handler: type) Handler {
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: fmt17", .{});
        }
    }.impl;
}
