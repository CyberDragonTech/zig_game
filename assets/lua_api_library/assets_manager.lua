---@meta


AssetsManager = {}

---Load BMP image and set strign id to it
---
---Return false when fails
---@param file string file path relative to assets/textures/
---@param texture_id string
---@return boolean
function AssetsManager.load_texture(file, texture_id) end

---Get texture with secified ID annd returns its pointer as number
---
---If texture was not found return -1
---@param texture_id string
---@return integer
function AssetsManager.get_texture(texture_id) end