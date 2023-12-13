import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/frameTimer"
import "CoreLibs/sprites"
import "startscreen"

local L = {}
level = L

local pd <const> = playdate
local gfx <const> = pd.graphics
local spriteSheet <const> = gfx.imagetable.new("invaders")

local game = {}

-- padding on either side of initial invader load
local screenWidth  = pd.display.getWidth()
local screenHeight = pd.display.getHeight()

local invaderXMargin     = 5
-- margin between invaders
local invaderYMargin     = 10
-- number of invaders per row
local invaderColCount    = 6
-- number of invader rows
local invaderRowCount    = 3
-- perform update every frameTick frames
local frameTick          = 5
-- amount for invaders to move horizontally
local invaderXStep       = 6
-- amount for invaders to move horizontally
local invaderYStep       = 7
-- number of updates to descend
local descendYUpdates    = 1
-- initial horizontal move direction for invaders
local invaderDirection   = -1
-- width of invaders
local invaderWidth       = 32
-- initial row to update
local updateRow          = 3
-- initial direction of rows to update
local updateRowDirection = -1
-- descend
local yDescend = 0
local updateVelocity = 0

local shipHeight = 32
local shipWidth = 32
local shipMargin = 3
local shipXStep = 5

local crankMoveMargin = 0.75

local laserWidth = 5
local laserHeight = 10
local laserSpeed = 9

local laserFirePct <const> =  70

local initialUpdateFrames <const> = 7
local framesRemaining = initialUpdateFrames

local timeToUpdateDuration <const> = 30000 -- 30 seconds
local timeToUpdateEndValue <const> = timeToUpdateDuration * 2

local laserFireDelay <const> = 400

local finished = false

local function createSprite(initialX, initialY, image, opts)
  local sprite = gfx.sprite.new(image)
  sprite.dead = false
  sprite.id = opts.id

  -- gfx stuff
  local width, height = image:getSize()
  local boundsRect = pd.geometry.rect.new(initialX - width / 2, initialY - height / 2, width, height)
  local collideRect = pd.geometry.rect.new(0, 0, width, height) 
  sprite:setBounds(boundsRect)
  sprite:setCollideRect(collideRect)
  if (opts.setInverted) then image:setInverted(true) end
  sprite:add()
  return sprite
end

local function updateFramesRemaining()
  if (framesRemaining <= 0) then
    framesRemaining = initialUpdateFrames - updateVelocity
  else
    framesRemaining = framesRemaining - 1
  end
end

function game:init()
  self.invaderRowToUpdate = updateRow
  self.yDescendUpdateCounter = descendYUpdates
  self.lasers = {}
  self.invaders = {}
  self.paused = false
  self:createInvaders()
  self:createShip()

  -- could always decrease end value to drag out exponential increase
  self.speedTimer = pd.timer.new(timeToUpdateDuration, 1, timeToUpdateEndValue, pd.easingFunctions.inExpo)
  self.speedTimer.updateCallback = function(timer)
    updateVelocity = updateVelocity + (timer.value / timeToUpdateEndValue) * initialUpdateFrames
  end

  self.fireTimer = pd.timer.performAfterDelay(laserFireDelay, function()
    for _,i in ipairs(self:invadersToFire()) do
      if (math.random() * 100 < laserFirePct) then
        i.fireLaser()
      end
    end
  end)
  self.fireTimer.repeats = true
end

function game:loadStartScreen()

end

local function createLaser(x, y, direction)
  local laser = createSprite(x, y, spriteSheet:getImage(12), {setInverted = true, id = "laser"})
  laser.direction = direction
  laser.update = function()
    if (not game.paused) then
      laser:moveTo(x, laser.y + laserSpeed * direction)
    end
  end

  function laser.destory()
    laser.dead = true
    laser:remove()
  end

  return laser
end

function game:createInvaders()
  local xOffset = (screenWidth - ((invaderWidth * invaderColCount) + invaderXMargin * (invaderColCount - 1))) / 2
  local yOffset = 10
  
  for i=0,(invaderRowCount * invaderColCount)-1 do
    local col = i % invaderColCount
    local row = math.floor(i / invaderColCount)
    local x   = xOffset + (col * (invaderWidth + invaderXMargin))
    local y   = yOffset + (math.floor(i / invaderColCount) * invaderWidth)
    
    local images = {}
    local img1, img2
    if (row == 0) then
      img1, img2 = spriteSheet:getImage(1), spriteSheet:getImage(2)
    elseif (row < 2) then
      img1, img2 = spriteSheet:getImage(3), spriteSheet:getImage(4)
    else
      img1, img2 = spriteSheet:getImage(5), spriteSheet:getImage(6)
    end
    table.insert(images, img1)
    table.insert(images, img2)

    local invader = createSprite(x, y, img1, {id = "invader"})
    invader.i = 0

    function invader.flipImage()
      if (not invader.dead) then
        local i = invader.i
        invader.i = (i + 1) % #images
        invader:setImage(images[invader.i + 1])
      end
    end

    function invader.shouldFireLaser()
      if (invader.dead) then
        return false
      end

      local invToShip = math.abs(invader.x - self.ship.x)
      if (invToShip <= 32 and self.invaderRowToUpdate == row) then
        if (row == 2) then
          return true
        else
          local allClear = true
          for i=(row+1),2 do
            allClear = allClear and self.invaders[(col + 1) + (i * invaderColCount)].dead
          end
          if (allClear) then
            return true
          else
            return false
          end
        end
      else
        return false
      end
    end

    function invader.fireLaser()
      table.insert(self.lasers, createLaser(invader.x, invader.y, 1))
    end

    function invader:collisionResponse(other)
      return gfx.sprite.kCollisionTypeOverlap
    end

    self.invaders[i+1] = invader
  end
end

function game:createShip()
  local x, y = screenWidth / 2 - shipWidth / 2, screenHeight - (shipHeight / 2)

  local image = spriteSheet:getImage(14)
  local ship = createSprite(x, y, image, {setInverted = true, id = "ship"})

  ship.hits = 0

  function ship.move(direction)
    x = x + shipXStep * direction
    ship:moveTo(x, y)
  end

  function ship.fireLaser()
    table.insert(self.lasers, createLaser(ship.x, ship.y, -1))
  end

  function ship:collisionResponse(other)
    return gfx.sprite.kCollisionTypeFreeze
  end

  self.ship = ship
end

function game:updateShip()
  local change, _ = pd.getCrankChange()
  if (change < -crankMoveMargin) then
    self.ship.move(-1)
  elseif (change > crankMoveMargin) then
    self.ship.move(1)
  end
end

local function handleCollisions(game)
  local collisions = gfx.sprite.allOverlappingSprites()

  for i = 1, #collisions do
    local collisionPair = collisions[i]
    local sprite1 = collisionPair[1]
    local sprite2 = collisionPair[2]
    
    if (
      sprite1:alphaCollision(sprite2)
        and (not sprite1.dead) and (not sprite2.dead)
    ) then
      if (
        (sprite1.id == "ship"
          and sprite2.id == "invader")
        or
        (sprite2.id == "ship"
          and sprite1.id == "invader")
      ) then
  
        local ship, invader
        if (sprite1.id == "ship") then
          ship, invader = sprite1, sprite2
        else
          ship, invader = sprite2, sprite1
        end
  
        ship.dead = true
        invader.dead = true
  
      elseif (
        (sprite1.id == "laser"
          and sprite2.id == "invader")
        or
        (sprite2.id == "laser"
          and sprite1.id == "invader")
      ) then
        
        local laser, invader
        if (sprite1.id == "laser") then
          laser, invader = sprite1, sprite2
        else
          laser, invader = sprite2, sprite1
        end
  
        if (laser.direction == -1) then
          laser.dead = true
          laser:remove()
  
          invader.dead = true
          invader:setImage(spriteSheet:getImage(13))
          game.paused = true
          pd.timer.performAfterDelay(500, function()
            invader:remove()
            game.paused = false
          end)
        end
  
      elseif (
        (sprite1.id == "laser"
          and sprite2.id == "ship")
        or
        (sprite2.id == "laser"
          and sprite1.id == "ship")
      ) then

        local laser, ship
        if (sprite1.id == "laser") then
          laser, ship = sprite1, sprite2
        else
          laser, ship = sprite2, sprite1
        end
  
        if (laser.direction == 1) then
          laser.dead = true
          laser:remove()
  
          if (ship.hits >= 2) then
            ship.dead = true
            ship:setImage(spriteSheet:getImage(13))
            game.paused = true
            pd.timer.new(3000, function ()
              finished = true
            end)
          else
            ship.hits = ship.hits + 1
          end
        end
        
      else
        -- print("other collision")
      end
    end
  end
end

function game:update()
  if (not self.paused) then
    self:updateInvaders()
    self:updateShip()
    handleCollisions(self)
    updateFramesRemaining()
    gfx.setColor(gfx.kColorWhite)
  end
end

function game:draw()
end

function game:updateInvaders()
  if (framesRemaining > 0) then return end

  if (self.checkInvadersWithinBounds(self)) then
    invaderDirection = invaderDirection * -1
    yDescend = 1
    frameTick = frameTick - 1
    self:updateInvaderPositions()
  else
    self:updateInvaderPositions()
  end

  if (yDescend == 1 and self.yDescendUpdateCounter > 0) then
    self.yDescendUpdateCounter = self.yDescendUpdateCounter - 1
  elseif (self.yDescendUpdateCounter == 0) then
    self.yDescendUpdateCounter = descendYUpdates
    yDescend = 0
  end
  self.invaderRowToUpdate = (self.invaderRowToUpdate + updateRowDirection) % invaderRowCount
end

function game:updateInvaderPositions()
  local invaders = self.invaders
  for i, v in ipairs(invaders) do
    local currentRow = math.floor((i - 1) / invaderColCount)
    local currentX, currentY = v:getPosition()
    local updatedX, updatedY = currentX, currentY + invaderYStep * yDescend
    if (currentRow == self.invaderRowToUpdate) then
      updatedX = currentX + invaderXStep * invaderDirection
      v.flipImage()
    end
    v:moveTo(updatedX, updatedY)
  end
end

function game:checkInvadersWithinBounds()
  local invaders = self.invaders
  local sideMargin = invaderWidth
  return
    self.invaderRowToUpdate == 2 and ((invaders[18].x + invaderXStep) >= (pd.display.getWidth() - (18 + sideMargin))
      or (invaders[13].x - invaderXStep) <= sideMargin)
end

function game:invadersToFire()
  local invaders = {}
  for _,v in ipairs(self.invaders) do
    if (v.shouldFireLaser()) then
      table.insert(invaders, v)
    end
  end
  return invaders
end

function game:deadInvaders()
  local invaders = {}
  for _,v in ipairs(self.invaders) do
    if (v.dead) then
      table.insert(invaders, v)
    end
  end
  return invaders
end

function game:fireShipLaser()
  self.ship.fireLaser()
end

function L.update()
  game:update()
end

local readyToFireDelay <const> = 400
local readyToFire = true
local inputHandlers = {
  BButtonUp = function()
      if (readyToFire) then
        game:fireShipLaser()
        readyToFire = false
        pd.timer.new(readyToFireDelay, function ()
          readyToFire = true
        end)
      end
  end
}

function L.load()
  game:init()
  pd.inputHandlers.push(inputHandlers)
end

function L.exit()
  framesRemaining = initialUpdateFrames
  updateVelocity = 0
  finished = false

  for _,v in ipairs(game.invaders) do
    v:remove()
  end

  for _,v in ipairs(game.lasers) do
    v:remove()
  end

  game.ship:remove()

  game.fireTimer:remove()

  game.speedTimer:remove()
end

function L.finished()
  return finished
end

function L.draw()
  game:draw()
end

return level