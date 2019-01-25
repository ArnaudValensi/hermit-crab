function require_player()
    idle_sprite = 1
    gravity = 2

    function new_player()
        pos_x = 0
        pos_y = 0
        is_grounded = false
        velocity = {
            x = 0,
            y = 0,
        }

        return {
            update = function()
                if (btn(0)) then
                    pos_x = pos_x - 1
                end
                if (btn(1)) then
                    pos_x = pos_x + 1
                end

                velocity.y = velocity.y + gravity
                pos_y = pos_y + velocity.y
            end,
            draw = function()
                print('('..pos_x..', '..pos_y..')', 0, 0, 7)
                spr(idle_sprite, pos_x, pos_y)
            end
        }
    end

    return new_player
end
