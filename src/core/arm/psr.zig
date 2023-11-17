pub fn statusTransfer(comptime Handler: type, comptime immediate: bool, comptime use_spsr: bool, comptime to_status: bool) Handler {
    _ = to_status;
    _ = use_spsr;
    _ = immediate;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm statusTransfer", .{});
        }
    }.impl;
}
