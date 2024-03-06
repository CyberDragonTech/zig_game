const std = @import("std");
const Engine = @import("engine.zig");
pub const Sprite = @import("sprite.zig");


const MODULE_STRING: []const u8 = "Gfx";
const Self = @This();

pub const TARGET_WIDTH: u32 = 256;
pub const TARGET_HEIGHT: u32 = 256;
pub const TARGET_CLEAR_COLOR: Engine.sdl.Color = Engine.sdl.Color.rgb(0x0F, 0x0F, 0x0F);
pub const SPRITE_SIZE: u32 = 16;

window: Engine.sdl.Window,
renderer: Engine.sdl.Renderer,
screen: Engine.sdl.Texture,

camera_offset: Engine.sdl.Point,
ui_draw_mode: bool,

pub fn init(window: Engine.sdl.Window) !Self {
    const renderer = try Engine.sdl.createRenderer(window, null, .{ .accelerated = true });

    const screen = try Engine.sdl.createTexture(
        renderer, 
        Engine.sdl.PixelFormatEnum.argb8888,
        Engine.sdl.Texture.Access.target,
        TARGET_WIDTH,
        TARGET_HEIGHT
    );
    return Self {
        .window = window,
        .renderer = renderer,
        .screen = screen,
        .camera_offset = .{.x = 0, .y = 0},
        .ui_draw_mode = false
    };
}

pub fn start_frame(self: *Self) !void {
    try self.renderer.setTarget(self.screen);
    try self.renderer.setColor(TARGET_CLEAR_COLOR);
    try self.renderer.clear();
}

pub fn end_frame(self: *Self) !void {
    try self.renderer.setTarget(null);

    const win_size = self.window.getSize();
    const win_width: u32 = @intCast(win_size.width);
    const win_height: u32 = @intCast(win_size.height);
    const min_side: u32 = @intCast(@min(win_size.width, win_size.height));

    const x: u32 = win_width / 2 - min_side / 2;
    const y: u32 = win_height / 2 - min_side / 2;

    try  self.renderer.copy(self.screen, .{
        .x = @intCast(x),
        .y = @intCast(y),
        .width = @intCast(min_side),
        .height = @intCast(min_side),
    }, null);
}

pub fn clear_screen(self: *Self) !void {
    try self.renderer.setColorRGB(0x00, 0x00, 0x00);
    try self.renderer.clear();
}

pub fn present(self: *Self) !void {
    self.renderer.present();
}

pub fn draw_sprite(self: *Self, sprite: *const Sprite) !void {
    var dst_rect = sprite.dst_rect;
    dst_rect.x *= SPRITE_SIZE;
    dst_rect.y *= SPRITE_SIZE;
    if (!self.ui_draw_mode) {
        dst_rect.x += self.camera_offset.x * SPRITE_SIZE;
        dst_rect.y += self.camera_offset.y * SPRITE_SIZE;
    }
    try self.renderer.copy(sprite.texture, dst_rect, sprite.segment);
}

pub fn load_bmp(self: *Self, file_path: [:0]const u8) ?Engine.sdl.Texture {
    var texture: ?Engine.sdl.Texture = null;
    const s_res = Engine.sdl.loadBmp(file_path) catch null;
    if (s_res == null) {
        Engine.Logger.log_error(
            MODULE_STRING, 
            "Failed to load texture at: {s}", 
            .{file_path}
        );
        return null;
    }
    texture = Engine.sdl.createTextureFromSurface(self.renderer, s_res.?) catch null;
    Engine.Logger.log_error(
        MODULE_STRING, 
        "Texture {s} was loaded", 
        .{file_path}
    );
    return texture;
}

pub fn deinit(self: *Self) void {
    self.screen.destroy();
    self.renderer.destroy();
}