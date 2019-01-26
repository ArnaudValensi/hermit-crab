function require_camera()
    local half_screen = 64
    local smooth_speed = 0.2
    local vertical_offset = 24

    local function lerp(a, b, t)
        return a + (b - a) * t
    end

    local function new_camera(player)
        local pos = new_vec(0, 0)
        local offset = new_vec(0, 0)

        return {
            update = function()
                local player_center_pos = player.get_center_pos()

                pos.x = lerp(pos.x, player_center_pos.x, smooth_speed)
                pos.y = lerp(pos.y, player_center_pos.y, smooth_speed)

                offset.x = pos.x - half_screen
                offset.y = pos.y - half_screen - vertical_offset
            end,
            get_offset = function()
                return offset.x, offset.y
            end
        }
    end

    return new_camera
end
