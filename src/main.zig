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

    // direct boot
    if (true) {
        const Bank = core.Arm7tdmi.Bank;

        @memset(&cpu.regs, 0);
        cpu.regs[13] = 0x03007F00;
        cpu.regs[15] = 0x08000000;

        cpu.bank.regs[Bank.regIdx(.Irq, .R13)] = 0x0300_7FA0;
        cpu.bank.regs[Bank.regIdx(.Supervisor, .R13)] = 0x0300_7FE0;

        cpu.cpsr = .{ .mode = .System };

        // TODO set bios latch
    }

    while (true) cpu.step();
}
