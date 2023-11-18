const helpers = @import("../helpers.zig");

pub fn singleDataSwap(comptime Handler: type, comptime byte: bool) Handler {
    _ = byte;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm singleDataSwap", .{});
        }
    }.impl;
}

pub fn halfwordSignedTransfer(comptime Handler: type, comptime pre: bool, comptime add: bool, comptime immediate: bool, comptime writeback: bool, comptime load: bool, comptime op: u2) Handler {
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            const rn = opcode >> 16 & 0xF;
            const rd = opcode >> 12 & 0xF;
            const rm = opcode & 0xF;
            const imm_offset_high = opcode >> 8 & 0xF;

            const base = cpu.regs[rn] + if (!load and rn == 0xF) 4 else @as(u32, 0);
            const offset = if (immediate) imm_offset_high << 4 | rm else cpu.regs[rm];

            const modified_base = if (add) base +% offset else base -% offset;
            var address = if (pre) modified_base else base;

            var result: u32 = undefined;

            if (load) {
                switch (op) {
                    0b00 => @compileError("unreachable"),
                    0b01 => result = helpers.rotr(u32, cpu.read(u16, address), 8 * (address & 1)), // ldrh
                    0b10 => result = helpers.sext(u32, u8, cpu.read(u8, address)), // ldrsb
                    0b11 => {
                        const val = cpu.read(u16, address);
                        result = if (address & 1 == 1) helpers.sext(u32, u8, @as(u8, @truncate(val >> 8))) else helpers.sext(u32, u16, val); // ldrsh
                    },
                }
            } else {
                switch (op) {
                    0b00 => @compileError("unreachable"),
                    0b01 => cpu.write(u16, address, @as(u16, @truncate(cpu.regs[rd]))), // strh
                    0b10 => cpu.panic("todo", .{}), // ldrd
                    0b11 => cpu.panic("todo", .{}), // strd
                }
            }

            address = modified_base;
            if (writeback and pre or !pre) cpu.regs[rn] = address;
            if (load) cpu.regs[rd] = result; // handle rd == rn
        }
    }.impl;
}

pub fn singleDataTransfer(comptime Handler: type, comptime immediate: bool, comptime pre: bool, comptime add: bool, comptime byte: bool, comptime writeback: bool, comptime load: bool) Handler {
    _ = load;
    _ = writeback;
    _ = byte;
    _ = add;
    _ = pre;
    _ = immediate;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm singleDataTransfer", .{});
        }
    }.impl;
}

pub fn blockDataTransfer(comptime Handler: type, comptime pre: bool, comptime add: bool, comptime user_mode: bool, comptime writeback: bool, comptime load: bool) Handler {
    _ = load;
    _ = writeback;
    _ = user_mode;
    _ = add;
    _ = pre;
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            _ = opcode;
            cpu.panic("[CPU/Execute] TODO: arm blockDataTransfer", .{});
        }
    }.impl;
}
