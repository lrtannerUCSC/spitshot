-- duplicationUpgrade.lua
local Upgrade = require("upgrade")

local DuplicationUpgrade = {}
DuplicationUpgrade.__index = DuplicationUpgrade
setmetatable(DuplicationUpgrade, {__index = Upgrade})

function DuplicationUpgrade:new(x, y, radius, color, type, count)
    local instance = Upgrade:new(x, y, radius, color, type)
    setmetatable(instance, self)

    instance.type = type or "duplicationUpgrade"
    instance.count = count
    
    return instance
end

function DuplicationUpgrade:update(dt)

end

function DuplicationUpgrade:draw()
    love.graphics.push()
    
    -- Draw duplicationUpgrade body
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    
    love.graphics.pop()
end


return DuplicationUpgrade