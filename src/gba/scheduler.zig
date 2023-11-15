const std = @import("std");

const Allocator = std.mem.Allocator;
const Order = std.math.Order;
const PriorityQueue = std.PriorityQueue(Event, void, lessThan);

const log = std.log.scoped(.scheduler);

tick: u64 = 0,
queue: PriorityQueue,

const Self = @This();

pub fn init(allocator: Allocator) Self {
    var sched = .{ .queue = PriorityQueue.init(allocator, {}) };

    sched.queue.add(.{ .kind = .HeatDeath, .tick = std.math.maxInt(u64) }) catch unreachable;

    return sched;
}

pub fn deinit(self: *Self) void {
    self.queue.deinit();
    self.* = undefined;
}

pub fn reset(self: *Self) void {
    self.queue.deinit();
    self.* = init(self.queue.allocator);
}

pub inline fn now(self: *const Self) u64 {
    return self.tick;
}

pub fn handleEvent(self: *Self) void {
    const event = self.queue.remove();
    const late = self.tick - event.tick;
    _ = late;

    switch (event.kind) {
        .HeatDeath => {
            log.err("heat death! This **should** never happen 🤞", .{});
            unreachable;
        },
    }
}

/// Removes the **first** scheduled event of given kind
pub fn removeEvent(self: *Self, kind: EventKind) void {
    for (self.queue.items, 0..) |event, i| {
        if (std.meta.eql(event.kind, kind)) {
            _ = self.queue.removeIndex(i);
            log.debug("Removed {?}@{}", .{ event.kind, event.tick });
            break;
        }
    }
}

pub fn addEvent(self: *Self, kind: EventKind, end: u64) void {
    self.queue.add(.{ .kind = kind, .tick = self.now() + end }) catch unreachable;
}

pub fn next(self: *const Self) u64 {
    // Safety: There will always be a heat death event in the queue
    @setRuntimeSafety(false);
    return self.queue.items[0].tick;
}

pub const Event = struct {
    kind: EventKind,
    tick: u64,
};

pub const EventKind = union(enum) {
    HeatDeath,
};

fn lessThan(_: void, a: Event, b: Event) Order {
    return std.math.order(a.tick, b.tick);
}
