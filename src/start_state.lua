function new_sprite(options)
    local sprite = {
        sprite_number = options.sprite_number,
        width_in_cell = options.width_in_cell,
        height_in_cell = options.height_in_cell,
        draw_at = function(self, x, y)
            spr(self.sprite_number, x, y, self.width_in_cell, self.height_in_cell)
        end,
    }

    return sprite
end

function new_title_picture()
    local decor_sprite = new_sprite({
        sprite_number = 160,
        width_in_cell = 16,
        height_in_cell = 2,
    })
    local title_sprite = new_sprite({
        sprite_number = 192,
        width_in_cell = 16,
        height_in_cell = 3,
    })

    local title_picture = {
        draw_at = function(self, x, y)
            -- printh('draw at:'..x..', '..y, 'log');
            rectfill(0, 0, 16 * 8, 10 * 8 + y, 1)
            palt(0, false)
            decor_sprite:draw_at(0, 78 + y)
            palt(0, true)
            title_sprite:draw_at(0, 90 + y)
        end
    }

    return title_picture
end

function new_tween(from, to, duration_in_frames)
    local current_value = from
    local current_frame = 0

    function ease_in_out_quad(t)
        if t < 0.5 then
            return 2*t*t
        end

        return -1+(4-2*t)*t
    end

    local tween = {
        update = function()
            local time = current_frame / duration_in_frames

            if (current_frame < duration_in_frames) then
                local easing = ease_in_out_quad(time)

                current_frame += 1
                current_value = from + (to - from) * easing
            else
                current_value = to
            end
        end,
        get_value = function()
            return current_value
        end,
    }

    return tween
end

function require_start_state()
    local title_picture = new_title_picture()
    local easing = new_tween(0, -50, 30)
    local scheduler = new_scheduler()
    local display_press_start = false

    local start_state = {
        on_start = function()
            easing = new_tween(0, -50, 30)
            display_press_start = false
            scheduler:set_timeout(1, function()
                display_press_start = true
            end)
        end,

        on_stop = function()

        end,

        update = function()
            if (btn(4) or btn(5)) then
                sfx(16)
                scheduler:set_timeout(1, function()
                    change_state(play_state)
                end)
            end

            easing.update()
            scheduler:update()
        end,

        draw = function()
            cls()
            camera(0, 0)
            title_picture:draw_at(0, easing.get_value())

            if display_press_start then
                draw_text("press 🅾️ / z to start ", 64, 100)
            end
        end
    }

    return start_state
end
