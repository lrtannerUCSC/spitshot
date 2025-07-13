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
    instance.currentGumball = nil

    return instance
end

function Mouth:update(dt)
    self.currentGumball = nil
end

function Mouth:onCollision(other)
    if other.type == "gumball" then
        self.currentGumball = other.id
    end
end
return Mouth