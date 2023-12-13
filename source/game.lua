import "startscreen"
import "level"
import "endscreen"

print("level: ", level)

local G = {}
game = G

startscreen.nextScene = level
level.nextScene = endscreen
endscreen.nextScene = startscreen

local activeScene = startscreen

function G.load()
  activeScene.load()
end

function G.update()
  if (
    activeScene.finished()
  ) then
    activeScene.exit()
    activeScene = activeScene.nextScene
    activeScene.load()
  end
  activeScene.update()
end

function G.draw()
  activeScene.draw()
end

return game