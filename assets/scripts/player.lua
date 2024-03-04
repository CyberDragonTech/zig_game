

local Player = {}
local scancodes = require "assets/scripts/scancodes"



function Player.start()
    Player.tex = get_texture("entity")
    print(Player.tex)
    ---@class (exact) Sprite
    Player.sprite = {}
    Player.sprite.texture = Player.tex
    Player.sprite.segment = {x = 0, y = 0, w = 16, h = 16}
    Player.sprite.dst_rect = {x = 10, y = 10, w = 16, h = 16}
end

function Player.update()
    if is_key_just_pressed(scancodes.SDL_SCANCODE_W) then
        Player.sprite.dst_rect.y = Player.sprite.dst_rect.y - 1
    end
    if is_key_just_pressed(scancodes.SDL_SCANCODE_S) then
        Player.sprite.dst_rect.y = Player.sprite.dst_rect.y + 1
    end

    if is_key_just_pressed(scancodes.SDL_SCANCODE_A) then
        Player.sprite.dst_rect.x = Player.sprite.dst_rect.x - 1
    end
    if is_key_just_pressed(scancodes.SDL_SCANCODE_D) then
        Player.sprite.dst_rect.x = Player.sprite.dst_rect.x + 1
    end
end

function Player.draw()
    gfx_draw_sprite(Player.sprite)
end

return Player
