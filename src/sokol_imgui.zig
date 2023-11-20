const std = @import("std");
const sokol = @import("sokol");
const imgui = @import("imgui");
const builtin = @import("builtin");

const Allocator = std.mem.Allocator;

const sg = sokol.gfx;
const sapp = sokol.app;
const log = std.log.scoped(.SokolImgui);

const INVALID_ID = 0;

const _simgui_vs_bytecode_hlsl4: [892]u8 = .{
    0x44, 0x58, 0x42, 0x43, 0x0d, 0xbd, 0x9e, 0x9e, 0x7d, 0xc0, 0x2b, 0x54, 0x88, 0xf9, 0xca, 0x89,
    0x32, 0xe4, 0x0c, 0x59, 0x01, 0x00, 0x00, 0x00, 0x7c, 0x03, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00,
    0x34, 0x00, 0x00, 0x00, 0xfc, 0x00, 0x00, 0x00, 0x60, 0x01, 0x00, 0x00, 0xd0, 0x01, 0x00, 0x00,
    0x00, 0x03, 0x00, 0x00, 0x52, 0x44, 0x45, 0x46, 0xc0, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
    0x48, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x04, 0xfe, 0xff,
    0x10, 0x81, 0x00, 0x00, 0x98, 0x00, 0x00, 0x00, 0x3c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x76, 0x73, 0x5f, 0x70, 0x61, 0x72, 0x61, 0x6d,
    0x73, 0x00, 0xab, 0xab, 0x3c, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00,
    0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x78, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x88, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x5f, 0x32, 0x32, 0x5f, 0x64, 0x69, 0x73, 0x70, 0x5f, 0x73, 0x69, 0x7a,
    0x65, 0x00, 0xab, 0xab, 0x01, 0x00, 0x03, 0x00, 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x4d, 0x69, 0x63, 0x72, 0x6f, 0x73, 0x6f, 0x66, 0x74, 0x20, 0x28, 0x52,
    0x29, 0x20, 0x48, 0x4c, 0x53, 0x4c, 0x20, 0x53, 0x68, 0x61, 0x64, 0x65, 0x72, 0x20, 0x43, 0x6f,
    0x6d, 0x70, 0x69, 0x6c, 0x65, 0x72, 0x20, 0x31, 0x30, 0x2e, 0x31, 0x00, 0x49, 0x53, 0x47, 0x4e,
    0x5c, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x50, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x03, 0x03, 0x00, 0x00, 0x50, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x03, 0x00, 0x00, 0x50, 0x00, 0x00, 0x00,
    0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00,
    0x0f, 0x0f, 0x00, 0x00, 0x54, 0x45, 0x58, 0x43, 0x4f, 0x4f, 0x52, 0x44, 0x00, 0xab, 0xab, 0xab,
    0x4f, 0x53, 0x47, 0x4e, 0x68, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00,
    0x50, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x03, 0x0c, 0x00, 0x00, 0x50, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x00,
    0x59, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00,
    0x02, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x00, 0x54, 0x45, 0x58, 0x43, 0x4f, 0x4f, 0x52, 0x44,
    0x00, 0x53, 0x56, 0x5f, 0x50, 0x6f, 0x73, 0x69, 0x74, 0x69, 0x6f, 0x6e, 0x00, 0xab, 0xab, 0xab,
    0x53, 0x48, 0x44, 0x52, 0x28, 0x01, 0x00, 0x00, 0x40, 0x00, 0x01, 0x00, 0x4a, 0x00, 0x00, 0x00,
    0x59, 0x00, 0x00, 0x04, 0x46, 0x8e, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
    0x5f, 0x00, 0x00, 0x03, 0x32, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5f, 0x00, 0x00, 0x03,
    0x32, 0x10, 0x10, 0x00, 0x01, 0x00, 0x00, 0x00, 0x5f, 0x00, 0x00, 0x03, 0xf2, 0x10, 0x10, 0x00,
    0x02, 0x00, 0x00, 0x00, 0x65, 0x00, 0x00, 0x03, 0x32, 0x20, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x65, 0x00, 0x00, 0x03, 0xf2, 0x20, 0x10, 0x00, 0x01, 0x00, 0x00, 0x00, 0x67, 0x00, 0x00, 0x04,
    0xf2, 0x20, 0x10, 0x00, 0x02, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x68, 0x00, 0x00, 0x02,
    0x01, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x05, 0x32, 0x20, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x46, 0x10, 0x10, 0x00, 0x01, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x05, 0xf2, 0x20, 0x10, 0x00,
    0x01, 0x00, 0x00, 0x00, 0x46, 0x1e, 0x10, 0x00, 0x02, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x08,
    0x32, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x46, 0x80, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0a,
    0x32, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0xbf, 0x00, 0x00, 0x00, 0xbf, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x38, 0x00, 0x00, 0x0a, 0x32, 0x20, 0x10, 0x00, 0x02, 0x00, 0x00, 0x00,
    0x46, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40,
    0x00, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x08,
    0xc2, 0x20, 0x10, 0x00, 0x02, 0x00, 0x00, 0x00, 0x02, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3f, 0x00, 0x00, 0x80, 0x3f, 0x3e, 0x00, 0x00, 0x01,
    0x53, 0x54, 0x41, 0x54, 0x74, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
};
const _simgui_fs_bytecode_hlsl4: [608]u8 = .{
    0x44, 0x58, 0x42, 0x43, 0x3a, 0xa7, 0x41, 0x21, 0xb4, 0x2d, 0xa7, 0x6e, 0xfe, 0x31, 0xb0, 0xe0,
    0x14, 0xe0, 0xdf, 0x5a, 0x01, 0x00, 0x00, 0x00, 0x60, 0x02, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00,
    0x34, 0x00, 0x00, 0x00, 0xc8, 0x00, 0x00, 0x00, 0x14, 0x01, 0x00, 0x00, 0x48, 0x01, 0x00, 0x00,
    0xe4, 0x01, 0x00, 0x00, 0x52, 0x44, 0x45, 0x46, 0x8c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x04, 0xff, 0xff,
    0x10, 0x81, 0x00, 0x00, 0x64, 0x00, 0x00, 0x00, 0x5c, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00,
    0x05, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00,
    0x01, 0x00, 0x00, 0x00, 0x0d, 0x00, 0x00, 0x00, 0x73, 0x6d, 0x70, 0x00, 0x74, 0x65, 0x78, 0x00,
    0x4d, 0x69, 0x63, 0x72, 0x6f, 0x73, 0x6f, 0x66, 0x74, 0x20, 0x28, 0x52, 0x29, 0x20, 0x48, 0x4c,
    0x53, 0x4c, 0x20, 0x53, 0x68, 0x61, 0x64, 0x65, 0x72, 0x20, 0x43, 0x6f, 0x6d, 0x70, 0x69, 0x6c,
    0x65, 0x72, 0x20, 0x31, 0x30, 0x2e, 0x31, 0x00, 0x49, 0x53, 0x47, 0x4e, 0x44, 0x00, 0x00, 0x00,
    0x02, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x03, 0x00, 0x00,
    0x38, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00,
    0x01, 0x00, 0x00, 0x00, 0x0f, 0x0f, 0x00, 0x00, 0x54, 0x45, 0x58, 0x43, 0x4f, 0x4f, 0x52, 0x44,
    0x00, 0xab, 0xab, 0xab, 0x4f, 0x53, 0x47, 0x4e, 0x2c, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
    0x08, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0f, 0x00, 0x00, 0x00, 0x53, 0x56, 0x5f, 0x54,
    0x61, 0x72, 0x67, 0x65, 0x74, 0x00, 0xab, 0xab, 0x53, 0x48, 0x44, 0x52, 0x94, 0x00, 0x00, 0x00,
    0x40, 0x00, 0x00, 0x00, 0x25, 0x00, 0x00, 0x00, 0x5a, 0x00, 0x00, 0x03, 0x00, 0x60, 0x10, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x58, 0x18, 0x00, 0x04, 0x00, 0x70, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x55, 0x55, 0x00, 0x00, 0x62, 0x10, 0x00, 0x03, 0x32, 0x10, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x62, 0x10, 0x00, 0x03, 0xf2, 0x10, 0x10, 0x00, 0x01, 0x00, 0x00, 0x00, 0x65, 0x00, 0x00, 0x03,
    0xf2, 0x20, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x68, 0x00, 0x00, 0x02, 0x01, 0x00, 0x00, 0x00,
    0x45, 0x00, 0x00, 0x09, 0xf2, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46, 0x10, 0x10, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x46, 0x7e, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0x10, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x38, 0x00, 0x00, 0x07, 0xf2, 0x20, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x46, 0x0e, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46, 0x1e, 0x10, 0x00, 0x01, 0x00, 0x00, 0x00,
    0x3e, 0x00, 0x00, 0x01, 0x53, 0x54, 0x41, 0x54, 0x74, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00,
    0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
};

// A combined image-sampler pair used to inject custom images and samplers into Dear ImGui.
//
// Create with simgui_make_image(), and convert to an ImTextureID handle via
// simgui_imtextureid().
const simgui_image_t = struct {
    id: u32,
};

/// Descriptor struct for simgui_make_image(). You must provide
/// at least an sg_image handle. Keeping the sg_sampler handle
/// zero-initialized will select the builtin default sampler
/// which uses linear filtering.
const simgui_image_desc_t = struct {
    image: sg.Image,
    sampler: sg.Sampler,
};

const simgui_desc_t = struct {
    max_vertices: u32 = 65536,
    image_pool_size: usize = 256,
    color_format: sg.PixelFormat = .DEFAULT,
    depth_format: sg.PixelFormat = .DEFAULT,
    sample_count: i32 = 0,
    ini_filename: ?[*:0]const u8 = null,
    no_default_font: bool = false,
    /// if true, don't send Ctrl-V on EVENTTYPE_CLIPBOARD_PASTED
    disable_paste_override: bool = false,
    /// if true, don't control the mouse cursor type via sapp_set_mouse_cursor()
    disable_set_mouse_cursor: bool = false,
    /// if true, only resize edges from the bottom right corner
    disable_windows_resize_from_edges: bool = false,
    /// if true, alpha values get written into the framebuffer
    write_alpha_channel: bool = false,
    allocator: Allocator,
};

const simgui_frame_desc_t = struct {
    width: i32,
    height: i32,
    delta_time: f64,
    dpi_scale: f32,
};

// SOKOL_IMGUI_API_DECL void simgui_setup(const simgui_desc_t* desc);
// SOKOL_IMGUI_API_DECL void simgui_new_frame(const simgui_frame_desc_t* desc);
// SOKOL_IMGUI_API_DECL void simgui_render(void);
// SOKOL_IMGUI_API_DECL simgui_image_t simgui_make_image(const simgui_image_desc_t* desc);
// SOKOL_IMGUI_API_DECL void simgui_destroy_image(simgui_image_t img);
// SOKOL_IMGUI_API_DECL simgui_image_desc_t simgui_query_image_desc(simgui_image_t img);
// SOKOL_IMGUI_API_DECL void* simgui_imtextureid(simgui_image_t img);
// SOKOL_IMGUI_API_DECL simgui_image_t simgui_image_from_imtextureid(void* imtextureid);
// SOKOL_IMGUI_API_DECL void simgui_add_focus_event(bool focus);
// SOKOL_IMGUI_API_DECL void simgui_add_mouse_pos_event(float x, float y);
// SOKOL_IMGUI_API_DECL void simgui_add_touch_pos_event(float x, float y);
// SOKOL_IMGUI_API_DECL void simgui_add_mouse_button_event(int mouse_button, bool down);
// SOKOL_IMGUI_API_DECL void simgui_add_mouse_wheel_event(float wheel_x, float wheel_y);
// SOKOL_IMGUI_API_DECL void simgui_add_key_event(int (*map_keycode)(int), int keycode, bool down);
// SOKOL_IMGUI_API_DECL void simgui_add_input_character(uint32_t c);
// SOKOL_IMGUI_API_DECL void simgui_add_input_characters_utf8(const char* c);
// SOKOL_IMGUI_API_DECL void simgui_add_touch_button_event(int mouse_button, bool down);
// SOKOL_IMGUI_API_DECL bool simgui_handle_event(const sapp_event* ev);
// SOKOL_IMGUI_API_DECL int simgui_map_keycode(sapp_keycode keycode);  // returns ImGuiKey_*
// SOKOL_IMGUI_API_DECL void simgui_shutdown(void);

const _SIMGUI_INIT_COOKIE = 0xBABEBABE;
const _SIMGUI_INVALID_SLOT_INDEX = 0;
const _SIMGUI_SLOT_SHIFT = 16;
const _SIMGUI_MAX_POOL_SIZE = 1 << _SIMGUI_SLOT_SHIFT;
const _SIMGUI_SLOT_MASK = _SIMGUI_MAX_POOL_SIZE - 1;

// // helper macros and constants
// #define _simgui_def(val, def) (((val) == 0) ? (def) : (val))

const _simgui_vs_params_t = struct {
    disp_size: imgui.Vec2,
    _pad: [8]u8 = [_]u8{0} ** 8,
};

const _simgui_resource_state = enum(u32) {
    Initial,
    Alloc,
    Valid,
    Failed,
    Invalid,
};

const _simgui_slot_t = struct {
    id: u32 = 0,
    state: _simgui_resource_state = .Initial,
};

const _simgui_pool_t = struct {
    allocator: Allocator,
    size: usize,
    queue_top: usize,
    gen_ctrs: std.ArrayList(u32),
    free_queue: std.ArrayList(usize),
};

const _simgui_image_t = struct {
    slot: _simgui_slot_t = .{},
    image: sg.Image = .{},
    sampler: sg.Sampler = .{},
    pip: sg.Pipeline = .{},
};

const _simgui_image_pool_t = struct {
    pool: _simgui_pool_t,
    items: []_simgui_image_t,
};

const _simgui_state_t = struct {
    init_cookie: u32,
    desc: simgui_desc_t,
    cur_dpi_scale: f32,
    vbuf: sg.Buffer,
    ibuf: sg.Buffer,
    font_img: sg.Image,
    font_smp: sg.Sampler,
    default_font: simgui_image_t,
    def_img: sg.Image, // used as default image for user images
    def_smp: sg.Sampler, // used as default sampler for user images
    def_shd: sg.Shader,
    def_pip: sg.Pipeline,
    // separate shader and pipeline for unfilterable user images
    shd_unfilterable: sg.Shader,
    pip_unfilterable: sg.Pipeline,
    vertices: []imgui.DrawVert,
    indices: []imgui.DrawIdx,
    is_osx: bool,
    image_pool: _simgui_image_pool_t,
};

fn _simgui_set_clipboard(user_data: ?*anyopaque, text: ?[*:0]const u8) callconv(.C) void {
    _ = text;
    _ = user_data;
    // if (text) |t| sapp.setClipboardString();
    @panic("TODO: _simgui_set_clipboard");
}

fn _simgui_get_clipboard(user_data: ?*anyopaque) callconv(.C) ?[*:0]const u8 {
    _ = user_data;
    return sapp.getClipboardString();
}

// ██████   ██████   ██████  ██
// ██   ██ ██    ██ ██    ██ ██
// ██████  ██    ██ ██    ██ ██
// ██      ██    ██ ██    ██ ██
// ██       ██████   ██████  ███████
//
// >>pool
fn _simgui_init_pool(pool: *_simgui_pool_t, num: usize) !void {
    std.debug.assert(num >= 1);
    // slot 0 is reserved for the 'invalid id', so bump the pool size by 1
    pool.size = num + 1;
    pool.queue_top = 0;
    // generation counters indexable by pool slot index, slot 0 is reserved
    pool.gen_ctrs = try std.ArrayList(u32).initCapacity(pool.allocator, pool.size);
    _ = pool.gen_ctrs.addManyAsSliceAssumeCapacity(pool.size);
    // it's not a bug to only reserve 'num' here
    pool.free_queue = try std.ArrayList(usize).initCapacity(pool.allocator, num);
    _ = pool.free_queue.addManyAsSliceAssumeCapacity(num);
    // never allocate the zero-th pool item since the invalid id is 0
    var i = pool.size - 1;
    while (i >= 1) : (i -= 1) {
        pool.free_queue.items[pool.queue_top] = i;
        pool.queue_top += 1;
    }
}

// static void _simgui_discard_pool(_simgui_pool_t* pool) {
//     SOKOL_ASSERT(pool);
//     SOKOL_ASSERT(pool->free_queue);
//     _simgui_free(pool->free_queue);
//     pool->free_queue = 0;
//     SOKOL_ASSERT(pool->gen_ctrs);
//     _simgui_free(pool->gen_ctrs);
//     pool->gen_ctrs = 0;
//     pool->size = 0;
//     pool->queue_top = 0;
// }

fn _simgui_pool_alloc_index(pool: *_simgui_pool_t) usize {
    if (pool.queue_top > 0) {
        pool.queue_top -= 1;
        const slot_index = pool.free_queue.items[pool.queue_top];
        
        std.debug.assert(slot_index > 0 and slot_index < pool.size);
        return slot_index;
    } else {
        return _SIMGUI_INVALID_SLOT_INDEX;
    }
}

// static void _simgui_pool_free_index(_simgui_pool_t* pool, int slot_index) {
//     SOKOL_ASSERT((slot_index > _SIMGUI_INVALID_SLOT_INDEX) && (slot_index < pool->size));
//     SOKOL_ASSERT(pool);
//     SOKOL_ASSERT(pool->free_queue);
//     SOKOL_ASSERT(pool->queue_top < pool->size);
//     #ifdef SOKOL_DEBUG
//     // debug check against double-free
//     for (int i = 0; i < pool->queue_top; i++) {
//         SOKOL_ASSERT(pool->free_queue[i] != slot_index);
//     }
//     #endif
//     pool->free_queue[pool->queue_top++] = slot_index;
//     SOKOL_ASSERT(pool->queue_top <= (pool->size-1));
// }

/// initiailize a pool slot:
///  - bump the slot's generation counter
///  - create a resource id from the generation counter and slot index
///  - set the slot's id to this id
///  - set the slot's state to ALLOC
///  - return the handle id
fn _simgui_slot_init(pool: *_simgui_pool_t, slot: *_simgui_slot_t, slot_index: usize) u32 {
    // FIXME: add handling for an overflowing generation counter,
    // for now, just overflow (another option is to disable
    // the slot)
    std.debug.assert((slot_index > _SIMGUI_INVALID_SLOT_INDEX) and (slot_index < pool.size));
    std.debug.assert((slot.state == .Initial) and (slot.id == INVALID_ID));
    pool.gen_ctrs.items[slot_index] += 1;
    const ctr = pool.gen_ctrs.items[slot_index];
    slot.id = (ctr << _SIMGUI_SLOT_SHIFT) | @as(u32, @intCast(slot_index & _SIMGUI_SLOT_MASK));
    slot.state = .Alloc;
    return slot.id;
}

/// extract slot index from id
fn _simgui_slot_index(id: u32) usize {
    const slot_index: usize = @intCast(id & _SIMGUI_SLOT_MASK);
    std.debug.assert(_SIMGUI_INVALID_SLOT_INDEX != slot_index);
    return slot_index;
}

fn _simgui_init_item_pool(pool: *_simgui_pool_t, pool_size: usize, items_ptr: *[]_simgui_image_t) !void {
    // NOTE: the pools will have an additional item, since slot 0 is reserved
    std.debug.assert(pool.size == 0);
    std.debug.assert((pool_size > 0) and (pool_size < _SIMGUI_MAX_POOL_SIZE));
    try _simgui_init_pool(pool, pool_size);
    items_ptr.* = try pool.allocator.alloc(_simgui_image_t, pool.size);
    for (items_ptr.*) |*item| {
        item.* = .{};
    }
}

// static void _simgui_discard_item_pool(_simgui_pool_t* pool, void** items_ptr) {
//     SOKOL_ASSERT(pool && (pool->size != 0));
//     SOKOL_ASSERT(items_ptr && (*items_ptr != 0));
//     _simgui_free(*items_ptr); *items_ptr = 0;
//     _simgui_discard_pool(pool);
// }

fn _simgui_setup_image_pool(allocator: Allocator, pool_size: usize) !void {
    const p = &_simgui.image_pool;
    p.pool.allocator = allocator;
    try _simgui_init_item_pool(&p.pool, pool_size, &p.items);
}

// static void _simgui_discard_image_pool(void) {
//     _simgui_image_pool_t* p = &_simgui.image_pool;
//     _simgui_discard_item_pool(&p->pool, (void**)&p->items);
// }

fn _simgui_make_image_handle(id: u32) simgui_image_t {
    return .{ .id = id };
}

fn _simgui_image_at(id: u32) *_simgui_image_t {
    std.debug.assert(id != INVALID_ID);
    const p = &_simgui.image_pool;
    const slot_index = _simgui_slot_index(id);
    std.debug.assert(slot_index > _SIMGUI_INVALID_SLOT_INDEX and slot_index < p.pool.size);
    return &p.items[slot_index];
}

fn _simgui_lookup_image(id: u32) ?*_simgui_image_t {
    if (id != INVALID_ID) {
        const img = _simgui_image_at(id);
        if (img.slot.id == id) {
            return img;
        }
    }
    return null;
}

fn _simgui_alloc_image() simgui_image_t {
    const p = &_simgui.image_pool;
    const slot_index = _simgui_pool_alloc_index(&p.pool);
    if (_SIMGUI_INVALID_SLOT_INDEX != slot_index) {
        const id = _simgui_slot_init(&p.pool, &p.items[slot_index].slot, slot_index);
        return _simgui_make_image_handle(id);
    } else {
        // pool exhausted
        return _simgui_make_image_handle(INVALID_ID);
    }
}

fn _simgui_init_image(img: *_simgui_image_t, desc: *const simgui_image_desc_t) _simgui_resource_state {
    std.debug.assert(img.slot.state == .Alloc);
    std.debug.assert(_simgui.def_pip.id != INVALID_ID);
    std.debug.assert(_simgui.pip_unfilterable.id != INVALID_ID);
    img.image = desc.image;
    img.sampler = desc.sampler;
    img.pip = if (sg.queryPixelformat(sg.queryImageDesc(desc.image).pixel_format).filter) _simgui.def_pip else _simgui.pip_unfilterable;
    return .Valid;
}

fn _simgui_deinit_image(img: *_simgui_image_t) void {
    img.image.id = INVALID_ID;
    img.sampler.id = INVALID_ID;
    img.pip.id = INVALID_ID;
}

fn _simgui_destroy_image(img_id: simgui_image_t) void {
    if (_simgui_lookup_image(img_id.id)) |img| {
        _simgui_deinit_image(img);
        const p = &_simgui.image_pool;
        _ = p;
        img.* = .{};
        // TODO _simgui_pool_free_index(&p.pool, _simgui_slot_index(img_id.id));
    }
}

fn _simgui_destroy_all_images() void {
    const p = &_simgui.image_pool;
    for (p.items) |*img| {
        _simgui_destroy_image(_simgui_make_image_handle(img.slot.id));
    }
}

// static simgui_image_desc_t _simgui_image_desc_defaults(const simgui_image_desc_t* desc) {
//     SOKOL_ASSERT(desc);
//     simgui_image_desc_t res = *desc;
//     res.image.id = _simgui_def(res.image.id, _simgui.def_img.id);
//     res.sampler.id = _simgui_def(res.sampler.id, _simgui.def_smp.id);
//     return res;
// }

// static bool _simgui_is_osx(void) {
//     #if defined(SOKOL_DUMMY_BACKEND)
//         return false;
//     #elif defined(__EMSCRIPTEN__)
//         return simgui_js_is_osx();
//     #elif defined(__APPLE__)
//         return true;
//     #else
//         return false;
//     #endif
// }

var _simgui: _simgui_state_t = undefined;

// ██████  ██    ██ ██████  ██      ██  ██████
// ██   ██ ██    ██ ██   ██ ██      ██ ██
// ██████  ██    ██ ██████  ██      ██ ██
// ██      ██    ██ ██   ██ ██      ██ ██
// ██       ██████  ██████  ███████ ██  ██████
//
// >>public
pub fn simgui_setup(desc: simgui_desc_t) !void {
    _simgui.desc = desc;
    _simgui.init_cookie = _SIMGUI_INIT_COOKIE;
    _simgui.cur_dpi_scale = 1.0;
    _simgui.is_osx = builtin.os.tag == .macos;
    // can keep color_format, depth_format and sample_count as is,
    // since sokol_gfx.h will do its own default-value handling

    // setup image pool
    try _simgui_setup_image_pool(desc.allocator, _simgui.desc.image_pool_size);

    // allocate an intermediate vertex- and index-buffer
    std.debug.assert(_simgui.desc.max_vertices > 0);
    _simgui.vertices = try desc.allocator.alloc(imgui.DrawVert, _simgui.desc.max_vertices);
    _simgui.indices = try desc.allocator.alloc(imgui.DrawIdx, _simgui.desc.max_vertices * 3);

    // initialize Dear ImGui
    _ = imgui.CreateContext() orelse @panic("todo: CreateContext");
    imgui.StyleColorsDark();
    var io = imgui.GetIO();
    if (!_simgui.desc.no_default_font) {
        _ = io.Fonts.?.AddFontDefault() orelse @panic("todo: addFontDefault");
    }
    io.IniFilename = _simgui.desc.ini_filename;
    io.ConfigMacOSXBehaviors = _simgui.is_osx;
    io.BackendFlags.RendererHasVtxOffset = true;
    if (!_simgui.desc.disable_set_mouse_cursor) {
        io.BackendFlags.HasMouseCursors = true;
    }
    io.SetClipboardTextFn = @constCast(&_simgui_set_clipboard);
    io.GetClipboardTextFn = @constCast(&_simgui_get_clipboard);
    io.ConfigWindowsResizeFromEdges = !_simgui.desc.disable_windows_resize_from_edges;

    // create sokol-gfx resources
    sg.pushDebugGroup("sokol-imgui");

    // shader object for using the embedded shader source (or bytecode)
    var shd_desc = sg.ShaderDesc{};
    shd_desc.attrs[0].name = "position";
    shd_desc.attrs[1].name = "texcoord0";
    shd_desc.attrs[2].name = "color0";
    shd_desc.attrs[0].sem_name = "TEXCOORD";
    shd_desc.attrs[0].sem_index = 0;
    shd_desc.attrs[1].sem_name = "TEXCOORD";
    shd_desc.attrs[1].sem_index = 1;
    shd_desc.attrs[2].sem_name = "TEXCOORD";
    shd_desc.attrs[2].sem_index = 2;
    const ub = &shd_desc.vs.uniform_blocks[0];
    ub.size = @sizeOf(_simgui_vs_params_t);
    ub.uniforms[0].name = "vs_params";
    ub.uniforms[0].type = .FLOAT4;
    ub.uniforms[0].array_count = 1;
    shd_desc.fs.images[0].used = true;
    shd_desc.fs.images[0].image_type = ._2D;
    shd_desc.fs.images[0].sample_type = .FLOAT;
    shd_desc.fs.samplers[0].used = true;
    shd_desc.fs.samplers[0].sampler_type = .FILTERING;
    shd_desc.fs.image_sampler_pairs[0].used = true;
    shd_desc.fs.image_sampler_pairs[0].image_slot = 0;
    shd_desc.fs.image_sampler_pairs[0].sampler_slot = 0;
    shd_desc.fs.image_sampler_pairs[0].glsl_name = "tex_smp";
    shd_desc.label = "sokol-imgui-shader";
    switch (sg.queryBackend()) {
        .GLCORE33 => {
            //     shd_desc.vs.source = _simgui_vs_source_glsl330;
            //     shd_desc.fs.source = _simgui_fs_source_glsl330;
            @panic("shader backend");
        },
        .GLES3 => {
            //     shd_desc.vs.source = _simgui_vs_source_glsl300es;
            //     shd_desc.fs.source = _simgui_fs_source_glsl300es;
            @panic("shader backend");
        },
        .D3D11 => {
            shd_desc.vs.bytecode = sg.asRange(&_simgui_vs_bytecode_hlsl4);
            shd_desc.fs.bytecode = sg.asRange(&_simgui_fs_bytecode_hlsl4);
        },
        .METAL_IOS, .METAL_MACOS, .METAL_SIMULATOR => |metal_kind| {
            _ = metal_kind;
            //     shd_desc.vs.entry = "main0";
            //     shd_desc.fs.entry = "main0";
            //     switch (sg_query_backend()) {
            //         case SG_BACKEND_METAL_MACOS:
            //             shd_desc.vs.bytecode = SG_RANGE(_simgui_vs_bytecode_metal_macos);
            //             shd_desc.fs.bytecode = SG_RANGE(_simgui_fs_bytecode_metal_macos);
            //             break;
            //         case SG_BACKEND_METAL_IOS:
            //             shd_desc.vs.bytecode = SG_RANGE(_simgui_vs_bytecode_metal_ios);
            //             shd_desc.fs.bytecode = SG_RANGE(_simgui_fs_bytecode_metal_ios);
            //             break;
            //         default:
            //             shd_desc.vs.source = _simgui_vs_source_metal_sim;
            //             shd_desc.fs.source = _simgui_fs_source_metal_sim;
            //             break;
            //     }
            @panic("shader backend");
        },
        .WGPU => {
            //     shd_desc.vs.source = _simgui_vs_source_wgsl;
            //     shd_desc.fs.source = _simgui_fs_source_wgsl;
            @panic("shader backend");
        },
        .DUMMY => {
            //     shd_desc.vs.source = _simgui_vs_source_dummy;
            //     shd_desc.fs.source = _simgui_fs_source_dummy;
            @panic("shader backend");
        },
    }
    _simgui.def_shd = sg.makeShader(shd_desc);

    // pipeline object for imgui rendering
    var pip_desc = sg.PipelineDesc{};
    pip_desc.layout.buffers[0].stride = @sizeOf(imgui.DrawVert);
    {
        const attr = &pip_desc.layout.attrs[0];
        attr.offset = @offsetOf(imgui.DrawVert, "pos");
        attr.format = .FLOAT2;
    }
    {
        const attr = &pip_desc.layout.attrs[1];
        attr.offset = @offsetOf(imgui.DrawVert, "uv");
        attr.format = .FLOAT2;
    }
    {
        const attr = &pip_desc.layout.attrs[2];
        attr.offset = @offsetOf(imgui.DrawVert, "col");
        attr.format = .UBYTE4N;
    }
    pip_desc.shader = _simgui.def_shd;
    pip_desc.index_type = .UINT16;
    pip_desc.sample_count = _simgui.desc.sample_count;
    pip_desc.depth.pixel_format = _simgui.desc.depth_format;
    pip_desc.colors[0].pixel_format = _simgui.desc.color_format;
    pip_desc.colors[0].write_mask = if (_simgui.desc.write_alpha_channel) .RGBA else .RGB;
    pip_desc.colors[0].blend.enabled = true;
    pip_desc.colors[0].blend.src_factor_rgb = .SRC_ALPHA;
    pip_desc.colors[0].blend.dst_factor_rgb = .ONE_MINUS_SRC_ALPHA;
    if (_simgui.desc.write_alpha_channel) {
        pip_desc.colors[0].blend.src_factor_alpha = .ONE;
        pip_desc.colors[0].blend.dst_factor_alpha = .ONE;
    }
    pip_desc.label = "sokol-imgui-pipeline";
    _simgui.def_pip = sg.makePipeline(pip_desc);

    // create a unfilterable/nonfiltering variants of the shader and pipeline
    shd_desc.fs.images[0].sample_type = .UNFILTERABLE_FLOAT;
    shd_desc.fs.samplers[0].sampler_type = .NONFILTERING;
    shd_desc.label = "sokol-imgui-shader-unfilterable";
    _simgui.shd_unfilterable = sg.makeShader(shd_desc);
    pip_desc.shader = _simgui.shd_unfilterable;
    pip_desc.label = "sokol-imgui-pipeline-unfilterable";
    _simgui.pip_unfilterable = sg.makePipeline(pip_desc);

    _simgui.vbuf = sg.makeBuffer(.{
        .usage = .STREAM,
        .size = _simgui.vertices.len,
        .label = "sokol-imgui-vertices",
    });

    _simgui.ibuf = sg.makeBuffer(.{
        .type = .INDEXBUFFER,
        .usage = .STREAM,
        .size = _simgui.indices.len,
        .label = "sokol-imgui-indices",
    });

    // a default font sampler
    _simgui.font_smp = sg.makeSampler(.{
        .wrap_u = .CLAMP_TO_EDGE,
        .wrap_v = .CLAMP_TO_EDGE,
        .min_filter = .LINEAR,
        .mag_filter = .LINEAR,
        .mipmap_filter = .NONE,
        .label = "sokol-imgui-font-sampler",
    });

    // a default user-image sampler
    _simgui.def_smp = sg.makeSampler(.{
        .wrap_u = .CLAMP_TO_EDGE,
        .wrap_v = .CLAMP_TO_EDGE,
        .min_filter = .NEAREST,
        .mag_filter = .NEAREST,
        .mipmap_filter = .NONE,
        .label = "sokol-imgui-default-sampler",
    });

    // a default user image
    const def_pixels: [64]u32 = [_]u32{0xFFFF_FFFF} ** 64;
    var data: sg.ImageData = .{};
    data.subimage[0][0].ptr = @as(*u8, @ptrCast(@constCast(&def_pixels)));
    data.subimage[0][0].size = @sizeOf([64]u32);
    _simgui.def_img = sg.makeImage(.{
        .width = 8,
        .height = 8,
        .pixel_format = .RGBA8,
        .data = data,
        .label = "sokol-imgui-default-image",
    });

    // default font texture
    if (!_simgui.desc.no_default_font) {
        var font_pixels: ?[*]u8 = undefined;
        var font_width: i32 = undefined;
        var font_height: i32 = undefined;
        var bytes_per_pixel: i32 = undefined;
        imgui.raw.ImFontAtlas_GetTexDataAsRGBA32(io.Fonts.?, &font_pixels, &font_width, &font_height, &bytes_per_pixel);

        var font_data: sg.ImageData = .{};
        font_data.subimage[0][0].ptr = font_pixels.?;
        font_data.subimage[0][0].size = @as(usize, @intCast(font_width * font_height)) * @sizeOf(u32);
        _simgui.font_img = sg.makeImage(.{
            .width = font_width,
            .height = font_height,
            .pixel_format = .RGBA8,
            .data = font_data,
            .label = "sokol-imgui-font-image",
        });

        _simgui.default_font = try simgui_make_image(.{
            .image = _simgui.font_img,
            .sampler = _simgui.font_smp,
        });
        io.Fonts.?.TexID = simgui_imtextureid(_simgui.default_font);
    }

    sg.popDebugGroup();
}

pub fn simgui_shutdown() void {
    std.debug.assert(_simgui.init_cookie == _SIMGUI_INIT_COOKIE);

    imgui.DestroyContext();
    // NOTE: it's valid to call the destroy funcs with SG_INVALID_ID
    sg.destroyPipeline(_simgui.pip_unfilterable);
    sg.destroyShader(_simgui.shd_unfilterable);
    sg.destroyPipeline(_simgui.def_pip);
    sg.destroyShader(_simgui.def_shd);
    sg.destroySampler(_simgui.font_smp);
    sg.destroyImage(_simgui.font_img);
    sg.destroySampler(_simgui.def_smp);
    sg.destroyImage(_simgui.def_img);
    sg.destroyBuffer(_simgui.ibuf);
    sg.destroyBuffer(_simgui.vbuf);
    sg.popDebugGroup();
    sg.pushDebugGroup("sokol-imgui");
    _simgui_destroy_all_images();
    // TODO _simgui_discard_image_pool();

    _simgui.desc.allocator.free(_simgui.vertices);
    _simgui.desc.allocator.free(_simgui.indices);
    _simgui.init_cookie = 0;
}

pub fn simgui_make_image(desc: simgui_image_desc_t) !simgui_image_t {
    std.debug.assert(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);

    const img_id = _simgui_alloc_image();
    const img = _simgui_lookup_image(img_id.id);

    if (img) |i| {
        i.slot.state = _simgui_init_image(i, &desc);
        std.debug.assert((i.slot.state == .Valid) or (i.slot.state == .Failed));
    } else {
        //     _SIMGUI_ERROR(IMAGE_POOL_EXHAUSTED);
        @panic("image_pool_exhausted");
    }
    return img_id;
}

// SOKOL_API_IMPL void simgui_destroy_image(simgui_image_t img_id) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//     _simgui_destroy_image(img_id);
// }

// SOKOL_API_IMPL simgui_image_desc_t simgui_query_image_desc(simgui_image_t img_id) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//     _simgui_image_t* img = _simgui_lookup_image(img_id.id);
//     simgui_image_desc_t desc;
//     _simgui_clear(&desc, sizeof(desc));
//     if (img) {
//         desc.image = img->image;
//         desc.sampler = img->sampler;
//     }
//     return desc;
// }

pub fn simgui_imtextureid(img: simgui_image_t) imgui.TextureID {
    std.debug.assert(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
    // return (void*)(uintptr_t)img.id;
    return @enumFromInt(img.id);
}

// SOKOL_API_IMPL simgui_image_t simgui_image_from_imtextureid(void* imtextureid) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//     simgui_image_t img = { (uint32_t)(uintptr_t) imtextureid };
//     return img;
// }

pub fn simgui_new_frame(desc: simgui_frame_desc_t) void {
    std.debug.assert(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
    std.debug.assert(desc.width > 0);
    std.debug.assert(desc.height > 0);
    _simgui.cur_dpi_scale = desc.dpi_scale;

    const io = imgui.GetIO();
    io.DisplaySize.x = @as(f32, @floatFromInt(desc.width)) / _simgui.cur_dpi_scale;
    io.DisplaySize.y = @as(f32, @floatFromInt(desc.height)) / _simgui.cur_dpi_scale;
    io.DeltaTime = @floatCast(desc.delta_time);

    if (io.WantTextInput and !sapp.keyboardShown()) {
        sapp.showKeyboard(true);
    }

    if (!io.WantTextInput and sapp.keyboardShown()) {
        sapp.showKeyboard(false);
    }

    if (!_simgui.desc.disable_set_mouse_cursor) {
        const imgui_cursor = imgui.GetMouseCursor();
        const cursor = switch (imgui_cursor) {
            .Arrow => .ARROW,
            .TextInput => .IBEAM,
            .ResizeAll => .RESIZE_ALL,
            .ResizeNS => .RESIZE_NS,
            .ResizeEW => .RESIZE_EW,
            .ResizeNESW => .RESIZE_NESW,
            .ResizeNWSE => .RESIZE_NWSE,
            .Hand => .POINTING_HAND,
            .NotAllowed => .NOT_ALLOWED,
            else => sapp.getMouseCursor(),
        };
        sapp.setMouseCursor(cursor);
    }

    imgui.NewFrame();
}

fn _simgui_bind_image_sampler(bindings: *sg.Bindings, tex_id: imgui.TextureID) ?*_simgui_image_t {
    const img = _simgui_lookup_image(@intCast(@intFromEnum(tex_id)));
    if (img) |i| {
        bindings.fs.images[0] = i.image;
        bindings.fs.samplers[0] = i.sampler;
    } else {
        bindings.fs.images[0] = _simgui.def_img;
        bindings.fs.samplers[0] = _simgui.def_smp;
    }
    return img;
}

fn _simgui_imdrawlist_at(draw_data: *imgui.DrawData, cl_index: usize) *imgui.DrawList {
    return draw_data.CmdLists.Data.?[cl_index].?;
}

pub fn simgui_render() void {
    std.debug.assert(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);

    imgui.Render();
    const draw_data = imgui.GetDrawData();
    const io = imgui.GetIO();

    if (@intFromPtr(draw_data) == 0 or draw_data.CmdListsCount == 0) {
        return;
    }

    // copy vertices and indices into an intermediate buffer so that
    // they can be updated with a single sg_update_buffer() call each
    // (sg_append_buffer() has performance problems on some GL platforms),
    // also keep track of valid number of command lists in case of a
    // buffer overflow
    var all_vtx_size: usize = 0;
    var all_idx_size: usize = 0;
    var cmd_list_count: usize = 0;
    for (0..@as(usize, @intCast(draw_data.CmdListsCount))) |cl_index| {
        cmd_list_count += 1;
        const cl = _simgui_imdrawlist_at(draw_data, cl_index);
        const vtx_size = cl.VtxBuffer.Size * @sizeOf(imgui.DrawVert);
        const idx_size = cl.IdxBuffer.Size * @sizeOf(imgui.DrawIdx);

        // check for buffer overflow
        if (((all_vtx_size + vtx_size) > _simgui.vertices.len) or ((all_idx_size + idx_size) > _simgui.indices.len)) {
            break;
        }

        // copy vertices and indices into common buffers
        if (vtx_size > 0) {
            const src: []imgui.DrawVert = cl.VtxBuffer.Data.?[0..cl.VtxBuffer.Size];
            const dst = _simgui.vertices[all_vtx_size / @sizeOf(imgui.DrawVert) ..];
            @memcpy(dst[0..src.len], src);
        }
        if (idx_size > 0) {
            const src: []imgui.DrawIdx = cl.IdxBuffer.Data.?[0..cl.IdxBuffer.Size];
            const dst = _simgui.indices[all_idx_size / @sizeOf(imgui.DrawIdx) ..];
            @memcpy(dst[0..src.len], src);
        }

        all_vtx_size += vtx_size;
        all_idx_size += idx_size;
    }

    if (0 == cmd_list_count) {
        return;
    }

    // update the sokol-gfx vertex- and index-buffer
    sg.pushDebugGroup("sokol-imgui");
    if (all_vtx_size > 0) {
        // sg_range vtx_data = _simgui.vertices;
        // vtx_data.size = all_vtx_size;
        // sg_update_buffer(_simgui.vbuf, &vtx_data);
        sg.updateBuffer(_simgui.vbuf, .{
            .ptr = _simgui.vertices.ptr,
            .size = all_vtx_size,
        });
    }
    if (all_idx_size > 0) {
        sg.updateBuffer(_simgui.ibuf, .{
            .ptr = _simgui.indices.ptr,
            .size = all_idx_size,
        });
    }

    // render the ImGui command list
    const dpi_scale = _simgui.cur_dpi_scale;
    const fb_width: i32 = @intFromFloat(io.DisplaySize.x * dpi_scale);
    const fb_height: i32 = @intFromFloat(io.DisplaySize.y * dpi_scale);
    sg.applyViewport(0, 0, fb_width, fb_height, true);
    sg.applyScissorRect(0, 0, fb_width, fb_height, true);

    sg.applyPipeline(_simgui.def_pip);

    const vs_params = _simgui_vs_params_t{ .disp_size = io.DisplaySize };
    sg.applyUniforms(.VS, 0, sg.asRange(&vs_params));

    var bind = sg.Bindings{ .index_buffer = _simgui.ibuf };
    bind.vertex_buffers[0] = _simgui.vbuf;
    var tex_id = io.Fonts.?.TexID;
    _ = _simgui_bind_image_sampler(&bind, tex_id);

    var vb_offset: i32 = 0;
    var ib_offset: i32 = 0;
    for (0..cmd_list_count) |cl_index| {
        const cl = _simgui_imdrawlist_at(draw_data, cl_index);

        bind.vertex_buffer_offsets[0] = vb_offset;
        bind.index_buffer_offset = ib_offset;
        sg.applyBindings(bind);

        const num_cmds = cl.CmdBuffer.Size;
        var vtx_offset: u32 = 0;
        for (0..num_cmds) |cmd_index| {
            //             ImDrawCmd* pcmd = &cl->CmdBuffer.Data[cmd_index];
            const pcmd: *imgui.DrawCmd = &cl.CmdBuffer.Data.?[cmd_index];
            if (pcmd.UserCallback) |callback| {
                _ = callback;
                @panic("todo: usercallback");
                // pcmd->UserCallback(cl, pcmd);
                // // need to re-apply all state after calling a user callback
                // sg_apply_viewport(0, 0, fb_width, fb_height, true);
                // sg_apply_pipeline(_simgui.def_pip);
                // sg_apply_uniforms(SG_SHADERSTAGE_VS, 0, SG_RANGE_REF(vs_params));
                // sg_apply_bindings(&bind);
            } else {
                if ((tex_id != pcmd.TextureId) or (vtx_offset != pcmd.VtxOffset)) {
                    tex_id = pcmd.TextureId;
                    vtx_offset = pcmd.VtxOffset;
                    const img = _simgui_bind_image_sampler(&bind, tex_id);
                    sg.applyPipeline(if (img) |i| i.pip else _simgui.def_pip);
                    sg.applyUniforms(.VS, 0, sg.asRange(&vs_params));
                    bind.vertex_buffer_offsets[0] = vb_offset + @as(i32, @intCast(pcmd.VtxOffset * @sizeOf(imgui.DrawVert)));
                    sg.applyBindings(bind);
                }
                const scissor_x: i32 = @intFromFloat(pcmd.ClipRect.x * dpi_scale);
                const scissor_y: i32 = @intFromFloat(pcmd.ClipRect.y * dpi_scale);
                const scissor_w: i32 = @intFromFloat((pcmd.ClipRect.z - pcmd.ClipRect.x) * dpi_scale);
                const scissor_h: i32 = @intFromFloat((pcmd.ClipRect.w - pcmd.ClipRect.y) * dpi_scale);
                sg.applyScissorRect(scissor_x, scissor_y, scissor_w, scissor_h, true);
                sg.draw(pcmd.IdxOffset, pcmd.ElemCount, 1);
            }
        }
        const vtx_size = cl.VtxBuffer.Size * @sizeOf(imgui.DrawVert);
        const idx_size = cl.IdxBuffer.Size * @sizeOf(imgui.DrawIdx);
        vb_offset += @intCast(vtx_size);
        ib_offset += @intCast(idx_size);
    }
    sg.applyViewport(0, 0, fb_width, fb_height, true);
    sg.applyScissorRect(0, 0, fb_width, fb_height, true);
    sg.popDebugGroup();
}

// SOKOL_API_IMPL void simgui_add_focus_event(bool focus) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//         ImGuiIO* io = igGetIO();
//         ImGuiIO_AddFocusEvent(io, focus);
// }

// SOKOL_API_IMPL void simgui_add_mouse_pos_event(float x, float y) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//         ImGuiIO* io = igGetIO();
//         ImGuiIO_AddMouseSourceEvent(io, ImGuiMouseSource_Mouse);
//         ImGuiIO_AddMousePosEvent(io, x, y);
// }

// SOKOL_API_IMPL void simgui_add_touch_pos_event(float x, float y) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//         ImGuiIO* io = igGetIO();
//         ImGuiIO_AddMouseSourceEvent(io, ImGuiMouseSource_TouchScreen);
//         ImGuiIO_AddMousePosEvent(io, x, y);
// }

// SOKOL_API_IMPL void simgui_add_mouse_button_event(int mouse_button, bool down) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//         ImGuiIO* io = igGetIO();
//         ImGuiIO_AddMouseSourceEvent(io, ImGuiMouseSource_Mouse);
//         ImGuiIO_AddMouseButtonEvent(io, mouse_button, down);
// }

// SOKOL_API_IMPL void simgui_add_touch_button_event(int mouse_button, bool down) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//         ImGuiIO* io = igGetIO();
//         ImGuiIO_AddMouseSourceEvent(io, ImGuiMouseSource_TouchScreen);
//         ImGuiIO_AddMouseButtonEvent(io, mouse_button, down);
// }

// SOKOL_API_IMPL void simgui_add_mouse_wheel_event(float wheel_x, float wheel_y) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//         ImGuiIO* io = igGetIO();
//         ImGuiIO_AddMouseSourceEvent(io, ImGuiMouseSource_Mouse);
//         ImGuiIO_AddMouseWheelEvent(io, wheel_x, wheel_y);
// }

// SOKOL_API_IMPL void simgui_add_key_event(int (*map_keycode)(int), int keycode, bool down) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//     const ImGuiKey imgui_key = (ImGuiKey)map_keycode(keycode);
//         ImGuiIO* io = igGetIO();
//         ImGuiIO_AddKeyEvent(io, imgui_key, down);
//         ImGuiIO_SetKeyEventNativeData(io, imgui_key, keycode, 0, -1);
// }

// SOKOL_API_IMPL void simgui_add_input_character(uint32_t c) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//         ImGuiIO* io = igGetIO();
//         ImGuiIO_AddInputCharacter(io, c);
// }

// SOKOL_API_IMPL void simgui_add_input_characters_utf8(const char* c) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//         ImGuiIO* io = igGetIO();
//         ImGuiIO_AddInputCharactersUTF8(io, c);
// }

// _SOKOL_PRIVATE bool _simgui_is_ctrl(uint32_t modifiers) {
//     if (_simgui.is_osx) {
//         return 0 != (modifiers & SAPP_MODIFIER_SUPER);
//     } else {
//         return 0 != (modifiers & SAPP_MODIFIER_CTRL);
//     }
// }

// _SOKOL_PRIVATE ImGuiKey _simgui_map_keycode(sapp_keycode key) {
//     switch (key) {
//         case SAPP_KEYCODE_SPACE:        return ImGuiKey_Space;
//         case SAPP_KEYCODE_APOSTROPHE:   return ImGuiKey_Apostrophe;
//         case SAPP_KEYCODE_COMMA:        return ImGuiKey_Comma;
//         case SAPP_KEYCODE_MINUS:        return ImGuiKey_Minus;
//         case SAPP_KEYCODE_PERIOD:       return ImGuiKey_Apostrophe;
//         case SAPP_KEYCODE_SLASH:        return ImGuiKey_Slash;
//         case SAPP_KEYCODE_0:            return ImGuiKey_0;
//         case SAPP_KEYCODE_1:            return ImGuiKey_1;
//         case SAPP_KEYCODE_2:            return ImGuiKey_2;
//         case SAPP_KEYCODE_3:            return ImGuiKey_3;
//         case SAPP_KEYCODE_4:            return ImGuiKey_4;
//         case SAPP_KEYCODE_5:            return ImGuiKey_5;
//         case SAPP_KEYCODE_6:            return ImGuiKey_6;
//         case SAPP_KEYCODE_7:            return ImGuiKey_7;
//         case SAPP_KEYCODE_8:            return ImGuiKey_8;
//         case SAPP_KEYCODE_9:            return ImGuiKey_9;
//         case SAPP_KEYCODE_SEMICOLON:    return ImGuiKey_Semicolon;
//         case SAPP_KEYCODE_EQUAL:        return ImGuiKey_Equal;
//         case SAPP_KEYCODE_A:            return ImGuiKey_A;
//         case SAPP_KEYCODE_B:            return ImGuiKey_B;
//         case SAPP_KEYCODE_C:            return ImGuiKey_C;
//         case SAPP_KEYCODE_D:            return ImGuiKey_D;
//         case SAPP_KEYCODE_E:            return ImGuiKey_E;
//         case SAPP_KEYCODE_F:            return ImGuiKey_F;
//         case SAPP_KEYCODE_G:            return ImGuiKey_G;
//         case SAPP_KEYCODE_H:            return ImGuiKey_H;
//         case SAPP_KEYCODE_I:            return ImGuiKey_I;
//         case SAPP_KEYCODE_J:            return ImGuiKey_J;
//         case SAPP_KEYCODE_K:            return ImGuiKey_K;
//         case SAPP_KEYCODE_L:            return ImGuiKey_L;
//         case SAPP_KEYCODE_M:            return ImGuiKey_M;
//         case SAPP_KEYCODE_N:            return ImGuiKey_N;
//         case SAPP_KEYCODE_O:            return ImGuiKey_O;
//         case SAPP_KEYCODE_P:            return ImGuiKey_P;
//         case SAPP_KEYCODE_Q:            return ImGuiKey_Q;
//         case SAPP_KEYCODE_R:            return ImGuiKey_R;
//         case SAPP_KEYCODE_S:            return ImGuiKey_S;
//         case SAPP_KEYCODE_T:            return ImGuiKey_T;
//         case SAPP_KEYCODE_U:            return ImGuiKey_U;
//         case SAPP_KEYCODE_V:            return ImGuiKey_V;
//         case SAPP_KEYCODE_W:            return ImGuiKey_W;
//         case SAPP_KEYCODE_X:            return ImGuiKey_X;
//         case SAPP_KEYCODE_Y:            return ImGuiKey_Y;
//         case SAPP_KEYCODE_Z:            return ImGuiKey_Z;
//         case SAPP_KEYCODE_LEFT_BRACKET: return ImGuiKey_LeftBracket;
//         case SAPP_KEYCODE_BACKSLASH:    return ImGuiKey_Backslash;
//         case SAPP_KEYCODE_RIGHT_BRACKET:return ImGuiKey_RightBracket;
//         case SAPP_KEYCODE_GRAVE_ACCENT: return ImGuiKey_GraveAccent;
//         case SAPP_KEYCODE_ESCAPE:       return ImGuiKey_Escape;
//         case SAPP_KEYCODE_ENTER:        return ImGuiKey_Enter;
//         case SAPP_KEYCODE_TAB:          return ImGuiKey_Tab;
//         case SAPP_KEYCODE_BACKSPACE:    return ImGuiKey_Backspace;
//         case SAPP_KEYCODE_INSERT:       return ImGuiKey_Insert;
//         case SAPP_KEYCODE_DELETE:       return ImGuiKey_Delete;
//         case SAPP_KEYCODE_RIGHT:        return ImGuiKey_RightArrow;
//         case SAPP_KEYCODE_LEFT:         return ImGuiKey_LeftArrow;
//         case SAPP_KEYCODE_DOWN:         return ImGuiKey_DownArrow;
//         case SAPP_KEYCODE_UP:           return ImGuiKey_UpArrow;
//         case SAPP_KEYCODE_PAGE_UP:      return ImGuiKey_PageUp;
//         case SAPP_KEYCODE_PAGE_DOWN:    return ImGuiKey_PageDown;
//         case SAPP_KEYCODE_HOME:         return ImGuiKey_Home;
//         case SAPP_KEYCODE_END:          return ImGuiKey_End;
//         case SAPP_KEYCODE_CAPS_LOCK:    return ImGuiKey_CapsLock;
//         case SAPP_KEYCODE_SCROLL_LOCK:  return ImGuiKey_ScrollLock;
//         case SAPP_KEYCODE_NUM_LOCK:     return ImGuiKey_NumLock;
//         case SAPP_KEYCODE_PRINT_SCREEN: return ImGuiKey_PrintScreen;
//         case SAPP_KEYCODE_PAUSE:        return ImGuiKey_Pause;
//         case SAPP_KEYCODE_F1:           return ImGuiKey_F1;
//         case SAPP_KEYCODE_F2:           return ImGuiKey_F2;
//         case SAPP_KEYCODE_F3:           return ImGuiKey_F3;
//         case SAPP_KEYCODE_F4:           return ImGuiKey_F4;
//         case SAPP_KEYCODE_F5:           return ImGuiKey_F5;
//         case SAPP_KEYCODE_F6:           return ImGuiKey_F6;
//         case SAPP_KEYCODE_F7:           return ImGuiKey_F7;
//         case SAPP_KEYCODE_F8:           return ImGuiKey_F8;
//         case SAPP_KEYCODE_F9:           return ImGuiKey_F9;
//         case SAPP_KEYCODE_F10:          return ImGuiKey_F10;
//         case SAPP_KEYCODE_F11:          return ImGuiKey_F11;
//         case SAPP_KEYCODE_F12:          return ImGuiKey_F12;
//         case SAPP_KEYCODE_KP_0:         return ImGuiKey_Keypad0;
//         case SAPP_KEYCODE_KP_1:         return ImGuiKey_Keypad1;
//         case SAPP_KEYCODE_KP_2:         return ImGuiKey_Keypad2;
//         case SAPP_KEYCODE_KP_3:         return ImGuiKey_Keypad3;
//         case SAPP_KEYCODE_KP_4:         return ImGuiKey_Keypad4;
//         case SAPP_KEYCODE_KP_5:         return ImGuiKey_Keypad5;
//         case SAPP_KEYCODE_KP_6:         return ImGuiKey_Keypad6;
//         case SAPP_KEYCODE_KP_7:         return ImGuiKey_Keypad7;
//         case SAPP_KEYCODE_KP_8:         return ImGuiKey_Keypad8;
//         case SAPP_KEYCODE_KP_9:         return ImGuiKey_Keypad9;
//         case SAPP_KEYCODE_KP_DECIMAL:   return ImGuiKey_KeypadDecimal;
//         case SAPP_KEYCODE_KP_DIVIDE:    return ImGuiKey_KeypadDivide;
//         case SAPP_KEYCODE_KP_MULTIPLY:  return ImGuiKey_KeypadMultiply;
//         case SAPP_KEYCODE_KP_SUBTRACT:  return ImGuiKey_KeypadSubtract;
//         case SAPP_KEYCODE_KP_ADD:       return ImGuiKey_KeypadAdd;
//         case SAPP_KEYCODE_KP_ENTER:     return ImGuiKey_KeypadEnter;
//         case SAPP_KEYCODE_KP_EQUAL:     return ImGuiKey_KeypadEqual;
//         case SAPP_KEYCODE_LEFT_SHIFT:   return ImGuiKey_LeftShift;
//         case SAPP_KEYCODE_LEFT_CONTROL: return ImGuiKey_LeftCtrl;
//         case SAPP_KEYCODE_LEFT_ALT:     return ImGuiKey_LeftAlt;
//         case SAPP_KEYCODE_LEFT_SUPER:   return ImGuiKey_LeftSuper;
//         case SAPP_KEYCODE_RIGHT_SHIFT:  return ImGuiKey_RightShift;
//         case SAPP_KEYCODE_RIGHT_CONTROL:return ImGuiKey_RightCtrl;
//         case SAPP_KEYCODE_RIGHT_ALT:    return ImGuiKey_RightAlt;
//         case SAPP_KEYCODE_RIGHT_SUPER:  return ImGuiKey_RightSuper;
//         case SAPP_KEYCODE_MENU:         return ImGuiKey_Menu;
//         default:                        return ImGuiKey_None;
//     }
// }

// _SOKOL_PRIVATE void _simgui_add_sapp_key_event(ImGuiIO* io, sapp_keycode sapp_key, bool down) {
//     const ImGuiKey imgui_key = _simgui_map_keycode(sapp_key);
//         ImGuiIO_AddKeyEvent(io, imgui_key, down);
//         ImGuiIO_SetKeyEventNativeData(io, imgui_key, (int)sapp_key, 0, -1);
// }

// _SOKOL_PRIVATE void _simgui_add_imgui_key_event(ImGuiIO* io, ImGuiKey imgui_key, bool down) {
//         ImGuiIO_AddKeyEvent(io, imgui_key, down);
// }

// _SOKOL_PRIVATE void _simgui_update_modifiers(ImGuiIO* io, uint32_t mods) {
//     _simgui_add_imgui_key_event(io, ImGuiMod_Ctrl, (mods & SAPP_MODIFIER_CTRL) != 0);
//     _simgui_add_imgui_key_event(io, ImGuiMod_Shift, (mods & SAPP_MODIFIER_SHIFT) != 0);
//     _simgui_add_imgui_key_event(io, ImGuiMod_Alt, (mods & SAPP_MODIFIER_ALT) != 0);
//     _simgui_add_imgui_key_event(io, ImGuiMod_Super, (mods & SAPP_MODIFIER_SUPER) != 0);
// }

// // returns Ctrl or Super, depending on platform
// _SOKOL_PRIVATE ImGuiKey _simgui_copypaste_modifier(void) {
//     return _simgui.is_osx ? ImGuiMod_Super : ImGuiMod_Ctrl;
// }

// SOKOL_API_IMPL int simgui_map_keycode(sapp_keycode keycode) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//     return (int)_simgui_map_keycode(keycode);
// }

// SOKOL_API_IMPL bool simgui_handle_event(const sapp_event* ev) {
//     SOKOL_ASSERT(_SIMGUI_INIT_COOKIE == _simgui.init_cookie);
//     const float dpi_scale = _simgui.cur_dpi_scale;
//         ImGuiIO* io = igGetIO();
//     switch (ev->type) {
//         case SAPP_EVENTTYPE_FOCUSED:
//             simgui_add_focus_event(true);
//             break;
//         case SAPP_EVENTTYPE_UNFOCUSED:
//             simgui_add_focus_event(false);
//             break;
//         case SAPP_EVENTTYPE_MOUSE_DOWN:
//             simgui_add_mouse_pos_event(ev->mouse_x / dpi_scale, ev->mouse_y / dpi_scale);
//             simgui_add_mouse_button_event((int)ev->mouse_button, true);
//             _simgui_update_modifiers(io, ev->modifiers);
//             break;
//         case SAPP_EVENTTYPE_MOUSE_UP:
//             simgui_add_mouse_pos_event(ev->mouse_x / dpi_scale, ev->mouse_y / dpi_scale);
//             simgui_add_mouse_button_event((int)ev->mouse_button, false);
//             _simgui_update_modifiers(io, ev->modifiers);
//             break;
//         case SAPP_EVENTTYPE_MOUSE_MOVE:
//             simgui_add_mouse_pos_event(ev->mouse_x / dpi_scale, ev->mouse_y / dpi_scale);
//             break;
//         case SAPP_EVENTTYPE_MOUSE_ENTER:
//         case SAPP_EVENTTYPE_MOUSE_LEAVE:
//             // FIXME: since the sokol_app.h emscripten backend doesn't support
//             // mouse capture, mouse buttons must be released when the mouse leaves the
//             // browser window, so that they don't "stick" when released outside the window.
//             // A cleaner solution would be a new sokol_app.h function to query
//             // "platform behaviour flags".
//             #if defined(__EMSCRIPTEN__)
//             for (int i = 0; i < SAPP_MAX_MOUSEBUTTONS; i++) {
//                 simgui_add_mouse_button_event(i, false);
//             }
//             #endif
//             break;
//         case SAPP_EVENTTYPE_MOUSE_SCROLL:
//             simgui_add_mouse_wheel_event(ev->scroll_x, ev->scroll_y);
//             break;
//         case SAPP_EVENTTYPE_TOUCHES_BEGAN:
//             simgui_add_touch_pos_event(ev->touches[0].pos_x / dpi_scale, ev->touches[0].pos_y / dpi_scale);
//             simgui_add_touch_button_event(0, true);
//             break;
//         case SAPP_EVENTTYPE_TOUCHES_MOVED:
//             simgui_add_touch_pos_event(ev->touches[0].pos_x / dpi_scale, ev->touches[0].pos_y / dpi_scale);
//             break;
//         case SAPP_EVENTTYPE_TOUCHES_ENDED:
//             simgui_add_touch_pos_event(ev->touches[0].pos_x / dpi_scale, ev->touches[0].pos_y / dpi_scale);
//             simgui_add_touch_button_event(0, false);
//             break;
//         case SAPP_EVENTTYPE_TOUCHES_CANCELLED:
//             simgui_add_touch_button_event(0, false);
//             break;
//         case SAPP_EVENTTYPE_KEY_DOWN:
//             _simgui_update_modifiers(io, ev->modifiers);
//             // intercept Ctrl-V, this is handled via EVENTTYPE_CLIPBOARD_PASTED
//             if (!_simgui.desc.disable_paste_override) {
//                 if (_simgui_is_ctrl(ev->modifiers) && (ev->key_code == SAPP_KEYCODE_V)) {
//                     break;
//                 }
//             }
//             // on web platform, don't forward Ctrl-X, Ctrl-V to the browser
//             if (_simgui_is_ctrl(ev->modifiers) && (ev->key_code == SAPP_KEYCODE_X)) {
//                 sapp_consume_event();
//             }
//             if (_simgui_is_ctrl(ev->modifiers) && (ev->key_code == SAPP_KEYCODE_C)) {
//                 sapp_consume_event();
//             }
//             // it's ok to add ImGuiKey_None key events
//             _simgui_add_sapp_key_event(io, ev->key_code, true);
//             break;
//         case SAPP_EVENTTYPE_KEY_UP:
//             _simgui_update_modifiers(io, ev->modifiers);
//             // intercept Ctrl-V, this is handled via EVENTTYPE_CLIPBOARD_PASTED
//             if (_simgui_is_ctrl(ev->modifiers) && (ev->key_code == SAPP_KEYCODE_V)) {
//                 break;
//             }
//             // on web platform, don't forward Ctrl-X, Ctrl-V to the browser
//             if (_simgui_is_ctrl(ev->modifiers) && (ev->key_code == SAPP_KEYCODE_X)) {
//                 sapp_consume_event();
//             }
//             if (_simgui_is_ctrl(ev->modifiers) && (ev->key_code == SAPP_KEYCODE_C)) {
//                 sapp_consume_event();
//             }
//             // it's ok to add ImGuiKey_None key events
//             _simgui_add_sapp_key_event(io, ev->key_code, false);
//             break;
//         case SAPP_EVENTTYPE_CHAR:
//             /* on some platforms, special keys may be reported as
//                characters, which may confuse some ImGui widgets,
//                drop those, also don't forward characters if some
//                modifiers have been pressed
//             */
//             _simgui_update_modifiers(io, ev->modifiers);
//             if ((ev->char_code >= 32) &&
//                 (ev->char_code != 127) &&
//                 (0 == (ev->modifiers & (SAPP_MODIFIER_ALT|SAPP_MODIFIER_CTRL|SAPP_MODIFIER_SUPER))))
//             {
//                 simgui_add_input_character(ev->char_code);
//             }
//             break;
//         case SAPP_EVENTTYPE_CLIPBOARD_PASTED:
//             // simulate a Ctrl-V key down/up
//             if (!_simgui.desc.disable_paste_override) {
//                 _simgui_add_imgui_key_event(io, _simgui_copypaste_modifier(), true);
//                 _simgui_add_imgui_key_event(io, ImGuiKey_V, true);
//                 _simgui_add_imgui_key_event(io, ImGuiKey_V, false);
//                 _simgui_add_imgui_key_event(io, _simgui_copypaste_modifier(), false);
//             }
//             break;
//         default:
//             break;
//     }
//     return io->WantCaptureKeyboard || io->WantCaptureMouse;
// }
