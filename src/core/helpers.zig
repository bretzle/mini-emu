const std = @import("std");
const StatusReg = @import("../core.zig").StatusReg;

pub const rotr = std.math.rotr;

pub fn sext(comptime T: type, comptime U: type, val: anytype) T {
    comptime std.debug.assert(@typeInfo(U).Int.bits <= @typeInfo(T).Int.bits);

    const iT = std.meta.Int(.signed, @typeInfo(T).Int.bits);
    const ExtU = if (@typeInfo(U).Int.signedness == .unsigned) T else iT;
    const shift_amt: std.math.Log2Int(T) = @intCast(@typeInfo(T).Int.bits - @typeInfo(U).Int.bits);

    return @bitCast(@as(iT, @bitCast(@as(ExtU, @as(U, @truncate(val))) << shift_amt)) >> shift_amt);
}

/// vvv barrel shifter vvv
pub fn exec(comptime S: bool, cpu: anytype, opcode: u32) u32 {
    var result: u32 = undefined;
    if (opcode >> 4 & 1 == 1) {
        result = register(S, cpu, opcode);
    } else {
        result = immediate(S, cpu, opcode);
    }

    return result;
}

fn register(comptime S: bool, cpu: anytype, opcode: u32) u32 {
    const rs_idx = opcode >> 8 & 0xF;
    const rm = cpu.regs[opcode & 0xF];
    const rs: u8 = @truncate(cpu.regs[rs_idx]);

    return switch (@as(u2, @truncate(opcode >> 5))) {
        0b00 => lsl(S, &cpu.cpsr, rm, rs),
        0b01 => lsr(S, &cpu.cpsr, rm, rs),
        0b10 => asr(S, &cpu.cpsr, rm, rs),
        0b11 => ror(S, &cpu.cpsr, rm, rs),
    };
}

pub fn immediate(comptime S: bool, cpu: anytype, opcode: u32) u32 {
    const amount: u8 = @truncate(opcode >> 7 & 0x1F);
    const rm = cpu.regs[opcode & 0xF];

    // FIXME: I don't think result needs to be mutable here
    var result: u32 = undefined;
    if (amount == 0) {
        switch (@as(u2, @truncate(opcode >> 5))) {
            0b00 => {
                // LSL #0
                result = rm;
            },
            0b01 => {
                // LSR #0 aka LSR #32
                if (S) cpu.cpsr.c.write(rm >> 31 & 1 == 1);
                result = 0;
            },
            0b10 => {
                // ASR #0 aka ASR #32
                result = @bitCast(@as(i32, @bitCast(rm)) >> 31);
                if (S) cpu.cpsr.c.write(result >> 31 & 1 == 1);
            },
            0b11 => {
                // ROR #0 aka RRX
                const carry: u32 = @intFromBool(cpu.cpsr.carry);
                if (S) cpu.cpsr.c.write(rm & 1 == 1);

                result = (carry << 31) | (rm >> 1);
            },
        }
    } else switch (@as(u2, @truncate(opcode >> 5))) {
        0b00 => result = lsl(S, &cpu.cpsr, rm, amount),
        0b01 => result = lsr(S, &cpu.cpsr, rm, amount),
        0b10 => result = asr(S, &cpu.cpsr, rm, amount),
        0b11 => result = ror(S, &cpu.cpsr, rm, amount),
    }

    return result;
}

pub fn lsl(comptime S: bool, cpsr: *StatusReg, rm: u32, total_amount: u8) u32 {
    const amount: u5 = @truncate(total_amount);
    const bit_count: u8 = @typeInfo(u32).Int.bits;

    var result: u32 = 0x0000_0000;
    if (total_amount < bit_count) {
        // We can perform a well-defined shift here
        result = rm << amount;

        if (S and total_amount != 0) {
            const carry_bit: u5 = @truncate(bit_count - amount);
            cpsr.c.write(rm >> carry_bit & 1 == 1);
        }
    } else {
        if (S) {
            if (total_amount == bit_count) {
                // Shifted all bits out, carry bit is bit 0 of rm
                cpsr.c.write(rm & 1 == 1);
            } else {
                cpsr.c.write(false);
            }
        }
    }

    return result;
}

pub fn lsr(comptime S: bool, cpsr: *StatusReg, rm: u32, total_amount: u32) u32 {
    const amount: u5 = @truncate(total_amount);
    const bit_count: u8 = @typeInfo(u32).Int.bits;

    var result: u32 = 0x0000_0000;
    if (total_amount < bit_count) {
        // We can perform a well-defined shift
        result = rm >> amount;
        if (S and total_amount != 0) cpsr.c.write(rm >> (amount - 1) & 1 == 1);
    } else {
        if (S) {
            if (total_amount == bit_count) {
                // LSR #32
                cpsr.c.write(rm >> 31 & 1 == 1);
            } else {
                // All bits have been shifted out, including carry bit
                cpsr.c.write(false);
            }
        }
    }

    return result;
}

pub fn asr(comptime S: bool, cpsr: *StatusReg, rm: u32, total_amount: u8) u32 {
    const amount: u5 = @truncate(total_amount);
    const bit_count: u8 = @typeInfo(u32).Int.bits;

    var result: u32 = 0x0000_0000;
    if (total_amount < bit_count) {
        result = @bitCast(@as(i32, @bitCast(rm)) >> amount);
        if (S and total_amount != 0) cpsr.c.write(rm >> (amount - 1) & 1 == 1);
    } else {
        // ASR #32 and ASR #>32 have the same result
        result = @bitCast(@as(i32, @bitCast(rm)) >> 31);
        if (S) cpsr.c.write(result >> 31 & 1 == 1);
    }

    return result;
}

pub fn ror(comptime S: bool, cpsr: *StatusReg, rm: u32, total_amount: u8) u32 {
    const result = rotr(u32, rm, total_amount);

    if (S and total_amount != 0) {
        cpsr.c.write(result >> 31 & 1 == 1);
    }

    return result;
}
