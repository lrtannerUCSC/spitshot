-- mouth.lua
-- Mouth entity derived from base Entity

local Entity = require("entity")

local Mouth = {}
Mouth.__index = Mouth
setmetatable(Mouth, {__index = Entity})

function Mouth:new(x, y, radius, color, type)
    local instance = Entity:new(x, y, radius, 0, color, type)
    setmetatable(instance, self)

    -- Mouth-specific properties
    instance.type = type or "mouth"

    return instance
end

return Mouth