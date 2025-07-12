-- gumball.lua
-- Gumball entity derived from base Entity

local Entity = require("entity")

local Gumball = {}
Gumball.__index = Gumball
setmetatable(Gumball, {__index = Entity})

function Gumball:new(x, y, radius, speed, color, type)
    local instance = Entity:new(x, y, radius, speed, color, type)
    setmetatable(instance, self)

    instance.type = type or "gumball"
    instance.health = 3
    instance.direction = 0  -- Now in radians (0 = right)
    instance.rotationSpeed = math.rad(90)
    instance.flag = false
    instance.movementDirection = instance.direction
    instance.currentMouth = nil
    instance.baseSpeed = speed       -- Base movement speed
    instance.baseRotation = math.rad(90)      -- Base rotation speed (radians/sec)
    instance.chargeMax = 15.0       -- Maximum charge multiplier
    instance.chargeRate = 5      -- Charge rate per second
    instance.currentCharge = 1.0   -- Current charge multiplier (starts at 1x)
    instance.isCharging = false    -- Whether we're currently charging
    instance.chargeStartTime = 0   -- When charging started
    instance.visitedMouths = {}
    instance.points = 0
    instance.pointMult = 1
    instance.iFrames = 0.8
    instance.iFrameTimer = 0.5
    instance.directionDirection = 1

    return instance
end

function Gumball:update(dt)
    self.direction = (self.direction + dt * self.directionDirection * self.rotationSpeed) % (2 * math.pi)
    if self.flag then
        self:move(dt)
    end
    if self.iFrameTimer > 0 then
        self.iFrameTimer = self.iFrameTimer - dt
    else
        self.color = {0.3, 1, 0.3}
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
    
    local rect_width = self.radius/2
    local rect_height = self.radius*3
    love.graphics.rectangle("fill", 
        -rect_width/2,  -- X position: half width left to center
        -rect_height, -- Y position: half height up to center
        rect_width, 
        rect_height)
    
    love.graphics.pop()
    
    -- Draw entity type
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.points, self.x-self.radius/2, self.y-self.radius/2)
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
        local visited = false
        for _, mouth in ipairs(self.visitedMouths) do
            if other.id == mouth.id then
                visited = true
            end
        end
        if visited then
            self.points = self.points + 1 * self.pointMult
        else
            self.points = self.points + 5 * self.pointMult
        end
        table.insert(self.visitedMouths, other)
    end
    if other.type == "projectile" then
        if self.flag then
            if self.iFrameTimer <= 0 then
                self.iFrameTimer = self.iFrames
                self.color = {1, 0, 0}
                self.health = self.health - 1
            end
        end
    end
    if other.type == "healingUpgrade" then
        self.health = self.health + 1
        other.active = false
    end
end


return Gumball