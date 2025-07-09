-- entity.lua
-- Base Entity class for all game objects

local Entity = {}
Entity.__index = Entity

-- Constructor
function Entity:new(x, y, radius)
    local instance = {}
    setmetatable(instance, self)
    
    -- Common properties for all entities
    instance.x = x or 0
    instance.y = y or 0
    instance.radius = radius or 100
    instance.speed = 50
    instance.color = {1, 1, 1}
    instance.type = "entity"
    instance.active = true
    instance.id = tostring(math.random(1000000))
    
    return instance
end

-- Common methods for all entities
function Entity:update(dt)
    -- Base update logic
end

function Entity:draw()
    -- Set color and draw rectangle
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    
    -- Draw entity type
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.type, self.x-self.radius/3, self.y - 5)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

function Entity:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Entity:checkCollision(other)
    return math.abs(self.x - other.x) < (self.radius + other.radius) and
           math.abs(self.y - other.y) < (self.radius + other.radius)
end


function Entity:onCollision(other)
    -- Base collision behavior
end

function Entity:getInfo()
    return {
        type = self.type,
        position = {x = self.x, y = self.y},
        size = {radius = self.radius},
        id = self.id
    }
end

return Entity
