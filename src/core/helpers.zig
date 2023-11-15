const std = @import("std");

pub fn sext(comptime T: type, comptime U: type, val: anytype) T {
    comptime std.debug.assert(@typeInfo(U).Int.bits <= @typeInfo(T).Int.bits);

    const iT = std.meta.Int(.signed, @typeInfo(T).Int.bits);
    const ExtU = if (@typeInfo(U).Int.signedness == .unsigned) T else iT;
    const shift_amt: std.math.Log2Int(T) = @intCast(@typeInfo(T).Int.bits - @typeInfo(U).Int.bits);

    return @bitCast(@as(iT, @bitCast(@as(ExtU, @as(U, @truncate(val))) << shift_amt)) >> shift_amt);
}
