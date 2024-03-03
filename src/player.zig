const Engine = @import("engine.zig");


const Self = @This();

sprite: Engine.Gfx.Sprite,
position: Engine.sdl.Point,

pub fn init(sprite: Engine.Gfx.Sprite, position: Engine.sdl.Point) Self {
    return Self {
        .sprite = sprite,
        .position = position,
    };
}

pub fn update(self: *Self, game_state: *Engine.GameState) !void {
    _ = self;
    _ = game_state;
    // game_state.gfx.camera_offset.x += 1;

}

pub fn draw(self: *Self, game_state: *Engine.GameState) !void {
    self.sprite.dst_rect.x = self.position.x;
    self.sprite.dst_rect.y = self.position.y;

    try game_state.gfx.draw_sprite(&self.sprite);
}


