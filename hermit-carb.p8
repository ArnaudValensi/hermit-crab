pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function require_player()
    idle_sprite = 1
    gravity = 0.5
    jump_force = 5
    fall_coef = 2
    player_height = 8
    map_cell_spr = 999

    function new_player()
        pos_x = 0
        pos_y = 0
        acc_x=0.5
        dcc_x=0.05
        max_dx = 2
        flipx = false
        is_grounded = false
        velocity = {
            x = 0,
            y = 0,
        }
        jump_pressed_before = false

        collide_side = function()
            if velocity.x < 0 then
                if fget(mget(pos_x / 8, pos_y / 8), 7) then
                    velocity.x = 0
                    pos_x = flr(pos_x / 8) * 8 + 8
                    return true
                end
            else
                if fget(mget(pos_x / 8 + 1, pos_y / 8), 7) then
                    velocity.x = 0
                    pos_x = flr(pos_x / 8) * 8
                    return true
                end
                return false
            end
        end

        move_x = function()
            if (btn(0)) then
                velocity.x -= acc_x
                flipx = true
            elseif (btn(1)) then
                velocity.x += acc_x
                flipx = false
            else
                velocity.x *= dcc_x
            end

			velocity.x=mid(-max_dx,velocity.x,max_dx)
			pos_x+=velocity.x
			collide_side()
        end

        return {
            update = function()
                move_x()

                jump_pressed = btn(4)

                map_cell_spr = mget(pos_x / 8, (pos_y + 8) / 8);
                is_grounded = fget(map_cell_spr, 7)

                if (is_grounded) then
                    velocity.y = 0

                    if (jump_pressed) then -- Jump (z)
                        velocity.y = -jump_force
                    end
                else
                    if (velocity.y < 0 and jump_pressed_before and jump_pressed == false) then
                        velocity.y = 0
                    elseif (velocity.y > 0) then -- Falling
                        velocity.y = velocity.y + gravity * fall_coef
                    else
                        velocity.y = velocity.y + gravity
                    end
                end

                if (jump_pressed) then
                    jump_pressed_before = true
                else
                    jump_pressed_before = false
                end

                pos_y = pos_y + velocity.y
            end,
            draw = function()
                print(map_cell_spr, 0, 0, 7)
                spr(idle_sprite, pos_x, pos_y, 1, 1, flipx)
            end
        }
    end

    return new_player
end
new_player = require_player()

-- Globals
player = new_player()

function _update()
  player.update()
end

function _draw()
  cls()
  camera(0, 0)
  map(0, 0, 0, 0, 16, 16)
  camera(cam_x, cam_y)
  player.draw()
end

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
99999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__gff__
0101010103030303010101010101000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4141414141414140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041414141414140410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
