pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function require_hello()
    return function()
        -- do something.
    end
end
hello = require_hello()

-- globals
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

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000808080000000000000000000000000
80000000008000000000000000000000000000000000000000000000000000000000000000000000001510008801100000888880000000000000000000000000
8000a0a00800a0a00110a0a00110a0a0000000000000000000000000000000001110a0a01110a0a000515000088a151000088800000110880000000000000000
880888008808880011118800111188000000000000000000000000000000000015511800155118000111110088881151001a8a100151a8800000000000000000
08888808888888001111880811118800000110000001100000011000000a1000151188081511880001a8a100088a151000111110151188880000000000000000
08888880088888080118888001188808001a1a000011a100001111000011110001188880011888080088800088011000000515000151a8800000000000000000
00888808008888800088880800888880001111000011110000a1a100001a11000188880801888880088888000000000000015100000110880000000000000000
00080800008080080008080000808008000110000001a00000011000000110000008080000808008080808000000000000001000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111a1a01111a1a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15511100155111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15111108151111000111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111118011111108015a1a1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888808008888800151111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080800008080080111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000005000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000057500000000000005750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00555577750055000055557775005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005575cccc5575000055751111557500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00057751157750000005775dd5775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005775c657750000005775165775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055566665550000005556666555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005111ccccc15000005ddd11111d500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005777c1cc11c7500057771d11dd1750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0050077711cc175000500777dd11d750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05700077c1cc7750057000771d117750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
057000777c1175000570007771dd7500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00570007777775000057000777777500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000c777750000005000177775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005000c777750000005000177775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050005555500000005000555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
