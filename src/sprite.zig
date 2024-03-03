const sdl = @import("sdl2");


const Self = @This();

texture: sdl.Texture,
segment: sdl.Rectangle,

dst_rect: sdl.Rectangle,

pub fn new(texture: sdl.Texture, segment: sdl.Rectangle, dst_rect: sdl.Rectangle) Self {
    return Self {
        .texture = texture,
        .segment = segment,
        .dst_rect = dst_rect,
    };
}
