new_player = require_player()
new_camera = require_camera()
new_scheduler = require_scheduler()
new_level = require_level()

-- Globals
player = new_player()
scheduler = new_scheduler()
level = new_level(1)

function _init()
    level.init(player)
    goal = {
        get_center_pos = function()
            return new_vec(125 * 8, 10 * 8)
        end
    }
    cam = new_camera(goal)
    scheduler:set_timeout(2, function() cam.set_target(player) end)
end

function _update()
    player.update()
    cam.update()
    scheduler:update()
end

function _draw()
    cls()
    camera(cam.get_offset())
    map(0, 0, 0, 0, 128, 128)
    player.draw()

    -- HUD
    camera(0, 0)
    -- print(cam.get_offset(), 0, 0, 7)
end
