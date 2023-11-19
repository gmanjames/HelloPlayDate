import "game"
import "CoreLibs/ui"

local game = game()

playdate.display.setRefreshRate(30)

local gfx <const> = playdate.graphics
local font = gfx.font.new('fnt/Mini Sans 2X')

local function loadGame()
  math.randomseed(playdate.getSecondsSinceEpoch()) -- seed for math.random
  gfx.setFont(font)
end

loadGame()

function playdate.BButtonDown()
	game:fireShipLaser()
end

function playdate.update()
  playdate.frameTimer.updateTimers()
  game:update()
  

  gfx.clear()
  gfx.sprite.update()
  game:draw()
end