hello = require_hello()

-- Globals
cam_x = 0
cam_y = 0

function update_input()
  if (btn(0) and cam_x > 0) then
    cam_x = cam_x - 1
  end
  if (btn(1) and cam_x < 127) then
    cam_x = cam_x + 1
  end
  if (btn(2) and cam_y > 0) then
    cam_y = cam_y - 1
  end
  if (btn(3) and cam_y < 127) then
    cam_y = cam_y + 1
  end
end

function _update()
  update_input()
end

function _draw()
  cls()
  camera(cam_x, cam_y)
  print('('..cam_x..', '..cam_y..')', cam_x, cam_y, 7)
end

hello()
