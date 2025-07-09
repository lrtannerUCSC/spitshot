-- entityfactory.lua
local Entity = require("entity")
local Mouth = require("mouth")
local Gumball = require("gumball")
local Projectile = require("projectile")
local EntityFactory = {}

-- Configuration for procedural Mouth spawning
EntityFactory.MOUTH_SPAWN = {
    RADIUS = 1000,           -- Area around camera to consider
    MIN_DISTANCE = 400,     -- Minimum space between Mouths
    GRID_SIZE = 500,        -- Exploration grid chunk size
    MAX_ATTEMPTS = 5,      -- Max attempts to find valid position
    SPAWN_COOLDOWN = 75    -- Pixels camera must move before next spawn
}

-- State tracking
EntityFactory.exploredChunks = {}
EntityFactory.lastSpawnPosition = {x = 0, y = 0}

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
    
    return Projectile:new(projX, projY, targetX, targetY, radius)
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
    
    return Projectile:new(projX, projY, targetX, targetY, radius)
end

function EntityFactory:createMouth(x, y, radius)
    return Mouth:new(x, y, radius or 50)
end

function EntityFactory:getCurrentChunk(x, y)
    local gs = self.MOUTH_SPAWN.GRID_SIZE
    return {
        x = math.floor(x / gs),
        y = math.floor(y / gs)
    }
end

function EntityFactory:attemptProceduralMouthSpawn(cameraX, cameraY, existingEntities)
    -- Check spawn cooldown
    if self:distance(cameraX, cameraY, self.lastSpawnPosition.x, self.lastSpawnPosition.y) < self.MOUTH_SPAWN.SPAWN_COOLDOWN then
        return nil
    end

    -- Mark current chunk as explored
    local chunk = self:getCurrentChunk(cameraX, cameraY)
    self.exploredChunks[chunk.x..","..chunk.y] = true

    -- Try to find valid spawn position
    for i = 1, self.MOUTH_SPAWN.MAX_ATTEMPTS do
        local angle = math.random() * math.pi * 2
        local distance = self.MOUTH_SPAWN.RADIUS * (0.8 + math.random() * 0.4)
        local x = cameraX + math.cos(angle) * distance
        local y = cameraY + math.sin(angle) * distance

        if self:isPositionValid(x, y, existingEntities) then
            self.lastSpawnPosition = {x = cameraX, y = cameraY}
            return self:createMouth(x, y)
        end
    end
    return nil
end

function EntityFactory:isPositionValid(x, y, entities)
    for _, e in ipairs(entities) do
        if e.name == "mouth" and self:distance(x, y, e.x, e.y) < self.MOUTH_SPAWN.MIN_DISTANCE then
            return false
        end
    end
    return true
end

function EntityFactory:distance(x1, y1, x2, y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

return EntityFactory