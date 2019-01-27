function require_play_state()
    local curr_level = 2
    local nb_level = 2
    local player = new_player()
    local scheduler = new_scheduler()
    local level = new_level(curr_level)
    local state_transitionning = false

    function start_end_transition()
        if (not state_transitionning) then
            if (level.has_won()) then
                sfx(3)
                scheduler:set_timeout(2, function()
                    change_state(end_level_state, { has_won = true, next_level = curr_level % 2 + 1 })
                end)
            else
                sfx(14)
                scheduler:set_timeout(2, function()
                    change_state(end_level_state, { has_won = false, next_level = curr_level })
                end)
            end
            state_transitionning = true
        end
    end

    local play_state = {
        on_start = function(option)
            if option and option.next_level and curr_level != option.next_level then
                curr_level = option.next_level
                level = new_level(curr_level)
            end
            state_transitionning = false
            level.init(player)
            goal = {
                get_center_pos = function()
                    return level.goal_pos()
                end
            }
            cam = new_camera(goal)
            scheduler:set_timeout(2, function() cam.set_target(player) end)
            music(1)
        end,

        on_stop = function()
            music(-1)
        end,

        update = function()
            level:update()

            if (level.is_ended()) then
                start_end_transition()
            else
                player.update(level)
                cam.update()
            end

            scheduler:update()
        end,

        draw = function()
            cls()
            camera(cam.get_offset())
            local viewport = level.get_viewport()
            map(viewport.left, viewport.top, 0, 0, viewport.right, viewport.bottom)
            level.draw()
            player.draw()
        end
    }

    return play_state
end
