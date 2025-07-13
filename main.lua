-- Load required libraries and modules
local Gumball = require("gumball")
local EntityFactory = require("entityFactory")

-- Game state
local entities = {}
local gumball = nil
local spawnParameters = {}

-- Camera system
local camera = {
    x = 0,
    y = 0,
    scale = 1,
    minScale = 0.5,
    maxScale = 2,
    panSpeed = 50,
    target = nil
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

    local mouthSpawnParams = {
        radius = 20,
        color = {0.9, 0.2, 0.5},
        type = "mouth"
    }

    local buttSpawnParams = {
        radius = 10,
        color = {0.9, 0.7, 0.1},
        type = "butt",
        direction = 0,
        rotationSpeed = 60,
        shotSpeed = 30,
        fireRate = 1,
        projRadius = 5,
        projLifespan = 15
    }

    local noseSpawnParams = {
        radius = 15,
        color = {0.8, 0.95, 0.7},
        type = "nose",
        direction = 0,
        rotationSpeed = 90,
        shotSpeed = 20,
        fireRate = .75,
        projRadius = 7.5,
        projLifespan = 15
    }

    local healingUpgradeSpawnParams = {
        radius = 20,
        color = {0.2, 0.8, 0.4},
        type = "healingUpgrade",
        health = 1
    }

    table.insert(spawnParameters, mouthSpawnParams)
    table.insert(spawnParameters, buttSpawnParams)
    table.insert(spawnParameters, noseSpawnParams)
    table.insert(spawnParameters, healingUpgradeSpawnParams)
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
    generateEntities(true, true, true, true)
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
end



-- GUMBALL CHARGING

function love.mousepressed(x, y, button)
    if button == 1 then  -- Left mouse button
        if gumball then
            gumball:chargeStart()
        end
    end
    if button == 2 then  -- Right mouse button
        if gumball then
            gumball:changeDirection()
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and gumball and gumball.isCharging then
        if gumball then
            gumball:releaseCharge()
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
    camera.y = camera.y + dt * camera.panSpeed
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
                    entity1:onCollision(entity2)
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

function generateEntities(mouths, butts, noses, healing)
    if mouths then
        local newMouth = EntityFactory:attemptProceduralSpawn(camera.x, camera.y, entities, "mouth", 1, spawnParameters[1])
        if newMouth then
            table.insert(entities, newMouth)
        end
    end
    

    if butts then
        local newButt = EntityFactory:attemptProceduralSpawn(camera.x, camera.y, entities, "butt", 2, spawnParameters[2])
        if newButt then
            table.insert(entities, newButt[1])
            table.insert(entities, newButt[2])
        end
    end
    
    if noses then
        local newNose = EntityFactory:attemptProceduralSpawn(camera.x, camera.y, entities, "nose", 3, spawnParameters[3])
        if newNose then
            table.insert(entities, newNose[1])
            table.insert(entities, newNose[2])
        end
    end
    
    if healing then
        local newHealingUpgrade = EntityFactory:attemptProceduralSpawn(camera.x, camera.y, entities, "healingUpgrade", 4, spawnParameters[4])
        if newHealingUpgrade then
            table.insert(entities, newHealingUpgrade)
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
    if gumball then
        love.graphics.print("Health: " .. gumball.health, 10, y)
    end
end