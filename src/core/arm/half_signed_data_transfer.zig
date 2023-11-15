const helpers = @import("../helpers.zig");

pub fn halfAndSignedDataTransfer(comptime Handler: type, comptime P: bool, comptime U: bool, comptime I: bool, comptime W: bool, comptime L: bool) Handler {
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            const rn = opcode >> 16 & 0xF;
            const rd = opcode >> 12 & 0xF;
            const rm = opcode & 0xF;
            const imm_offset_high = opcode >> 8 & 0xF;

            const base = cpu.regs[rn] + @as(u32, if (!L and rn == 0xF) 4 else 0);
            const offset = if (I) imm_offset_high << 4 | rm else cpu.regs[rm];

            const modified_base = if (U) base +% offset else base -% offset;
            var address = if (P) modified_base else base;

            const op: u2 = @truncate(opcode >> 5);
            var result: u32 = undefined;

            if (L) {
                switch (op) {
                    0b00 => unreachable,
                    0b01 => result = helpers.rotr(u32, cpu.read(u16, address), 8 * (address & 1)), // lsrh
                    0b10 => result = helpers.sext(u32, u8, cpu.read(u8, address)), // ldrsb
                    0b11 => {
                        const val = cpu.read(u16, address);
                        result = if (address & 1 == 1) helpers.sext(u32, u8, @as(u8, @truncate(val >> 8))) else helpers.sext(u32, u16, val); // ldrsh
                    },
                }
            } else {
                switch (op) {
                    0b00 => {
                        const swap_addr = cpu.regs[rn];
                        if (L) {
                            // swpb
                            const val = cpu.read(u8, swap_addr);
                            cpu.write(u8, swap_addr, @as(u8, @truncate(cpu.regs[rm])));
                            cpu.regs[rd] = val;
                        } else {
                            // swp
                            const val = helpers.rotr(u32, cpu.read(u32, swap_addr), 8 * (swap_addr & 0x3));
                            cpu.write(u32, swap_addr, cpu.regs[rm]);
                            cpu.regs[rd] = val;
                        }
                    },
                    0b01 => cpu.write(u16, address, @as(u16, @truncate(cpu.regs[rd]))), // strh
                    0b10 => @panic("TODO: ldrd only exists in v5te"), // ldrd
                    0b11 => @panic("TODO: strd only exists in v5te"), // strd
                }
            }

            address = modified_base;
            if (W and P or !P) cpu.regs[rn] = address;
            if (L) cpu.regs[rd] = result; // handle rd == rn
        }
    }.impl;
}
