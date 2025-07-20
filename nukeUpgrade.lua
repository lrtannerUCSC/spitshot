-- nukeUpgrade.lua
local Upgrade = require("upgrade")

local NukeUpgrade = {}
NukeUpgrade.__index = NukeUpgrade
setmetatable(NukeUpgrade, {__index = Upgrade})

function NukeUpgrade:new(x, y, radius, color, type, subtype, cost, count)
    local instance = Upgrade:new(x, y, radius, color, type, subtype, cost)
    setmetatable(instance, self)

    instance.count = count
    
    return instance
end

function NukeUpgrade:update(dt)

end

return NukeUpgrade