pub fn singleDataTransfer(comptime Handler: type, comptime I: bool, comptime P: bool, comptime U: bool, comptime B: bool, comptime W: bool, comptime L: bool) Handler {
    _ = L;
    _ = W;
    _ = B;
    _ = U;
    _ = P;
    _ = I;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm singleDataTransfer", .{});
        }
    }.impl;
}
