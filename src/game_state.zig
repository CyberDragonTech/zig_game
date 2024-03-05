const std = @import("std");
const Engine = @import("engine.zig");



const Self = @This();

window: Engine.sdl.Window,
gfx: Engine.Gfx,
input: Engine.Input,
assets_manager: Engine.AssetsManager,
lua_manager: Engine.LuaContext.LuaManager,
game_time: Engine.GameTime,




pub fn run(self: *Self) !void {
    try self.lua_manager.load_lua_api(self);
    try Engine.IO.println("GS[INFO]: Lua API loaded", .{});

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
    }
    try Engine.IO.println("Finishing...", .{});
}

pub fn deinit(self: *Self) void {
    self.lua_manager.deinit();
    self.assets_manager.deinit();
    self.input.deinit();
    self.gfx.deinit();
    self.window.destroy();
    Engine.sdl.quit();
    const res = Engine.gpa.deinit();
    if (res == .leak) {
        Engine.IO.print_err("Memory leak has been identified during programm execution", .{});
    }
}

pub fn init() !Self {
    try Engine.IO.println("Starting...", .{});
    try Engine.sdl.init(.{
        .video = true,
        .events = true,
        .audio = true,
    });

    const window = try Engine.sdl.createWindow(
        "SDL2 Wrapper Demo",
        .{ .centered = {} }, .{ .centered = {} },
        640, 480,
        .{ .vis = .shown, .resizable = true },
    );
    try Engine.IO.println("GS[INFO]: Window created", .{});

    const _gfx = try Engine.Gfx.init(window);
    try Engine.IO.println("GS[INFO]: Graphics initialized", .{});

    const lua = Engine.LuaContext.LuaManager.init(Engine.allocator) catch {
        Engine.IO.print_err("GS[ERROR]: Failed to initialize Lua", .{});
        return error.Runtime;
    };
    try Engine.IO.println("GS[INFO]: Lua Manager initialized", .{});

    return Self{
        .window = window,
        .gfx = _gfx,
        .input = try Engine.Input.init(Engine.allocator),
        .assets_manager = Engine.AssetsManager.init(Engine.allocator),
        .lua_manager = lua,
        .game_time = Engine.GameTime.init(),
    };
}
