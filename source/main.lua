import "game"
import "CoreLibs/ui"
import "CoreLibs/graphics"

playdate.display.setRefreshRate(30)

local gfx <const> = playdate.graphics


local function loadGame()
  math.randomseed(playdate.getSecondsSinceEpoch()) -- seed for math.random
  game.load()
end

local function draw()
  gfx.clear()
  gfx.setBackgroundColor(gfx.kColorBlack)
  gfx.setColor(gfx.kColorWhite)
  gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
  game.draw()
end

loadGame()

function playdate.update()
  playdate.timer.updateTimers()
  playdate.frameTimer.updateTimers()
  -- if ((not game.ship.dead) and (not game.paused)) then
  
  game.update()
  draw()
  gfx.sprite.update()
  -- end
end