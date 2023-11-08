import "CoreLibs/graphics"
import "CoreLibs/object"
import 'CoreLibs/frameTimer'

local gfx <const> = playdate.graphics

class("game").extends()

-- margin between invaders
invaderMargin      = 5
-- padding on either side of initial invader load
screenXPadding     = 64
-- number of invaders per row
invaderColCount    = 11
-- number of invader rows
invaderRowCount    = 4
-- perform update every frameTick frames
frameTick          = 5
-- amount for invaders to move horizontally
invaderXStep       = 5
-- amount for invaders to move horizontally
invaderYStep       = 7
-- number of updates to descend
descendYUpdates    = 2
-- initial horizontal move direction for invaders
invaderDirection   = -1
-- total available screen length to render invaders in
availableXRange    = playdate.display.getWidth() - screenXPadding * 2
-- width of invaders
invaderWidth       = (availableXRange - invaderMargin * (invaderColCount - 1)) / invaderColCount
-- initial row to update
updateRow          = 3
-- initial direction of rows to update
updateRowDirection = -1
-- descend
yDescend = 0

function game:init()
  game:createInvaders()

  self.invaderRowToUpdate = updateRow
  self.yDescendUpdateCounter = descendYUpdates
  self.stepTimer = playdate.frameTimer.new(frameTick, self.updateInvaders, self)
  self.stepTimer.repeats = true
end

function game:createInvaders()
  self.invaders = {}
  for i=0,(invaderRowCount * invaderColCount)-1 do
    local x = screenXPadding + ((i % invaderColCount) * (invaderWidth + invaderMargin))
    local y = invaderMargin + (math.floor(i / invaderColCount) * (invaderWidth + invaderMargin))
    self.invaders[i+1] = playdate.geometry.rect.new(x, y, invaderWidth, invaderWidth)
  end
end

function game:updateInvaders()
  if (self.checkInvadersWithinBounds(self)) then
    invaderDirection = invaderDirection * -1
    yDescend = 1
    game.updateInvaderPositions(self)
  else
    game.updateInvaderPositions(self)
  end

  if (yDescend == 1 and self.yDescendUpdateCounter > 0) then
    self.yDescendUpdateCounter -= 1
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
    if (currentRow == self.invaderRowToUpdate) then
      v.x += invaderXStep * invaderDirection
    end
    v.y += invaderYStep * yDescend
  end
end

function game:checkInvadersWithinBounds()
  local invaders = self.invaders
  return
  self.invaderRowToUpdate == 3 and ((invaders[44].x + invaderXStep) >= (playdate.display.getWidth() - (invaderMargin * 5 + invaderWidth))
      or (invaders[34].x - invaderXStep) <= (invaderMargin * 5))
end

function game:draw()
    gfx.setColor(gfx.kColorBlack)
    for _,v in ipairs(self.invaders) do
      gfx.drawRect(v.x, v.y, v.width, v.height)
    end
end