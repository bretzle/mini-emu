pub fn singleDataSwap(comptime Handler: type, comptime byte: bool) Handler {
    _ = byte;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm singleDataSwap", .{});
        }
    }.impl;
}

pub fn halfwordSignedTransfer(comptime Handler: type, comptime pre: bool, comptime add: bool, comptime immediate: bool, comptime writeback: bool, comptime load: bool, comptime op: u4) Handler {
    _ = op;
    _ = load;
    _ = writeback;
    _ = immediate;
    _ = add;
    _ = pre;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm halfwordSignedTransfer", .{});
        }
    }.impl;
}

pub fn singleDataTransfer(comptime Handler: type, comptime immediate: bool, comptime pre: bool, comptime add: bool, comptime byte: bool, comptime writeback: bool, comptime load: bool) Handler {
    _ = load;
    _ = writeback;
    _ = byte;
    _ = add;
    _ = pre;
    _ = immediate;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm singleDataTransfer", .{});
        }
    }.impl;
}

pub fn blockDataTransfer(comptime Handler: type, comptime pre: bool, comptime add: bool, comptime user_mode: bool, comptime writeback: bool, comptime load: bool) Handler {
    _ = load;
    _ = writeback;
    _ = user_mode;
    _ = add;
    _ = pre;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm blockDataTransfer", .{});
        }
    }.impl;
}
