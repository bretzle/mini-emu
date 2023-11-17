pub fn multiply(comptime Handler: type, comptime accumulate: bool, comptime set_flags: bool) Handler {
    _ = set_flags;
    _ = accumulate;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm multiply", .{});
        }
    }.impl;
}

pub fn multiplyLong(comptime Handler: type, comptime sign_extend: bool, comptime accumulate: bool, comptime set_flags: bool) Handler {
    _ = sign_extend;
    _ = set_flags;
    _ = accumulate;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm multiplyLong", .{});
        }
    }.impl;
}
