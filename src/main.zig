const std = @import("std");
const imgui = @import("imgui");
const sokol = @import("sokol");
const simg = @import("sokol_imgui.zig");

const sg = sokol.gfx;
const sapp = sokol.app;

const core = @import("core.zig");
const Scheduler = @import("gba/scheduler.zig");
const Bus = @import("gba/bus.zig");
const interface = @import("interface.zig");
const Gba = @import("gba.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var allocator = gpa.allocator();

var gba: *Gba = undefined;

var pass_action: sg.PassAction = .{};

pub fn main() !void {
    defer std.debug.assert(gpa.deinit() == .ok);

    gba = try Gba.create(allocator);
    defer gba.deinit(allocator);

    gba.direct_boot();

    // while (true) gba.cpu.step();

    sapp.run(.{
        .window_title = "mini-emu",
        .width = 1280,
        .height = 720,

        .init_cb = init,
        .frame_cb = frame,
        .event_cb = event,
        .cleanup_cb = cleanup,
    });
}

export fn init() void {
    sg.setup(.{ .context = sokol.app_gfx_glue.context() });

    pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 1, .g = 1, .b = 0, .a = 1 },
    };

    std.debug.print("Backend: {}\n", .{sg.queryBackend()});

    simg.simgui_setup(.{ .allocator = allocator, .no_default_font = false }) catch |err| std.debug.panic("{}", .{err});
}

export fn frame() void {
    simg.simgui_new_frame(.{
        .width = sapp.width(),
        .height = sapp.height(),
        .delta_time = sapp.frameDuration(),
        .dpi_scale = sapp.dpiScale(),
    });

    const g = pass_action.colors[0].clear_value.g + 0.001;
    pass_action.colors[0].clear_value.g = if (g > 1.0) 0.0 else g;
    sg.beginDefaultPass(pass_action, sapp.width(), sapp.height());
    imgui.ShowDemoWindow();
    simg.simgui_render();
    sg.endPass();
    sg.commit();
}

export fn event(_: [*c]const sapp.Event) void {}

export fn cleanup() void {
    simg.simgui_shutdown();
    sg.shutdown();
}
