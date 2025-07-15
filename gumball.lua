-- gumball.lua
-- Gumball entity derived from base Entity

local Entity = require("entity")

local Gumball = {}
Gumball.__index = Gumball
setmetatable(Gumball, {__index = Entity})

function Gumball:new(x, y, radius, speed, color, type)
    local instance = Entity:new(x, y, radius, speed, color, type)
    setmetatable(instance, self)

    -- Gumball-specific properties
    instance.type = type or "gumball"
    instance.baseSpeed = speed       -- Base movement speed
    instance.baseColor = color or {1.0, 0.8, 0.8}
    instance.damageColor = {1.0, 0.2, 0.2}
    instance.health = 3

    instance.currentMouth = nil -- The current mouth the gumball is in

    -- Movement properties
    instance.flag = false -- Whether the gumball is currently moving
    instance.direction = 0  -- Now in radians (0 = right)
    instance.movementDirection = instance.direction
    instance.directionDirection = 1 -- 1 = clockwise, -1 = counterclockwise

    -- Rotation properties
    instance.rotationSpeed = math.rad(90)
    instance.baseRotation = math.rad(90)      -- Base rotation speed (radians/sec)

    -- Charge properties
    instance.chargeMax = 9.0       -- Maximum charge multiplier
    instance.chargeRate = 3      -- Charge rate per second
    instance.currentCharge = 1.0   -- Current charge multiplier (starts at 1x)
    instance.isCharging = false    -- Whether we're currently charging
    instance.chargeStartTime = 0   -- When charging started
    instance.chargeMult = 5

    -- Duplication properties
    instance.duplicationCooldown = 0.5
    instance.duplicationTimer = 0.5

    -- Score properties
    instance.visitedMouths = {}
    instance.points = 0
    instance.pointMult = 1
   
    -- I-frames
    instance.iFrames = 0.8
    instance.iFrameTimer = 0.5
    

    return instance
end

function Gumball:update(dt, entities, camera)
    self:healthCheck(entities)
    self.rotationSpeed = self.baseRotation + math.rad(self.points)
    if self.isCharging then
        self:chargeCheck()
    end

    self.direction = (self.direction + dt * self.directionDirection * self.rotationSpeed) % (2 * math.pi)
    if self.flag then
        self:move(dt, camera)
    end

    self.duplicationTimer = self.duplicationTimer - dt

    if self.iFrameTimer > 0 then
        self.iFrameTimer = self.iFrameTimer - dt
    else
        self.color = self.baseColor
    end
    
end

function Gumball:move(dt, camera)
    -- Calculate screen boundaries relative to camera
    local screenLeft = camera.x - love.graphics.getWidth()/(2*camera.scale)
    local screenRight = camera.x + love.graphics.getWidth()/(2*camera.scale)
    local screenTop = camera.y - love.graphics.getHeight()/(2*camera.scale)
    local screenBottom = camera.y + love.graphics.getHeight()/(2*camera.scale)
    
    -- Calculate movement
    local dx = math.cos(self.movementDirection) * self.speed * dt
    local dy = math.sin(self.movementDirection) * self.speed * dt
    
    -- Store previous position for collision recovery
    local prevX, prevY = self.x, self.y
    
    -- Apply movement
    self.x = self.x + dx
    self.y = self.y + dy
    
    -- Boundary checks with better collision response
    local bounced = false
    
    -- Left/Right boundary check
    if self.x - self.radius < screenLeft then
        self.x = screenLeft + self.radius
        self.movementDirection = math.pi - self.movementDirection
        bounced = true
    elseif self.x + self.radius > screenRight then
        self.x = screenRight - self.radius
        self.movementDirection = math.pi - self.movementDirection
        bounced = true
    end
    
    -- Top/Bottom boundary check (accounts for camera panning)
    if self.y - self.radius < screenTop then
        self.y = screenTop + self.radius
        self.movementDirection = -self.movementDirection
        bounced = true
    elseif self.y + self.radius > screenBottom then
        self.y = screenBottom - self.radius
        self.movementDirection = -self.movementDirection
        bounced = true
    end
    
    if bounced then
        self.speed = self.speed * 0.95  -- Reduce speed slightly on bounce
    end
    
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

function Gumball:onCollision(other, entities)
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
                self.color = self.damageColor
                self.health = self.health - 1
            end
        end
    end
    if other.type == "healingUpgrade" then
        self.health = self.health + 1
        other.active = false
    end
    if other.type == "duplicationUpgrade" then
        other.active = false
        if self.duplicationTimer <= 0 then
            self.duplicationTimer = self.duplicationCooldown
            local gumballJr = Gumball:new(self.x, self.y, self.radius, self.baseSpeed, self.color, self.type)
            table.insert(entities, gumballJr)
        end
    end
    if other.type == "nukeUpgrade" then
        local pointTracker = 0
        for _, entity in ipairs(entities) do
            if entity.type == "projectile" then
                pointTracker = pointTracker + 1
                if pointTracker >= 5 then
                    pointTracker = 0
                    self.points = self.points + 1
                end
                entity.active = false
            end
        end
        other.active = false
    end
end

function Gumball:healthCheck(entities)
    if self.health <= 0 then
        self.active = false
    end
    local continue = false
    for _, entity in ipairs(entities) do
        if entity.type == "gumball" and entity.active then
            continue = true
        end
    end
    if not continue then
        love.event.quit()
    end
end

function Gumball:chargeCheck()
    self.currentCharge = math.min(1.0 + (self.chargeRate * (love.timer.getTime() - self.chargeStartTime)), self.chargeMax)
    self.rotationSpeed = self.baseRotation * self.currentCharge
end

function Gumball:chargeStart()
    self.isCharging = true
    self.chargeStartTime = love.timer.getTime()
    self.currentCharge = 1.0  -- Reset charge when starting new press
end

function Gumball:cancelCharge()
    self.isCharging = false
    self.chargeStartTime = 0
    self.currentCharge = 1.0  -- Reset charge when starting new press
end

function Gumball:releaseCharge()
    local chargeTime = love.timer.getTime() - self.chargeStartTime
    -- Calculate charge multiplier (capped at chargeMax)
    self.currentCharge = math.min(1.0 + (self.chargeRate * chargeTime), self.chargeMax)
        

    self.isCharging = false
    self.flag = true
    self.movementDirection = self.direction
    self.speed = self.baseSpeed * self.currentCharge/self.chargeMult
    self.rotationSpeed = self.baseRotation
end

function Gumball:changeDirection()
    self.directionDirection = self.directionDirection * -1
end

return Gumball