import "game"
local game = game()

playdate.display.setRefreshRate(20)

local gfx <const> = playdate.graphics
local font = gfx.font.new('fnt/Mini Sans 2X')

local function loadGame()
  math.randomseed(playdate.getSecondsSinceEpoch()) -- seed for math.random
  gfx.setFont(font)
end

local function drawGame()
  gfx.clear()
  game:draw()
end

loadGame()

function playdate.update()
  playdate.frameTimer.updateTimers()
  drawGame()
  playdate.drawFPS(0,0)
end