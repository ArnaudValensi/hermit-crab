function new_vec(x, y)
  return {
    x = x,
    y = y,
  }
end

new_player = require_player()
new_camera = require_camera()

-- Globals
player = new_player()
cam = new_camera(player)

function _init()
    player.change_state("round_shell")
end

function _update()
  player.update()
  cam.update()
end

function _draw()
  cls()
  camera(cam.get_offset())
  map(0, 0, 0, 0, 128, 128)
  player.draw()

  -- HUD
  camera(0, 0)
  -- print(cam.get_offset(), 0, 0, 7)
end
