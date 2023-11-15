const std = @import("std");

const Architecture = enum { v4t, v5te };

pub const Arm7tdmi = Core(.v4t);

fn Core(comptime isa: Architecture) type {
    if (isa != .v4t) {
        @compileError("other isa's are not yet implimented");
    }

    const Pipeline = struct {
        stage: [2]?u32 = [_]?u32{null} ** 2,
        flushed: bool = false,

        fn step(self: *@This(), comptime T: type, cpu: *Core(isa)) ?T {
            comptime std.debug.assert(T == u32 or T == u16);

            const opcode = self.stage[0];
            self.stage[0] = self.stage[1];
            self.stage[1] = cpu.fetch(T, cpu.regs[15]);

            return @truncate(opcode orelse return null);
        }
    };

    const Bank = struct {
        regs: [12]u32 = [_]u32{0} ** 12,
        fiq: [10]u32 = [_]u32{0} ** 10,
        spsr: [5]StatusReg = [_]StatusReg{.{}} ** 5,
    };

    return struct {
        const Self = @This();
        pub const arch = isa;
        const arm = @import("core/arm.zig");
        const thumb = @import("core/thumb.zig");

        bus: IBus,
        scheduler: IScheduler,

        regs: [16]u32 = [_]u32{0} ** 16,
        pipe: Pipeline = .{},
        cpsr: StatusReg = .{ .mode = .System },
        spsr: StatusReg = @bitCast(@as(u32, 0)),
        bank: Bank = .{},

        pub fn create(scheduler: IScheduler, bus: IBus) Self {
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
                const opcode = self.bus.dbgRead(u32, self.regs[15] - 4);
                const id = arm.idx(opcode);
                std.debug.print("opcode: ID: 0x{X:0>3} 0x{X:0>8}\n", .{ id, opcode });
            }

            // TODO: std.debug.print("tick: {}\n\n", .{self.sched.now()});

            std.debug.panic(fmt, args);
        }
    
        pub fn read(self: *Self, comptime T: type, addr: u32) T {
            return self.bus.read(T, addr);
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

pub const IBus = struct {
    ptr: *anyopaque,
    vtable: *const Vtable,

    const Vtable = struct {
        read8: *const fn (ptr: *anyopaque, addr: u32) u8,
        read16: *const fn (ptr: *anyopaque, addr: u32) u16,
        read32: *const fn (ptr: *anyopaque, addr: u32) u32,

        write8: *const fn (ptr: *anyopaque, addr: u32, val: u8) void,
        write16: *const fn (ptr: *anyopaque, addr: u32, val: u16) void,
        write32: *const fn (ptr: *anyopaque, addr: u32, val: u32) void,

        dbg_read8: *const fn (ptr: *anyopaque, addr: u32) u8,
        dbg_read16: *const fn (ptr: *anyopaque, addr: u32) u16,
        dbg_read32: *const fn (ptr: *anyopaque, addr: u32) u32,

        dbg_write8: *const fn (ptr: *anyopaque, addr: u32, val: u8) void,
        dbg_write16: *const fn (ptr: *anyopaque, addr: u32, val: u16) void,
        dbg_write32: *const fn (ptr: *anyopaque, addr: u32, val: u32) void,

        reset: *const fn (ptr: *anyopaque) void,
    };

    pub fn create(bus: anytype) @This() {
        const P = @TypeOf(bus);
        const info = @typeInfo(P);

        comptime {
            std.debug.assert(info == .Pointer);
            std.debug.assert(info.Pointer.size == .One);
            std.debug.assert(@typeInfo(info.Pointer.child) == .Struct);
        }

        const impl = struct {
            fn read8(ptr: *anyopaque, addr: u32) u8 {
                const self: P = @ptrCast(@alignCast(ptr));
                return self.read(u8, addr);
            }

            fn read16(ptr: *anyopaque, addr: u32) u16 {
                const self: P = @ptrCast(@alignCast(ptr));
                return self.read(u16, addr);
            }

            fn read32(ptr: *anyopaque, addr: u32) u32 {
                const self: P = @ptrCast(@alignCast(ptr));
                return self.read(u32, addr);
            }

            fn write8(ptr: *anyopaque, addr: u32, val: u8) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.write(u8, addr, val);
            }

            fn write16(ptr: *anyopaque, addr: u32, val: u16) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.write(u16, addr, val);
            }

            fn write32(ptr: *anyopaque, addr: u32, val: u32) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.write(u32, addr, val);
            }

            fn dbgRead8(ptr: *anyopaque, addr: u32) u8 {
                const self: P = @ptrCast(@alignCast(ptr));
                return self.dbgRead(u8, addr);
            }

            fn dbgRead16(ptr: *anyopaque, addr: u32) u16 {
                const self: P = @ptrCast(@alignCast(ptr));
                return self.dbgRead(u16, addr);
            }

            fn dbgRead32(ptr: *anyopaque, addr: u32) u32 {
                const self: P = @ptrCast(@alignCast(ptr));
                return self.dbgRead(u32, addr);
            }

            fn dbgWrite8(ptr: *anyopaque, addr: u32, val: u8) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.dbgWrite(u8, addr, val);
            }

            fn dbgWrite16(ptr: *anyopaque, addr: u32, val: u16) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.dbgWrite(u16, addr, val);
            }

            fn dbgWrite32(ptr: *anyopaque, addr: u32, val: u32) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.dbgWrite(u32, addr, val);
            }

            fn reset(ptr: *anyopaque) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.reset();
            }
        };

        return .{
            .ptr = bus,
            .vtable = &.{
                .read8 = impl.read8,
                .read16 = impl.read16,
                .read32 = impl.read32,

                .write8 = impl.write8,
                .write16 = impl.write16,
                .write32 = impl.write32,

                .dbg_read8 = impl.dbgRead8,
                .dbg_read16 = impl.dbgRead16,
                .dbg_read32 = impl.dbgRead32,

                .dbg_write8 = impl.dbgWrite8,
                .dbg_write16 = impl.dbgWrite16,
                .dbg_write32 = impl.dbgWrite32,
                
                .reset = impl.reset,
            },
        };
    }

    pub fn read(self: @This(), comptime T: type, addr: u32) T {
        return switch (T) {
            u32 => self.vtable.read32(self.ptr, addr),
            u16 => self.vtable.read16(self.ptr, addr),
            u8 => self.vtable.read8(self.ptr, addr),
            else => @compileError("invalid type"),
        };
    }

    pub fn write(self: @This(), comptime T: type, addr: u32, val: T) void {
        switch (T) {
            u32 => self.vtable.write32(self.ptr, addr, val),
            u16 => self.vtable.write16(self.ptr, addr, val),
            u8 => self.vtable.write8(self.ptr, addr, val),
            else => @compileError("invalid type"),
        }
    }

    pub fn dbgRead(self: @This(), comptime T: type, addr: u32) T {
        return switch (T) {
            u32 => self.vtable.dbg_read32(self.ptr, addr),
            u16 => self.vtable.dbg_read16(self.ptr, addr),
            u8 => self.vtable.dbg_read8(self.ptr, addr),
            else => @compileError("invalid type"),
        };
    }

    pub fn dbgWrite(self: @This(), comptime T: type, addr: u32, val: T) void {
        switch (T) {
            u32 => self.vtable.dbg_write32(self.ptr, addr, val),
            u16 => self.vtable.dbg_write16(self.ptr, addr, val),
            u8 => self.vtable.dbg_write8(self.ptr, addr, val),
            else => @compileError("invalid type"),
        }
    }

    pub fn reset(self: @This()) void {
        self.vtable.reset(self.ptr);
    }
};

pub const IScheduler = struct {};
