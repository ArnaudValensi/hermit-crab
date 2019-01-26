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
            viewport = {
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
                },
            }
        }
    }

    local function create_entity(params)
        return new_entity(params.x, params.y, params.type)
    end

    local function new_level(idx)
        local _level = levels[idx]
        local _entities = {}
        local _state = 'running'

        return {
            goal_pos = function()
                return new_vec(_level.goal.x * 8, _level.goal.y * 8)
            end,
            get_viewport = function()
                return _level.viewport
            end,
            init = function(player)
                _entities = {}
                _state = 'running'
                player.change_state(_level.player_start.state)
                player.set_pos(_level.player_start.x, _level.player_start.y)
                add(_entities, create_entity(_level.goal))
                for params in all(_level.entities) do
                    add(_entities, create_entity(params))
                end
            end,
            update = function(self, player)
                for entity in all(_entities) do
                    entity:update(player, self)
                end
                _entities = filter(_entities, function(item) return not item.deleted end)

                if (_state == 'won') then
                    change_state(end_level_state, { has_won = true })
                end

                if (not player.is_alive()) then
                    sfx(14)
                    change_state(end_level_state, { has_won = false })
                end
            end,
            draw = function()
                for entity in all(_entities) do
                    entity:draw()
                end
            end,
            set_game_state = function(new_state)
                _state = new_state
            end
        }
    end

    return new_level
end
