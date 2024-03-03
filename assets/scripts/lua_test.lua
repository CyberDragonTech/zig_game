mod = {}


function mod.test()
    print("Hello, Zig, form Lua")
    return "Hello, Zig, form Lua"
end


function mod.io_test(a)
    if type(a) ~= "number" then
        return -1
    end
    if a < 10 then
        return 0
    else
        return 1
    end
end


return mod