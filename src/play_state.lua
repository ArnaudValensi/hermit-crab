function require_play_state()
    local player = new_player()
    local scheduler = new_scheduler()
    local level = new_level(1)

    local play_state = {
        on_start = function()
            level.init(player)
            goal = {
                get_center_pos = function()
                return new_vec(75 * 8, 10 * 8)
                end
            }
            cam = new_camera(goal)
            scheduler:set_timeout(2, function() cam.set_target(player) end)
        end,

        update = function()
            player.update()
            cam.update()
            level.update()
            scheduler:update()
        end,

        draw = function()
            cls()
            camera(cam.get_offset())
            map(0, 0, 0, 0, 128, 128)
            level.draw()
            player.draw()
        end
    }

    return play_state
end
