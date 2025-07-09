-- entityfactory.lua
local Entity = require("entity")
local Mouth = require("mouth")
local Gumball = require("gumball")
local Projectile = require("projectile")
local EntityFactory = {}

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

return EntityFactory