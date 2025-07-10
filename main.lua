-- Load required libraries and modules
local Entity = require("entity")
local Mouth = require("mouth")
local Gumball = require("gumball")
local Projectile = require("projectile")
local Turret = require("turret")
local EntityFactory = require("entityFactory")

-- Game state
local entities = {}
local gumball = nil

-- Camera system
local camera = {
    x = 0,
    y = 0,
    scale = 0.5,
    target = nil
}

function camera:apply()
    love.graphics.push()
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(-self.x + love.graphics.getWidth()/(2*self.scale), 
                           -self.y + love.graphics.getHeight()/(2*self.scale))
end

function camera:clear()
    love.graphics.pop()
end

function love.load()
    love.entities = entities

    -- Set random seed
    math.randomseed(os.time())

    -- local mouth = Mouth:new(20, 20, 5) -- ORIGIN MARKER LOL
    -- table.insert(entities, mouth)
    -- local mouth1 = Mouth:new(500, 200, 20)
    -- table.insert(entities, mouth1)
    -- local mouth2 = Mouth:new(200, 500, 20)
    -- table.insert(entities, mouth2)


    -- local turret1 = Turret:new(320, 320, 40, 50, 60, 0.25)
    -- table.insert(entities, turret1)
    -- local turret2 = Turret:new(320, 320, 40, 50, 60, 0.25, math.rad(180))
    -- table.insert(entities, turret2)

    -- local newProj = EntityFactory:createProjectile(150, 150, 0, 30, 50)
    -- table.insert(entities, newProj)

    gumball = Gumball:new(400, 400, 10, 200)
    table.insert(entities, gumball)

    
    
    -- Initialize camera to gumball position
    camera.x = gumball.x
    camera.y = gumball.y
end


local projectileTimer = 0
local projectileInterval = 0.5  -- seconds between spawns

function love.update(dt)
    -- if gumball.health <= 0 then
    --     love.event.quit()
    -- end
    -- Update charging if mouse is held down
    if gumball.isCharging then
        gumball.currentCharge = math.min(1.0 + (gumball.chargeRate * (love.timer.getTime() - gumball.chargeStartTime)), gumball.chargeMax)
        gumball.rotationSpeed = gumball.baseRotation * gumball.currentCharge -- MAGIC NUMBER
    end
    -- Update camera to follow gumball
    if gumball then
        camera.target = gumball
        camera.x = camera.x + (gumball.x - camera.x) * 0.1
        camera.y = camera.y + (gumball.y - camera.y) * 0.1
    end
    
    -- Update all entities
    for _, entity in ipairs(entities) do
        if entity.type == "turret" then
            entity:update(dt, entities)
        else
            entity:update(dt)
        end
        
        local margin = 200
        local screenWidth = love.graphics.getWidth() / camera.scale
        local screenHeight = love.graphics.getHeight() / camera.scale
        
        -- Calculate boundaries relative to camera
        local leftBound = camera.x - screenWidth/2 - margin
        local rightBound = camera.x + screenWidth/2 + margin
        local topBound = camera.y - screenHeight/2 - margin
        local bottomBound = camera.y + screenHeight/2 + margin
        
        -- Check if entity is outside boundaries
        if entity.x < leftBound or entity.x > rightBound or
           entity.y < topBound or entity.y > bottomBound then
            entity.active = false
        end
    end
    
    -- Collision detection
    for i, entity1 in ipairs(entities) do
        for j, entity2 in ipairs(entities) do
            if i ~= j then
                if entity1:checkCollision(entity2) then
                    entity1:onCollision(entity2)
                end
            end
        end
    end
 
    -- Remove inactive entities
    for i = #entities, 1, -1 do
        if not entities[i].active then
            table.remove(entities, i)
        end
    end

    -- -- Projectile spawning with proper timer
    -- projectileTimer = projectileTimer + dt
    -- if projectileTimer >= projectileInterval then
    --     projectileTimer = 0  -- Reset timer
    --     local projectile = EntityFactory:createRandomGridProjectile(
    --         15,  -- radius
    --         love.graphics.getWidth(), 
    --         love.graphics.getHeight(), 
    --         camera.x, 
    --         camera.y
    --     )
    --     table.insert(entities, projectile)
    -- end

    local newButt = EntityFactory:attemptProceduralSpawn(camera.x, camera.y, entities, "butt")

    if newButt then
        table.insert(entities, newButt[1])
        table.insert(entities, newButt[2])
    end

    local newNose = EntityFactory:attemptProceduralSpawn(camera.x, camera.y, entities, "nose")

    if newNose then
        table.insert(entities, newNose[1])
        table.insert(entities, newNose[2])
    end
    
    local newMouth = EntityFactory:attemptProceduralSpawn(camera.x, camera.y, entities, "mouth")

    if newMouth then
        table.insert(entities, newMouth)
    end

    
end

function love.draw()
    -- Clear the screen
    love.graphics.clear(0.2, 0.2, 0.2)
    
    -- Apply camera transformation
    camera:apply()
    
    -- First draw all non-gumball entities
    for _, entity in ipairs(entities) do
        if entity ~= gumball then  -- Draw everything except gumball first
            entity:draw()
        end
    end
    
    -- Then draw the gumball on top
    if gumball then
        gumball:draw()
    end
    
    -- Clear camera transformation before drawing HUD
    camera:clear()
    
    -- Draw HUD (not affected by camera)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Entities: " .. #entities, 10, 30)
    love.graphics.print(string.format("Camera: %.0f,%.0f (%.1fx)", camera.x, camera.y, camera.scale), 10, 50)
    
    -- Draw entity type labels with colors
    local y = 80
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Entity Types:", 10, y)
    y = y + 20
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "r" or "R" then
        local proj = EntityFactory:createRandomProjectile(25, love.graphics.getWidth(), love.graphics.getHeight(), camera.x, camera.y)
        table.insert(entities, proj)
        
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then  -- Left mouse button
        gumball.isCharging = true
        gumball.chargeStartTime = love.timer.getTime()
        gumball.currentCharge = 1.0  -- Reset charge when starting new press
    end
end

function love.mousereleased(x, y, button)
    if button == 1 and gumball.isCharging then
        -- gumball.currentMouth = nil
        gumball.isCharging = false
        local chargeTime = love.timer.getTime() - gumball.chargeStartTime
        
        -- Calculate charge multiplier (capped at chargeMax)
        gumball.currentCharge = math.min(1.0 + (gumball.chargeRate * chargeTime), gumball.chargeMax)
        
        -- Apply the charged movement
        gumball.flag = true
        gumball.movementDirection = gumball.direction
        gumball.speed = gumball.baseSpeed * gumball.currentCharge/5 -- MAGIC NUMBER
        gumball.rotationSpeed = gumball.baseRotation
    end
end

function love.wheelmoved(x, y)
    -- Zoom in/out with mouse wheel
    if y > 0 then
        camera.scale = camera.scale * 1.1
    elseif y < 0 then
        camera.scale = camera.scale / 1.1
    end
    -- Limit zoom range
    camera.scale = math.max(0.1, math.min(2, camera.scale))
end