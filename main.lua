-- Load required libraries and modules
local Entity = require("entity")
local Mouth = require("mouth")
local Gumball = require("gumball")

-- Game state
local entities = {}
local gumball = nil

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
end

function love.update(dt)
    -- Update all entities
    for _, entity in ipairs(entities) do
        entity:update(dt)
    end
    
    -- Collision detection (simplified)
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
end

function love.draw()
    -- Clear the screen
    love.graphics.clear(0.2, 0.2, 0.2)
    
    -- Draw all entities
    for _, entity in ipairs(entities) do
        entity:draw()
    end
    
    -- Draw HUD
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Entities: " .. #entities, 10, 30)
    
    -- Draw entity type labels with colors
    local y = 80
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Entity Types:", 10, y)
    y = y + 20
end

function love.keypressed(key)
end

function love.mousepressed(x, y)
    gumball.flag = not gumball.flag
    if not gumball.flag then
        gumball.currentMouth = nil
    end
    gumball.movementDirection = gumball.direction
end