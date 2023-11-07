import "CoreLibs/graphics"
import "CoreLibs/object"
import 'CoreLibs/frameTimer'

local gfx <const> = playdate.graphics

class("dvd").extends()

function dvd:draw()
    gfx.drawText("Hell world!")
end
