-- Load required libraries and modules
local Gumball = require("gumball")
local EntityFactory = require("entityFactory")

-- Game state
local entities = {}
local gumball = nil
local spawnParameters = {}
local totalPoints = 0

-- Camera system
local camera = {
    x = 0,
    y = 0,
    scale = 1,
    minScale = 0.5,
    maxScale = 2,
    panSpeed = 50,
    target = nil,
    -- New properties for random panning
    currentDirection = nil,
    directionTimer = 0,
    directionChangeInterval = 60,  -- seconds between direction changes
    directions = {
        "up", "down", "left", "right",
        "up-left", "up-right", "down-left", "down-right"
    }
}

function love.load()
    love.entities = entities

    -- Set random seed
    math.randomseed(os.time())

    local originX = love.graphics.getWidth() / 2 * camera.scale
    local originY = love.graphics.getHeight() / 2 * camera.scale
    gumball = Gumball:new(originX, originY, 10, 200, {1.0, 0.8, 0.8})
    table.insert(entities, gumball)

    -- Initialize camera position
    camera.x = originX
    camera.y = originY
end


function love.update(dt)
    -- Update camera position
    camera:scroll(dt)

    -- Update all entities
    updateEntities(dt)
    
    -- Collision detection
    checkCollisions(entities)
 
    -- Remove inactive entities
    removeInactiveEntities(entities)

    -- Wave generation
    EntityFactory:update(dt, entities, camera)

    -- Procedural generation for entities
    generateEntities(true, true, true, true, false, true)
end

function love.draw()
    -- Clear the screen
    love.graphics.clear(0.2, 0.2, 0.2)
    
    -- Apply camera transformation
    camera:apply()
    
    drawEntities()
    
    -- Clear camera transformation before drawing HUD
    camera:clear()

    drawHud()
end


function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "i" or "I" then --Invulnerable
        if gumball then
            gumball.health = gumball.health + 10000000
        end
    end
    if key == "r" or "R" then
        local proj = EntityFactory:createRandomProjectile(25, love.graphics.getWidth(), love.graphics.getHeight(), camera.x, camera.y)
        table.insert(entities, proj)
        
    end
    if key == "e" or "E" then
        for _, entity in ipairs(entities) do
            if entity.type == "gumball" then
                entity:cancelCharge()
            end
        end
    end
end



-- GUMBALL CHARGING

function love.mousepressed(x, y, button)
    if button == 1 then  -- Left mouse button
        for _, entity in ipairs(entities) do
            if entity.type == "gumball" then
                entity:chargeStart()
            end
        end
    end

    if button == 2 then  -- Right mouse button
        for _, entity in ipairs(entities) do
            if entity.type == "gumball" then
                entity:changeDirection()
            end
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and gumball and gumball.isCharging then
        for _, entity in ipairs(entities) do
            if entity.type == "gumball" then
                entity:releaseCharge()
            end
        end
        
    end
end



-- CAMERA FUNCTIONS

function camera:apply()
    love.graphics.push()
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(-self.x + love.graphics.getWidth()/(2*self.scale), 
                           -self.y + love.graphics.getHeight()/(2*self.scale))
end

function camera:clear()
    love.graphics.pop()
end

function camera:scroll(dt)
    if not self.currentDirection then
        self:chooseRandomDirection()
    end
    
    -- Update timer
    self.directionTimer = self.directionTimer + dt
    
    -- Check if it's time to change direction
    if self.directionTimer >= self.directionChangeInterval then
        self:chooseRandomDirection()
    end
    
    -- Move based on current direction
    local speed = self.panSpeed * dt
    if self.currentDirection == "up" then
        self.y = self.y - speed
    elseif self.currentDirection == "down" then
        self.y = self.y + speed
    elseif self.currentDirection == "left" then
        self.x = self.x - speed
    elseif self.currentDirection == "right" then
        self.x = self.x + speed
    elseif self.currentDirection == "up-left" then
        self.x = self.x - speed * 0.707  -- 1/sqrt(2) for diagonal
        self.y = self.y - speed * 0.707
    elseif self.currentDirection == "up-right" then
        self.x = self.x + speed * 0.707
        self.y = self.y - speed * 0.707
    elseif self.currentDirection == "down-left" then
        self.x = self.x - speed * 0.707
        self.y = self.y + speed * 0.707
    elseif self.currentDirection == "down-right" then
        self.x = self.x + speed * 0.707
        self.y = self.y + speed * 0.707
    end
end

function camera:chooseRandomDirection()
    -- Get a random index from the directions table
    local randomIndex = math.random(1, #self.directions)
    self.currentDirection = self.directions[randomIndex]
    
    -- Randomize the next interval (between 2-5 seconds)
    self.directionChangeInterval = math.random(30,60)
    self.directionTimer = 0
    
    print("New camera direction: " .. self.currentDirection)
end

function love.wheelmoved(x, y)
    -- Zoom in/out with mouse wheel
    if y > 0 then
        camera.scale = camera.scale * 1.1
    elseif y < 0 then
        camera.scale = camera.scale / 1.1
    end
    -- Limit zoom range
    camera.scale = math.max(camera.minScale, math.min(camera.maxScale, camera.scale))
end

-- UTILITY FUNCTIONS
function updateEntities(dt)
    for _, entity in ipairs(entities) do
        entity:update(dt, entities, camera)
        -- updatePoints(entity) 
        local marginX = 50
        local marginY = love.graphics.getHeight() / camera.minScale
        entityBoundaryCheck(entity, marginX, marginY)
        
    end
end

function drawEntities()
    for _, entity in ipairs(entities) do
        if entity ~= gumball then  -- Draw everything except gumball first
            entity:draw()
        end
    end
    
    -- Then draw the gumball on top
    if gumball then
        gumball:draw()
    end
end

function entityBoundaryCheck(entity, marginX, marginY)
    local screenWidth = love.graphics.getWidth() / camera.minScale
    local screenHeight = love.graphics.getHeight() / camera.minScale
    
    -- Calculate boundaries relative to camera
    local leftBound = camera.x - screenWidth/2 - marginX
    local rightBound = camera.x + screenWidth/2 + marginX
    local topBound = camera.y - screenHeight/2 - marginY
    local bottomBound = camera.y + screenHeight/2 + marginY
    
    -- Check if entity is outside boundaries
    if entity.x < leftBound or entity.x > rightBound or
        entity.y < topBound or entity.y > bottomBound then
        entity.active = false
    end
end

function checkCollisions(entities)
    for i, entity1 in ipairs(entities) do
        for j, entity2 in ipairs(entities) do
            if i ~= j then
                if entity1:checkCollision(entity2) then
                    if entity1.type == "gumball" then
                        entity1:onCollision(entity2, entities)
                    else
                        entity1:onCollision(entity2)
                    end
                    
                end
            end
        end
    end
end

function removeInactiveEntities(entities)
    for i = #entities, 1, -1 do
        if not entities[i].active then
            table.remove(entities, i)
        end
    end
end

function generateEntities(mouths, butts, noses, healing, duplicating, nuking)
    if mouths then
        local newMouth = EntityFactory:attemptProceduralSpawn(camera.x, camera.y, entities, "mouth", 1)
        if newMouth then
            table.insert(entities, newMouth)
        end
    end
    

    if butts then
        local newButt = EntityFactory:attemptProceduralSpawn(camera.x, camera.y, entities, "butt", 2)
        if newButt then
            table.insert(entities, newButt[1])
            table.insert(entities, newButt[2])
        end
    end
    
    if noses then
        local newNose = EntityFactory:attemptProceduralSpawn(camera.x, camera.y, entities, "nose", 3)
        if newNose then
            table.insert(entities, newNose[1])
            table.insert(entities, newNose[2])
        end
    end
    
    if healing then
        local newHealingUpgrade = EntityFactory:attemptProceduralSpawn(camera.x, camera.y, entities, "healingUpgrade", 4)
        if newHealingUpgrade then
            table.insert(entities, newHealingUpgrade)
        end
    end

    if duplicating then
        local newDuplicationUpgrade = EntityFactory:attemptProceduralSpawn(camera.x, camera.y, entities, "duplicationUpgrade", 5)
        if newDuplicationUpgrade then
            table.insert(entities, newDuplicationUpgrade)
        end
    end

    if nuking then
        local newNukeUpgrade = EntityFactory:attemptProceduralSpawn(camera.x, camera.y, entities, "nukeUpgrade", 6)
        if newNukeUpgrade then
            table.insert(entities, newNukeUpgrade)
        end
    end
end



-- HUD
function drawHud()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Entities: " .. #entities, 10, 30)
    love.graphics.print(string.format("Camera: %.0f,%.0f (%.1fx)", camera.x, camera.y, camera.scale), 10, 50)
    
    -- Draw entity type labels with colors
    local y = 80
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Health: " .. gumball.health, 10, y)
end

function updatePoints(entity)
    if entity.type == "gumball" then
        totalPoints = totalPoints + entity.points
    end
end