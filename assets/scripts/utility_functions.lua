local Utils = {}


function Utils.table_deep_copy(t)
    if (type(t) ~= "table") then
        return t
    end
    local t2 = {}
    for k,v in pairs(t) do
        local nv
        if type(v) ~= "table" then
            nv = v
        else
            nv = Utils.table_deep_copy(v)
        end
        t2[k] = nv
    end
    return t2
  end


function Utils.dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. Utils.dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

return Utils