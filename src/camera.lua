function require_camera()
    local half_screen = 64
    local smooth_speed = 0.2
    local vertical_offset = 24
    local shake_force = 5
    local shake_duration = 10

    local function lerp(a, b, t)
        return a + (b - a) * t
    end

    local function new_camera(player)
        local pos = new_vec(0, 0) -- This is the center of the camera.
        local offset = new_vec(0, 0)
        local shake_offset = new_vec(0, 0)
        local shake_countdown = 0

        function update_shake()
            if (shake_countdown > 0) then
                shake_offset.x = rnd(shake_force) - (shake_force / 2)
                shake_offset.y = rnd(shake_force) - (shake_force / 2)
                shake_countdown -= 1
            elseif (shake_countdown == 0) then
                shake_offset.x = 0
                shake_offset.y = 0
            end
        end

        return {
            update = function()
                update_shake()

                local player_center_pos = player.get_center_pos()

                pos.x = lerp(pos.x, player_center_pos.x, smooth_speed)
                pos.y = lerp(pos.y, player_center_pos.y, smooth_speed)

                offset.x = pos.x - half_screen + shake_offset.x
                offset.y = pos.y - half_screen + shake_offset.y - vertical_offset
            end,
            get_offset = function()
                return offset.x, offset.y
            end,
            add_shake = function()
                shake_countdown = shake_duration
            end
        }
    end

    return new_camera
end
