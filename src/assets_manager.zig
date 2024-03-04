const std = @import("std");
const Engine = @import("engine.zig");


const TEXTURE_ASSES_PATH: []const u8 = "assets/textures/";


const Self = @This();

const TextureHashMap = std.StringHashMap(Engine.sdl.Texture);

textures: TextureHashMap,



pub fn init(allocator: std.mem.Allocator) Self {
    return Self {
        .textures = TextureHashMap.init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    var iter = self.textures.iterator();
    while (iter.next()) |entry| {
        entry.value_ptr.destroy();
        self.textures.allocator.free(entry.key_ptr.*);
    }
    self.textures.deinit();
    Engine.IO.print_err("AS[INFO]: deinitialized", .{});
}

pub fn dump(self: *Self) void {
    Engine.IO.print_err("AS[INFO]: Entires:", .{});
    var iter = self.textures.iterator();
    while (iter.next()) |entry| {
        Engine.IO.print_err("AS[INFO]: \"{s}\" | {}", .{entry.key_ptr.*, entry.value_ptr});
    }
}

pub fn load_texture(
    self: *Self, 
    allocator: std.mem.Allocator, 
    gfx: *Engine.Gfx, 
    file: []const u8, 
    id: []const u8
) !void {
    var str_path = try Engine.zigstr.fromConstBytes(allocator, "");
    try str_path.concat(TEXTURE_ASSES_PATH);
    try str_path.concat(file);
    defer str_path.deinit();

    const texture = gfx.load_bmp(
        Engine.Utils.str_to_cstr(str_path.bytes()),
    );
    if (texture) |tex| {
        self.textures.put(id, tex) catch {
            return error.Memory; 
        };
        try Engine.IO.println("AS[INFO]: texture {s} was loaded", .{str_path});
    } else {
        try Engine.IO.println("AS[ERROR]: texture {s} was failed to load", .{str_path});
    }
}

pub fn get_texture(self: *Self, id: []const u8) ?Engine.sdl.Texture {
    return self.textures.get(id);
}