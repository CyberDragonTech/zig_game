const std = @import("std");
pub const sdl = @import("sdl2");
pub const ziglua = @import("ziglua");
pub const zigstr = @import("zigstr");

pub const Logger = @import("log.zig");
pub const Utils = @import("utils.zig");
pub const IO = @import("io.zig");
pub const GameState = @import("game_state.zig");
pub const GameTime = @import("game_time.zig");
pub const Input = @import("input.zig");
pub const Gfx = @import("gfx.zig");
pub const AssetsManager = @import("assets_manager.zig");
pub const LuaContext = @import("lua_context.zig");
pub const LuaObject = @import("lua_object.zig");
pub const LuaAPI = @import("lua_api.zig").LuaAPI;


pub var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator: std.mem.Allocator = gpa.allocator();