function require_end_level_state()
    local display_win = false

    local end_level_state = {
        on_start = function(option)
            display_win = option and option.has_won or false
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

            if (display_win) then
                draw_text("you found a home !", 64, 32)
                draw_text("However...", 64, 48)
                draw_text("Your princess is", 64, 64)
                draw_text("in another shell", 64, 80)
                draw_text("press 🅾️ / z to continue", 64, 120)
            else
                draw_text("sadly... you died...", 64, 64)
                draw_text("press 🅾️ / z to retry", 64, 120)
            end
        end
    }

    return end_level_state
end
