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
    local title_picture = {
        draw_at = function(x, y)

        end
    }
end

function require_start_state()
    local title_sprite = new_sprite({
        sprite_number = 208,
        width_in_cell = 16,
        height_in_cell = 4,
    })

    local start_state = {
        on_start = function()
            printh('[1]', 'log');

        end,

        on_stop = function()

        end,

        update = function()
            if (btn(4) or btn(5)) then
                change_state(play_state)
            end
        end,

        draw = function()
            cls()
            camera(0, 0)
            title_sprite:draw_at(0, 90)
            -- draw_text("press 🅾️ / z to start ", 64, 120)
        end
    }

    return start_state
end
