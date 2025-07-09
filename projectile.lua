-- projectile.lua
local Entity = require("entity")

local Projectile = {}
Projectile.__index = Projectile
setmetatable(Projectile, {__index = Entity})

function Projectile:new(x, y, targetX, targetY, radius, speed, color, type)
    local instance = Entity:new(x, y, radius)
    setmetatable(instance, self)

    instance.color = color or {1, 0.5, 0.2}  -- Orange projectiles by default
    instance.type = type or "projectile"
    instance.speed = speed or 200
    instance.active = true
    instance.targetX = targetX
    instance.targetY = targetY
    
    -- Calculate initial direction toward target
    instance.direction = math.atan2(targetY - y, targetX - x)
    
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
        
        -- -- Optional: Deactivate if out of screen bounds
        -- local margin = 100
        -- if self.x < -margin or self.x > love.graphics.getWidth() + margin or
        -- self.y < -margin or self.y > love.graphics.getHeight() + margin then
        --     self.active = false
        -- end
    end
end

function Projectile:draw()
    love.graphics.push()
    
    -- Draw projectile body
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    
    -- Draw direction indicator
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.direction + math.pi/2)  -- Point in movement direction
    
    local indicator_width = self.radius/4
    local indicator_length = self.radius*2
    love.graphics.rectangle("fill", 
        -indicator_width/2, 
        -indicator_length, 
        indicator_width, 
        indicator_length)
    
    love.graphics.pop()
end

function Projectile:checkCollision(other)
end

function Projectile:onCollision(other)

end

return Projectile