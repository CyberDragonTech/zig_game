---@meta


---Global list of all loaded scripts in engine
__modules__ = {}


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

---Load BMP image and set strign id to it
---
---Return false when fails
---@param file string file path relative to assets/textures/
---@param texture_id string
---@return boolean
function load_texture(file, texture_id) end