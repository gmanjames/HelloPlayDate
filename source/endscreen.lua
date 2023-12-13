import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/sprites"
import "CoreLibs/ui"
import "CoreLibs/graphics"

local pd = playdate

local EC = {}
endscreen = EC

local finished = false

local transitionDelay <const> = 1000
function EC.load()
  pd.timer.new(transitionDelay, function ()
    finished = true
  end)
end

function EC.update()
end

function EC.finished()
  return finished
end

function EC.draw()
end

function EC.exit()
end

return endscreen