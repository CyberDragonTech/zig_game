const std = @import("std");
const Engine = @import("engine.zig");


const MODULE_STRING: []const u8 = "GameState";

const Self = @This();

window: Engine.sdl.Window,
gfx: Engine.Gfx,
input: Engine.Input,
assets_manager: Engine.AssetsManager,
lua_manager: Engine.LuaContext.LuaManager,
game_time: Engine.GameTime,




pub fn run(self: *Self) !void {
    self.lua_manager.load_lua_api(self) catch {
        Engine.Logger.log_error(MODULE_STRING, "Lua API failed loaded", .{});
        return error.Fail;
    };
    Engine.Logger.log_info(MODULE_STRING, "Lua API loaded", .{});

    var texture_loader = Engine.LuaObject.fromScriptFile(
        Engine.allocator, 
        &self.lua_manager, 
        "assets/scripts/modules/texture_loader.lua", 
        "__texture_loader__",
    );
    texture_loader.call_function(
        "load", 
        0, 
        &Engine.LuaContext.NoArguments
    );
    self.lua_manager.clear_stack();

    var player = Engine.LuaObject.fromScriptFile(
        Engine.allocator, 
        &self.lua_manager, 
        "assets/scripts/modules/player.lua", 
        "__player__",
    );

    player.call_self_function(
        "start", 
        0, 
        &Engine.LuaContext.NoArguments
    );
    self.lua_manager.clear_stack();


    mainLoop: while (true) {
        self.game_time.update();
        self.input.update();

        while (Engine.sdl.pollEvent()) |ev| {
            self.input.process_event(ev);
            switch (ev) {
                .quit => break :mainLoop,
                else => {},
            }
        }

        player.call_self_function(
            "update", 
            0, 
            &Engine.LuaContext.NoArguments
        );
        self.lua_manager.clear_stack();

        try self.gfx.clear_screen();
        try self.gfx.start_frame();
        
        player.call_self_function(
            "draw", 
            0, 
            &Engine.LuaContext.NoArguments
        );
        self.lua_manager.clear_stack();

        try self.gfx.end_frame();
        try self.gfx.present();
        // break;
    }
    Engine.Logger.log_info(MODULE_STRING, "Finishing game loop", .{});
}

pub fn deinit(self: *Self) void {
    self.lua_manager.deinit();
    Engine.Logger.log_info(MODULE_STRING, "LuaManager deinitialized", .{});
    self.assets_manager.deinit();
    Engine.Logger.log_info(MODULE_STRING, "AssetsManager deinitialized", .{});
    self.input.deinit();
    Engine.Logger.log_info(MODULE_STRING, "InputManager deinitialized", .{});
    self.gfx.deinit();
    Engine.Logger.log_info(MODULE_STRING, "Gfx deinitialized", .{});
    self.window.destroy();
    Engine.Logger.log_info(MODULE_STRING, "Window closed", .{});
    Engine.sdl.quit();
    Engine.Logger.log_info(MODULE_STRING, "SDL2 deinitialized", .{});
    const res = Engine.gpa.deinit();
    Engine.Logger.log_info(MODULE_STRING, "GeneralPerposeAllocator deinitialized", .{});
    if (res == .leak) {
        Engine.Logger.log_debug(
            MODULE_STRING, 
            "Memory leak has been identified during programm execution", 
            .{}
        );
    }
}

pub fn init() !Self {
    Engine.sdl.init(.{
        .video = true,
        .events = true,
        .audio = true,
    }) catch {
        Engine.Logger.log_error(MODULE_STRING, "Failed to initialize SDL2", .{});
        return error.SdlError;
    };
    Engine.Logger.log_info(MODULE_STRING, "GameState initialized", .{});
//------------------------------------------------------------------------------------------------------
    const window = try Engine.sdl.createWindow(
        "SDL2 Wrapper Demo",
        .{ .centered = {} }, .{ .centered = {} },
        640, 480,
        .{ .vis = .shown, .resizable = true },
    );
    Engine.Logger.log_info(MODULE_STRING, "Window created", .{});
//------------------------------------------------------------------------------------------------------
    const _gfx = Engine.Gfx.init(window) catch {
        Engine.Logger.log_error(MODULE_STRING, "Failed to initialize Gfx", .{});
        return error.SdlError;
    };
    Engine.Logger.log_info(MODULE_STRING, "Graphics initialized", .{});
//------------------------------------------------------------------------------------------------------
    const input = Engine.Input.init(Engine.allocator) catch {
        Engine.Logger.log_error(MODULE_STRING, "Failed to initialize InputManager", .{});
        return error.Fail;
    };
    Engine.Logger.log_info(MODULE_STRING, "InputManager initialized", .{});
//------------------------------------------------------------------------------------------------------
    const assets_manager = Engine.AssetsManager.init(Engine.allocator);
    Engine.Logger.log_info(MODULE_STRING, "AssetsManager initialized", .{});
//------------------------------------------------------------------------------------------------------
    const lua = Engine.LuaContext.LuaManager.init(Engine.allocator) catch {
        Engine.Logger.log_error(MODULE_STRING, "Failed to initialize Lua", .{});
        return error.Runtime;
    };
    Engine.Logger.log_info(MODULE_STRING, "LuaManager initialized", .{});
//------------------------------------------------------------------------------------------------------
    return Self{
        .window = window,
        .gfx = _gfx,
        .input = input,
        .assets_manager = assets_manager,
        .lua_manager = lua,
        .game_time = Engine.GameTime.init(),
    };

}

