function require_level()
    local levels = {
        {
            player_start = {
                x = 2 * 8,
                y = 10 * 8,
                state = "naked"
            },
            goal = {
                type = "goal",
                x = 124,
                y = 5,
            },
            layout = {
                left = 0,
                right = 128,
                top = 0,
                bottom = 16
            },
            entities = {
                {
                    type = "round_shell",
                    x = 52,
                    y = 12,
                }
            }
        }
    }

    local function create_entity(params)
        return new_entity(params.x, params.y, params.type)
    end

    local function new_level(idx)
        local _level = levels[idx]
        local _entities = {}

        return {
            goal_pos = function()
                return new_vec(_level.goal.x * 8, _level.goal.y * 8)
            end,
            init = function(player)
                player.change_state(_level.player_start.state)
                player.set_pos(_level.player_start.x, _level.player_start.y)
                add(_entities, create_entity(_level.goal))
                for params in all(_level.entities) do
                    add(_entities, create_entity(params))
                end
            end,
            update = function(player)
                for entity in all(_entities) do
                    entity:update(player, self)
                end
                _entities = filter(_entities, function(item) return not item.deleted end)
            end,
            draw = function()
                for entity in all(_entities) do
                    entity:draw()
                end
            end
        }
    end

    return new_level
end
