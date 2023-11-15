const std = @import("std");

const Allocator = std.mem.Allocator;

const log = std.log.scoped(.Cartridge);

title: [12]u8,
buf: []u8,
// backup: Backup,
// gpio: *Gpio,
allocator: Allocator,

const Self = @This();

pub fn init(allocator: Allocator, rom_path: ?[]const u8, save_path: ?[]const u8) !Self {
    _ = save_path;

    const parsed = if (rom_path) |path| blk: {
        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        const buffer = try file.readToEndAlloc(allocator, try file.getEndPos());
        const title = buffer[0xA0..0xAC];

        log.info("Title: {s}", .{title});
        const version = buffer[0xBC];
        if (version != 0) log.info("Version: {}", .{version});
        log.info("Game Code: {s}", .{buffer[0xAC..0xB0]});
        log.info("Maker Code: {s}", .{buffer[0xB0..0xB2]});

        break :blk .{ buffer, title.* };
    } else .{ try allocator.alloc(u8, 0), [_]u8{0} ** 12 };

    return .{
        .title = parsed[1],
        .buf = parsed[0],
        .allocator = allocator,
    };
}

pub fn deinit(self: *Self) void {
    self.allocator.free(self.buf);
    self.* = undefined;
}

pub fn read(self: *Self, comptime T: type, address: u32) T {
    const addr = address & 0x1FFFFFF;

    // TODO: check if backup is eeprom

    // TODO: check gpio

    return switch (T) {
        u32 => (@as(T, self.get(addr + 3)) << 24) | (@as(T, self.get(addr + 2)) << 16) | (@as(T, self.get(addr + 1)) << 8) | (@as(T, self.get(addr))),
        u16 => (@as(T, self.get(addr + 1)) << 8) | @as(T, self.get(addr)),
        u8 => self.get(addr),
        else => @compileError("unsupported type"),
    };
}

inline fn get(self: *const Self, i: u32) u8 {
    @setRuntimeSafety(false);
    if (i < self.buf.len) return self.buf[i];

    const lhs = i >> 1 & 0xFFFF;
    return @truncate(lhs >> 8 * @as(u5, @truncate(i & 1)));
}
