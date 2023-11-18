const std = @import("std");
const Arm7tdmi = @import("../core.zig").Arm7tdmi;

const transfer = @import("arm/transfer.zig");
const branch = @import("arm/branch.zig");
const mult = @import("arm/multiply.zig");
const swi = @import("arm/software_interrupt.zig").softwareInterrupt;
const dataProcessing = @import("arm/data_processing.zig").dataProcessing;
const statusTransfer = @import("arm/psr.zig").statusTransfer;

pub const Handler = *const fn (*Arm7tdmi, u32) void;
pub const lut = generate();

pub fn idx(opcode: u32) u12 {
    return @truncate(((opcode >> 16) & 0xFF0) | ((opcode >> 4) & 0xF));
}

fn generate() [0x1000]Handler {
    return comptime cblk: {
        @setEvalBranchQuota(10000);
        var table = [_]Handler{und} ** 0x1000;

        for (&table, 0..) |*handler, i| {
            const instruction = ((i & 0xFF0) << 16) | ((i & 0xF) << 4);
            const opcode = instruction & 0x0FFFFFFF;

            const pre = instruction & (1 << 24) != 0;
            const add = instruction & (1 << 23) != 0;
            const wb = instruction & (1 << 21) != 0;
            const load = instruction & (1 << 20) != 0;

            handler.* = switch (@as(u2, opcode >> 26)) {
                0b00 => blk: {
                    if (opcode & (1 << 25) != 0) {
                        // ARM.8 Data processing and PSR transfer ... immediate
                        const set_flags = instruction & (1 << 20) != 0;
                        const op = (instruction >> 21) & 0xF;

                        if (!set_flags and op >= 0b1000 and op <= 0b1011) {
                            const use_spsr = instruction & (1 << 22) != 0;
                            const to_status = instruction & (1 << 21) != 0;
                            break :blk statusTransfer(Handler, true, use_spsr, to_status);
                        } else {
                            const field4 = (instruction >> 4) & 0xF;
                            break :blk dataProcessing(Handler, true, @enumFromInt(op), set_flags, field4);
                        }
                    } else if ((opcode & 0xFF000F0) == 0x1200010) {
                        // ARM.3 Branch and exchange
                        // TODO: Some bad instructions might be falsely detected as BX.
                        // How does HW handle this?
                        break :blk branch.branchAndExchange(Handler);
                    } else if ((opcode & 0x10000F0) == 0x0000090) {
                        // ARM.1 Multiply (accumulate), ARM.2 Multiply (accumulate) long
                        const accumulate = instruction & (1 << 21) != 0;
                        const set_flags = instruction & (1 << 20) != 0;

                        if (opcode & (1 << 23) != 0) {
                            const sign_extend = instruction & (1 << 22) != 0;
                            break :blk mult.multiplyLong(Handler, sign_extend, accumulate, set_flags);
                        } else {
                            break :blk mult.multiply(Handler, accumulate, set_flags);
                        }
                    } else if ((opcode & 0x10000F0) == 0x1000090) {
                        // ARM.4 Single data swap
                        const byte = instruction & (1 << 22) != 0;
                        break :blk transfer.singleDataSwap(Handler, byte);
                    } else if ((opcode & 0xF0) == 0xB0 or (opcode & 0xD0) == 0xD0) {
                        // ARM.5 Halfword data transfer, register offset
                        // ARM.6 Halfword data transfer, immediate offset
                        // ARM.7 Signed data transfer (byte/halfword)
                        const immediate = instruction & (1 << 22) != 0;
                        const op: u2 = @truncate(instruction >> 5);
                        break :blk transfer.halfwordSignedTransfer(Handler, pre, add, immediate, wb, load, op);
                    } else {
                        // ARM.8 Data processing and PSR transfer
                        const set_flags = instruction & (1 << 20) != 0;
                        const op = (instruction >> 21) & 0xF;

                        if (!set_flags and op >= 0b1000 and op <= 0b1011) {
                            const use_spsr = instruction & (1 << 22) != 0;
                            const to_status = instruction & (1 << 21) != 0;
                            break :blk statusTransfer(Handler, false, use_spsr, to_status);
                        } else {
                            const field4 = (instruction >> 4) & 0xF;
                            break :blk dataProcessing(Handler, false, @enumFromInt(op), set_flags, field4);
                        }
                    }
                },
                0b01 => blk: {
                    // ARM.9 Single data transfer, ARM.10 Undefined
                    if ((opcode & 0x2000010) == 0x2000010) {
                        break :blk und;
                    } else {
                        const immediate = ~instruction & (1 << 25) != 0;
                        const byte = instruction & (1 << 22) != 0;
                        break :blk transfer.singleDataTransfer(Handler, immediate, pre, add, byte, wb, load);
                    }
                },
                0b10 => blk: {
                    // ARM.11 Block data transfer, ARM.12 Branch
                    if (opcode & (1 << 25) != 0) {
                        break :blk branch.branchAndLink(Handler, (opcode >> 24) & 1 != 0);
                    } else {
                        const user_mode = instruction & (1 << 22) != 0;
                        break :blk transfer.blockDataTransfer(Handler, pre, add, user_mode, wb, load);
                    }
                },
                0b11 => blk: {
                    if (opcode & (1 << 25) != 0) {
                        if (opcode & (1 << 24) != 0) {
                            // ARM.16 Software interrupt
                            break :blk swi(Handler);
                        } else {
                            // ARM.14 Coprocessor data operation
                            // ARM.15 Coprocessor register transfer
                            break :blk und;
                        }
                    } else {
                        // ARM.13 Coprocessor data transfer
                        break :blk und;
                    }
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
