import "startscreen"
import "level"

print("level: ", level)

local G = {}
game = G

local activeScene = startscreen
activeScene.nextScene = level

function G.load()
  activeScene.load()
end

function G.update()
  if (
    activeScene.finished()
  ) then
    activeScene = level
    activeScene.load()
  end
  activeScene.update()
end

function G.draw()
  activeScene.draw()
end

return game