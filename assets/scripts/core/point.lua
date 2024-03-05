local Point = {}

---@param x number
---@param y number
function Point.new(x, y)

---@class Point
---@field x number
---@field y number
    local point = {
        x = x,
        y = y,
    }

---@param _x number
---@param _y number
    function point:move(_x, _y)
        self.x = self.x + _x
        self.y = self.y + _y
    end
    
---@param _x number
---@param _y number
    function point:set_position(_x, _y)
        self.x = _x
        self.y = _y
    end
    return point
end

return Point