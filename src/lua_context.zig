const std = @import("std");
const Engine = @import("engine.zig");

const LMError = error {
    ModuleNotFound,
    FieldNotFound,

    UnsoppertedType,
    IncorrectType,

    LuaRuntime,
};

pub const NoArguments = [0]Engine.LuaContext.LuaArgument{};
pub const LuaArgument = union(enum) {
    None: void,
    Nil: void,
    Bool: bool,
    Int: i64,
    Float: f64,
};

const LuaApi = struct {
    const Self = @This();
    var game_state: ?*Engine.GameState = null;

    pub fn init_lua_api(lua: *Engine.ziglua.Lua) void {
        push_function(lua, "is_key_pressed", is_key_pressed);
        push_function(lua, "is_key_just_pressed", is_key_just_pressed);
        push_function(lua, "get_texture", get_texture);
        push_function(lua, "gfx_draw_sprite", gfx_draw_sprite);
        push_function(lua, "load_texture", load_texture);
        push_function(lua, "gfx_set_ui_draw_mode", gfx_set_ui_draw_mode);
        push_function(lua, "gfx_set_camera_offset", gfx_set_camera_offset);
        push_function(lua, "delta_time_seconds", delta_time_seconds);
        push_function(lua, "fps", fps);
    }

    fn push_function(lua: *Engine.ziglua.Lua, name: [:0]const u8, func: fn(*Engine.ziglua.Lua) i32) void {
        lua.pushFunction(Engine.ziglua.wrap(func));
        lua.setGlobal(name);
    }

    fn table_to_rect(lua: *Engine.ziglua.Lua, index: i32) ?Engine.sdl.Rectangle {
        if (!lua.isTable(index)) {
            return null;
        }
        _ = lua.pushString("x");
        _ = lua.getTable(-2);
        const x = lua.toInteger(-1) catch {
            return null;
        };
        lua.pop(1);

        _ = lua.pushString("y");
        _ = lua.getTable(-2);
        const y = lua.toInteger(-1) catch {
            return null;
        };
        lua.pop(1);

        _ = lua.pushString("w");
        _ = lua.getTable(-2);
        const w = lua.toInteger(-1) catch {
            return null;
        };
        lua.pop(1);

        _ = lua.pushString("h");
        _ = lua.getTable(-2);
        const h = lua.toInteger(-1) catch {
            return null;
        };
        lua.pop(1);

        return Engine.sdl.Rectangle {
            .x      = @intCast(x),
            .y      = @intCast(y),
            .width  = @intCast(w),
            .height = @intCast(h),
        };
    }

    fn table_to_point(lua: *Engine.ziglua.Lua, index: i32) ?Engine.sdl.Point {
        if (!lua.isTable(index)) {
            return null;
        }
        _ = lua.pushString("x");
        _ = lua.getTable(-2);
        const x = lua.toInteger(-1) catch {
            return null;
        };
        lua.pop(1);

        _ = lua.pushString("y");
        _ = lua.getTable(-2);
        const y = lua.toInteger(-1) catch {
            return null;
        };
        lua.pop(1);

        return Engine.sdl.Point {
            .x      = @intCast(x),
            .y      = @intCast(y),
        };
    }

    fn table_to_sprite(lua: *Engine.ziglua.Lua, index: i32) ?Engine.Gfx.Sprite {
        if (!lua.isTable(index)) {
            return null;
        }
        _ = lua.pushString("texture");
        _ = lua.getTable(-2);
        const texture_int_ptr = lua.toInteger(-1) catch {
            return null;
        }; 
        lua.pop(1);

        _ = lua.pushString("segment");
        _ = lua.getTable(-2);
        const segment = table_to_rect(lua, -1) orelse {
            return null;
        };
        lua.pop(1);

        _ = lua.pushString("dst_rect");
        _ = lua.getTable(-2);
        const dst_rect = table_to_rect(lua, -1) orelse {
            return null;
        };
        lua.pop(1);

        const texture_usize_ptr: usize = @intCast(texture_int_ptr);
        const texture = Engine.sdl.Texture {
            .ptr = @ptrFromInt(texture_usize_ptr),
        };
        return Engine.Gfx.Sprite {
            .texture = texture,
            .segment = segment,
            .dst_rect = dst_rect,
        };
    }

    fn is_key_just_pressed(lua: *Engine.ziglua.Lua) i32 {
        var res = false;
        if (game_state) |gs| {
            if (lua.isInteger(1)) {
                const sc = lua.toInteger(1) catch 0;
                res = gs.input.is_just_pressed(@enumFromInt(sc));
            }
        }
        lua.pushBoolean(res);
        return 1;
    }

    fn is_key_pressed(lua: *Engine.ziglua.Lua) i32 {
        var res = false;
        if (game_state) |gs| {
            if (lua.isInteger(1)) {
                const sc = lua.toInteger(1) catch 0;
                res = gs.input.is_pressed(@enumFromInt(sc));
            }
        }
        lua.pushBoolean(res);
        return 1;
    }

    fn load_texture(lua: *Engine.ziglua.Lua) i32 {
        var res = false;
        if (game_state) |gs| ret: {
            const file_str = lua.toBytes(1) catch {
                break :ret ;
            };
            const id_str = lua.toBytes(2) catch {
                break :ret ;
            };
            const id_key = Engine.Utils.make_str_heap_copy(
                Engine.allocator, 
                id_str
            ) catch {
                break :ret ;
            };
            gs.assets_manager.load_texture(
                Engine.allocator, 
                &gs.gfx, 
                file_str, 
                id_key
            ) catch {
                break :ret ;
            };
            res = true;
        }
        lua.pushBoolean(res);
        return 1;
    }

    fn get_texture(lua: *Engine.ziglua.Lua) i32 {
        var res: i64 = -1;
        if (game_state) |gs| {
            if (lua.isString(1)) {
                const tex_id = lua.toString(1) catch "";
                const id = Engine.Utils.cstr_to_str(tex_id);
                const tex = gs.assets_manager.get_texture(id);
                if (tex) |t| {
                    const int_ptr: usize = @intFromPtr(t.ptr);
                    res = @intCast(int_ptr);
                }
            }
        }
        lua.pushInteger(@intCast(res));
        return 1;
    }

    pub fn gfx_draw_sprite(lua: *Engine.ziglua.Lua) i32 {
        var res = false;
        if (game_state) |gs| {
            const sprite = table_to_sprite(lua, 1);
            if (sprite) |spr| {
                
                gs.gfx.draw_sprite(&spr) catch {
                    res = false;
                };
                res = true;
            }
        }
        lua.pushBoolean(res);
        return if (res) 1 else 0;
    }

    pub fn gfx_set_ui_draw_mode(lua: *Engine.ziglua.Lua) i32 {
        if (game_state) |gs| {
            const mode = lua.toBoolean(1);
            gs.gfx.ui_draw_mode = mode;
        }
        return 1;
    }

    pub fn gfx_set_camera_offset(lua: *Engine.ziglua.Lua) i32 {
        if (game_state) |gs| {
            const point = table_to_point(lua, 1);
            if (point) |offset| {
                gs.gfx.camera_offset = offset;
            }
        }
        return 1;
    }

    pub fn delta_time_seconds(lua: *Engine.ziglua.Lua) i32 {
        var res: f64 = 0.0;
        if (game_state) |gs| {
            res = gs.game_time.delta_time_seconds;
        }
        lua.pushNumber(res);
        return 1;
    }

    pub fn fps(lua: *Engine.ziglua.Lua) i32 {
        var res: u16 = 0;
        if (game_state) |gs| {
            res = gs.game_time.fps;
        }
        lua.pushInteger(@intCast(res));
        return 1;
    }
};

pub const LuaScript = struct {
    const Self = @This();

    file_path: Engine.zigstr,
    object_name: Engine.zigstr,
    lua_manager: *LuaManager,

    pub fn deinit(self: *Self) void {
        self.file_path.deinit();
        self.object_name.deinit();
    }

    pub fn call_function(
        self: *const Self, func_name: [:0]const u8, 
        return_expect: u32, 
        args: []const LuaArgument,
        call_self: bool
    ) LMError!void {
        self.lua_manager.get_module(Engine.Utils.str_to_cstr(self.object_name.bytes())) catch {
            std.debug.panic("LS[PANIC]: Module {s} was not found", .{
                self.object_name.bytes()
            });
        };
        self.lua_manager.call_table_function(
            -1, 
            func_name, 
            return_expect, 
            args,
            call_self
        ) catch {
            Engine.IO.print_err("LuaScript[ERROR]: {s} failed to call function {s}", 
            .{
                self.object_name, 
                func_name
                }
            );
            return LMError.LuaRuntime;
        };
    }
};


pub const LuaManager = struct {
    const Self = @This();
    
    pub const MODULES_TABLE_NAME: [:0]const u8 = "__modules__";

    lua: Engine.ziglua.Lua,


    pub fn init(allocator: std.mem.Allocator) !Self {
        var lua = try Engine.ziglua.Lua.init(allocator);
        lua.openLibs();
        
        lua.createTable(0, 1);
        lua.setGlobal(MODULES_TABLE_NAME);

        return Self {
            .lua = lua,
        };
    }

    pub fn load_lua_api(self: *Self, game_state: *Engine.GameState) !void {
        LuaApi.game_state = game_state;
        LuaApi.init_lua_api(&self.lua);
    }

    pub fn deinit(self: *Self) void {
        self.lua.deinit();
    }

    pub fn load_script(
        self: *Self, allocator: std.mem.Allocator, file_path: []const u8, object_name: []const u8
    ) !LuaScript {
        self.get_modules_table();
        self.lua.loadFile(Engine.Utils.str_to_cstr(file_path), .text) catch {
            Engine.IO.print_err("GS[ERROR]: Failed to load lua file {s}\nLua: {s}", .{
                file_path,
                try self.lua.toString(-1)
            });
            return error.Runtime;
        };
        self.lua.protectedCall(0, 1, 0) catch {
            Engine.IO.print_err("GS[ERROR]: Failed to load lua module {s}\nLua: {s}", .{
                file_path,
                try self.lua.toString(-1)
            });
            return error.File;
        };
        self.lua.setField(-2, Engine.Utils.str_to_cstr(object_name));
        return LuaScript {
            .file_path = try Engine.zigstr.fromConstBytes(allocator, file_path),
            .object_name = try Engine.zigstr.fromConstBytes(allocator, object_name),
            .lua_manager = self,
        };
    }

    pub fn clear_stack(self: *Self) void {
        self.lua.setTop(0);
    }

    pub fn print_stack(self: *Self) void {
        const top = self.lua.getTop();
        Engine.IO.print_err("{}", .{top});
        for (1..@intCast(top + 1)) |i| {
            Engine.IO.print_err("{}|{} : {s}", 
                .{i, @as(i32, @intCast(i)) - top - 1, self.lua.typeNameIndex(@intCast(i))}
            );
        }
    }

    fn push_args(self: *Self, args: []const LuaArgument) LMError!i32 {
        var argc: i32 = 0;
        for (args) |item| {
            argc += 1;
            switch (item) {
                LuaArgument.Bool => {
                    self.lua.pushBoolean(item.Bool);
                },
                LuaArgument.Int => {
                    self.lua.pushInteger(@intCast(item.Int));
                },
                LuaArgument.Float => {
                    self.lua.pushNumber(@floatCast(item.Float));
                },
                else => {
                    Engine.IO.print_err("LM[ERROR]: Unsupported argumen type", .{});
                    return LMError.UnsoppertedType;
                }
            }
        }
        return argc;
    }

    pub fn call_table_function(
        self: *Self, 
        tables_stack_index: i32, 
        func_name: [:0]const u8, 
        return_expect: u32, 
        args: []const LuaArgument,
        call_self: bool
    ) LMError!void {
        const f_type = self.lua.getField(tables_stack_index, func_name);
        var argc: i32 = 0;
        if (call_self) {
            self.lua.pushValue(tables_stack_index - 1);
            argc += 1;
        }
        argc += try self.push_args(args);
        if (f_type == .function) {
            self.lua.protectedCall(argc, @intCast(return_expect), 0) catch {
                Engine.IO.print_err("LM[ERROR]: Failed to call Lua function '{s}'\nLua: {s}", .{
                    func_name,
                    self.lua.toString(-1) catch ret: {
                        break :ret "";
                    }
                });
                self.print_stack();
                return LMError.LuaRuntime;
            };
        } else {
            Engine.IO.print_err("GS[ERROR]: {s} is not a function", .{func_name});
            return LMError.IncorrectType;
        }
    }

    /// Push module table to the stack
    /// Return error if module was not found 
    pub fn get_module(self: *Self, module_name: [:0]const u8) LMError!void {
        self.get_modules_table();
        const o_type = self.lua.getField(-1, module_name);
        if (o_type != .table) {
            self.lua.pop(2);
            return LMError.ModuleNotFound;
        }
    }

    /// Push modules table to the stack
    /// Panic if modules table is not in a global scope
    pub fn get_modules_table(self: *Self) void {
        const o_type = self.lua.getGlobal(MODULES_TABLE_NAME) catch {
            Engine.IO.print_err("LM[ERROR]: Failed to find __modules__ table\nLua: {s}", .{
                self.lua.toString(-1) catch ret: {
                    break :ret "";
                }
            });
            std.debug.panic("LM[PANIC]: Modules table was not found", .{});
        };
        if (o_type != .table) {
            std.debug.panic("LM[PANIC]: Modules table was not found", .{});
        }
    }
};