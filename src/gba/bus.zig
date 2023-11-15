const std = @import("std");

const Scheduler = @import("scheduler.zig");
const Arm7tdmi = @import("../core.zig").Arm7tdmi;
const Allocator = std.mem.Allocator;

const log = std.log.scoped(.Bus);

const Self = @This();

cpu: *Arm7tdmi,
sched: *Scheduler,

allocator: Allocator,

pub fn init(self: *Self, allocator: Allocator, sched: *Scheduler, cpu: *Arm7tdmi) !void {
    self.* = .{
        .cpu = cpu,
        .sched = sched,
        .allocator = allocator,
    };
}

pub fn deinit(self: *Self) void {
    self.* = undefined;
}

pub fn reset(_: *Self) void {
    std.debug.print("reseting!\n\n", .{});
}

pub fn read(_: *Self, comptime T: type, _: u32) T {
    return 0;
}

pub fn write(_: *Self, comptime T: type, _: u32, _: T) void {}

pub fn dbgRead(_: *Self, comptime T: type, _: u32) T {
    return 0;
}

pub fn dbgWrite(_: *Self, comptime T: type, _: u32, _: T) void {}
