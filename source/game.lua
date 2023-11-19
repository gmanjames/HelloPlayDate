import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/frameTimer"
import "CoreLibs/sprites"

local pd <const> = playdate
local gfx <const> = pd.graphics
local spriteSheet <const> = gfx.imagetable.new("invaders")

class("game").extends()

-- padding on either side of initial invader load
screenWidth  = pd.display.getWidth()
screenHeight = pd.display.getHeight()

invaderXMargin     = 5
-- margin between invaders
invaderYMargin     = 10
-- number of invaders per row
invaderColCount    = 6
-- number of invader rows
invaderRowCount    = 3
-- perform update every frameTick frames
frameTick          = 5
-- amount for invaders to move horizontally
invaderXStep       = 6
-- amount for invaders to move horizontally
invaderYStep       = 7
-- number of updates to descend
descendYUpdates    = 1
-- initial horizontal move direction for invaders
invaderDirection   = -1
-- width of invaders
invaderWidth       = 32
-- initial row to update
updateRow          = 3
-- initial direction of rows to update
updateRowDirection = -1
-- descend
yDescend = 0
local updateVelocity = 0

shipHeight = 32
shipWidth = 32
shipMargin = 3
shipXStep = 4

crankMoveMargin = 0.75

laserWidth = 5
laserHeight = 10
laserSpeed = 10

local initialUpdateFrames <const> = 7
local framesRemaining = initialUpdateFrames

-- Called each update. Decrements frames remaining or resets them
local function updateFramesRemaining()
  if (framesRemaining <= 0) then
    framesRemaining = initialUpdateFrames - updateVelocity
    print(framesRemaining)
  else
    framesRemaining = framesRemaining - 1
  end
end

function game:init()
  self.invaderRowToUpdate = updateRow
  self.yDescendUpdateCounter = descendYUpdates

  -- self.stepTimer = pd.frameTimer.new(frameTick, self.updateInvaders, self)
  -- self.stepTimer.repeats = true
  -- self.stepTimer.reverses = true

  self.lasers = {}
  self.invaders = {}
  self:createInvaders()
  self:createShip()
end

function game:createInvaders()
  local xOffset = (screenWidth - ((invaderWidth * invaderColCount) + invaderXMargin * (invaderColCount - 1))) / 2
  local yOffset = 10
  
  for i=0,(invaderRowCount * invaderColCount)-1 do
    local x   = xOffset + ((i % invaderColCount) * (invaderWidth + invaderXMargin))
    local y   = yOffset + (math.floor(i / invaderColCount) * invaderWidth)
    
    local row = math.floor(i / invaderColCount)
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

    local invader = gfx.sprite.new(img1)
    invader.i = 0
    invader:moveTo(x, y)
    invader:setBounds(pd.geometry.rect.new(x, y, invaderWidth, invaderWidth))
    invader:add()
    invader:setVisible(true)

    function invader.flipImage()
      local i = invader.i
      invader.i = (i + 1) % #images
      invader:setImage(images[invader.i + 1])
    end

    self.invaders[i+1] = invader
  end
end

function game:createShip()
  local x, y = screenWidth / 2 - shipWidth / 2, screenHeight - (shipHeight / 2)
  local hits = 0

  local image = spriteSheet:getImage(14)
  image:setInverted(true)
  local ship = gfx.sprite.new(image)
  ship:setBounds(pd.geometry.rect.new(x, y, shipWidth, shipHeight))
  ship:moveTo(x, y)
  ship:add()
  ship:setVisible(true)

  function ship.hit()
    hits = hits + 1
  end

  function ship.getHits()
    return hits
  end

  function ship.move(direction)
    x = x + shipXStep * direction
    ship:moveTo(x, y)
  end

  function ship.fireLaser()
    local laserX = rect.x + (shipWidth / 2 - laserWidth / 2)
    local laserY = rect.y - laserHeight
    self:fireLaser(laserX, laserY, -1)
  end

  self.ship = ship
end

function game:fireLaser(x, y, direction)
  local laser = {}
  local rect  = pd.geometry.rect.new(x, y, laserWidth, laserHeight)
  local alive = true

  function laser.draw()
    gfx.drawRect(rect)
  end
  function laser.move()
    rect.y = rect.y + laserSpeed * direction
  end
  function laser.destroy()
    alive = false
  end
  function laser.getAlive()
    return alive
  end
  function laser.getXBounds()
    
  end

  table.insert(self.lasers, laser)
end

function game:updateShip()
  local change, _ = pd.getCrankChange()
  if (change < -crankMoveMargin) then
    self.ship.move(-1)
  elseif (change > crankMoveMargin) then
    self.ship.move(1)
  end
end

function game:update()
  self:updateInvaders()
  self:updateShip()
  updateFramesRemaining()
end

function game:updateInvaders()
  if (framesRemaining > 0) then return end

  if (self.checkInvadersWithinBounds(self)) then
    invaderDirection = invaderDirection * -1
    yDescend = 1
    frameTick = frameTick - 1
    updateVelocity = updateVelocity + 2
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
  return
    self.invaderRowToUpdate == 2 and ((invaders[18].x + invaderXStep) >= (pd.display.getWidth() - (18 + invaderWidth))
      or (invaders[13].x - invaderXStep) <= 18)
end

function game:draw()
    gfx.setBackgroundColor(gfx.kColorBlack)
end

function game:fireShipLaser()
  self.ship.fireLaser()
end