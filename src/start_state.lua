function require_start_state(change_state, play_state)
    local start_state = {
        on_start = function()

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
            draw_text("press 🅾️ / z to start ", 64, 120)
        end
    }

    return start_state
end
