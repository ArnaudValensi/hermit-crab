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
            acc_x = 0.3,
            dcc_x = 0.05,
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

        local change_state = function(new_state)
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

        return {
            update = function()
                move_x()
                handle_jump_and_gravity()
            end,
            draw = function()
                animtick -= 1
                if animtick <= 0 then
                    sprite_idx = (sprite_idx) % #frames + 1
                    animtick = 5
                end
                print(sprite_idx, 0, 0, 7)
                spr(frames[sprite_idx], pos_x, pos_y, 1, 1, flipx)
            end
        }
    end

    return new_player
end
