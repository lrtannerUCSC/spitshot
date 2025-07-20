-- upgrade.lua
local Entity = require("entity")

local Upgrade = {}
Upgrade.__index = Upgrade
setmetatable(Upgrade, {__index = Entity})

function Upgrade:new(x, y, radius, color, type, subtype, cost)
    local instance = Entity:new(x, y, radius, 0, color, type)
    setmetatable(instance, self)

    instance.type = type or "upgrade"
    instance.subtype = subtype or nil
    instance.cost = cost or 0
    
    return instance
end

function Upgrade:update(dt)
end

function Upgrade:draw()
    love.graphics.push()
    
    -- Draw upgrade body
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.cost, self.x-self.radius/2, self.y - 5)
    
    love.graphics.pop()
end

function Upgrade:onCollision(other)
end

return Upgrade