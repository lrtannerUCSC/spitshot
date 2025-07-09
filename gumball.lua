-- gumball.lua
-- Gumball entity derived from base Entity

local Entity = require("entity")

local Gumball = {}
Gumball.__index = Gumball
setmetatable(Gumball, {__index = Entity})

function Gumball:new(x, y, radius, speed, color, type)
    local instance = Entity:new(x, y, radius)
    setmetatable(instance, self)

    instance.color = color or {0.3, 1, 0.3}
    instance.type = type or "gumball"
    instance.direction = 0  -- Now in radians (0 = right)
    instance.rotationSpeed = math.rad(60)
    instance.speed = speed or 100
    instance.flag = false
    instance.movementDirection = instance.direction
    instance.currentMouth = nil

    return instance
end

function Gumball:update(dt)
    self.direction = (self.direction + dt * self.rotationSpeed) % (2 * math.pi)
    if self.flag then
        self:move(dt)
        self.color = {0, 0, 1}  -- Blue when moving
    else
        self.color = {0.3, 1, 0.3}  -- Green when stationary
    end
end

function Gumball:move(dt)
    local dx = math.cos(self.movementDirection) * self.speed * dt
    local dy = math.sin(self.movementDirection) * self.speed * dt
    self.x = self.x + dx
    self.y = self.y + dy
end

function Gumball:draw()
    love.graphics.push()
    
    -- Draw the circle
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    
    -- Draw centered direction indicator
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.direction+math.rad(90))  -- Rotate to current direction
    
    local rect_width = self.radius/5
    local rect_height = self.radius*2
    love.graphics.rectangle("fill", 
        -rect_width/2,  -- X position: half width left to center
        -rect_height, -- Y position: half height up to center
        rect_width, 
        rect_height)
    
    love.graphics.pop()
    
    -- Draw entity type
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.type, self.x-self.radius/3, self.y - 5)
    love.graphics.setColor(1, 1, 1)
end

function Gumball:checkCollision(other)
    return math.abs(self.x - other.x) < (other.radius) and
           math.abs(self.y - other.y) < (other.radius)
end

function Gumball:onCollision(other)
    if other.type == "mouth" and other.id ~= self.currentMouth then
        self.x = other.x
        self.y = other.y
        self.flag = false
        self.currentMouth = other.id
    end
end


return Gumball