const std = @import("std");
const imgui = @import("imgui");
const sokol = @import("sokol");

const core = @import("core.zig");
const Scheduler = @import("gba/scheduler.zig");
const Bus = @import("gba/bus.zig");
const interface = @import("interface.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

pub fn main() !void {
    var sched = Scheduler.init(allocator);
    defer sched.deinit();

    var bus: Bus = undefined;

    var ibus = interface.Bus.create(&bus);
    var isched = interface.Scheduler.create(&sched);
    var cpu = core.Arm7tdmi.create(isched, ibus);
    
    try bus.init(allocator, &sched, &cpu);
    defer bus.deinit();

    ibus.reset();

    for (0..10) |_| {
        cpu.step();
    }
}

const MyBus = struct {
    const Self = @This();

    pub fn read(_: *Self, comptime T: type, _: u32) T {
        return 0;
    }

    pub fn write(_: *Self, comptime T: type, _: u32, _: T) void {}

    pub fn dbgRead(_: *Self, comptime T: type, _: u32) T {
        return 0;
    }

    pub fn dbgWrite(_: *Self, comptime T: type, _: u32, _: T) void {}

    pub fn reset(_: *Self) void {
        std.debug.print("reseting!\n\n", .{});
    }
};
