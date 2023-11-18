const helpers = @import("../helpers.zig");

const sext = helpers.sext;

pub fn branch(comptime Handler: type, comptime L: bool) Handler {
    _ = L;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm branch", .{});
        }
    }.impl;
}

pub fn branchAndExchange(comptime Handler: type) Handler {
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm branchAndExchange", .{});
        }
    }.impl;
}

pub fn branchAndLink(comptime Handler: type, comptime link: bool) Handler {
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            var offset = opcode & 0xFFFFFF;

            if (offset & 0x800000 != 0) {
                offset |= 0xFF000000;
            }

            if (link) cpu.regs[14] = cpu.regs[15] - 4;
            cpu.regs[15] +%= offset *% 4;
            cpu.pipe.reload(cpu);
        }
    }.impl;
}
