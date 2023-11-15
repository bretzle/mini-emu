pub fn fmt1(comptime Handler: type, comptime op: u2, comptime offset: u5) Handler {
    _ = offset;
    _ = op;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt1", .{});
        }
    }.impl;
}

pub fn fmt5(comptime Handler: type, comptime op: u2, comptime h1: u1, comptime h2: u1) Handler {
    _ = h2;
    _ = h1;
    _ = op;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt5", .{});
        }
    }.impl;
}

pub fn fmt2(comptime Handler: type, comptime I: bool, is_sub: bool, rn: u3) Handler {
    _ = rn;
    _ = is_sub;
    _ = I;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt2", .{});
        }
    }.impl;
}

pub fn fmt3(comptime Handler: type, comptime op: u2, comptime rd: u3) Handler {
    _ = rd;
    _ = op;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt3", .{});
        }
    }.impl;
}

pub fn fmt12(comptime Handler: type, comptime isSP: bool, comptime rd: u3) Handler {
    _ = rd;
    _ = isSP;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt12", .{});
        }
    }.impl;
}

pub fn fmt13(comptime Handler: type, comptime S: bool) Handler {
    _ = S;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb fmt13", .{});
        }
    }.impl;
}

pub fn bkpt(comptime Handler: type) Handler {
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u16) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: thumb bkpt", .{});
        }
    }.impl;
}
