import "CoreLibs/graphics"
import "CoreLibs/object"
import 'CoreLibs/frameTimer'

local gfx <const> = playdate.graphics

class("dvd").extends()

invaderMargin    = 5
screenXPadding   = 64
invaderColCount  = 11
invaderRowCount  = 4
frameTick        = 7
invaderStep      = 5
invaderDirection = -1
availableXRange  = playdate.display.getWidth() - screenXPadding * 2
invaderWidth     = (availableXRange - invaderMargin * (invaderColCount - 1)) / invaderColCount

function dvd:init(xspeed, yspeed)
  dvd:createInvaders()

  self.invaderRowToUpdate = 0
  self.stepTimer = playdate.frameTimer.new(frameTick, self.update, self)
  self.stepTimer.repeats = true
end

function dvd:createInvaders()
  self.invaders = {}
  for i=0,(invaderRowCount * invaderColCount)-1 do
    local x = screenXPadding + ((i % invaderColCount) * (invaderWidth + invaderMargin))
    local y = invaderMargin + (math.floor(i / invaderColCount) * (invaderWidth + invaderMargin))
    self.invaders[i+1] = playdate.geometry.rect.new(x, y, invaderWidth, invaderWidth)
  end
end

function dvd:swapColors()
	-- if (gfx.getBackgroundColor() == gfx.kColorWhite) then
	-- 	gfx.setBackgroundColor(gfx.kColorBlack)
	-- 	gfx.setColor(gfx.kColorWhite)
	-- else
	-- 	gfx.setBackgroundColor(gfx.kColorWhite)
	-- 	gfx.setColor(gfx.kColorBlack)
	-- end
end

function dvd:updateState()
  local invaders = self.invaders
  if (
    invaders[11].x >= (playdate.display.getWidth() - (invaderMargin * 5 + invaderWidth))
      or invaders[1].x <= (invaderMargin * 5)
  ) then
    invaderDirection = invaderDirection * -1
  end
  print(invaderDirection)
end

function dvd:update()
  local invaders = self.invaders

  if (self.invaderRowToUpdate == 0) then
    self.updateState(self)
  end

  for i, v in ipairs(invaders) do
    local currentRow = math.floor((i - 1) / invaderColCount)
    if (currentRow == self.invaderRowToUpdate) then
      v.x += invaderStep * invaderDirection
    end
  end
  self.invaderRowToUpdate = (self.invaderRowToUpdate + 1) % invaderRowCount
end

function dvd:draw()
    gfx.setColor(gfx.kColorBlack)
    for _,v in ipairs(self.invaders) do
      gfx.drawRect(v.x, v.y, v.width, v.height)
    end
end