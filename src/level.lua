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
        },
        {
            player_start = {
                x = 2 * 8,
                y = 5 * 8,
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
                top = 16,
                bottom = 32
            },
            entities = {
                {
                    type = "box_shell",
                    x = 10,
                    y = 6,
                },
            }
        }
    }

    local function create_entity(params)
        return new_entity(params.x, params.y, params.type)
    end

    local function new_level(idx)
        local _level = levels[idx]
        local _player = nil
        local _entities = {}
        local _state = 'running'
        local _state_transitionning = false

        return {
            goal_pos = function()
                return new_vec(_level.goal.x * 8, _level.goal.y * 8)
            end,
            get_viewport = function()
                return _level.viewport
            end,
            sprite_at = function(x, y)
                return mget(x + _level.viewport.left, y + _level.viewport.top)
            end,
            init = function(player)
                _entities = {}
                _player = player
                _state = 'running'
                _state_transitionning = false
                player.change_state(_level.player_start.state)
                player.set_pos(_level.player_start.x, _level.player_start.y)
                add(_entities, create_entity(_level.goal))
                for params in all(_level.entities) do
                    add(_entities, create_entity(params))
                end
            end,
            update = function(self)
                for entity in all(_entities) do
                    entity:update(_player, self)
                end
                _entities = filter(_entities, function(item) return not item.deleted end)

                if (not _player.is_alive() and _state == 'running') then
                    _state = 'lost'
                end
            end,
            draw = function()
                for entity in all(_entities) do
                    entity:draw()
                end
            end,
            set_game_state = function(new_state)
                _state = new_state
            end,
            is_ended = function()
                return _state != 'running'
            end,
            has_won = function()
                return _state == 'won'
            end
        }
    end

    return new_level
end
