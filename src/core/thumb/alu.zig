pub fn fmt4(comptime Handler: type, comptime op: u4) Handler {
    _ = op;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt4", .{});
        }
    }.impl;
}
