const std = @import("std");
const Engine = @import("engine.zig");
const Player = @import("player.zig");


const ns_per_us: u64 = 1000;
const ns_per_ms: u64 = 1000 * ns_per_us;
const ns_per_s: u64 = 1000 * ns_per_ms;

const Self = @This();


window: Engine.sdl.Window,
gfx: Engine.Gfx,
input: Engine.Input,
lua_manager: Engine.LuaContext.LuaManager,


pub fn run(self: *Self) !void {
    try self.lua_manager.load_lua_api(self);
    try Engine.IO.println("GS[INFO]: Lua API loaded", .{});

    var script1 = self.lua_manager.load_script(
        Engine.allocator, 
        "assets/scripts/lua_test.lua", 
        "__script_1__"
    ) catch {
        Engine.IO.print_err("Failed to load __script_1__", .{});
        return error.Fail;
    };
    defer script1.deinit();
    try Engine.IO.println("GS[INFO]: __script_1__ is loaded", .{});

    const spr_test_res = self.gfx.loadBMP("assets/textures/spr_test.bmp");
    if (spr_test_res == null) {
        Engine.IO.print_err("Failed to load player texture", .{});
        return error.Runtime;
    }
    const spr_test: Engine.sdl.Texture = spr_test_res.?;
    const t_info = try spr_test.query();

    const sprite = Engine.Gfx.Sprite.new(spr_test, .{
        .x = 0,
        .y = 0,
        .width = @intCast(t_info.width),
        .height = @intCast(t_info.height),
    }, .{
        .x = 16,
        .y = 32,
        .width = @intCast(t_info.width),
        .height = @intCast(t_info.height),
    });
    var player = Player.init(sprite, Engine.sdl.Point{.x = 10, .y = 1});

    mainLoop: while (true) {
        self.input.update();

        while (Engine.sdl.pollEvent()) |ev| {
            self.input.process_event(ev);
            switch (ev) {
                .quit => break :mainLoop,
                else => {},
            }
        }

        try script1.call_function("update", 0, &[_]Engine.LuaContext.LuaArgument{});
        self.lua_manager.clear_stack();
        
        try player.update(self);

        try self.gfx.clear_screen();
        try self.gfx.start_frame();

        try player.draw(self);

        try self.gfx.end_frame();
        try self.gfx.present();
        // std.time.sleep(ns_per_ms * 500);
    }
    try Engine.IO.println("Finishing...", .{});
}

pub fn deinit(self: *Self) void {
    self.lua_manager.deinit();
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
        .lua_manager = lua,
    };
}
