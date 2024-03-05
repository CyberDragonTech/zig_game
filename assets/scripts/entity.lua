local Rect = require "assets.scripts.core.rect"

local MIN_COUNTER = 30
local MAX_COUNTER = 100

local Entity = {}


function Entity:start()
    self.position = Rect.new(math.random(0, 15), math.random(0, 15), 16, 16)
    self.counter = math.random(MIN_COUNTER, MAX_COUNTER)
    ---@class (exact) Sprite
    self.sprite = {}
    self.sprite.texture = get_texture("entity")
    self.sprite.segment = Rect.new(0, 0, 16, 16)
    self.sprite.dst_rect = Rect.new(10, 10, 16, 16)
end

function Entity:update()
    self.counter = self.counter - 1
    if self.counter <= 0 then
        -- self.position:move(math.random(-1, 1), math.random(-1, 1))
        -- self.counter = math.random(MIN_COUNTER, MAX_COUNTER)
    end

    if self.position.x < 0 then
        self.position.x = 0
    end
    if self.position.y < 0 then
        self.position.y = 0
    end

    local MAP_BOUNDARY = (256 / 16) - 1
    if self.position.x >= MAP_BOUNDARY then
        self.position.x = MAP_BOUNDARY
    end
    if self.position.y >=  MAP_BOUNDARY then
        self.position.y = MAP_BOUNDARY
    end
end

function Entity:draw()
    self.sprite.dst_rect:set_position(self.position.x, self.position.y)
    gfx_draw_sprite(self.sprite)
end

return Entity
