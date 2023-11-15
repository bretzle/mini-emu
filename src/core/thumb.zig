const std = @import("std");
const Arm7tdmi = @import("../core.zig").Arm7tdmi;

pub const InstrFn = *const fn (*Arm7tdmi, u16) void;
pub const lut = generate();

pub fn idx(opcode: u16) u10 {
    return @truncate(opcode >> 6);
}

fn generate() [0x400]InstrFn {
    return comptime cblk: {
        var table = [_]InstrFn{und} ** 0x400;

        break :cblk table;
    };
}

fn und(_: *Arm7tdmi, _: u16) void {
    @panic("do something more useful");
}
