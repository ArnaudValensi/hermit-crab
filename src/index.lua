new_player = require_player()
new_camera = require_camera()
new_scheduler = require_scheduler()

-- Globals
player = new_player()
scheduler = new_scheduler()

function draw_text(str,x,y,al,extra,c1,c2)
  str = ""..str
  local al = al or 1
  local c1 = c1 or 7
  local c2 = c2 or 13

  if al == 1 then x -= #str * 2 - 1
  elseif al == 2 then x -= #str * 4 end

  y -= 3

  if extra then
   print(str,x,y+3,0)
   print(str,x-1,y+2,0)
   print(str,x+1,y+2,0)
   print(str,x-2,y+1,0)
   print(str,x+2,y+1,0)
   print(str,x-2,y,0)
   print(str,x+2,y,0)
   print(str,x-1,y-1,0)
   print(str,x+1,y-1,0)
   print(str,x,y-2,0)
  end

  print(str,x+1,y+1,c2)
  print(str,x-1,y+1,c2)
  print(str,x,y+2,c2)
  print(str,x+1,y,c1)
  print(str,x-1,y,c1)
  print(str,x,y+1,c1)
  print(str,x,y-1,c1)
  print(str,x,y,0)
end

function change_state(to_state)
  cls()
  state = to_state
  to_state.on_start()
  to_state.update()
end

start_state = {
  on_start = function()

  end,

  update = function()
    if (btn(4) or btn(5)) then
      change_state(play_state)
    end
  end,

  draw = function()
    cls()
    draw_text("press 🅾️ / z to start ", 64, 120)
  end
}

play_state = {
  on_start = function()
    player.change_state("round_shell")
    goal = {
      get_center_pos = function()
        return new_vec(75 * 8, 10 * 8)
      end
    }
    cam = new_camera(goal)
    scheduler:set_timeout(2, function() cam.set_target(player) end)
  end,

  update = function()
    player.update()
    cam.update()
    scheduler:update()
  end,

  draw = function()
    cls()
    camera(cam.get_offset())
    map(0, 0, 0, 0, 128, 128)
    player.draw()
  end
}

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
