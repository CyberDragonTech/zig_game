const std = @import("std");
const builtin = @import("builtin");
const Datetime = @import("zig_datetime").datetime.Datetime;

const debug_log_file_path: []const u8 = "logs/log_debug.txt";
var date_string_buf: [48]u8 = undefined;
var log_file_path_buf: [64]u8 = undefined;
var log_file_name_path: []const u8 = undefined;
var date_str_len: usize = 0;
var log_file: ?std.fs.File = null;



pub fn init() void {
    const dt = Datetime.now();
    log_file_name_path = std.fmt.bufPrint(
        &log_file_path_buf, 
        "logs/log_{}.{}.{}_{}.{}.txt", 
        .{
            dt.date.year,
            dt.date.month,
            dt.date.day,
            dt.time.hour,
            dt.time.minute
        }
    ) catch debug_log_file_path;
    std.debug.print("{s}", .{log_file_name_path});

    std.fs.cwd().makeDir("logs") catch {};
    log_file = std.fs.cwd().createFile(log_file_name_path, .{
        .read = true,
    }) catch |err| ret: {
        std.debug.print("\nFailed to create log file. {}\n", .{err});
        break :ret null;
    };
}

pub fn deinit() void {
    if (log_file) |file| {
        file.close();
    }
}

fn log_line(
    comptime module: []const u8, 
    comptime level: []const u8, 
    comptime fmt: []const u8, args: anytype
) void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    stdout.print(module, .{}) catch {};
    stdout.print(level, .{}) catch {};
    stdout.print(fmt, args) catch {};
    stdout.print("\n", .{}) catch {};

    if (log_file) |file| {
        const writer = file.writer();
        writer.print(module, .{}) catch {};
        writer.print(level, .{}) catch {};
        writer.print(fmt, args) catch {};
        writer.print("\n", .{}) catch {};
    }
}

pub fn log_info(comptime module: []const u8, comptime fmt: []const u8, args: anytype) void {
    log_line(module, "[INFO]:", fmt, args);
}

pub fn log_warn(comptime module: []const u8, comptime fmt: []const u8, args: anytype) void {
    log_line(module, "[WARN]:", fmt, args);
}

pub fn log_error(comptime module: []const u8, comptime fmt: []const u8, args: anytype) void {
    log_line(module, "[ERROR]:", fmt, args);
}

pub fn log_debug(comptime module: []const u8, comptime fmt: []const u8, args: anytype) void {
    if (builtin.mode == .Debug) {
        log_line(module, "[DEBUG]:", fmt, args);
    }
}