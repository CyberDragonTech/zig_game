const std = @import("std");
const Engine = @import("engine.zig");



const Self = @This();


current_state: ?Engine.LuaObject,


pub fn init() Self {
    return Self {
        .current_state = null,
    };
}