Mod = {}
local scancodes = require "assets/scripts/scancodes"

function Mod.update()
    if is_key_just_pressed(scancodes.SDL_SCANCODE_SPACE) then
        print("Hello, Zig, form Lua")
    end
end


return Mod