new_player = require_player()

-- Globals
player = new_player()

function _init()
    player.change_state("round_shell")
end

function _update()
    player.update()
end

function _draw()
    cls()
    camera(0, 0)
    map(0, 0, 0, 0, 16, 16)
    camera(cam_x, cam_y)
    player.draw()
end
