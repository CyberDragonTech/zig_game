const std = @import("std");
const Engine = @import("engine.zig");


var game_state: ?*Engine.GameState = null;


fn push_function_to_table(lua: *Engine.ziglua.Lua, name: [:0]const u8, func: fn(*Engine.ziglua.Lua) i32) void {
    lua.pushFunction(Engine.ziglua.wrap(func));
    lua.setField(-2, name);
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




const LuaAPI_Input = struct {

    pub fn init(lua: *Engine.ziglua.Lua) void {
        lua.newTable();
        push_function_to_table(lua, "is_key_just_released", is_key_just_released);
        push_function_to_table(lua, "is_key_just_pressed", is_key_just_pressed);
        push_function_to_table(lua, "is_key_pressed", is_key_pressed);
        lua.setGlobal("Input");
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

    fn is_key_just_released(lua: *Engine.ziglua.Lua) i32 {
        var res = false;
        if (game_state) |gs| {
            if (lua.isInteger(1)) {
                const sc = lua.toInteger(1) catch 0;
                res = gs.input.is_just_released(@enumFromInt(sc));
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
};


pub const LuaAPI_Gfx = struct {

    pub fn init(lua: *Engine.ziglua.Lua) void {
        lua.newTable();

        push_function_to_table(lua, "draw_sprite", gfx_draw_sprite);
        push_function_to_table(lua, "set_ui_draw_mode", gfx_set_ui_draw_mode);
        push_function_to_table(lua, "set_camera_offset", gfx_set_camera_offset);
        push_function_to_table(lua, "sprite_size", sprite_size);
        push_function_to_table(lua, "target_width", target_width);
        push_function_to_table(lua, "target_height", target_height);

        lua.setGlobal("Gfx");
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
        return 0;
    }

    pub fn gfx_set_ui_draw_mode(lua: *Engine.ziglua.Lua) i32 {
        if (game_state) |gs| {
            const mode = lua.toBoolean(1);
            gs.gfx.ui_draw_mode = mode;
        }
        return 0;
    }

    pub fn gfx_set_camera_offset(lua: *Engine.ziglua.Lua) i32 {
        if (game_state) |gs| {
            const point = table_to_point(lua, 1);
            if (point) |offset| {
                gs.gfx.camera_offset = offset;
            }
        }
        return 0;
    }

    pub fn sprite_size(lua: *Engine.ziglua.Lua) i32 {
        var res: u32 = 0;
        if (game_state) |_| {
            res = Engine.Gfx.SPRITE_SIZE;
        }
        lua.pushInteger(res);
        return 1;
    }

    pub fn target_width(lua: *Engine.ziglua.Lua) i32 {
        var res: u32 = 0;
        if (game_state) |_| {
            res = Engine.Gfx.TARGET_WIDTH;
        }
        lua.pushInteger(res);
        return 1;
    }

    pub fn target_height(lua: *Engine.ziglua.Lua) i32 {
        var res: u32 = 0;
        if (game_state) |_| {
            res = Engine.Gfx.TARGET_HEIGHT;
        }
        lua.pushInteger(res);
        return 1;
    }

};


pub const LuaAPI_AssetsManager = struct {

    pub fn init(lua: *Engine.ziglua.Lua) void {
        lua.newTable();

        push_function_to_table(lua, "load_texture", load_texture);
        push_function_to_table(lua, "get_texture", get_texture);

        lua.setGlobal("AssetsManager");
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
    
};


pub const LuaAPI_Engine = struct {

    pub fn init(lua: *Engine.ziglua.Lua) void {
        lua.newTable();

        push_function_to_table(lua, "delta_time_seconds", delta_time_seconds);
        push_function_to_table(lua, "fps", fps);

        lua.setGlobal("Engine");
    }

    fn delta_time_seconds(lua: *Engine.ziglua.Lua) i32 {
        var res: f64 = 0.0;
        if (game_state) |gs| {
            res = gs.game_time.delta_time_seconds;
        }
        lua.pushNumber(res);
        return 1;
    }

    fn fps(lua: *Engine.ziglua.Lua) i32 {
        var res: u16 = 0;
        if (game_state) |gs| {
            res = gs.game_time.fps;
        }
        lua.pushInteger(@intCast(res));
        return 1;
    }

};


pub const LuaAPI = struct {
    const Self = @This();

    pub fn init_lua_api(lua: *Engine.ziglua.Lua, _game_state: *Engine.GameState) void {
        game_state = _game_state;
        LuaAPI_Engine.init(lua);
        LuaAPI_Input.init(lua);
        LuaAPI_Gfx.init(lua);
        LuaAPI_AssetsManager.init(lua);
    }

    fn push_function(lua: *Engine.ziglua.Lua, name: [:0]const u8, func: fn(*Engine.ziglua.Lua) i32) void {
        lua.pushFunction(Engine.ziglua.wrap(func));
        lua.setGlobal(name);
    }


};