-- healingUpgrade.lua
local Upgrade = require("upgrade")

local HealingUpgrade = {}
HealingUpgrade.__index = HealingUpgrade
setmetatable(HealingUpgrade, {__index = Upgrade})

function HealingUpgrade:new(x, y, radius, speed, color, type, health)
    local instance = Upgrade:new(x, y, radius)
    setmetatable(instance, self)

    instance.color = color or {0, 0.5, 0.2}
    instance.type = type or "healingUpgrade"
    instance.speed = speed or 0
    instance.active = true
    instance.health = health
    
    return instance
end

function HealingUpgrade:update(dt)

end

function HealingUpgrade:draw()
    love.graphics.push()
    
    -- Draw healingUpgrade body
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    
    love.graphics.pop()
end


return HealingUpgrade