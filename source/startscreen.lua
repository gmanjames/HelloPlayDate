import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/sprites"
import "CoreLibs/ui"
import "CoreLibs/graphics"

local SC = {}
startscreen = SC

local pd <const> = playdate
local gfx <const> = pd.graphics
local spriteSheet <const> = gfx.imagetable.new("invaders")

local typeOutText    <const> = {"PLAY", "SPACE INVADERS", "= 30 POINTS", "= 20 POINTS", "= 10 POINTS"}
local typeOutSprites <const> = {}
local currentWordIdx = 1
local currentWordPos = 1

local finished = false

local font        <const> = gfx.font.new('font/Mini Sans 2X')
local screenWidth <const> = pd.display.getWidth()
local glyphWidth  <const> = 18
local glyphHeight <const> = 20

local textPoss <const> = {
  {x = (screenWidth / 2) - (font:getTextWidth(typeOutText[1]) / 2), y = 16}, -- play
  {x = (screenWidth / 2) - (font:getTextWidth(typeOutText[2]) / 2), y = 48}, -- space
  {x = (screenWidth / 2) - ((font:getTextWidth(typeOutText[3])) / 2) + 16, y = 144}, -- =30
  {x = (screenWidth / 2) - ((font:getTextWidth(typeOutText[4])) / 2) + 16, y = 176}, -- =20
  {x = (screenWidth / 2) - ((font:getTextWidth(typeOutText[5])) / 2) + 16, y = 208}  -- =10
}

local titleSpt, inv1, inv2, inv3
local function addScoreAdvanceTable()
  local titleTxt = "*SCORE ADVANCE TABLE*"
  local titleWid = font:getTextWidth(titleTxt)
  titleSpt = gfx.sprite.spriteWithText("*" .. titleTxt .. "*", 100000, 100000)

  titleSpt:setBounds(
    (screenWidth / 2) - titleWid / 2,
    112,
    titleWid,
    font:getHeight()
  )
  titleSpt:add()

  local invImg1 = spriteSheet:getImage(1)
  inv1 = gfx.sprite.new(invImg1)
  inv1:setBounds((screenWidth / 2) - ((font:getTextWidth(typeOutText[3]) + 32) / 2), 136, 32, 32)
  inv1:add()

  local invImg2 = spriteSheet:getImage(3)
  inv2 = gfx.sprite.new(invImg2)
  inv2:setBounds((screenWidth / 2) - ((font:getTextWidth(typeOutText[4]) + 32) / 2), 168, 32, 32)
  inv2:add()

  local invImg3 = spriteSheet:getImage(5)
  inv3 = gfx.sprite.new(invImg3)
  inv3:setBounds((screenWidth / 2) - ((font:getTextWidth(typeOutText[5]) + 32) / 2), 200, 32, 32)
  inv3:add()
end

local function updateChars(timer)
  local orgTxt = typeOutText[currentWordIdx]

  if (currentWordPos > string.len(orgTxt)) then
    -- we're done here
    if (currentWordIdx == #typeOutText) then
      timer:remove()
      return
    end

    currentWordIdx = currentWordIdx + 1
    currentWordPos = 1

    orgTxt = typeOutText[currentWordIdx]
  end

  if (currentWordIdx == 3 and currentWordPos == 1) then
    addScoreAdvanceTable()
  end

  local sub = string.sub(orgTxt, 1, currentWordPos)
  local swp = gfx.sprite.spriteWithText(sub, font:getTextWidth(sub), font:getHeight())
  local org = typeOutSprites[currentWordIdx]

  if (org) then
    org:remove()
  end

  typeOutSprites[currentWordIdx] = swp
  swp:setBounds(
    textPoss[currentWordIdx].x,
    textPoss[currentWordIdx].y,
    font:getTextWidth(sub),
    font:getHeight()
  )
  swp:add()
  
  currentWordPos = currentWordPos + 1
end

local drawCharDelay <const> = 75
local drawCharTimer <const> = pd.timer.new(drawCharDelay)
drawCharTimer.repeats = true
drawCharTimer:pause()

function SC.load()
  gfx.setFont(font)
  drawCharTimer.timerEndedCallback = updateChars
  drawCharTimer:start()
end

function SC.update()
  if (
    (pd.buttonJustPressed(pd.kButtonA)
      or pd.buttonJustPressed(pd.kButtonB))
  ) then
    finished = true
  end
end

function SC.exit()
  drawCharTimer:pause()
  drawCharTimer:reset()

  if (titleSpt) then
    titleSpt:remove()
  end

  if (inv1) then
    inv1:remove()
  end

  if (inv2) then
    inv2:remove()
  end

  if (inv3) then
    inv3:remove()
  end

  for _,s in ipairs(typeOutSprites) do
    s:remove()
  end

  while (table.remove(typeOutSprites)) do end
  
  currentWordIdx = 1
  currentWordPos = 1

  finished = false
end

function SC.finished()
  return finished
end

function SC.draw()
  -- for i,w in ipairs(menuTextToDraw) do
  --   local pos = textPoss[i]
  --   gfx.drawText(w, pos.x, pos.y) -- 16px font size?
  -- end
end

return startscreen