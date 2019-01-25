function require_player()
    idle_sprite = 1
    gravity = 0.5
    jump_force = 5
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
                    velocity.y = velocity.y + gravity

                    if (velocity.y < 0 and jump_pressed_before and jump_pressed == false) then
                        velocity.y = 0
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
