-- entityfactory.lua
local Entity = require("entity")
local Mouth = require("mouth")
local Gumball = require("gumball")
local Projectile = require("projectile")
local Turret = require("turret")  -- Make sure to require your Turret class

local EntityFactory = {}

-- Generalized spawn configuration
EntityFactory.SPAWN_CONFIG_MOUTH = {
    RADIUS = 1200,           -- Area around camera to consider
    MIN_DISTANCE = 150,      -- Minimum space between entities
    GRID_SIZE = 500,         -- Exploration grid chunk size
    MAX_ATTEMPTS = 10,       -- Max attempts to find valid position
    SPAWN_COOLDOWN = 10      -- Pixels camera must move before next spawn
}

EntityFactory.SPAWN_CONFIG_TURRET = {
    RADIUS = 1200,           -- Area around camera to consider
    MIN_DISTANCE = 450,      -- Minimum space between entities
    GRID_SIZE = 500,         -- Exploration grid chunk size
    MAX_ATTEMPTS = 20,       -- Max attempts to find valid position
    SPAWN_COOLDOWN = 50      -- Pixels camera must move before next spawn
}

-- State tracking
EntityFactory.exploredChunks = {}
EntityFactory.lastSpawnPosition = {x = 0, y = 0}

-- Entity creation functions
function EntityFactory:createProjectile(x, y, direction, radius, speed)
    return Projectile:new(x, y, direction, nil, nil, radius, speed)
end

function EntityFactory:createMouth(x, y, radius)
    return Mouth:new(x, y, radius or 20)
end

function EntityFactory:createTurret(x, y, radius)
    return Turret:new(x, y, radius or 30, 100, 45, 1)
end

function EntityFactory:createTwinTurrets(x, y, radius)
    local turret1 = Turret:new(
        x, y,  -- Position
        x, y,  -- Rotation origin (same as position)
        radius or 30,
        100,   -- speed
        45,    -- rotation speed (degrees/sec)
        1,     -- fire rate
        0      -- Initial direction (right)
    )
    
    local turret2 = Turret:new(
        x, y,  -- Same position
        x, y,  -- Same rotation origin
        radius or 30,
        100,   -- speed
        45,    -- rotation speed
        1,     -- fire rate
        math.pi  -- Opposite direction (left)
    )
    
    return {turret1, turret2}  -- Return both turrets as a pair
end

-- Generalized procedural spawn function
function EntityFactory:attemptProceduralSpawn(cameraX, cameraY, existingEntities, entityType, spawnParams)
    local config
    if entityType == "mouth" then
        config = self.SPAWN_CONFIG_MOUTH
    elseif entityType == "turret" then
        config = self.SPAWN_CONFIG_TURRET
    end
    -- Check spawn cooldown
    if self:distance(cameraX, cameraY, self.lastSpawnPosition.x, self.lastSpawnPosition.y) < config.SPAWN_COOLDOWN then
        return nil
    end

    -- Mark current chunk as explored
    local chunk = self:getCurrentChunk(cameraX, cameraY, config)
    self.exploredChunks[chunk.x..","..chunk.y] = true

    -- Try to find valid spawn position
    for i = 1, config.MAX_ATTEMPTS do
        local angle = math.random() * math.pi * 2
        local distance = config.RADIUS * (0.8 + math.random() * 0.4)
        local x = cameraX + math.cos(angle) * distance
        local y = cameraY + math.sin(angle) * distance

        if self:isPositionValid(x, y, existingEntities, entityType, config) then
            self.lastSpawnPosition = {x = cameraX, y = cameraY}
            
            -- Create the appropriate entity type
            if entityType == "mouth" then
                return self:createMouth(x, y, spawnParams and spawnParams.radius)
            elseif entityType == "turret" then
                local turret1 = self:createTurret(
                x, 
                y  -- Position
                )
            
                local turret2 = self:createTurret(
                    x, 
                    y  -- Position
                )
                turret2.direction = math.pi
            return {turret1, turret2}  -- Return both turrets as a pairs
            -- Add more entity types as needed
            end
        end
    end
    return nil
end

-- Updated position validation
function EntityFactory:isPositionValid(x, y, entities, entityType, config)
    for _, e in ipairs(entities) do
        -- Check against all entities of the same type
        if (e.type == entityType or e.name == entityType) and 
           self:distance(x, y, e.x, e.y) < config.MIN_DISTANCE then
            return false
        end
    end
    return true
end

function EntityFactory:createRandomProjectile(radius, screenWidth, screenHeight, originX, originY)

    -- Calculate the minimum radius needed to ensure off-screen spawning
    -- (distance from center to corner plus padding)
    local minRadius = math.sqrt((screenWidth/2)^2 + (screenHeight/2)^2) + 100
    
    -- Random angle in radians (0 to 2π)
    local angle = math.random() * 2 * math.pi
    
    -- Calculate spawn position on circumference
    local projX = originX + minRadius * math.cos(angle)
    local projY = originY + minRadius * math.sin(angle)
    
    -- Target somewhere in the central area of the screen
    local targetX = originX + math.random(-screenWidth/4, screenWidth/4)
    local targetY = originY + math.random(-screenHeight/4, screenHeight/4)
    
    return Projectile:new(projX, projY, nil, targetX, targetY, radius)
end

function EntityFactory:createRandomGridProjectile(radius, screenWidth, screenHeight, originX, originY)
    -- Choose one of the four cardinal directions (0=right, 1=left, 2=down, 3=up)
    local direction = math.random(0, 3)
    
    local projX, projY, targetX, targetY
    local padding = 100  -- How far off-screen to spawn
    
    if direction == 0 then    -- Right to left (westward)
        projX = originX + screenWidth/2 + padding
        projY = originY + math.random(screenHeight/8, screenHeight*7/8)
        targetX = originX - screenWidth/2 - padding
        targetY = projY  -- Keep same Y to move horizontally
    elseif direction == 1 then -- Left to right (eastward)
        projX = originX - screenWidth/2 - padding
        projY = originY + math.random(screenHeight/8, screenHeight*7/8)
        targetX = originX + screenWidth/2 + padding
        targetY = projY
    elseif direction == 2 then -- Top to bottom (southward)
        projX = originX + math.random(screenWidth/8, screenWidth*7/8)
        projY = originY - screenHeight/2 - padding
        targetX = projX
        targetY = originY + screenHeight/2 + padding
    else                      -- Bottom to top (northward)
        projX = originX + math.random(screenWidth/8, screenWidth*7/8)
        projY = originY + screenHeight/2 + padding
        targetX = projX
        targetY = originY - screenHeight/2 - padding
    end
    
    return Projectile:new(projX, projY, nil, targetX, targetY, radius)
end

-- Keep these helper functions
function EntityFactory:getCurrentChunk(x, y, config)
    local gs = config.GRID_SIZE
    return {
        x = math.floor(x / gs),
        y = math.floor(y / gs)
    }
end

function EntityFactory:distance(x1, y1, x2, y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

return EntityFactory