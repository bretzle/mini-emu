const helpers = @import("../helpers.zig");

pub fn singleDataTransfer(comptime Handler: type, comptime I: bool, comptime P: bool, comptime U: bool, comptime B: bool, comptime W: bool, comptime L: bool) Handler {
    const Core = @typeInfo(@typeInfo(@typeInfo(Handler).Pointer.child).Fn.params[0].type.?).Pointer.child;

    return struct {
        fn impl(cpu: *Core, opcode: u32) void {
            const rn = opcode >> 16 & 0xF;
            const rd = opcode >> 12 & 0xF;
            
            const base = cpu.regs[rn];
            const offset = if (I) helpers.immediate(false, cpu, opcode) else opcode & 0xFFF;
            const modified_base = if (U) base +% offset else base -% offset;
            
            var address = if (P) modified_base else base;
            var result: u32 = 0;

            if (L) {
                if (B) {
                    result = cpu.read(u8, address); // ldrb
                } else {
                    const val = cpu.read(u32, address);
                    result = helpers.rotr(u32, val, 8 * (address & 0x3)); // ldr
                }
            } else {
                const val = cpu.regs[rd] + if (rd == 0xF) 4 else @as(u32, 0);
                if (B) {
                    cpu.write(u8, address, @as(u8, @truncate(val))); // strb
                } else {
                    cpu.write(u32, address, val); // str
                }
            }

            address = modified_base;
            if (W and P or !P) {
                cpu.regs[rn] = address;
                if (rn == 0xF) cpu.pipe.reload(cpu);
            }

            if (L) {
                cpu.regs[rd] = result;
                if (rd == 0xF) {
                    if (Core.arch == .v5te) {
                        @compileError("v5 stuff");
                    }
                    cpu.pipe.reload(cpu);
                }
            }
        }
    }.impl;
}
