-- duplicationUpgrade.lua
local Upgrade = require("upgrade")

local DuplicationUpgrade = {}
DuplicationUpgrade.__index = DuplicationUpgrade
setmetatable(DuplicationUpgrade, {__index = Upgrade})

function DuplicationUpgrade:new(x, y, radius, color, type, subtype, cost, count)
    local instance = Upgrade:new(x, y, radius, color, type, subtype, cost)
    setmetatable(instance, self)

    instance.count = count
    
    return instance
end

function DuplicationUpgrade:update(dt)

end


return DuplicationUpgrade