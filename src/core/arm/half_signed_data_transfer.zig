pub fn halfAndSignedDataTransfer(comptime Handler: type, comptime P: bool, comptime U: bool, comptime I: bool, comptime W: bool, comptime L: bool) Handler {
    _ = L;
    _ = W;
    _ = I;
    _ = U;
    _ = P;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm halfAndSignedDataTransfer", .{});
        }
    }.impl;
}
