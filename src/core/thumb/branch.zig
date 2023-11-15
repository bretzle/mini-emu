pub fn fmt16(comptime Handler: type, comptime cond: u4) Handler {
    _ = cond;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt16", .{});
        }
    }.impl;
}


pub fn linkExchange(comptime Handler: type, comptime H: u2) Handler {
    _ = H;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb linkExchange", .{});
        }
    }.impl;
}
