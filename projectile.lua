-- projectile.lua
local Entity = require("entity")

local Projectile = {}
Projectile.__index = Projectile
setmetatable(Projectile, {__index = Entity})

function Projectile:new(x, y, radius, speed, color, type, direction, targetX, targetY, lifespan)
    local instance = Entity:new(x, y, radius, speed, color, type)
    setmetatable(instance, self)

    instance.type = type or "projectile"
    instance.targetX = targetX or nil
    instance.targetY = targetY or nil
    instance.lifespan =  lifespan or 10
    instance.lifeDuration = 0
    
    -- Calculate initial direction toward target
    instance.direction = direction or math.atan2(targetY - y, targetX - x)
    
    -- Movement vector components (normalized)
    instance.dx = math.cos(instance.direction)
    instance.dy = math.sin(instance.direction)
    
    return instance
end

function Projectile:update(dt)
    if self.active then
        -- Move continuously in the calculated direction
        self.x = self.x + self.dx * self.speed * dt
        self.y = self.y + self.dy * self.speed * dt
        
        self.lifeDuration = self.lifeDuration + dt
        if self.lifeDuration >= self.lifespan then
            self.active = false
        end
        
    end
end

function Projectile:draw()
    love.graphics.push()
    
    -- Draw projectile body
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    
    love.graphics.pop()
end

function Projectile:checkCollision(other)
end

function Projectile:onCollision(other)
end

return Projectile