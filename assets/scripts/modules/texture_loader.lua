local TextureLoader = {}


function TextureLoader.load()
    if not load_texture("entity.bmp", "entity") then
        print("TextureLoader[ERROR]: Failed to load entity.bmp")
    end
end

return TextureLoader