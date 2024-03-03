const std = @import("std");


const BUFFER_SIZE: usize = 512;
var buffer: [BUFFER_SIZE]u8 = undefined;
pub fn str_to_cstr(str: []const u8) [:0]const u8 {
    return std.fmt.bufPrintZ(&buffer, "{s}", .{str}) catch ret: {
        break :ret "";
    };
}