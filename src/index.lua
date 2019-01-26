new_player = require_player()
new_camera = require_camera()
new_scheduler = require_scheduler()
new_level = require_level()
new_entity = require_entity()
play_state = require_play_state()
end_level_state = require_end_level_state()
start_state = require_start_state()

function change_state(to_state, options)
  cls()
  state.on_stop()
  state = to_state
  to_state.on_start(options)
  to_state.update()
end

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
