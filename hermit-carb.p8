pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function require_camera()
    local half_screen = 64
    local smooth_speed = 0.2
    local vertical_offset = 24
    local shake_force = 5
    local shake_duration = 10

    local function lerp(a, b, t)
        return a + (b - a) * t
    end

    local function new_camera(player)
        local pos = new_vec(0, 0) -- this is the center of the camera.
        local offset = new_vec(0, 0)
        local shake_offset = new_vec(0, 0)
        local shake_countdown = 0

        function update_shake()
            if (shake_countdown > 0) then
                shake_offset.x = rnd(shake_force) - (shake_force / 2)
                shake_offset.y = rnd(shake_force) - (shake_force / 2)
                shake_countdown -= 1
            elseif (shake_countdown == 0) then
                shake_offset.x = 0
                shake_offset.y = 0
            end
        end

        return {
            update = function()
                update_shake()

                local player_center_pos = player.get_center_pos()

                pos.x = lerp(pos.x, player_center_pos.x, smooth_speed)
                pos.y = lerp(pos.y, player_center_pos.y, smooth_speed)

                offset.x = pos.x - half_screen + shake_offset.x
                offset.y = pos.y - half_screen + shake_offset.y - vertical_offset
            end,
            get_offset = function()
                return offset.x, offset.y
            end,
            add_shake = function()
                shake_countdown = shake_duration
            end
        }
    end

    return new_camera
end
function require_player()
    local idle_sprite = 1
    local gravity = 0.5
    local jump_force = 5
    local fall_coef = 2
    local player_height = 8
    local map_cell_spr = 999

    local default_acc_x=0.5
    local default_dcc_x=0.05
    local default_max_dx = 2

    local shell_states = {
        ["naked"] = {
            frames = {0, 1},
            acc_x = 0.5,
            dcc_x = 0.05,
            max_dx = 2,
        },
        ["round_shell"] = {
            frames = {2, 3},
            acc_x = 0.5,
            dcc_x = 0.05,
            max_dx = 2,
        },
        ["round_shell_in_shell"] = {
            frames = {4, 5, 6, 7},
            acc_x = 0.1,
            dcc_x = 0.01,
            max_dx = 10,
        },
    }

    function new_player()
        local pos_x = 0
        local pos_y = 0
        local animtick = 5
        local frames={0, 1}
        local acc_x = 0.5
        local dcc_x = 0.05
        local max_dx = 2
        local shell_state = shell_states["naked"]
        local sprite_idx = 1
        local flipx = false
        local is_grounded = false
        local velocity = {
            x = 0,
            y = 0,
        }
        local jump_pressed_before = false
        local action_pressed_before = false

        local _change_state = function(new_state)
            shell_state = shell_states[new_state]
            frames=shell_state.frames
            sprite_idx = 1
            acc_x = shell_state.acc_x
            dcc_x = shell_state.dcc_x
            max_dx = shell_state.max_dx
        end

        local collide_side = function()
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

        local move_x = function()
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

        local handle_jump_and_gravity = function()
            local jump_pressed = btn(4)

            if (is_grounded) then
                velocity.y = 0

                if (jump_pressed) then -- jump (z)
                    velocity.y = -jump_force
                    sfx(0)
                end
            else
                if (velocity.y < 0 and jump_pressed_before and jump_pressed == false) then
                    velocity.y = 0
                elseif (velocity.y > 0) then -- falling
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

            local left_feet_spr = mget(pos_x / 8, (pos_y + 8) / 8);
            local right_feet_spr = mget((pos_x + 7) / 8, (pos_y + 8) / 8);
            local collide_left = fget(left_feet_spr, 7)
            local collide_right = fget(right_feet_spr, 7)

            is_grounded = collide_left or collide_right

            if (is_grounded) then -- fix y position
                pos_y = pos_y - pos_y % 8
            end
        end

        local handle_action = function()
            local action_pressed = btn(5)
            if (not action_pressed_before and action_pressed) then
                action_pressed_before = true
                _change_state("round_shell_in_shell")
                sfx(1)
            elseif (action_pressed_before and not action_pressed) then
                action_pressed_before = false
                _change_state("round_shell")
                sfx(2)
            end
        end

        return {
            change_state = function(new_state)
                _change_state(new_state)
            end,
            update = function()
                move_x()
                handle_jump_and_gravity()
                handle_action()
            end,
            draw = function()
                animtick -= 1
                if animtick <= 0 then
                    sprite_idx = (sprite_idx) % #frames + 1
                    animtick = 5
                end
                print(sprite_idx, 0, 0, 7)
                spr(frames[sprite_idx], pos_x, pos_y, 1, 1, flipx)
            end,
            get_pos_x = function()
                return pos_x
            end,
            get_center_pos = function()
                return new_vec(pos_x + 4, pos_y + 4)
            end,
            get_width = function()
                return 8
            end
        }
    end

    return new_player
end
function new_vec(x, y)
    return {
        x = x,
        y = y,
    }
end
new_player = require_player()
new_camera = require_camera()

-- globals
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

  -- hud
  camera(0, 0)
  -- print(cam.get_offset(), 0, 0, 7)
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
555555555999599955555555cc0000cc0000000000000000599959995555555500000000cc0000cc000000000000000000000000000000000000000000000000
999999999999999999999999c003300c0000000000000000999979999999999900000000c003300c000000000000000000000000000000000000000000000000
95999599959995999597779900303300000000000000000095997799959777990000000000303300000000000000000000000000000000000000000000000000
999999999999999999777779c033330c0000000000000000999799999977777900000000c033330c000000000000000000000000000000000000000000000000
99959995999599959970707503330330000000000000000097759995997070750000000003330330000000000000000000000000000000000000000000000000
999999999999999999977799c033330c0000000000000000997999999997779900000000c033330c000000000000000000000000000000000000000000000000
99599959995999599959995900303300000000000000000099599959995999590000000000303300000000000000000000000000000000000000000000000000
999999999999999999977799c033330c0000000000000000999999999997779900000000c033330c000000000000000000000000000000000000000000000000
555555555555555559995999cc0330cc0000000000000000555555555999599900000000cc0330cc000000000000000000000000000000000000000000000000
599999955999999599999999c033330c0000000000000000599979959999999900000000c033330c000000000000000000000000000000000000000000000000
55999595559995959597779900303300000000000000000055997795959777990000000000303300000000000000000000000000000000000000000000000000
599999955999999599777779c033330c0000000000000000599799959977777900000000c033330c000000000000000000000000000000000000000000000000
59959995599599959970707503330330000000000000000057759995997070750000000003330330000000000000000000000000000000000000000000000000
599999955999999599977799c033330c0000000000000000597999959997779900000000c033330c000000000000000000000000000000000000000000000000
59599955595999559959995900303300000000000000000059599955995999590000000000303300000000000000000000000000000000000000000000000000
599999955555555599977799c033330c0000000000000000599999959997779900000000c033330c000000000000000000000000000000000000000000000000
59995999599959955999599900000000000000000000000059995999000000000000000000000000000000000000000000000000000000000000000000000000
59999999999999959999799900000000000000000000000059997999000000000000000000000000000000000000000000000000000000000000000000000000
55999599959995959599779900000000000000000000000055997799000000000000000000000000000000000000000000000000000000000000000000000000
59999999999999959997999900000000000000000000000059979999000000000000000000000000000000000000000000000000000000000000000000000000
59959995999599959775999500000000000000000000000057759995000000000000000000000000000000000000000000000000000000000000000000000000
59999999999999959979999900000000000000000000000059799999000000000000000000000000000000000000000000000000000000000000000000000000
59599959995999559959995900000000000000000000000059599959000000000000000000000000000000000000000000000000000000000000000000000000
59999999999999959999999900000000000000000000000059999999000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59999999999999950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55999599959995950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59999999999999950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59959995999599950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59999999999999950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59599959995999550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59999999999999950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccccc666666ccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccc6677777766ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccc677777777776cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccc6677777766ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccccc666666ccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
ccccccc5ccccccccccccccc5cccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccc575ccccccccccccc575ccccccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc55557775cc55cccc55557775cc55cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc5575cccc5575cccc557511115575cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc5775115775cccccc5775dd5775ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc5775c65775cccccc5775165775ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc5556666555cccccc5556666555ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc5111ccccc15ccccc5ddd11111d5cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc5777c1cc11c75ccc57771d11dd175c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc50077711cc175ccc500777dd11d75c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c5700077c1cc775cc57000771d11775c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c57000777c1175ccc570007771dd75cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc570007777775cccc570007777775cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc5000c77775cccccc5000177775ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc5000c77775cccccc5000177775ccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc500055555ccccccc500055555cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0101010103030303010101010101000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080808080000080800080000000000000808080800000808000800000000000008080800000008000000000000000000080800000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
8080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080807000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808081828080808080808080808080808080808080808080808080808080806000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080604100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8080808080808080808080808080808080808080808080808182808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808081828080808080604100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4380808080808182808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080806000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5380808080808080808080808080808080808080808080808080808080808080808080818280808080808080808080808080808080808080808080808080808080808080808080808080808080808080806000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5380808080808080808080808080808182808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080818280808080808080808080808080808080806000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080c0c16000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080d0d16000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808081828080808080808080808080808080808080808080808080808080c2c38070404100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53808080808080808080808080808050808080808080808080808080808080808080808080808080808080804380808080808080808080808080808080808080808080808081828080808080d2d37041414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5380808080808080808080808080704171808080808080808080808080805080808080808080808080808080538080808080808080808080804380808080808080808080808070404040404040404141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4040404040404040404040404040414141404040404040404040404040404140404040404040404040404040404040404040404040404040404040404040404040404040404041414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000e5500e5500f55010550125501355015550175501a5501d55021550275500150003500035000250003500015000150001500015000150001500035000250001500005000050000500005000050000500
0001000014050180501b0501e050200502005022050220502205022050210501f0501c0501905015050110500f050000000000000000000000000000000000000000000000000000000000000000000000000000
0001000002050060500a0500c0500d0500e0500e0500e0500e0500d0500c0500a050080501100012000190001c000200000000000000000000000000000000000000000000000000000000000000000000000000
