-- entityfactory.lua
local Entity = require("entity")
local Mouth = require("mouth")
local Gumball = require("gumball")
local Projectile = require("projectile")
local Turret = require("turret")
local HealingUpgrade = require("healingUpgrade")

local EntityFactory = {}

-- Generalized spawn configuration
EntityFactory.spawnConfigs = {}
local mouthConfig1 = {
    RADIUS = 500,           -- Area around camera to consider
    MIN_DISTANCE = 10,      -- Minimum space between entities
    GRID_SIZE = 500,         -- Exploration grid chunk size
    MAX_ATTEMPTS = 10,       -- Max attempts to find valid position
    SPAWN_COOLDOWN = 20      -- Pixels camera must move before next spawn
}

local buttConfig1 = {
    RADIUS = 500,           -- Area around camera to consider
    MIN_DISTANCE = 450,      -- Minimum space between entities
    GRID_SIZE = 500,         -- Exploration grid chunk size
    MAX_ATTEMPTS = 20,       -- Max attempts to find valid position
    SPAWN_COOLDOWN = 200      -- Pixels camera must move before next spawn
}

local noseConfig1 = {
    RADIUS = 500,           -- Area around camera to consider
    MIN_DISTANCE = 450,      -- Minimum space between entities
    GRID_SIZE = 500,         -- Exploration grid chunk size
    MAX_ATTEMPTS = 20,       -- Max attempts to find valid position
    SPAWN_COOLDOWN = 200      -- Pixels camera must move before next spawn
}

local healingUpgradeConfig1 = {
    RADIUS = 500,           -- Area around camera to consider
    MIN_DISTANCE = 450,      -- Minimum space between entities
    GRID_SIZE = 500,         -- Exploration grid chunk size
    MAX_ATTEMPTS = 20,       -- Max attempts to find valid position
    SPAWN_COOLDOWN = 100      -- Pixels camera must move before next spawn
}

table.insert(EntityFactory.spawnConfigs, mouthConfig1)
table.insert(EntityFactory.spawnConfigs, buttConfig1)
table.insert(EntityFactory.spawnConfigs, noseConfig1)
table.insert(EntityFactory.spawnConfigs, healingUpgradeConfig1)
-- State tracking
EntityFactory.exploredChunks = {}
EntityFactory.lastSpawnPositions = {
    mouth = {x = 0, y = 0},
    butt = {x = 0, y = 0},
    nose = {x = 0, y = 0},
    healingUpgrade = {x = 0, y = 0}
}

function EntityFactory:update(dt, entities, camera)
    -- Handle projectile wall spawning
    local params1 = {
        interval = 10,          -- seconds between spawns
        initialInterval = 10,
        count = 5,            -- number of projectiles
        direction = "right",    -- "left", "right", "top", "bottom"
        spread = 1.5,          -- spacing multiplier
        angle = 0,             -- base angle (0=right, math.pi/2=down, etc.)
        offsetX = 0,           -- additional X offset
        offsetY = love.graphics.getHeight()*camera.minScale *1.5,           -- additional Y offset
        
        radius = 25,
        speed = 65,            -- projectile speed
        color = {0.5, 0.3, 0.8},
        type = "projectile",
        lifespan = 60,
    }
    local newProjectiles = EntityFactory:spawnProjectileWall(dt, camera, params1)

    local params2 = {
        interval = 20,          -- seconds between spawns
        initialInterval = 15,
        count = 5,            -- number of projectiles
        direction = "top",    -- "left", "right", "top", "bottom"
        spread = 2,          -- spacing multiplier
        angle = 0,             -- base angle (0=right, math.pi/2=down, etc.)
        offsetX = 0,           -- additional X offset
        offsetY = 0,
        
        radius = 45,
        speed = 55,            -- projectile speed
        color = {0.5, 0.3, 0.8},
        type = "projectile",
        lifespan = 60,
    }
    local newProjectiles2 = EntityFactory:spawnProjectileWall(dt, camera, params2)
    for _, projectile in ipairs(newProjectiles2) do
        table.insert(newProjectiles, projectile)
    end
    for _, projectile in ipairs(newProjectiles) do
        table.insert(entities, projectile)
    end
end
-- Entity creation functions
function EntityFactory:createProjectile(x, y, radius, speed, color, type, direction, lifespan)
    return Projectile:new(x, y, radius, speed, color, type, direction, nil, nil, lifespan)
end

function EntityFactory:spawnProjectileWall(dt, camera, params)
    -- Default parameters
    local defaults = {
        interval = 5,          -- seconds between spawns
        count = 5,            -- number of projectiles
        direction = "left",    -- "left", "right", "top", "bottom"
        spread = 1.5,          -- spacing multiplier
        angle = 0,             -- base angle (0=right, math.pi/2=down, etc.)
        offsetX = 0,           -- additional X offset
        offsetY = 0,           -- additional Y offset

        radius = 25,
        speed = 30,            -- projectile speed
        color = {0.5, 0.3, 0.8},
        type = "projectile",
        lifespan = 15,
    }
    
    -- Merge provided params with defaults
    params = params or {}
    for k, v in pairs(defaults) do
        if params[k] == nil then
            params[k] = v
        end
    end

    -- Initialize timer if it doesn't exist
    self.projectileWallTimer = self.projectileWallTimer or params.initialInterval
    self.projectileWallTimer = self.projectileWallTimer + dt

    local newProjectiles = {}

    if self.projectileWallTimer >= params.interval then
        self.projectileWallTimer = 0  -- Reset timer
        
        -- Calculate starting position based on direction
        local projX, projY
        local screenWidth = love.graphics.getWidth() / camera.minScale
        local screenHeight = love.graphics.getHeight() / camera.minScale
        
        if params.direction == "left" then
            projX = camera.x - screenWidth/2 - params.offsetX
            projY = camera.y - screenHeight/2 + (screenHeight/params.count)/2 + params.offsetY
        elseif params.direction == "right" then
            projX = camera.x + screenWidth/2 + params.offsetX
            projY = camera.y - screenHeight/2 + (screenHeight/params.count)/2 + params.offsetY
            params.angle = math.pi  -- Face left
        elseif params.direction == "top" then
            projX = camera.x - screenWidth/2 + (screenWidth/params.count)/2 + params.offsetX
            projY = camera.y - screenHeight/2 - params.offsetY
            params.angle = math.pi/2  -- Face down
        elseif params.direction == "bottom" then
            projX = camera.x - screenWidth/2 + (screenWidth/params.count)/2 + params.offsetX
            projY = camera.y + screenHeight/2 + params.offsetY
            params.angle = -math.pi/2  -- Face up
        end
        
        -- Create wall of projectiles
        for i = 0, params.count - 1 do
            local projectile = EntityFactory:createProjectile(projX, projY, params.radius, params.speed, params.color, params.type, params.angle, params.lifespan)
            
            if projectile then
                table.insert(newProjectiles, projectile)
            end
            
            -- Adjust position for next projectile
            if params.direction == "left" or params.direction == "right" then
                projY = projY + screenHeight / (params.count)  -- Vertical spread
            else
                projX = projX + screenWidth / (params.count)   -- Horizontal spread
            end
        end
    end

    return newProjectiles
end

function EntityFactory:createMouth(x, y, radius, color)
    return Mouth:new(x, y, radius, color, "mouth")
end

function EntityFactory:createTurret(x, y, radius, color, type, direction, rotationSpeed, shotSpeed, fireRate, projRadius, projLifespan)
    return Turret:new(x, y, radius, color, type, direction, rotationSpeed, shotSpeed, fireRate, projRadius, projLifespan)
end

function EntityFactory:createTwinTurrets(x, y, radius, color, type, direction, rotationSpeed, shotSpeed, fireRate, projRadius, projLifespan)
    local turret1 = Turret:new(x, y, radius, color, type, direction, rotationSpeed, shotSpeed, fireRate, projRadius, projLifespan)
    
    local turret2 = Turret:new(x, y, radius, color, type, (direction + math.pi), rotationSpeed, shotSpeed, fireRate, projRadius, projLifespan)
    
    return {turret1, turret2}  -- Return both turrets as a pair
end

function EntityFactory:createHealingUpgrade(x, y, radius, color, health)
    return HealingUpgrade:new(x, y, radius, color, "healingUpgrade", health)
end
-- Generalized procedural spawn function
function EntityFactory:attemptProceduralSpawn(cameraX, cameraY, existingEntities, entityType, configNum, spawnParams)
    local config
    config = EntityFactory.spawnConfigs[configNum]
    -- Check spawn cooldown
    if self:distance(cameraX, cameraY, self.lastSpawnPositions[entityType].x, self.lastSpawnPositions[entityType].y) < config.SPAWN_COOLDOWN then
        return nil
    end

    -- Mark current chunk as explored
    local chunk = self:getCurrentChunk(cameraX, cameraY, config)
    self.exploredChunks[chunk.x..","..chunk.y] = true

    -- Try to find valid spawn positionspawnParams.projRadius,
    for i = 1, config.MAX_ATTEMPTS do
        local angle = math.random() * math.pi * 2
        local distance = config.RADIUS * (0.8 + math.random() * 0.4)
        local x = cameraX + math.cos(angle) * distance
        local y = cameraY + math.sin(angle) * distance

        if self:isPositionValid(x, y, existingEntities, entityType, config) then
            self.lastSpawnPositions[entityType] = {x = cameraX, y = cameraY}
            
            -- Create the appropriate entity type
            if entityType == "mouth" then
                return self:createMouth(x, y, spawnParams.radius, spawnParams.color)
            elseif entityType == "butt" then
                local turret1 = self:createTurret(x, y, spawnParams.radius, spawnParams.color, entityType, spawnParams.direction, spawnParams.rotationSpeed, spawnParams.shotSpeed, spawnParams.fireRate, spawnParams.projRadius,spawnParams.projLifespan)
            
                local turret2 = self:createTurret(x, y, spawnParams.radius, spawnParams.color, entityType, (spawnParams.direction + math.pi), spawnParams.rotationSpeed, spawnParams.shotSpeed, spawnParams.fireRate, spawnParams.projRadius,spawnParams.projLifespan)
                turret2.direction = math.pi
                return {turret1, turret2}  -- Return both turrets as a pairs
            elseif entityType == "nose" then
                local turret1 = self:createTurret(x-20, y, spawnParams.radius, spawnParams.color, entityType, spawnParams.direction, spawnParams.rotationSpeed, spawnParams.shotSpeed, spawnParams.fireRate, spawnParams.projRadius,spawnParams.projLifespan)

            
                local turret2 = self:createTurret(x+20, y, spawnParams.radius, spawnParams.color, entityType, (spawnParams.direction + math.pi), spawnParams.rotationSpeed, spawnParams.shotSpeed, spawnParams.fireRate, spawnParams.projRadius,spawnParams.projLifespan)

                return {turret1, turret2}  -- Return both turrets as a pairs
            elseif entityType == "healingUpgrade" then
                return self:createHealingUpgrade(x, y, spawnParams.radius, spawnParams.color, spawnParams.health)
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

function EntityFactory:createRandomProjectile(radius, screenWidth, screenHeight, originX, originY, lifespan)

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
    
    return Projectile:new(projX, projY, radius, 50, nil, nil, targetX, targetY, lifespan)
end

function EntityFactory:createRandomGridProjectile(radius, screenWidth, screenHeight, originX, originY, lifespan)
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
    
    return Projectile:new(projX, projY, radius, 50, nil, nil, targetX, targetY, lifespan)
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