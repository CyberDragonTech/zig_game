---@meta


---@class Rect
---@field x number
---@field y number
---@field w number
---@field h number
Rect = {}

---@class Sprite
---@field texture number
---@field segment Rect
---@field dst_rect Rect
Sprite = {}

---Check is key is pressed
---@param scancode integer sdl scancode
---@return boolean
function is_key_pressed(scancode) end

---Check is key was just pressed this frame
---@param scancode integer sdl scancode
---@return boolean
function is_key_just_pressed(scancode) end

---Get texture with secified ID annd returns its pointer as number
---
---If texture was not found return -1
---@param texture_id string
---@return integer
function get_texture(texture_id) end

---Draw sprite
---@param sprite Sprite
---@return boolean
function gfx_draw_sprite(sprite) end


---Global list of all loaded scripts in engine
__modules__ = {}