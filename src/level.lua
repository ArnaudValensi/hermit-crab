function require_level()
    local levels = {
        {
            player_start = {
                x = 123 * 8,
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
                x = 3 * 8,
                y = 10 * 8,
                state = "naked"
            },
            goal = {
                type = "goal",
                x = 124,
                y = 11,
            },
            viewport = {
                left = 0,
                right = 128,
                top = 16,
                bottom = 16
            },
            entities = {
                {
                    many = true,
                    type = "conveyor_belt",
                    pos = {
                        {x = 13, y = 13,},
                        {x = 14, y = 13,},
                        {x = 15, y = 13,},
                        {x = 16, y = 13,},
                        {x = 17, y = 13,},

                        {x = 23, y = 13,},
                        {x = 24, y = 13,},
                        {x = 25, y = 13,},
                        {x = 26, y = 13,},
                        {x = 27, y = 13,},

                        {x = 35, y = 11,},
                        {x = 36, y = 11,},
                        {x = 37, y = 11,},
                        {x = 40, y = 8,},
                        {x = 41, y = 8,},
                        {x = 42, y = 8,},
                        {x = 46, y = 7,},
                        {x = 47, y = 7,},
                        {x = 48, y = 7,},

                        {x = 64, y = 11,},
                        {x = 65, y = 11,},
                        {x = 66, y = 11,},
                        {x = 69, y = 8,},
                        {x = 70, y = 8,},
                        {x = 71, y = 8,},
                        {x = 75, y = 7,},
                        {x = 76, y = 7,},
                        {x = 77, y = 7,},

                        {x = 88, y = 13,},
                        {x = 89, y = 13,},
                        {x = 90, y = 13,},
                        {x = 91, y = 13,},
                        {x = 92, y = 13,},
                        {x = 93, y = 13,},

                        {x = 114, y = 13,},
                        {x = 115, y = 13,},
                        {x = 116, y = 13,},
                        {x = 117, y = 13,},
                        {x = 118, y = 13,},
                    }
                },
                {
                    many = true,
                    type = "ceil_laser_beam",
                    pos = {
                        {x = 25, y = 9,},

                        {x = 71, y = 3,},
                        {x = 77, y = 2,},

                        {x = 101, y = 3,},
                        {x = 107, y = 2,},
                    }
                },
                {
                    many = true,
                    type = "box_shell",
                    pos = {
                        {x = 10, y = 12,},
                        {x = 25, y = 7,},
                    },
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
                    if not params.many then
                        add(_entities, create_entity(params))
                    else
                        for pos in all(params.pos) do
                            add(_entities, create_entity({type = params.type, x = pos.x, y = pos.y}))
                        end
                    end
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
