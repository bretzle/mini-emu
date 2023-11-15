const std = @import("std");

pub const Scheduler = struct {};

pub const Bus = struct {
    ptr: *anyopaque,
    vtable: *const Vtable,

    const Vtable = struct {
        read8: *const fn (ptr: *anyopaque, addr: u32) u8,
        read16: *const fn (ptr: *anyopaque, addr: u32) u16,
        read32: *const fn (ptr: *anyopaque, addr: u32) u32,

        write8: *const fn (ptr: *anyopaque, addr: u32, val: u8) void,
        write16: *const fn (ptr: *anyopaque, addr: u32, val: u16) void,
        write32: *const fn (ptr: *anyopaque, addr: u32, val: u32) void,

        dbg_read8: *const fn (ptr: *anyopaque, addr: u32) u8,
        dbg_read16: *const fn (ptr: *anyopaque, addr: u32) u16,
        dbg_read32: *const fn (ptr: *anyopaque, addr: u32) u32,

        dbg_write8: *const fn (ptr: *anyopaque, addr: u32, val: u8) void,
        dbg_write16: *const fn (ptr: *anyopaque, addr: u32, val: u16) void,
        dbg_write32: *const fn (ptr: *anyopaque, addr: u32, val: u32) void,

        reset: *const fn (ptr: *anyopaque) void,
    };

    pub fn create(bus: anytype) @This() {
        const P = @TypeOf(bus);
        const info = @typeInfo(P);

        comptime {
            std.debug.assert(info == .Pointer);
            std.debug.assert(info.Pointer.size == .One);
            std.debug.assert(@typeInfo(info.Pointer.child) == .Struct);
        }

        const impl = struct {
            fn read8(ptr: *anyopaque, addr: u32) u8 {
                const self: P = @ptrCast(@alignCast(ptr));
                return self.read(u8, addr);
            }

            fn read16(ptr: *anyopaque, addr: u32) u16 {
                const self: P = @ptrCast(@alignCast(ptr));
                return self.read(u16, addr);
            }

            fn read32(ptr: *anyopaque, addr: u32) u32 {
                const self: P = @ptrCast(@alignCast(ptr));
                return self.read(u32, addr);
            }

            fn write8(ptr: *anyopaque, addr: u32, val: u8) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.write(u8, addr, val);
            }

            fn write16(ptr: *anyopaque, addr: u32, val: u16) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.write(u16, addr, val);
            }

            fn write32(ptr: *anyopaque, addr: u32, val: u32) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.write(u32, addr, val);
            }

            fn dbgRead8(ptr: *anyopaque, addr: u32) u8 {
                const self: P = @ptrCast(@alignCast(ptr));
                return self.dbgRead(u8, addr);
            }

            fn dbgRead16(ptr: *anyopaque, addr: u32) u16 {
                const self: P = @ptrCast(@alignCast(ptr));
                return self.dbgRead(u16, addr);
            }

            fn dbgRead32(ptr: *anyopaque, addr: u32) u32 {
                const self: P = @ptrCast(@alignCast(ptr));
                return self.dbgRead(u32, addr);
            }

            fn dbgWrite8(ptr: *anyopaque, addr: u32, val: u8) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.dbgWrite(u8, addr, val);
            }

            fn dbgWrite16(ptr: *anyopaque, addr: u32, val: u16) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.dbgWrite(u16, addr, val);
            }

            fn dbgWrite32(ptr: *anyopaque, addr: u32, val: u32) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.dbgWrite(u32, addr, val);
            }

            fn reset(ptr: *anyopaque) void {
                const self: P = @ptrCast(@alignCast(ptr));
                self.reset();
            }
        };

        return .{
            .ptr = bus,
            .vtable = &.{
                .read8 = impl.read8,
                .read16 = impl.read16,
                .read32 = impl.read32,

                .write8 = impl.write8,
                .write16 = impl.write16,
                .write32 = impl.write32,

                .dbg_read8 = impl.dbgRead8,
                .dbg_read16 = impl.dbgRead16,
                .dbg_read32 = impl.dbgRead32,

                .dbg_write8 = impl.dbgWrite8,
                .dbg_write16 = impl.dbgWrite16,
                .dbg_write32 = impl.dbgWrite32,

                .reset = impl.reset,
            },
        };
    }

    pub fn read(self: @This(), comptime T: type, addr: u32) T {
        return switch (T) {
            u32 => self.vtable.read32(self.ptr, addr),
            u16 => self.vtable.read16(self.ptr, addr),
            u8 => self.vtable.read8(self.ptr, addr),
            else => @compileError("invalid type"),
        };
    }

    pub fn write(self: @This(), comptime T: type, addr: u32, val: T) void {
        switch (T) {
            u32 => self.vtable.write32(self.ptr, addr, val),
            u16 => self.vtable.write16(self.ptr, addr, val),
            u8 => self.vtable.write8(self.ptr, addr, val),
            else => @compileError("invalid type"),
        }
    }

    pub fn dbgRead(self: @This(), comptime T: type, addr: u32) T {
        return switch (T) {
            u32 => self.vtable.dbg_read32(self.ptr, addr),
            u16 => self.vtable.dbg_read16(self.ptr, addr),
            u8 => self.vtable.dbg_read8(self.ptr, addr),
            else => @compileError("invalid type"),
        };
    }

    pub fn dbgWrite(self: @This(), comptime T: type, addr: u32, val: T) void {
        switch (T) {
            u32 => self.vtable.dbg_write32(self.ptr, addr, val),
            u16 => self.vtable.dbg_write16(self.ptr, addr, val),
            u8 => self.vtable.dbg_write8(self.ptr, addr, val),
            else => @compileError("invalid type"),
        }
    }

    pub fn reset(self: @This()) void {
        self.vtable.reset(self.ptr);
    }
};
