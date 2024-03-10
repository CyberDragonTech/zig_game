local TextureLoader = {}

TextureLoader.texture_list = {
   "entity.bmp", "entity"
}



function TextureLoader.load()
   AssetsManager.load_texture("entity.bmp", "entity")
end

return TextureLoader