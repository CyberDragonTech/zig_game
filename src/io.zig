const std = @import("std");


pub fn print_err(comptime fmt: []const u8, args: anytype) void {
    std.debug.print(fmt, args);
    std.debug.print("\n", .{});
}

pub fn println(comptime fmt: []const u8, args: anytype) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print(fmt, args);
    try stdout.print("\n", .{});

    try bw.flush(); // don't forget to flush!
}


var con_read_buffer: [256]u8 = undefined;
pub fn readln() ?[]u8 {
    const stdin = std.io.getStdIn().reader();
    const input =  stdin.readUntilDelimiterOrEof(
        con_read_buffer[0..], '\n') 
        catch |err| 
    {
        print_err("IO: Failed to read user input: {any}", .{err});
        return null;
    };
    
    return input;
}