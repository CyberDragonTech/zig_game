const std = @import("std");
const Engine = @import("engine.zig");


const Self = @This();


lua_scrips: ?Engine.LuaContext.LuaScript,


pub fn fromScriptFile(
    allocator: std.mem.Allocator,
    lua_manager: *Engine.LuaContext.LuaManager,
    file_path: []const u8,
    object_name: []const u8
) Self {
    const script = lua_manager.load_script(allocator, file_path, object_name) catch ret: {
        Engine.Logger.log_warn("LuaObject", "Failed to load script {s}", .{file_path});
        break :ret null;
    };
    Engine.Logger.log_info("LuaObject", "Loaded script {s}", .{file_path});
    return Self {
        .lua_scrips = script,
    };
}

pub fn deinit(self: *Self) void {
    if (self.lua_scrips) |script| {
        Engine.Logger.log_info("LuaObject", "Unloading script {s}", .{script.file_path});
        script.deinit();
    }
}

pub fn call_self_function(
    self: *const Self, 
    func_name: [:0]const u8, 
    return_expect: u32, 
    args: []const Engine.LuaContext.LuaArgument,
) void {
    if (self.lua_scrips) |script| {
        script.call_function(func_name, return_expect, args, true) catch {
            Engine.IO.print_err(
                "LuaObjest[ERROR]: \"{s}\" Failed to call script function \"{s}\" in",
                .{script.object_name, func_name}
            );
        };
    }
}

pub fn call_function(
    self: *Self, 
    func_name: [:0]const u8, 
    return_expect: u32, 
    args: []const Engine.LuaContext.LuaArgument,
) void {
    if (self.lua_scrips) |script| {
        script.call_function(func_name, return_expect, args, false) catch {
            Engine.IO.print_err(
                "LuaObjest[ERROR]: \"{s}\" Failed to call script function \"{s}\" in",
                .{script.object_name, func_name}
            );
        };
    }
}