pub fn fmt6(comptime Handler: type, comptime rd: u3) Handler {
    _ = rd;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt6", .{});
        }
    }.impl;
}

pub fn fmt78(comptime Handler: type, comptime op: u2, comptime T: bool) Handler {
    _ = T;
    _ = op;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt78", .{});
        }
    }.impl;
}

pub fn fmt9(comptime Handler: type, comptime B: bool, comptime L: bool, comptime offset: u5) Handler {
    _ = offset;
    _ = L;
    _ = B;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt9", .{});
        }
    }.impl;
}

pub fn fmt10(comptime Handler: type, comptime L: bool, comptime offset: u5) Handler {
    _ = offset;
    _ = L;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt10", .{});
        }
    }.impl;
}

pub fn fmt11(comptime Handler: type, comptime L: bool, comptime rd: u3) Handler {
    _ = rd;
    _ = L;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt11", .{});
        }
    }.impl;
}
