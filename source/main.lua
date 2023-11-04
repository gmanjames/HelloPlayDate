import "dvd" -- DEMO
local dvd = dvd(1, -1) -- DEMO

playdate.display.setRefreshRate(20)

local gfx <const> = playdate.graphics
local font = gfx.font.new('fnt/Mini Sans 2X') -- DEMO

local function loadGame()
	math.randomseed(playdate.getSecondsSinceEpoch()) -- seed for math.random
	gfx.setFont(font) -- DEMO
end

local function updateGame()
	-- dvd:update()
end

local function drawGame()
	gfx.clear() -- Clears the screen
	dvd:draw() -- DEMO
end

loadGame()

function playdate.update()
  playdate.frameTimer.updateTimers()
	updateGame()
	drawGame()
	playdate.drawFPS(0,0) -- FPS widget
end