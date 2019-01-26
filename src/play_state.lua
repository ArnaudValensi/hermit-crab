function require_play_state()
    local player = new_player()
    local scheduler = new_scheduler()

    local play_state = {
        on_start = function()
            player.change_state("round_shell")
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
            scheduler:update()
        end,

        draw = function()
            cls()
            camera(cam.get_offset())
            map(0, 0, 0, 0, 128, 128)
            player.draw()
        end
    }

    return play_state
end
