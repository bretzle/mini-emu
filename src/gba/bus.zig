const std = @import("std");

const Bios = @import("bus/bios.zig");
const Cartridge = @import("bus/cartridge.zig");
const Scheduler = @import("scheduler.zig");
const Arm7tdmi = @import("../core.zig").Arm7tdmi;
const Allocator = std.mem.Allocator;

const log = std.log.scoped(.Bus);

const timings = [_][0x10]u8{
    // BIOS, Unused, EWRAM, IWRAM, I/0, PALRAM, VRAM, OAM, ROM0, ROM0, ROM1, ROM1, ROM2, ROM2, SRAM, Unused
    [_]u8{ 1, 1, 3, 1, 1, 1, 1, 1, 5, 5, 5, 5, 5, 5, 5, 5 }, // 8-bit & 16-bit
    [_]u8{ 1, 1, 6, 1, 1, 2, 2, 1, 8, 8, 8, 8, 8, 8, 8, 8 }, // 32-bit
};

pub const fetch_timings = [_][0x10]u8{
    // BIOS, Unused, EWRAM, IWRAM, I/0, PALRAM, VRAM, OAM, ROM0, ROM0, ROM1, ROM1, ROM2, ROM2, SRAM, Unused
    [_]u8{ 1, 1, 3, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 5, 5 }, // 8-bit & 16-bit
    [_]u8{ 1, 1, 6, 1, 1, 2, 2, 1, 4, 4, 4, 4, 4, 4, 8, 8 }, // 32-bit
};

// Fastmem Related
const page_size = 1 * 0x400; // 1KiB
const address_space_size = 0x1000_0000;
const table_len = address_space_size / page_size;

const Self = @This();

bios: Bios,
cartridge: Cartridge,

cpu: *Arm7tdmi,
sched: *Scheduler,

allocator: Allocator,

pub fn init(allocator: Allocator, sched: *Scheduler, cpu: *Arm7tdmi) !Self {
    return .{
        .bios = try Bios.init(allocator, "bios.bin"),
        .cartridge = try Cartridge.init(allocator, "roms/first-1.gba", null),
        .cpu = cpu,
        .sched = sched,
        .allocator = allocator,
    };
}

pub fn deinit(self: *Self) void {
    self.bios.deinit();
    self.cartridge.deinit();
    self.* = undefined;
}

pub fn reset(_: *Self) void {
    std.debug.print("reseting!\n\n", .{});
}

pub fn read(self: *Self, comptime T: type, addr: u32) T {
    const bits = @typeInfo(std.math.IntFittingRange(0, page_size - 1)).Int.bits;
    const page = addr >> bits;
    const offset = addr & (page_size - 1);
    _ = offset;

    self.sched.tick += timings[@intFromBool(T == u32)][@as(u4, @truncate(addr >> 24))];

    if (page >= table_len) @panic("todo: openBus");

    // TODO: fastmem

    return self.slowRead(T, addr);
}

pub fn write(_: *Self, comptime T: type, _: u32, _: T) void {}

pub fn dbgRead(self: *Self, comptime T: type, addr: u32) T {
    return self.read(T, addr); // FIXME: dont do this
}

pub fn dbgWrite(_: *Self, comptime T: type, _: u32, _: T) void {}

fn slowRead(self: *Self, comptime T: type, addr: u32) T {
    @setCold(true); // TODO: should this be cold?

    const page: u8 = @truncate(addr >> 24);
    const address = forceAlign(T, addr);

    return switch (page) {
        0x00 => if (addr < Bios.size) self.bios.read(T, self.cpu.regs[15], addr) else @panic("open bus"),

        0x02 => @panic("todo"), // on-board work ram
        0x03 => @panic("todo"), // on-chip work ram
        0x04 => @panic("todo"), // io

        0x05 => @panic("todo"), // bg/obj palette ram
        0x06 => @panic("todo"), // vram
        0x07 => @panic("todo"), // oam - obj attributes

        0x08...0x0D => self.cartridge.read(T, address),
        0x0E...0x0F => @panic("todo"), // cartridge backup
        else => @panic("todo"), // openbus
    };
}

pub inline fn forceAlign(comptime T: type, address: u32) u32 {
    return switch (T) {
        u32 => address & ~@as(u32, 3),
        u16 => address & ~@as(u32, 1),
        u8 => address,
        else => @compileError("Bus: Invalid read/write type"),
    };
}
