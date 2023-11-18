const helpers = @import("../helpers.zig");

pub const DataOp = enum(u4) {
    AND = 0x0,
    EOR = 0x1,
    SUB = 0x2,
    RSB = 0x3,
    ADD = 0x4,
    ADC = 0x5,
    SBC = 0x6,
    RSC = 0x7,
    TST = 0x8,
    TEQ = 0x9,
    CMP = 0xA,
    CMN = 0xB,
    ORR = 0xC,
    MOV = 0xD,
    BIC = 0xE,
    MVN = 0xF,
};

pub fn dataProcessing(comptime Handler: type, comptime immediate: bool, comptime op: DataOp, comptime set_flags: bool, comptime field4: u4) Handler {
    _ = field4;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            const rd: u4 = @truncate(opcode >> 12 & 0xF);
            const rn = opcode >> 16 & 0xF;
            const old_carry = @intFromBool(cpu.cpsr.carry);

            // If certain conditions are met, PC is 12 ahead instead of 8
            // TODO: Why these conditions?
            if (!immediate and opcode >> 4 & 1 == 1) cpu.regs[15] += 4;
            const op1 = cpu.regs[rn];

            const amount: u8 = @truncate((opcode >> 8 & 0xF) << 1);
            const op2 = if (immediate) helpers.ror(set_flags, &cpu.cpsr, opcode & 0xFF, amount) else helpers.exec(set_flags, cpu, opcode);

            // Undo special condition from above
            if (!immediate and opcode >> 4 & 1 == 1) cpu.regs[15] -= 4;

            var overflow: u1 = undefined;

            // perform data processing logic
            const result: u32 = switch (op) {
                .AND => op1 & op2,
                .EOR => op1 ^ op2,
                .SUB => op1 -% op2,
                .RSB => op2 -% op1,
                .ADD => add(&overflow, op1, op2),
                .ADC => adc(&overflow, op1, op2, old_carry),
                .SBC => sbc(op1, op2, old_carry),
                .RSC => sbc(op2, op1, old_carry),
                .TST => if (rd == 15) return undefinedTestBehavior(cpu) else op1 & op2,
                .TEQ => if (rd == 15) return undefinedTestBehavior(cpu) else op1 ^ op2,
                .CMP => if (rd == 15) return undefinedTestBehavior(cpu) else op1 -% op2,
                .CMN => if (rd == 15) return undefinedTestBehavior(cpu) else add(&overflow, op1, op2),
                .ORR => op1 | op2,
                .MOV => op2,
                .BIC => op1 & ~op2,
                .MVN => ~op2,
            };

            // write to destination register
            switch (op) {
                .TST, .TEQ, .CMP, .CMN => {},
                else => {
                    cpu.regs[rd] = result;
                    if (rd == 0xF) {
                        if (set_flags) cpu.setCpsr(cpu.spsr);
                        cpu.pipe.reload(cpu);
                    }
                },
            }

            // write flags
            switch (op) {
                .AND, .EOR, .ORR, .MOV, .BIC, .MVN => if (set_flags and rd != 15) {
                    cpu.cpsr.negative = result >> 31 & 1 == 1;
                    cpu.cpsr.zero = result == 0;
                },
                .SUB, .RSB => if (set_flags and rd != 15) {
                    cpu.cpsr.negative = result >> 31 & 1 == 1;
                    cpu.cpsr.zero = result == 0;
                    if (op == .SUB) {
                        cpu.cpsr.carry = op2 <= op1;
                        cpu.cpsr.overflow = ((op1 ^ result) & (~op2 ^ result)) >> 31 & 1 == 1;
                    } else {
                        cpu.cpsr.carry = op1 <= op2;
                        cpu.cpsr.overflow = ((op2 ^ result) & (~op1 ^ result)) >> 31 & 1 == 1;
                    }
                },
                .ADD, .ADC => if (set_flags and rd != 0xF) {
                    cpu.cpsr.negative = result >> 31 & 1 == 1;
                    cpu.cpsr.zero = result == 0;
                    cpu.cpsr.carry = overflow == 0b1;
                    cpu.cpsr.overflow = ((op1 ^ result) & (op2 ^ result)) >> 31 & 1 == 1;
                },
                .SBC, .RSC => if (set_flags and rd != 0xF) {
                    cpu.cpsr.negative = result >> 31 & 1 == 1;
                    cpu.cpsr.zero = result == 0;

                    if (op == .SBC) {
                        const subtrahend = @as(u64, op2) -% old_carry +% 1;
                        cpu.cpsr.carry = subtrahend <= op1;
                        cpu.cpsr.overflow = ((op1 ^ result) & (~op2 ^ result)) >> 31 & 1 == 1;
                    } else {
                        const subtrahend = @as(u64, op1) -% old_carry +% 1;
                        cpu.cpsr.carry = subtrahend <= op2;
                        cpu.cpsr.overflow = ((op2 ^ result) & (~op1 ^ result)) >> 31 & 1 == 1;
                    }
                },
                .TST, .TEQ, .CMP, .CMN => {
                    cpu.cpsr.negative = result >> 31 & 1 == 1;
                    cpu.cpsr.zero = result == 0;

                    switch (op) {
                        .CMP => {
                            cpu.cpsr.carry = op2 <= op1;
                            cpu.cpsr.overflow = ((op1 ^ result) & (~op2 ^ result)) >> 31 & 1 == 1;
                        },
                        .CMN => {
                            cpu.cpsr.carry = overflow == 0b1;
                            cpu.cpsr.overflow = ((op1 ^ result) & (op2 ^ result)) >> 31 & 1 == 1;
                        },
                        .TST, .TEQ => {
                            // Barrel Shifter should always calc CPSR C in TST
                            if (!set_flags) _ = helpers.exec(true, cpu, opcode);
                        },
                        else => @compileError("unreachable"),
                    }
                },
            }
        }

        fn undefinedTestBehavior(cpu: *Core) void {
            @setCold(true);
            cpu.setCpsr(cpu.spsr);
        }
    }.impl;
}

inline fn add(overflow: *u1, left: u32, right: u32) u32 {
    const ret = @addWithOverflow(left, right);
    overflow.* = ret[1];
    return ret[0];
}

inline fn sbc(left: u32, right: u32, old_carry: u1) u32 {
    const subtrahend = @as(u64, right) -% old_carry +% 1;
    return @truncate(left -% subtrahend);
}

inline fn adc(overflow: *u1, left: u32, right: u32, old_carry: u1) u32 {
    const tmp = @addWithOverflow(left, right);
    const ret = @addWithOverflow(tmp[0], old_carry);
    overflow.* = tmp[1] | ret[1];

    return ret[0];
}
