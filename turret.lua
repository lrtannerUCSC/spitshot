-- turret.lua
-- Turret entity derived from base Entity

local Entity = require("entity")
local Projectile = require("projectile")

local Turret = {}
Turret.__index = Turret
setmetatable(Turret, {__index = Entity})

function Turret:new(x, y, radius, color, type, direction, rotationSpeed, shotSpeed, fireRate, projRadius, projLifespan)
    local instance = Entity:new(x, y, radius, 0, color, type)
    setmetatable(instance, self)

    instance.type = type or "turret"

    instance.direction = direction or 0  -- Now in radians (0 = right)
    instance.rotationSpeed = math.rad(rotationSpeed) or math.rad(60)

    instance.shotSpeed = shotSpeed
    instance.cooldown = fireRate
    instance.timer = fireRate
    
    instance.projectiles = {}
    instance.projRadius = projRadius
    instance.projLifespan = projLifespan

    return instance
end

function Turret:update(dt, entities)
    self.direction = (self.direction + dt * self.rotationSpeed) % (2 * math.pi)
    self.timer = self.timer - dt
    if (self.timer <= 0) then
        self:shoot(entities)
        self.timer = self.cooldown
    end
end

function Turret:move(dt)
    local dx = math.cos(self.movementDirection) * self.speed * dt
    local dy = math.sin(self.movementDirection) * self.speed * dt
    self.x = self.x + dx
    self.y = self.y + dy
end

function Turret:draw()
    love.graphics.push()
    
    -- First translate to the rotation origin point
    love.graphics.translate(self.x, self.y)
    
    -- Then apply the current rotation
    love.graphics.rotate(self.direction)
    
    
    -- Cheek parameters
    local cheekDistance = self.radius * 0.6  -- Distance from center
    local cheekSize = self.radius * 0.9  -- Slightly smaller than main radius
    
    -- Left cheek (90 degrees from forward)
    local leftX = math.cos(math.rad(90)) * cheekDistance
    local leftY = math.sin(math.rad(90)) * cheekDistance
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", leftX, leftY, cheekSize)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.circle("line", leftX, leftY, cheekSize)
    
    -- Right cheek (-90 degrees from forward)
    local rightX = math.cos(math.rad(-90)) * cheekDistance
    local rightY = math.sin(math.rad(-90)) * cheekDistance
    love.graphics.setColor(self.color)
    love.graphics.circle("fill", rightX, rightY, cheekSize)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.circle("line", rightX, rightY, cheekSize)
    
    
    love.graphics.pop()
end

function Turret:shoot(entities)
    -- Fire in the rear direction (opposite of facing)
    local projectile = Projectile:new(
        self.x,
        self.y,
        self.projRadius,
        self.shotSpeed,
        self.color,
        nil,
        self.direction + math.pi,  -- Fire backward,
        nil,
        nil,
        self.projLifespan  -- lifespan
    )
    if projectile then 
        table.insert(entities, projectile)
    end
end

function Turret:onCollision(other)
end


return Turret