const helpers = @import("../helpers.zig");

const sext = helpers.sext;

pub fn branch(comptime Handler: type, comptime L: bool) Handler {
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            const cond: u4 = @truncate(opcode >> 28);
            switch (cond) {
                // blx
                0xF => {
                    const offset = sext(u32, u24, opcode) << 2 | @as(u32, @intFromBool(L)) << 1;
                    cpu.regs[14] = cpu.regs[15] - 4;
                    cpu.cpsr.thumb = true;
                    cpu.regs[15] +%= offset;
                },
                else => {
                    if (L) cpu.regs[14] = cpu.regs[15] - 4;
                    cpu.regs[15] +%= sext(u32, u24, opcode);
                },
            }
            cpu.pipe.reload(cpu);
        }
    }.impl;
}

pub fn branchAndExchange(comptime Handler: type) Handler {
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            const rn = opcode & 0xF;
            const thumb = cpu.regs[rn] & 1 == 1;
            
            cpu.regs[15] = cpu.regs[rn] & ~@as(u32, if (thumb) 1 else 3);
            cpu.cpsr.thumb = thumb;
            cpu.pipe.reload(cpu);
        }
    }.impl;
}
