function require_level()
    local levels = {
        {
            player_start = {
                x = 2 * 8,
                y = 10 * 8,
                state = "naked"
            },
            layout = {
                left = 0,
                right = 128,
                top = 0,
                bottom = 16
            }
        }
    }

    local function new_level(idx)
        local _level = levels[idx]

        return {
            init = function(player)
                player.change_state(_level.player_start.state)
                player.set_pos(_level.player_start.x, _level.player_start.y)
            end
        }
    end

    return new_level
end
