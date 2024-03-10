const std = @import("std");
const Engine = @import("engine.zig");



const Self = @This();


allocator: std.mem.Allocator,
objects: std.ArrayListUnmanaged(Engine.LuaObject),



pub fn init() Self {
    return Self {
        
    };
}