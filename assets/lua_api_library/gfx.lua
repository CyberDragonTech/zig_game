---@meta

Gfx = {}

---Draw sprite. Return false if failed to draw.
---@param sprite Sprite
---@return boolean
function Gfx.draw_sprite(sprite) end

---If true, sprites will be drawn in screen position, if false - in world position
---@param mode boolean
function Gfx.set_ui_draw_mode(mode) end

---Set world camera position
---@param offset Point
function Gfx.set_camera_offset(offset) end

---Gfx sprite segment size in pixels
---@return number
function Gfx.sprite_size() end

---Gfx target width in pixels
---@return number
function Gfx.target_width() end

---Gfx target width in 
---@return number
function Gfx.target_height() end