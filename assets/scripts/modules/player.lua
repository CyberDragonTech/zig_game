local scancodes = require "assets.scripts.scancodes"

local Player = {}


function Player:start()
    self.position = point(2, 0)
    ---@class (exact) Sprite
    self.sprite = {}
    self.sprite.texture = AssetsManager.get_texture("entity")
    self.sprite.segment = rect(0, 0, 16, 16)
    self.sprite.dst_rect = rect(0, 0, 16, 16)
end

function Player:update()
    if Input.is_key_just_pressed(scancodes.SDL_SCANCODE_W) then
        self.position:move(0, -1)
    end
    if Input.is_key_just_pressed(scancodes.SDL_SCANCODE_S) then
        self.position:move(0, 1)
    end

    if Input.is_key_just_pressed(scancodes.SDL_SCANCODE_A) then
        self.position:move(-1, 0)
    end
    if Input.is_key_just_pressed(scancodes.SDL_SCANCODE_D) then
        self.position:move(1, 0)
    end

    Gfx.set_camera_offset(point(-self.position.x, -self.position.y))
end

function Player:draw()
    self.sprite.dst_rect:set_position(self.position.x, self.position.y)
    Gfx.draw_sprite(self.sprite)
end

return Player
