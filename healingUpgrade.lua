-- healingUpgrade.lua
local Upgrade = require("upgrade")

local HealingUpgrade = {}
HealingUpgrade.__index = HealingUpgrade
setmetatable(HealingUpgrade, {__index = Upgrade})

function HealingUpgrade:new(x, y, radius, color, type, subtype, cost, health)
    local instance = Upgrade:new(x, y, radius, color, type, subtype, cost)
    setmetatable(instance, self)

    instance.health = health
    
    return instance
end

function HealingUpgrade:update(dt)

end

return HealingUpgrade