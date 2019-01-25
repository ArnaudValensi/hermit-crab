function require_player()
    idle_sprite = 1
    gravity = 0.5
    player_height = 8
    map_cell_spr = 999

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

                pos_y = pos_y + velocity.y

                map_cell_spr = mget(pos_x / 8, (pos_y + 8) / 8);
                is_grounded = fget(map_cell_spr, 7)

                if (is_grounded) then
                    velocity.y = 0
                else
                    velocity.y = velocity.y + gravity
                end
            end,
            draw = function()
                print(map_cell_spr, 0, 0, 7)
                spr(idle_sprite, pos_x, pos_y)
            end
        }
    end

    return new_player
end
