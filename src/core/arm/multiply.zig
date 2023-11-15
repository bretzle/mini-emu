pub fn multiply(comptime Handler: type, comptime L: bool, comptime U: bool, comptime A: bool, comptime S: bool) Handler {
    _ = S;
    _ = A;
    _ = U;
    _ = L;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm multiply", .{});
        }
    }.impl;
}
