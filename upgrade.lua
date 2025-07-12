-- upgrade.lua
local Entity = require("entity")

local Upgrade = {}
Upgrade.__index = Upgrade
setmetatable(Upgrade, {__index = Entity})

function Upgrade:new(x, y, radius, color, type)
    local instance = Entity:new(x, y, radius, 0, color, type)
    setmetatable(instance, self)

    instance.type = type or "upgrade"
    
    return instance
end

function Upgrade:update(dt)

end

function Upgrade:draw()
    love.graphics.push()
    
    -- Draw upgrade body
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    
    love.graphics.pop()
end

function Upgrade:onCollision(other)
    self.active = false
end

return Upgrade