new_player = require_player()
new_camera = require_camera()
new_scheduler = require_scheduler()
play_state = require_play_state()

function change_state(to_state)
  cls()
  state = to_state
  to_state.on_start()
  to_state.update()
end

start_state = require_start_state(change_state, play_state)
state = start_state

function _init()
  state.on_start()
end

function _update()
  state.update()
end

function _draw()
  state.draw()
end
