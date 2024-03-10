---@meta

---Global list of all loaded scripts in engine
__modules__ = {}

---@class Sprite
---@field texture number
---@field segment Rect
---@field dst_rect Rect
Sprite = {}


---@class Point
---@field x number
---@field y number
Point = {}

---@param x number
---@param y number
function Point:move(x, y) end

---@param x number
---@param y number
function Point:set_position(x, y) end

---@class Rect
---@field x number
---@field y number
---@field w number
---@field h number
Rect = {}

---@param x number
---@param y number
function Rect:move(x, y) end

---@param x number
---@param y number
function Rect:set_position(x, y) end

---@param w number
---@param h number
function Rect:set_size(w, h) end

---@param x number
---@param y number
---@return Point
function point(x, y) end

---@param x number
---@param y number
---@param w number
---@param h number
---@return Rect
function rect(x, y, w, h) end