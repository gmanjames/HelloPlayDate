import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/sprites"
import "CoreLibs/ui"
import "CoreLibs/graphics"

local SC = {}
startscreen = SC

local pd = playdate
local gfx = pd.graphics

-- timer stuff for drawing text
local drawCharDelay <const> = 300
local drawCharTimer <const> = pd.timer.new(drawCharDelay)
drawCharTimer.repeats = true
drawCharTimer:pause()

local menuText       <const> = {"PLAY", "SPACE INVADERS"}
local menuTextToDraw <const> = {}
local currentWordIdx = 1
local currentWordPos = 1

local font = gfx.font.new('font/Mini Sans 2X')
local screenWidth  <const> = pd.display.getWidth()
local menuTextPoss <const> = {
  {x = (screenWidth / 2) - (font:getTextWidth("PLAY") / 2),  y = 64},
  {x = (screenWidth / 2) - (font:getTextWidth("SPACE INVADERS") / 2), y = 96},
}

local finished = false

local function updateChars()
  local orgTxt = menuText[currentWordIdx]
  local updTxt = menuTextToDraw[currentWordIdx] or ""

  if (orgTxt == "" or orgTxt == nil) then
    -- we're done here
    if (currentWordIdx == #menuText) then
      finished = true
      return
    end

    currentWordIdx = currentWordIdx + 1
    currentWordPos = 1
    print("here")

    orgTxt = menuText[currentWordIdx]
    updTxt = menuTextToDraw[currentWordIdx] or ""
  end

  updTxt = updTxt .. string.sub(orgTxt, 1, 1)
  orgTxt = string.sub(orgTxt, 2)

  menuText[currentWordIdx] = orgTxt
  menuTextToDraw[currentWordIdx] = updTxt

  currentWordPos = currentWordPos + 1
end

function SC.load()
  gfx.setFont(font)
  drawCharTimer.timerEndedCallback = updateChars
  drawCharTimer:start()
end

function SC.update()
  -- print(fireTimer.value)
end

function SC.finished()
  return finished
end

function SC.draw()
  for i,w in ipairs(menuTextToDraw) do
    local pos = menuTextPoss[i]
    gfx.drawText(w, pos.x, pos.y) -- 16px font size?
  end
end

return startscreen