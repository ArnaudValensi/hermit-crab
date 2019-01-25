new_player = require_player()

-- Globals
player = new_player()

function _update()
  player.update()
end

function _draw()
  cls()
  camera(cam_x, cam_y)
  player.draw()
end
