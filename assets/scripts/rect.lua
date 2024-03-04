local Rect = {}

---@param x number
---@param y number
---@param w number
---@param h number
function Rect.new(x, y, w, h)

---@class Rect
---@field x number
---@field y number
---@field w number
---@field h number
    rect = {
        x = x,
        y = y,
        w = w,
        h = h,
    }

---@param _x number
---@param _y number
    function rect:move(_x, _y)
        self.x = self.x + _x
        self.y = self.y + _y
    end
    
---@param _x number
---@param _y number
    function rect:set_position(_x, _y)
        self.x = _x
        self.y = _y
    end
    return rect
end

return Rect