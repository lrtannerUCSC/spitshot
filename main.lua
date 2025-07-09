-- Load required libraries and modules
local Entity = require("entity")
local Mouth = require("mouth")
local Gumball = require("gumball")
local Projectile = require("projectile")
local EntityFactory = require("entityFactory")

-- Game state
local entities = {}
local gumball = nil

-- Camera system
local camera = {
    x = 0,
    y = 0,
    scale = 1,
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

    local mouth = Mouth:new(200, 200, 50)
    table.insert(entities, mouth)
    local mouth1 = Mouth:new(500, 200, 50)
    table.insert(entities, mouth1)
    local mouth2 = Mouth:new(200, 500, 50)
    table.insert(entities, mouth2)

    gumball = Gumball:new(400, 400, 25, 200)
    table.insert(entities, gumball)
    
    -- Initialize camera to gumball position
    camera.x = gumball.x
    camera.y = gumball.y
end


local projectileTimer = 0
local projectileInterval = 1  -- seconds between spawns

function love.update(dt)
    -- Update camera to follow gumball
    if gumball then
        camera.target = gumball
        camera.x = camera.x + (gumball.x - camera.x) * 0.1
        camera.y = camera.y + (gumball.y - camera.y) * 0.1
    end
    
    -- Update all entities
    for _, entity in ipairs(entities) do
        entity:update(dt)
        -- Optional: Deactivate if out of screen bounds
        local margin = 150
        if entity.x < -margin or entity.x > love.graphics.getWidth() + camera.x + margin or
           entity.y < -margin or entity.y > love.graphics.getHeight() + camera.y + margin then
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

    -- Projectile spawning with proper timer
    projectileTimer = projectileTimer + dt
    if projectileTimer >= projectileInterval then
        projectileTimer = 0  -- Reset timer
        local projectile = EntityFactory:createRandomGridProjectile(
            25,  -- radius
            love.graphics.getWidth(), 
            love.graphics.getHeight(), 
            camera.x, 
            camera.y
        )
        table.insert(entities, projectile)
    end
end

function love.draw()
    -- Clear the screen
    love.graphics.clear(0.2, 0.2, 0.2)
    
    -- Apply camera transformation
    camera:apply()
    
    -- Draw all entities
    for _, entity in ipairs(entities) do
        entity:draw()
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
    if key == "r" or "R" then
        local proj = EntityFactory:createRandomProjectile(25, love.graphics.getWidth(), love.graphics.getHeight(), camera.x, camera.y)
        table.insert(entities, proj)
        
    end
end

function love.mousepressed(x, y)
    gumball.flag = not gumball.flag
    if not gumball.flag then
        gumball.currentMouth = nil
    end
    gumball.movementDirection = gumball.direction
end

function love.mousereleased(x, y)
end

function love.wheelmoved(x, y)
    -- Zoom in/out with mouse wheel
    if y > 0 then
        camera.scale = camera.scale * 1.1
    elseif y < 0 then
        camera.scale = camera.scale / 1.1
    end
    -- Limit zoom range
    camera.scale = math.max(0.5, math.min(2, camera.scale))
end