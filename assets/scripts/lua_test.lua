TestMod = {}
local scancodes = require "assets/scripts/scancodes"

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end


TestMod.tex = get_texture("spr_test")

---@class (exact) Sprite
TestMod.sprite = {}
TestMod.sprite.texture = TestMod.tex
TestMod.sprite.segment = {x = 0, y = 0, w = 16, h = 16}
TestMod.sprite.dst_rect = {x = 10, y = 10, w = 16, h = 16}

function TestMod.start()
    print(dump(__modules__) .. "\n")
end

function TestMod.update()
    if is_key_just_pressed(scancodes.SDL_SCANCODE_W) then
        TestMod.sprite.dst_rect.y = TestMod.sprite.dst_rect.y -1
    end
end

function TestMod.draw()
    local res = gfx_draw_sprite(TestMod.sprite)
end

return TestMod