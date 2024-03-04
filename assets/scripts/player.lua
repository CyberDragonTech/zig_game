local scancodes = require "assets/scripts/scancodes"
local Rect = require "assets/scripts/rect"

local Player = {}


function Player:start()
    ---@class (exact) Sprite
    Player.sprite = {}
    Player.sprite.texture = get_texture("entity")
    Player.sprite.segment = Rect.new(0, 0, 16, 16)
    Player.sprite.dst_rect = Rect.new(10, 10, 16, 16)
end

function Player:update()
    if is_key_just_pressed(scancodes.SDL_SCANCODE_W) then
        self.sprite.dst_rect:move(0, -1)
    end
    if is_key_just_pressed(scancodes.SDL_SCANCODE_S) then
        self.sprite.dst_rect:move(0, 1)
    end

    if is_key_just_pressed(scancodes.SDL_SCANCODE_A) then
        self.sprite.dst_rect:move(-1, 0)
    end
    if is_key_just_pressed(scancodes.SDL_SCANCODE_D) then
        self.sprite.dst_rect:move(1, 0)
    end

    if self.sprite.dst_rect.x < 0 then
        self.sprite.dst_rect.x = 0
    end
    if self.sprite.dst_rect.y < 0 then
        self.sprite.dst_rect.y = 0
    end

    local MAP_BOUNDARY = (256 / 16) - 1
    if self.sprite.dst_rect.x >= MAP_BOUNDARY then
        self.sprite.dst_rect.x = MAP_BOUNDARY
    end
    if self.sprite.dst_rect.y >=  MAP_BOUNDARY then
        self.sprite.dst_rect.y = MAP_BOUNDARY
    end
end

function Player:draw()
    gfx_draw_sprite(self.sprite)
end

return Player
