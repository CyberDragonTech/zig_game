local TextureLoader = {}


function TextureLoader.load()
    if not AssetsManager.load_texture("entity.bmp", "entity") then
        print("[Lua]TextureLoader[ERROR]: Failed to load entity.bmp")
    end
end

return TextureLoader