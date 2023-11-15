pub fn fmt14(comptime Handler: type, comptime L: bool, comptime R: bool) Handler {
    _ = R;
    _ = L;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt14", .{});
        }
    }.impl;
}

pub fn fmt15(comptime Handler: type, comptime L: bool, comptime rb: u3) Handler {
    _ = rb;
    _ = L;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt15", .{});
        }
    }.impl;
}
