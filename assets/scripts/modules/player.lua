local scancodes = require "assets.scripts.scancodes"
local Rect = require "assets.scripts.core.rect"
local Point = require "assets.scripts.core.point"
local Utils = require "assets.scripts.utility_functions"

local Player = {}


function Player:start()
    self.entity = require "assets.scripts.entity"
    self.entity1 = Utils.table_deep_copy(self.entity)
    self.entity:start()
    self.entity1:start()
    self.position = Point.new(0, 0)
    ---@class (exact) Sprite
    self.sprite = {}
    self.sprite.texture = get_texture("entity")
    self.sprite.segment = Rect.new(0, 0, 16, 16)
    self.sprite.dst_rect = Rect.new(0, 0, 16, 16)
end

function Player:update()
    self.entity:update()
    self.entity1:update()
    if is_key_just_pressed(scancodes.SDL_SCANCODE_W) then
        self.position:move(0, -1)
    end
    if is_key_just_pressed(scancodes.SDL_SCANCODE_S) then
        self.position:move(0, 1)
    end

    if is_key_just_pressed(scancodes.SDL_SCANCODE_A) then
        self.position:move(-1, 0)
    end
    if is_key_just_pressed(scancodes.SDL_SCANCODE_D) then
        self.position:move(1, 0)
    end

    gfx_set_camera_offset(Point.new(-self.position.x + 7, -self.position.y + 7))
end

function Player:draw()
    self.entity:draw()
    self.entity1:draw()

    self.sprite.dst_rect:set_position(self.position.x, self.position.y)
    gfx_draw_sprite(self.sprite)
end

return Player
