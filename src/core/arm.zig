const std = @import("std");
const Arm7tdmi = @import("../core.zig").Arm7tdmi;

pub const InstrFn = *const fn (*Arm7tdmi, u32) void;
pub const lut = generate();

pub fn idx(opcode: u32) u12 {
    return @as(u12, @truncate(opcode >> 20 & 0xFF)) << 4 | @as(u12, @truncate(opcode >> 4 & 0xF));
}

fn generate() [0x1000]InstrFn {
    return comptime cblk: {
        var table = [_]InstrFn{und} ** 0x1000;

        break :cblk table;
    };
}

fn und(cpu: *Arm7tdmi, opcode: u32) void {
    const id = idx(opcode);
    cpu.panic("[CPU/Decode] ID: 0x{X:0>3} 0x{X:0>8} is an illegal opcode", .{ id, opcode });
}
