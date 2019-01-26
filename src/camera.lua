function require_camera()
    local screen_width = 128;

    local function new_camera(player)
        local offset_x = 0
        local player_width = player.get_width()

        return {
            update = function()
                local player_pos_x = player.get_pos_x()
                offset_x = player_pos_x - screen_width / 2
            end,
            get_offset = function()
                return offset_x
            end
        }
    end

    return new_camera
end
