-- upgrade.lua
local Entity = require("entity")

local Upgrade = {}
Upgrade.__index = Upgrade
setmetatable(Upgrade, {__index = Entity})

function Upgrade:new(x, y, radius, speed, color, type)
    local instance = Entity:new(x, y, radius)
    setmetatable(instance, self)

    instance.color = color or {0, 0.5, 0.2}
    instance.type = type or "upgrade"
    instance.speed = speed or 0
    instance.active = true
    
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