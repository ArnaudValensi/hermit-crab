function require_camera()
    local half_screen_width = 64;

    local function new_camera(player)
        local offset_x = 0
        local player_width = player.get_width()

        return {
            update = function()
                local player_pos_x = player.get_pos_x()
                offset_x = player_pos_x + 4 - half_screen_width
            end,
            get_offset = function()
                return offset_x
            end
        }
    end

    return new_camera
end
