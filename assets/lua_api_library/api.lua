---@meta

---Global list of all loaded scripts in engine
__modules__ = {}

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

---If true, sprites will be drawn in screen position, if false - in world position
---@param mode boolean
function gfx_set_ui_draw_mode(mode) end

---Set world camera position
---@param offset Point
function gfx_set_camera_offset(offset) end

---Return time in secods that was taken to proccess previous frame
---@return number
function delta_time_seconds() end

---Return frames in previos second
---@return number
function fps() end

---Gfx sprite segment size in pixels
---@return number
function sprite_size() end

---Gfx target width in pixels
---@return number
function target_width() end

---Gfx target width in 
---@return number
function target_height() end