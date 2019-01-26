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

    local function new_camera(new_target)
        local pos = new_vec(0, 0) -- This is the center of the camera.
        local offset = new_vec(0, 0)
        local shake_offset = new_vec(0, 0)
        local shake_countdown = 0
        local target = new_target

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

                local player_center_pos = target.get_center_pos()

                print(player_center_pos.x..', '..player_center_pos.y, 0, 8, 7)

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
            end,
            set_target = function(new_target)
                target = new_target
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
            dcc_x = 0,
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
        local pos_x = 2 * 8
        local pos_y = 10 * 8
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

                if (jump_pressed) then -- Jump (z)
                    velocity.y = -jump_force
                    sfx(0)
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

            local left_feet_spr = mget(pos_x / 8, (pos_y + 8) / 8);
            local right_feet_spr = mget((pos_x + 7) / 8, (pos_y + 8) / 8);
            local collide_left = fget(left_feet_spr, 7)
            local collide_right = fget(right_feet_spr, 7)

            is_grounded = collide_left or collide_right

            if (is_grounded) then -- Fix y position
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
function require_scheduler()
    function new_scheduler()
        local scheduler = {
        coroutine = nil,
        update = function(self)
            if self.coroutine and costatus(self.coroutine) != 'dead' then
            coresume(self.coroutine)
            else
            self.coroutine = nil
            end
        end,
        set_timeout = function (self, delay_in_s, fn)
            self.coroutine = cocreate(function()
            local tick_before_timeout = delay_in_s * 30

            while (tick_before_timeout ~= 0) do
                yield()
                tick_before_timeout -= 1
            end
            fn()
            end)
        end
        };

        return scheduler
    end

    return new_scheduler
end
function new_vec(x, y)
    return {
        x = x,
        y = y,
    }
end
new_player = require_player()
new_camera = require_camera()
new_scheduler = require_scheduler()

-- Globals
player = new_player()
scheduler = new_scheduler()

function _init()
  player.change_state("round_shell")
  goal = {
    get_center_pos = function()
      return new_vec(75 * 8, 10 * 8)
    end
  }
  cam = new_camera(goal)
  scheduler:set_timeout(2, function() cam.set_target(player) end)
end

function _update()
  player.update()
  cam.update()
  scheduler:update()
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
cccccccccccccccccccaaccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccaaccccaccccac00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc11ccccca11accccc11ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc1111ccca1111acac1111ca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc1111ccca1111acac1111ca00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc11ccccca11accccc11ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccaaccccaccccac00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccaaccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555555555999599955555555cc0000cc0000000000000000599959995555555500000000cc0000cc0000000000000000000000000000000000000000cccccccc
999999999999999999999999c003300c0444b44000000000999979999999999900000000c003300c0000000000000000000000000000000000000000cccccccc
9599959995999599959777990030330004444b4000000000959977999597779900000000003033000000000000000000000000000000000000000000cccccccc
999999999999999999777779c033330c0b4b44b000000000999799999977777900000000c033330c0000000000000000000000000000000000000000cc5ccc5c
9995999599959995997070750333033004444b4000000000977599959970707500000000033303300000000000000000000000000000000000000000c565c565
999999999999999999977799c033330c0444b44000000000997999999997779900000000c033330c000000000000000000000000000000000000000056665666
99599959995999599959995900303300040000400000000099599959995999590000000000303300000000000000000000000000000000000000000056665666
999999999999999999977799c033330c040cc04000000000999999999997779900000000c033330c000000000000000000000000000000000000000055555555
555555555555555559995999cc0330cc0000000000000000555555555999599900000000cc0330cc000000000000000000000000000000000000000000000000
599999955999999599999999c033330c044b444000000000599979959999999900000000c033330c000000000000000000000000000000000000000000000000
5599959555999595959777990030330004b444400000000055997795959777990000000000303300000000000000000000000000000000000000000000000000
599999955999999599777779c033330c0b44b4b000000000599799959977777900000000c033330c000000000000000000000000000000000000000000000000
5995999559959995997070750333033004b444400000000057759995997070750000000003330330000000000000000000000000000000000000000000000000
599999955999999599977799c033330c044b444000000000597999959997779900000000c033330c000000000000000000000000000000000000000000000000
59599955595999559959995900303300040000400000000059599955995999590000000000303300000000000000000000000000000000000000000000000000
599999955555555599977799c033330c040cc04000000000599999959997779900000000c033330c000000000000000000000000000000000000000000000000
599959995999599559995999cccccccc000000000000000059995999000000000000000000000000000000000000000000000000000000000000000000000000
599999999999999599997999cccccccc077777700000000059997999000000000000000000000000000000000000000000000000000000000000000000000000
559995999599959595997799cccccccc070770700000000055997799000000000000000000000000000000000000000000000000000000000000000000000000
599999999999999599979999cccccccc077777700000000059979999000000000000000000000000000000000000000000000000000000000000000000000000
599599959995999597759995cccccccc040000400000000057759995000000000000000000000000000000000000000000000000000000000000000000000000
599999999999999599799999cccccccc047777400000000059799999000000000000000000000000000000000000000000000000000000000000000000000000
595999599959995599599959cccccccc040000400000000059599959000000000000000000000000000000000000000000000000000000000000000000000000
599999999999999599999999cccccccc040cc0400000000059999999000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59999999999999950000000000000000049999400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55999599959995950000000000000000099999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59999999999999950000000000000000045505400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59959995999599950000000000000000045455400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59999999999999950000000000000000045455400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59599959995999550000000000000000040000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
59999999999999950000000000000000040cc0400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccccc666666ccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccc6677777766ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccc677777777776cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccc6677777766ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccccc666666ccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccc7ccccccc7ccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc7a7ccccc787cccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc37cccccc37ccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc3ccccccc3ccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc3ccccccc3ccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc3ccccccc3ccccc5555ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0101010103030303010101010101000001010100000000000000000000000000030303000000000000000000000000000000000000000000000000000000000080808080000080800080000000000040808080800000808000800000000000008080800000008000000000000000000080800000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
8080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808043
8080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808053
8080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808081828080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808053
8080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080804380808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808053
8080808080808080808080808080808080808080808080808182808080808080808080808080808080808080808080808080808080808080805380808080808080808080808080808081828080808080808080808080808080808080808080808080808080808080808080808080808080808080808182808080808080808053
4380808080808182808080808080808080808080808080808080808080808080808080808080808080808070404040407180808080808070404071808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080c0c153
5380808080808080808080808080808080808080808080808080808080808080808080818280808080808080808080808080808080808060414161928080918080808080808080808080808080808080808080808080808080808080808080808080808080808080808080818280808080808080808080808080809074d0d153
5380808080808080808080808080808182808080808080808080808080808080808080808080807040718080808080808080808080808060414141404747477180808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080807040404040
5380808080808080808080808080808080808080808080808080808080808080808080808080806041618080808080808080808080808060414141414141416180808080808080808080808080808080808080808080818280808080808080808080808080808080808080808080808080808080808080808080806041414141
5380808080808080808080808080808080808080808080808080808080808080808080808080704141619180808080808080808080808060414141414141526180808080808080808080808080808080808080808080808080808080808080808081828080808080808080808080808080808080808080808091806041414141
538080808080808080808080808080707180808080808080808080808080808080808080808060414141718080808080818280808080806041414141414141614f4f4f4f4f4f707180808080808080808080808080808080808080808043808080808080808080808080808080808080808080808080808070714f6041414141
5380808080808080808080918080806061808080808080808080808080808080808080808070414141416180438080808080808080808060414141415241414140474040474041618080808080808080808080808080808080808080805380808080808080808080808080808080808182808092808080806041424141414141
5380808044804480448080438080906061808080808080808080804380808080909090808060414141416180539180808080449122915460414141414141524146464646464641414040404040404042427180808080808080808070424140404040404040404271808080808080808080807071808092806041416241414141
404040404040404040404041404040414140404040718080704040614f4f704040404040404141414141414040404040404040404040404141414141414141414646464646464141624141624162414141614f4f4f4f4f4f4f4f4f604141414141414141414141614f4f4f4f4f4f4f4f4f4f60614f4f504f6041414141414141
4141414141414141414141414141414141414141414140404141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141624141414146414140424042404042424241414141414141414141414141424242424242424242424141424241424162414141414141
4141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414146414641414141414146414141414141414141414141414141414141414141414141414141414141414141414141
000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f000000000000000000000000000000000000000000007f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f7f7f000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007f7f7f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000e5500e5500f55010550125501355015550175501a5501d55021550275500150003500035000250003500015000150001500015000150001500035000250001500005000050000500005000050000500
0001000014050180501b0501e050200502005022050220502205022050210501f0501c0501905015050110500f050000000000000000000000000000000000000000000000000000000000000000000000000000
0001000002050060500a0500c0500d0500e0500e0500e0500e0500d0500c0500a050080501100012000190001c000200000000000000000000000000000000000000000000000000000000000000000000000000
