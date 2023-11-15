const std = @import("std");

const Allocator = std.mem.Allocator;

const forceAlign = @import("../bus.zig").forceAlign;
const rotr = std.math.rotr;
const log = std.log.scoped(.bios);

pub const size = 0x4000;
const Self = @This();

buf: ?[]u8 = null,
allocator: Allocator,
latch: u32 = 0,

pub fn init(allocator: Allocator, bios_path: ?[]const u8) !Self {
    if (bios_path == null) return .{ .allocator = allocator };
    const path = bios_path.?;

    const buf = try allocator.alloc(u8, size);

    var bios: Self = .{ .buf = buf, .allocator = allocator };
    try bios.load(path);

    return bios;
}

pub fn deinit(self: *Self) void {
    if (self.buf) |buf| self.allocator.free(buf);
    self.* = undefined;
}

pub fn load(self: *Self, path: []const u8) !void {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const len = try file.readAll(self.buf orelse return error.UnallocatedBuffer);
    if (len != size) log.err("Expected BIOS to be {} bytes, was {} bytes", .{ size, len });
}

pub fn read(self: *Self, comptime T: type, r15: u32, addr: u32) T {
    if (r15 < Self.size) {
        const aligned = forceAlign(T, addr);
        self.latch = aligned;
        return self._read(T, addr);
    }

    log.warn("Open Bus! Read from 0x{X:0>8}, but PC was 0x{X:0>8}", .{ addr, r15 });
    const val = self._read(u32, self.latch);

    return @truncate(rotr(u32, val, 8 * rotateBy(T, addr)));
}

inline fn rotateBy(comptime T: type, address: u32) u32 {
    return switch (T) {
        u8 => address & 3,
        u16 => address & 2,
        u32 => 0,
        else => @compileError("bios: unsupported read width"),
    };
}

fn _read(self: *const Self, comptime T: type, addr: u32) T {
    const buf = self.buf orelse std.debug.panic("[BIOS] tried to read {} from 0x{X:0>8} but a bios was never loaded", .{ T, addr });

    return switch (T) {
        u32, u16, u8 => std.mem.readIntSliceLittle(T, buf[addr..][0..@sizeOf(T)]),
        else => @compileError("BIOS: Unsupported read width"),
    };
}
