-- mouth.lua
-- Mouth entity derived from base Entity

local Entity = require("entity")

local Mouth = {}
Mouth.__index = Mouth
setmetatable(Mouth, {__index = Entity})

function Mouth:new(x, y, radius, color, type)
    local instance = Entity:new(x, y, radius)
    setmetatable(instance, self)

    -- Mouth-specific properties
    instance.color = color or {1, 0.3, 0.3}  -- Red
    instance.type = type or "mouth"

    return instance
end

return Mouth