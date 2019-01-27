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
            action_push = nil,
            action_release = nil,
        },
        ["round_shell"] = {
            frames = {2, 3},
            acc_x = 0.5,
            dcc_x = 0,
            max_dx = 2,
            action_push = "round_shell_in_shell",
            action_release = nil,
        },
        ["round_shell_in_shell"] = {
            frames = {4, 5, 6, 7},
            acc_x = 0.1,
            dcc_x = 0.01,
            max_dx = 10,
            action_push = nil,
            action_release = "round_shell",
        },
        ["box_shell"] = {
            frames = {16, 17},
            acc_x = 0.5,
            dcc_x = 0,
            max_dx = 2,
            action_push = "box_shell_in_shell",
            action_release = nil,
        },
        ["box_shell_in_shell"] = {
            frames = {18},
            acc_x = 0,
            dcc_x = 1,
            max_dx = 2,
            invisible = true,
            action_push = nil,
            action_release = "box_shell",
        },
    }

    function new_player()
        local alive = true
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
        local pushed = false
        local is_grounded = false
        local velocity = {
            x = 0,
            y = 0,
        }
        local jump_pressed_before = false
        local action_pressed_before = false
        local display_shell_button = false

        local _change_state = function(new_state)
            alive = true
            shell_state = shell_states[new_state]
            frames=shell_state.frames
            sprite_idx = 1
            acc_x = shell_state.acc_x
            dcc_x = shell_state.dcc_x
            max_dx = shell_state.max_dx
        end

        local _die = function()
            alive = false
        end

        local collide_side = function(level)
            if velocity.x < 0 then
                collided_spr = level.sprite_at(pos_x / 8, pos_y / 8)
                if fget(collided_spr, 6) then
                    _die()
                elseif fget(collided_spr, 7) then
                    velocity.x = 0
                    pos_x = flr(pos_x / 8) * 8 + 8
                    return true
                end
            else
                collided_spr = level.sprite_at(pos_x / 8 + 1, pos_y / 8)
                if fget(collided_spr, 6) then
                    _die()
                elseif fget(collided_spr, 7) then
                    velocity.x = 0
                    pos_x = flr(pos_x / 8) * 8
                    return true
                end
                return false
            end
        end

        local move_x = function(level)
            if (btn(0)) then
                velocity.x -= acc_x
                flipx = true
            elseif (btn(1)) then
                velocity.x += acc_x
                flipx = false
            elseif not pushed then
                velocity.x *= dcc_x
            end

            velocity.x=mid(-max_dx,velocity.x,max_dx)
			pos_x+=velocity.x
            collide_side(level)
            pushed = false
        end

        local handle_jump_and_gravity = function(level)
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

            local left_feet_spr = level.sprite_at(pos_x / 8, (pos_y + 8) / 8);
            local right_feet_spr = level.sprite_at((pos_x + 7) / 8, (pos_y + 8) / 8);
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
                if shell_state.action_push then
                    _change_state(shell_state.action_push)
                    sfx(1)
                end
            elseif (action_pressed_before and not action_pressed) then
                action_pressed_before = false
                if shell_state.action_release then
                    _change_state(shell_state.action_release)
                    sfx(2)
                end
            end
        end

        return {
            is_alive = function()
                return alive
            end,
            is_visible = function()
                return not shell_state.invisible
            end,
            die = function()
                _die()
            end,
            set_pos = function(x, y)
                pos_x = x
                pos_y = y
                velocity.x = 0
                velocity.y = 0
            end,
            push = function(x, y)
                velocity.x += x
                velocity.y += y
                pushed = true
            end,
            change_state = function(new_state)
                if new_state == "round_shell" or new_state == "box_shell" then
                    display_shell_button = true
                end

                _change_state(new_state)
            end,
            update = function(level)
                if alive then
                    move_x(level)
                    handle_jump_and_gravity(level)
                    handle_action()
                end

                if display_shell_button and btn(5) then
                    display_shell_button = false
                end
            end,
            draw = function()
                if alive then
                    animtick -= 1
                    if animtick <= 0 then
                        sprite_idx = (sprite_idx) % #frames + 1
                        animtick = 5
                    end
                    spr(frames[sprite_idx], pos_x, pos_y, 1, 1, flipx)
                else
                    spr(15, pos_x, pos_y, 1, 1, flipx)
                end

                if display_shell_button then
                    camera(0, 0)
                    draw_text("hold x to use your shell", 64, 64)
                end
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
