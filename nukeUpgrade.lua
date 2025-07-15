-- nukeUpgrade.lua
local Upgrade = require("upgrade")

local NukeUpgrade = {}
NukeUpgrade.__index = NukeUpgrade
setmetatable(NukeUpgrade, {__index = Upgrade})

function NukeUpgrade:new(x, y, radius, color, type, count)
    local instance = Upgrade:new(x, y, radius, color, type)
    setmetatable(instance, self)

    instance.type = type or "nukeUpgrade"
    instance.count = count
    
    return instance
end

function NukeUpgrade:update(dt)

end

function NukeUpgrade:draw()
    love.graphics.push()
    
    -- Draw nukeUpgrade body
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    
    love.graphics.pop()
end


return NukeUpgrade