const std = @import("std");
const Arm7tdmi = @import("../core.zig").Arm7tdmi;

const processing = @import("arm/data_processing.zig").dataProcessing;
const transfer = @import("arm/single_data_transfer.zig").singleDataTransfer;
const blockTransfer = @import("arm/block_data_transfer.zig").blockDataTransfer;
const branch = @import("arm/branch.zig").branch;
const branchExchange = @import("arm/branch.zig").branchAndExchange;
const swi = @import("arm/software_interrupt.zig").softwareInterrupt;
const loadStoreExt = @import("arm/half_signed_data_transfer.zig").halfAndSignedDataTransfer;
const controlExt = @import("arm/psr_transfer.zig").control;
const multiplyExt = @import("arm/multiply.zig").multiply;

pub const Handler = *const fn (*Arm7tdmi, u32) void;
pub const lut = generate();

pub fn idx(opcode: u32) u12 {
    return @as(u12, @truncate(opcode >> 20 & 0xFF)) << 4 | @as(u12, @truncate(opcode >> 4 & 0xF));
}

fn generate() [0x1000]Handler {
    return comptime cblk: {
        @setEvalBranchQuota(7169);
        var table = [_]Handler{und} ** 0x1000;

        for (&table, 0..) |*handler, i| {
            handler.* = switch (@as(u2, i >> 10)) {
                0b00 => if (i == 0x121) blk: { // 12 bits
                    break :blk branchExchange(Handler);
                } else if (i & 0xF0F == 0x009) blk: { // 8 bits
                    const L = i >> 7 & 1 == 1;
                    const U = i >> 6 & 1 == 1;
                    const A = i >> 5 & 1 == 1;
                    const S = i >> 4 & 1 == 1;
                    break :blk multiplyExt(Handler, L, U, A, S);
                } else if (i & 0xE49 == 0x009 or i & 0xE49 == 0x049) blk: { // 6 bits
                    const P = i >> 8 & 1 == 1;
                    const U = i >> 7 & 1 == 1;
                    const I = i >> 6 & 1 == 1;
                    const W = i >> 5 & 1 == 1;
                    const L = i >> 4 & 1 == 1;
                    break :blk loadStoreExt(Handler, P, U, I, W, L);
                } else if (i & 0xD90 == 0x100) blk: { // 5 bits
                    const I = i >> 9 & 1 == 1;
                    const op = ((i >> 5) & 0x3) << 4 | (i & 0xF);
                    break :blk controlExt(Handler, I, op);
                } else blk: {
                    const I = i >> 9 & 1 == 1;
                    const S = i >> 4 & 1 == 1;
                    const instr_kind = i >> 5 & 0xF;
                    break :blk processing(Handler, I, S, instr_kind);
                },
                0b01 => if (i >> 9 & 1 == 1 and i & 1 == 1) und else blk: {
                    const I = i >> 9 & 1 == 1;
                    const P = i >> 8 & 1 == 1;
                    const U = i >> 7 & 1 == 1;
                    const B = i >> 6 & 1 == 1;
                    const W = i >> 5 & 1 == 1;
                    const L = i >> 4 & 1 == 1;
                    break :blk transfer(Handler, I, P, U, B, W, L);
                },
                else => switch (@as(u2, i >> 9 & 0x3)) {
                    // MSB is guaranteed to be 1
                    0b00 => blk: {
                        const P = i >> 8 & 1 == 1;
                        const U = i >> 7 & 1 == 1;
                        const S = i >> 6 & 1 == 1;
                        const W = i >> 5 & 1 == 1;
                        const L = i >> 4 & 1 == 1;
                        break :blk blockTransfer(Handler, P, U, S, W, L);
                    },
                    0b01 => blk: {
                        const L = i >> 8 & 1 == 1;
                        break :blk branch(Handler, L);
                    },
                    0b10 => und, // COP Data Transfer
                    0b11 => if (i >> 8 & 1 == 1) swi(Handler) else und, // COP Data Operation + Register Transfer
                },
            };
        }

        break :cblk table;
    };
}

fn und(cpu: *Arm7tdmi, opcode: u32) void {
    const id = idx(opcode);
    cpu.panic("[CPU/Decode] ID: 0x{X:0>3} 0x{X:0>8} is an illegal opcode", .{ id, opcode });
}
