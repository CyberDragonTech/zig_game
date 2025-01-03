const std = @import("std");


const BUFFER_SIZE: usize = 512;
var buffer: [BUFFER_SIZE]u8 = undefined;
pub fn str_to_cstr(str: []const u8) [:0]const u8 {
    return std.fmt.bufPrintZ(&buffer, "{s}", .{str}) catch "";
}

pub fn cstr_to_str(str: [*:0]const u8) []const u8 {
    return std.fmt.bufPrint(&buffer, "{s}", .{str}) catch "";
}


pub fn make_str_heap_copy(allocator: std.mem.Allocator, str: []const u8) ![]u8 {
    const new_str = allocator.alloc(u8, str.len) catch {
        return error.Memory;
    };
    @memcpy(new_str, str);
    return new_str;
}