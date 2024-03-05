const std = @import("std");
const Engine = @import("engine.zig");


const ns_per_us: u64 = 1000;
const ns_per_ms: u64 = 1000 * ns_per_us;
const ns_per_s: u64 = 1000 * ns_per_ms;

const Self = @This();

fps: u16,
delta_time_seconds: f64,

__fstart: i128,
__fend: i128,
__delta_nano: i128,
__fps_counter: u16,
__fps_timer: f64,


pub fn update(self: *Self) void {
    self.__fend = self.__fstart;
    self.__fstart = std.time.nanoTimestamp();
    self.__delta_nano = self.__fstart - self.__fend;
    self.delta_time_seconds = 
        @as(f64, @floatFromInt(self.__delta_nano)) / ns_per_s;

    self.__fps_timer -= self.delta_time_seconds;
    if (self.__fps_timer <= 0.0) {
        self.fps = self.__fps_counter;

        self.__fps_timer = 1.0;
        self.__fps_counter = 0;
    }
    self.__fps_counter += 1;
}


pub fn init() Self {
    return Self{
        .__fend = 0,
        .__fstart = 0,
        .__delta_nano = 0,
        .__fps_counter = 0,
        .__fps_timer = 0.0,
        .fps = 0,
        .delta_time_seconds = 0.0,
    };
}