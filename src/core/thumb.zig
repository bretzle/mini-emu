const std = @import("std");
const Arm7tdmi = @import("../core.zig").Arm7tdmi;

const processing = @import("thumb/data_processing.zig");
const alu = @import("thumb/alu.zig").fmt4;
const transfer = @import("thumb/data_transfer.zig");
const block_transfer = @import("thumb/block_data_transfer.zig");
const swi = @import("thumb/software_interrupt.zig").fmt17;
const branch = @import("thumb/branch.zig");

pub const Handler = *const fn (*Arm7tdmi, u16) void;
pub const lut = generate();

pub fn idx(opcode: u16) u10 {
    return @truncate(opcode >> 6);
}

fn generate() [0x400]Handler {
    return comptime cblk: {
        @setEvalBranchQuota(5025);
        var table = [_]Handler{und} ** 0x400;

        for (&table, 0..) |*handler, i| {
            handler.* = switch (@as(u3, i >> 7 & 0x7)) {
                0b000 => if (i >> 5 & 0x3 == 0b11) blk: {
                    const I = i >> 4 & 1 == 1;
                    const is_sub = i >> 3 & 1 == 1;
                    const rn = i & 0x7;
                    break :blk processing.fmt2(Handler, I, is_sub, rn);
                } else blk: {
                    const op = i >> 5 & 0x3;
                    const offset = i & 0x1F;
                    break :blk processing.fmt1(Handler, op, offset);
                },
                0b001 => blk: {
                    const op = i >> 5 & 0x3;
                    const rd = i >> 2 & 0x7;
                    break :blk processing.fmt3(Handler, op, rd);
                },
                0b010 => switch (@as(u2, i >> 5 & 0x3)) {
                    0b00 => if (i >> 4 & 1 == 1) blk: {
                        const op = i >> 2 & 0x3;
                        const h1 = i >> 1 & 1;
                        const h2 = i & 1;
                        break :blk processing.fmt5(Handler, op, h1, h2);
                    } else blk: {
                        const op = i & 0xF;
                        break :blk alu(Handler, op);
                    },
                    0b01 => blk: {
                        const rd = i >> 2 & 0x7;
                        break :blk transfer.fmt6(Handler, rd);
                    },
                    else => blk: {
                        const op = i >> 4 & 0x3;
                        const T = i >> 3 & 1 == 1;
                        break :blk transfer.fmt78(Handler, op, T);
                    },
                },
                0b011 => blk: {
                    const B = i >> 6 & 1 == 1;
                    const L = i >> 5 & 1 == 1;
                    const offset = i & 0x1F;
                    break :blk transfer.fmt9(Handler, B, L, offset);
                },
                else => switch (@as(u3, i >> 6 & 0x7)) {
                    // MSB is guaranteed to be 1
                    0b000 => blk: {
                        const L = i >> 5 & 1 == 1;
                        const offset = i & 0x1F;
                        break :blk transfer.fmt10(Handler, L, offset);
                    },
                    0b001 => blk: {
                        const L = i >> 5 & 1 == 1;
                        const rd = i >> 2 & 0x7;
                        break :blk transfer.fmt11(Handler, L, rd);
                    },
                    0b010 => blk: {
                        const isSP = i >> 5 & 1 == 1;
                        const rd = i >> 2 & 0x7;
                        break :blk processing.fmt12(Handler, isSP, rd);
                    },
                    0b011 => if (i >> 4 & 1 == 1) blk: {
                        const L = i >> 5 & 1 == 1;
                        const R = i >> 2 & 1 == 1;
                        break :blk block_transfer.fmt14(Handler, L, R);
                    } else blk: {
                        const S = i >> 1 & 1 == 1;
                        break :blk processing.fmt13(Handler, S);
                    },
                    0b100 => blk: {
                        const L = i >> 5 & 1 == 1;
                        const rb = i >> 2 & 0x7;

                        break :blk block_transfer.fmt15(Handler, L, rb);
                    },
                    0b101 => if (i >> 2 & 0xF == 0b1111) blk: {
                        break :blk swi(Handler);
                    } else blk: {
                        const cond = i >> 2 & 0xF;
                        break :blk branch.fmt16(Handler, cond);
                    },
                    0b110, 0b111 => blk: {
                        const H = i >> 5 & 0x3;
                        break :blk branch.linkExchange(Handler, H);
                    },
                },
            };
        }

        break :cblk table;
    };
}

fn und(cpu: *Arm7tdmi, opcode: u16) void {
    const id = idx(opcode);
    cpu.panic("[CPU/Decode] ID: 0x{X:0>3} 0x{X:0>4} is an illegal opcode", .{ id, opcode });
}
