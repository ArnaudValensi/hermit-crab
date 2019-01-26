function require_play_state()
    local player = new_player()
    local scheduler = new_scheduler()
    local level = new_level(1)

    local play_state = {
        on_start = function()
            level.init(player, scheduler)
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
            player.update()
            cam.update()
            level:update(player)
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
