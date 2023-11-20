const std = @import("std");

const core = @import("core.zig");
const Scheduler = @import("gba/scheduler.zig");
const Bus = @import("gba/bus.zig");
const interface = @import("interface.zig");

const Allocator = std.mem.Allocator;

const Self = @This();

sched: Scheduler = undefined,
bus: Bus = undefined,
ibus: interface.Bus,
isched: interface.Scheduler,
cpu: core.Arm7tdmi,

pub fn create(allocator: Allocator) !*Self {
    var gba = try allocator.create(Self);

    gba.* = .{
        .sched = Scheduler.init(allocator),
        .bus = try Bus.init(allocator, &gba.sched, &gba.cpu),
        .ibus = interface.Bus.create(&gba.bus),
        .isched = interface.Scheduler.create(&gba.sched),
        .cpu = core.Arm7tdmi.create(gba.isched, gba.ibus),
    };

    return gba;
}

pub fn deinit(self: *Self, allocator: Allocator) void {
    self.sched.deinit();
    self.bus.deinit();
    allocator.destroy(self);
}

pub fn direct_boot(self: *Self) void {
    const Bank = core.Arm7tdmi.Bank;

    @memset(&self.cpu.regs, 0);
    self.cpu.regs[13] = 0x03007F00;
    self.cpu.regs[15] = 0x08000000;

    self.cpu.bank.regs[Bank.regIdx(.Irq, .R13)] = 0x0300_7FA0;
    self.cpu.bank.regs[Bank.regIdx(.Supervisor, .R13)] = 0x0300_7FE0;

    self.cpu.cpsr = .{ .mode = .System };

    // TODO set bios latch
}
