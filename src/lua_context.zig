const std = @import("std");
const Engine = @import("engine.zig");

const LMError = error {
    ModuleNotFound,
    FieldNotFound,

    UnsoppertedType,
    IncorrectType,

    LuaRuntime,
};

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
    }

    fn push_function(lua: *Engine.ziglua.Lua, name: [:0]const u8, func: fn(*Engine.ziglua.Lua) i32) void {
        lua.pushFunction(Engine.ziglua.wrap(func));
        lua.setGlobal(name);
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

};

pub const LuaScript = struct {
    const Self = @This();

    file_path: Engine.zigstr,
    module_name: Engine.zigstr,
    lua_manager: *LuaManager,

    pub fn deinit(self: *Self) void {
        self.file_path.deinit();
        self.module_name.deinit();
    }

    pub fn call_function(self: *Self, func_name: [:0]const u8, return_expect: u32, args: []const LuaArgument) LMError!void {
        self.lua_manager.get_module(Engine.Utils.str_to_cstr(self.module_name.bytes())) catch {
            std.debug.panic("LS[PANIC]: Module {s} was not found", .{
                self.module_name.bytes()
            });
        };
        try self.lua_manager.call_table_function(-1, func_name, return_expect, args);
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
        self: *Self, allocator: std.mem.Allocator, file_path: []const u8, module_name: []const u8
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
        self.lua.setField(-2, Engine.Utils.str_to_cstr(module_name));
        return LuaScript {
            .file_path = try Engine.zigstr.fromConstBytes(allocator, file_path),
            .module_name = try Engine.zigstr.fromConstBytes(allocator, module_name),
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
        args: []const LuaArgument
    ) LMError!void {
        const f_type = self.lua.getField(tables_stack_index, func_name);
        const argc: i32 = try self.push_args(args);
        if (f_type == .function) {
            self.lua.protectedCall(argc, @intCast(return_expect), 0) catch {
                Engine.IO.print_err("LM[ERROR]: Failed to call Lua function '{s}'\nLua: {s}", .{
                    func_name,
                    self.lua.toString(-1) catch ret: {
                        break :ret "";
                    }
                });
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