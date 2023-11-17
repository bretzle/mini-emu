const std = @import("std");
const interface = @import("interface.zig");

const Architecture = enum { v4t, v5te };

pub const Arm7tdmi = Core(.v4t);

fn Core(comptime isa: Architecture) type {
    if (isa != .v4t) {
        @compileError("other isa's are not yet implimented");
    }

    return struct {
        const Self = @This();
        pub const arch = isa;
        const arm = @import("core/arm.zig");
        const thumb = @import("core/thumb.zig");

        bus: interface.Bus,
        scheduler: interface.Scheduler,

        regs: [16]u32 = [_]u32{0} ** 16,
        pipe: Pipeline = .{},
        cpsr: StatusReg = .{ .mode = .System },
        spsr: StatusReg = @bitCast(@as(u32, 0)),
        bank: Bank = .{},

        const Pipeline = struct {
            stage: [2]?u32 = [_]?u32{null} ** 2,
            flushed: bool = false,

            fn step(self: *@This(), comptime T: type, cpu: *Self) ?T {
                comptime std.debug.assert(T == u32 or T == u16);

                const opcode = self.stage[0];
                self.stage[0] = self.stage[1];
                self.stage[1] = cpu.fetch(T, cpu.regs[15]);

                return @truncate(opcode orelse return null);
            }

            pub fn reload(self: *@This(), cpu: *Self) void {
                if (cpu.cpsr.thumb) {
                    self.stage[0] = cpu.fetch(u16, cpu.regs[15]);
                    self.stage[1] = cpu.fetch(u16, cpu.regs[15] + 2);
                    cpu.regs[15] += 4;
                } else {
                    self.stage[0] = cpu.fetch(u32, cpu.regs[15]);
                    self.stage[1] = cpu.fetch(u32, cpu.regs[15] + 4);
                    cpu.regs[15] += 8;
                }

                self.flushed = true;
            }
        };

        pub const Bank = struct {
            regs: [12]u32 = [_]u32{0} ** 12,
            fiq: [10]u32 = [_]u32{0} ** 10,
            spsr: [5]StatusReg = [_]StatusReg{.{}} ** 5,

            const Kind = enum(u1) { R13 = 0, R14 };

            pub inline fn regIdx(mode: Mode, kind: Kind) usize {
                const idx: usize = switch (mode) {
                    .User, .System => 0,
                    .Supervisor => 1,
                    .Abort => 2,
                    .Undefined => 3,
                    .Irq => 4,
                    .Fiq => 5,
                };

                return (idx * 2) + if (kind == .R14) @as(usize, 1) else 0;
            }
        };

        pub fn create(scheduler: interface.Scheduler, bus: interface.Bus) Self {
            return .{
                .bus = bus,
                .scheduler = scheduler,
            };
        }

        pub fn reset(self: *Self) void {
            self.* = create(self.scheduler, self.bus);
        }

        pub fn step(self: *Self) void {
            defer {
                if (!self.pipe.flushed) self.regs[15] += if (self.cpsr.thumb) 2 else 4;
                self.pipe.flushed = false;
            }

            if (self.cpsr.thumb) {
                const opcode = self.pipe.step(u16, self) orelse return;
                thumb.lut[thumb.idx(opcode)](self, opcode);
            } else {
                const opcode = self.pipe.step(u32, self) orelse return;
                const cond: u4 = @truncate(opcode >> 28);

                if (self.cpsr.check(isa, cond)) {
                    arm.lut[arm.idx(opcode)](self, opcode);
                }
            }
        }

        fn fetch(self: *Self, comptime T: type, addr: u32) T {
            comptime std.debug.assert(T == u32 or T == u16);

            return self.read(T, addr);
        }

        pub fn panic(self: *const Self, comptime fmt: []const u8, args: anytype) noreturn {
            var i: usize = 0;
            while (i < 16) : (i += 4) {
                const i_1 = i + 1;
                const i_2 = i + 2;
                const i_3 = i + 3;
                std.debug.print("R{}: 0x{X:0>8}\tR{}: 0x{X:0>8}\tR{}: 0x{X:0>8}\tR{}: 0x{X:0>8}\n", .{ i, self.regs[i], i_1, self.regs[i_1], i_2, self.regs[i_2], i_3, self.regs[i_3] });
            }
            std.debug.print("cpsr: 0x{X:0>8} ", .{self.cpsr.raw()});
            self.cpsr.print();

            std.debug.print("spsr: 0x{X:0>8} ", .{self.spsr.raw()});
            self.spsr.print();

            std.debug.print("pipeline: {??X:0>8}\n", .{self.pipe.stage});

            if (self.cpsr.thumb) {
                const opcode = self.bus.dbgRead(u16, self.regs[15] - 4);
                const id = thumb.idx(opcode);
                std.debug.print("opcode: ID: 0x{b:0>10} 0x{X:0>4}\n", .{ id, opcode });
            } else {
                const opcode = self.bus.dbgRead(u32, self.regs[15] - 8);
                const id = arm.idx(opcode);
                std.debug.print("opcode: ID: 0x{X:0>3} 0x{X:0>8}\n", .{ id, opcode });
            }

            std.debug.print("tick: {}\n\n", .{self.scheduler.now()});

            std.debug.panic(fmt, args);
        }

        pub fn read(self: *Self, comptime T: type, addr: u32) T {
            return self.bus.read(T, addr);
        }

        pub fn write(self: *Self, comptime T: type, addr: u32, val: T) void {
            return self.bus.write(T, addr, val);
        }
    };
}

pub const Mode = enum(u5) {
    User = 0x10,
    Fiq = 0x11,
    Irq = 0x12,
    Supervisor = 0x13,
    Abort = 0x17,
    Undefined = 0x1b,
    System = 0x1f,

    pub fn toString(self: @This()) []const u8 {
        return switch (self) {
            .User => "usr",
            .Fiq => "fiq",
            .Irq => "irq",
            .Supervisor => "svc",
            .Abort => "abt",
            .Undefined => "und",
            .System => "sys",
        };
    }

    pub fn get(bits: u5) ?@This() {
        return std.meta.intToEnum(@This(), bits) catch null;
    }
};

pub const StatusReg = packed struct {
    mode: Mode = .System,
    thumb: bool = false,
    fiq: bool = false,
    irq: bool = false,
    _: u20 = 0,
    overflow: bool = false,
    carry: bool = false,
    zero: bool = false,
    negative: bool = false,

    const lut = [_]u16{
        0xF0F0, // EQ - Equal
        0x0F0F, // NE - Not Equal
        0xCCCC, // CS - Unsigned higher or same
        0x3333, // CC - Unsigned lower
        0xFF00, // MI - Negative
        0x00FF, // PL - Positive or Zero
        0xAAAA, // VS - Overflow
        0x5555, // VC - No Overflow
        0x0C0C, // HI - unsigned hierh
        0xF3F3, // LS - unsigned lower or same
        0xAA55, // GE - greater or equal
        0x55AA, // LT - less than
        0x0A05, // GT - greater than
        0xF5FA, // LE - less than or equal
        0xFFFF, // AL - always
        0x0000, // NV - never
    };

    inline fn raw(self: @This()) u32 {
        return @bitCast(self);
    }

    // TODO: this lut is different in other architectures!
    fn check(self: @This(), _: Architecture, cond: u4) bool {
        const flags: u4 = @truncate(self.raw());
        return lut[cond] & (@as(u16, 1) << flags) != 0;
    }

    fn print(self: @This()) void {
        std.debug.print("[", .{});

        if (self.negative) std.debug.print("N", .{}) else std.debug.print("-", .{});
        if (self.zero) std.debug.print("Z", .{}) else std.debug.print("-", .{});
        if (self.carry) std.debug.print("C", .{}) else std.debug.print("-", .{});
        if (self.overflow) std.debug.print("V", .{}) else std.debug.print("-", .{});
        if (self.irq) std.debug.print("I", .{}) else std.debug.print("-", .{});
        if (self.fiq) std.debug.print("F", .{}) else std.debug.print("-", .{});
        if (self.thumb) std.debug.print("T", .{}) else std.debug.print("-", .{});
        std.debug.print("|", .{});
        if (Mode.get(@intFromEnum(self.mode))) |m| std.debug.print("{s}", .{m.toString()}) else std.debug.print("---", .{});

        std.debug.print("]\n", .{});
    }
};
