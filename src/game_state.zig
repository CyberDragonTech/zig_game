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
    const spr_test_res = self.gfx.loadBMP("assets/textures/spr_test.bmp");
    if (spr_test_res == null) {
        Engine.IO.print_err("Failed to load player texture", .{});
        return error.Runtime;
    }

    var script1 = self.lua_manager.load_script(
        Engine.allocator, 
        "assets/scripts/lua_test.lua", 
        "__script_1__"
    ) catch {
        Engine.IO.print_err("Failed to load script1", .{});
        return error.Fail;
    };
    defer script1.deinit();
    
    try script1.call_function("test", 0, &[_]Engine.LuaContext.LuaArgument{});
    self.lua_manager.clear_stack();
    script1.call_function("io_test", 1, &[_]Engine.LuaContext.LuaArgument{
        .{.Int = 10},
    }) catch {
        Engine.IO.print_err("GS[ERROR]: Failed to call 'io_test'\nLua: {s}", .{
            try self.lua_manager.lua.toString(-1)
        });
        return error.Runtime;
    };
    Engine.IO.print_err("{}", .{
        self.lua_manager.lua.toInteger(-1) catch ret:{
            break :ret -100;
        }
    });
    self.lua_manager.clear_stack();

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
        while (Engine.sdl.pollEvent()) |ev| {
            switch (ev) {
                .quit => break :mainLoop,
                else => {},
            }
        }
        self.input.update();
        
        try player.update(self);

        try self.gfx.clear_screen();
        try self.gfx.start_frame();

        try player.draw(self);

        try self.gfx.end_frame();
        try self.gfx.present();
        std.time.sleep(ns_per_ms * 500);
    }
    try Engine.IO.println("Finishing...", .{});
}

pub fn deinit(self: *Self) void {
    self.lua_manager.deinit();
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

    const _gfx = try Engine.Gfx.init(window);



    const lua = Engine.LuaContext.LuaManager.init(Engine.allocator) catch {
        Engine.IO.print_err("GS: Failed to initialize Lua", .{});
        return error.Runtime;
    };

    return Self{
        .window = window,
        .gfx = _gfx,
        .input = Engine.Input.init(),
        .lua_manager = lua,
    };
}

    // --------------------------------------------------------------------------------------------
    // self.lua.doFile("assets/scripts/lua_test.lua") catch {
    //     Engine.IO.print_err("GS[ERROR]: Failed to load Lua script", .{});
    //     return error.Runtime;
    // };

    // const g = self.lua.getGlobal("test") catch {
    //     Engine.IO.print_err("GS[ERROR]: Failed to get Lua global", .{});
    //     return error.Runtime;
    // };

    // if (g == .function) {
    //     self.lua.protectedCall(0, 0, 0) catch {
    //         Engine.IO.print_err("GS[ERROR]: Failed to call Lua function", .{});
    //         return error.Runtime;
    //     };
    // }

    // self.lua.setTop(0);


    // const g_io_test = self.lua.getGlobal("io_test") catch {
    //     Engine.IO.print_err("GS[ERROR]: Failed to get Lua global 'io_test'\nLua: {s}", .{
    //         try self.lua.toString(-1)
    //     });
    //     return error.Runtime;
    // };

    // self.lua.pushInteger(5);

    // if (g_io_test == .function) {
    //     self.lua.protectedCall(1, 1, 0) catch {
    //         Engine.IO.print_err("GS[ERROR]: Failed to call Lua function 'io_test'\nLua: {s}", .{
    //             try self.lua.toString(-1)
    //         });
    //         return error.Runtime;
    //     };
    //     try Engine.IO.println("{}", .{ 
    //         try self.lua.toInteger(-1) 
    //     });
    // }
    // Engine.IO.print_err("{}", .{self.lua.getTop()});

    // self.lua.setTop(0);

    // --------------------------------------------------------------------------------------------

    // self.lua.createTable(0, 1);
    // self.lua.loadFile("assets/scripts/lua_test.lua", .text) catch {
    //     Engine.IO.print_err("GS[ERROR]: Failed to load lua script 1\nLua: {s}", .{
    //         try self.lua.toString(-1)
    //     });
    //     return error.Runtime;
    // };
    // self.lua.call(0, 1);
    // self.lua.setField(-2, "__lua_test_mod__");
    // self.lua.setGlobal("__modules__");

    // _ = self.lua.getGlobal("__modules__") catch {
    //     Engine.IO.print_err("GS[ERROR]: Failed to get Lua global '__modules__'\nLua: {s}", .{
    //         try self.lua.toString(-1)
    //     });
    //     return error.Runtime;
    // };
    // _ = self.lua.getField(-1, "__lua_test_mod__");
    // _ = self.lua.getField(-1, "test");
    // self.lua.call(0, 2);


    // Engine.IO.print_err("{}", .{self.lua.getTop()});
    // for (1..@intCast(self.lua.getTop()+1)) |i| {
    //     Engine.IO.print_err("{} : {s}", 
    //         .{self.lua.getTop() - @as(i32, @intCast(i)), self.lua.typeNameIndex(@intCast(i))}
    //     );
    // }
    // self.lua.setTop(0);