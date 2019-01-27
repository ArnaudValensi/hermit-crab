pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function require_camera()
    local half_screen = 64
    local smooth_speed = 0.2
    local vertical_offset = 24
    local shake_force = 5
    local shake_duration = 10

    local function lerp(a, b, t)
        return a + (b - a) * t
    end

    local function new_camera(new_target)
        local pos = new_vec(0, 0) -- This is the center of the camera.
        local offset = new_vec(0, 0)
        local shake_offset = new_vec(0, 0)
        local shake_countdown = 0
        local target = new_target

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

                local player_center_pos = target.get_center_pos()

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
            end,
            set_target = function(new_target)
                target = new_target
            end
        }
    end

    return new_camera
end
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
function require_end_level_state()
    local display_win = false
    local next_level = false

    local end_level_state = {
        on_start = function(option)
            display_win = option and option.has_won or false
            next_level = option and option.next_level or false
        end,

        on_stop = function()

        end,

        update = function()
            if (btn(4) or btn(5)) then
                if next_level then
                    change_state(play_state, {next_level = next_level})
                else
                    change_state(play_state)
                end
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
function require_entity()

    local basic_draw = function(self)
        self.animtick -= 1
        if self.animtick <= 0 then
            self.sprite_idx = (self.sprite_idx) % #(self.frames) + 1
            self.animtick = 5
        end
        spr(self.frames[self.sprite_idx], self.pos_x * 8, self.pos_y * 8)
    end

    local entities = {
        ["goal"] = {
            frames = {131},
            update = function(self, player, level)
                local ppos = player.get_center_pos()
                if (is_point_in_box(ppos.x, ppos.y, self.pos_x * 8, self.pos_y * 8, 24, 16)) then
                    level.set_game_state('won')
                end
            end,
            draw = function(self)
                spr(116, self.pos_x * 8, (self.pos_y + 1) * 8)
                spr(131, (self.pos_x + 1) * 8, self.pos_y * 8, 2, 2)
            end
        },
        ["conveyor_belt"] = {
            frames = {118, 119, 120},
            update = function(self, player, level)
                local ppos = player.get_center_pos()
                if (is_point_in_box(ppos.x, ppos.y, self.pos_x * 8, (self.pos_y - 1) * 8, 8, 8)) then
                    player.push(0.2, 0)
                end
            end,
            draw = basic_draw,
        },
        ["ceil_laser_beam"] = {
            frames = {77, 78},
            update = function(self, player, level)
                self.cells = vertical_ray_cast(self.pos_x, self.pos_y, 1, level)
                local ppos = player.get_center_pos()
                if player.is_visible() then
                    for cel in all(self.cells) do
                        if (is_point_in_box(ppos.x, ppos.y, cel.x * 8, cel.y * 8, 8, 8)) then
                            player.die()
                        end
                    end
                end
            end,
            draw = function(self)
                local beam_frames = {93, 94}
                self.animtick -= 1
                if self.animtick <= 0 then
                    self.sprite_idx = (self.sprite_idx) % #(self.frames) + 1
                    self.animtick = 5
                end
                spr(self.frames[self.sprite_idx], self.pos_x * 8, self.pos_y * 8)
                for cel in all(self.cells) do
                    spr(beam_frames[self.sprite_idx], cel.x * 8, cel.y * 8)
                end
            end,
        },
        ["round_shell"] = {
            frames = {33, 34},
            update = function(self, player, level)
                local ppos = player.get_center_pos()
                if (is_point_in_box(ppos.x, ppos.y, self.pos_x * 8, self.pos_y * 8, 8, 8)) then
                    player.change_state("round_shell")
                    self.deleted = true
                end
            end,
            draw = basic_draw,
        },
        ["box_shell"] = {
            frames = {49, 50},
            update = function(self, player, level)
                local ppos = player.get_center_pos()
                if (is_point_in_box(ppos.x, ppos.y, self.pos_x * 8, self.pos_y * 8, 8, 8)) then
                    player.change_state("box_shell")
                    self.deleted = true
                end
            end,
            draw = basic_draw,
        },
    }

    local function new_entity(x, y, entity_type)
        local _factory = entities[entity_type]

        return {
            deleted = false,
            pos_x = x,
            pos_y = y,
            animtick = 5,
            frames = _factory.frames,
            sprite_idx = _factory.frames[1],
            update = function(self, player, level)
                _factory.update(self, player, level)
            end,
            draw = function(self)
                _factory.draw(self)
            end,
        }
    end

    return new_entity
end
function filter(tbl, fn)
    newtbl = {}
    for item in all(tbl) do
        if fn(item) then
            newtbl[#newtbl + 1] = item
        end
    end
    return newtbl
end
function require_level()
    local levels = {
        {
            player_start = {
                x = 2 * 8,
                y = 10 * 8,
                state = "naked"
            },
            goal = {
                type = "goal",
                x = 124,
                y = 5,
            },
            viewport = {
                left = 0,
                right = 128,
                top = 0,
                bottom = 16
            },
            entities = {
                {
                    type = "round_shell",
                    x = 52,
                    y = 12,
                },
            }
        },
        {
            player_start = {
                x = 3 * 8,
                y = 10 * 8,
                state = "naked"
            },
            goal = {
                type = "goal",
                x = 124,
                y = 11,
            },
            viewport = {
                left = 0,
                right = 128,
                top = 16,
                bottom = 16
            },
            entities = {
                {
                    many = true,
                    type = "conveyor_belt",
                    pos = {
                        {x = 13, y = 13,},
                        {x = 14, y = 13,},
                        {x = 15, y = 13,},
                        {x = 16, y = 13,},
                        {x = 17, y = 13,},

                        {x = 23, y = 13,},
                        {x = 24, y = 13,},
                        {x = 25, y = 13,},
                        {x = 26, y = 13,},
                        {x = 27, y = 13,},

                        {x = 35, y = 11,},
                        {x = 36, y = 11,},
                        {x = 37, y = 11,},
                        {x = 40, y = 8,},
                        {x = 41, y = 8,},
                        {x = 42, y = 8,},
                        {x = 46, y = 7,},
                        {x = 47, y = 7,},
                        {x = 48, y = 7,},

                        {x = 64, y = 11,},
                        {x = 65, y = 11,},
                        {x = 66, y = 11,},
                        {x = 69, y = 8,},
                        {x = 70, y = 8,},
                        {x = 71, y = 8,},
                        {x = 75, y = 7,},
                        {x = 76, y = 7,},
                        {x = 77, y = 7,},

                        {x = 88, y = 13,},
                        {x = 89, y = 13,},
                        {x = 90, y = 13,},
                        {x = 91, y = 13,},
                        {x = 92, y = 13,},
                        {x = 93, y = 13,},

                        {x = 114, y = 13,},
                        {x = 115, y = 13,},
                        {x = 116, y = 13,},
                        {x = 117, y = 13,},
                        {x = 118, y = 13,},
                    }
                },
                {
                    many = true,
                    type = "ceil_laser_beam",
                    pos = {
                        {x = 25, y = 9,},

                        {x = 71, y = 3,},
                        {x = 77, y = 2,},

                        {x = 101, y = 3,},
                        {x = 107, y = 2,},
                    }
                },
                {
                    many = true,
                    type = "box_shell",
                    pos = {
                        {x = 10, y = 12,},
                        {x = 25, y = 7,},
                    },
                },
            }
        }
    }

    local function create_entity(params)
        return new_entity(params.x, params.y, params.type)
    end

    local function new_level(idx)
        local _level = levels[idx]
        local _player = nil
        local _entities = {}
        local _state = 'running'
        local _state_transitionning = false

        return {
            goal_pos = function()
                return new_vec(_level.goal.x * 8, _level.goal.y * 8)
            end,
            get_viewport = function()
                return _level.viewport
            end,
            sprite_at = function(x, y)
                return mget(x + _level.viewport.left, y + _level.viewport.top)
            end,
            init = function(player)
                _entities = {}
                _player = player
                _state = 'running'
                _state_transitionning = false
                player.change_state(_level.player_start.state)
                player.set_pos(_level.player_start.x, _level.player_start.y)
                add(_entities, create_entity(_level.goal))
                for params in all(_level.entities) do
                    if not params.many then
                        add(_entities, create_entity(params))
                    else
                        for pos in all(params.pos) do
                            add(_entities, create_entity({type = params.type, x = pos.x, y = pos.y}))
                        end
                    end
                end
            end,
            update = function(self)
                for entity in all(_entities) do
                    entity:update(_player, self)
                end
                _entities = filter(_entities, function(item) return not item.deleted end)

                if (not _player.is_alive() and _state == 'running') then
                    _state = 'lost'
                end
            end,
            draw = function()
                for entity in all(_entities) do
                    entity:draw()
                end
            end,
            set_game_state = function(new_state)
                _state = new_state
            end,
            is_ended = function()
                return _state != 'running'
            end,
            has_won = function()
                return _state == 'won'
            end
        }
    end

    return new_level
end
function is_point_in_box(px,py,x,y,w,h)
	if flr(px)>=flr(x) and flr(px)<flr(x+w) and flr(py)>=flr(y) and flr(py)<flr(y+h) then
		return true
	else
		return false
	end
end

function vertical_ray_cast(celx, cely, dir, level)
	empty_cells = {}
	cely += dir
	while not fget(level.sprite_at(celx, cely), 7) and cely > 0 and cely <= 128 do
		add(empty_cells, new_vec(celx, cely))
		cely += dir
	end
	return empty_cells
end
function require_play_state()
    local curr_level = 2
    local nb_level = 2
    local player = new_player()
    local scheduler = new_scheduler()
    local level = new_level(curr_level)
    local state_transitionning = false

    function start_end_transition()
        if (not state_transitionning) then
            if (level.has_won()) then
                sfx(3)
                scheduler:set_timeout(2, function()
                    change_state(end_level_state, { has_won = true, next_level = curr_level % 2 + 1 })
                end)
            else
                sfx(14)
                scheduler:set_timeout(2, function()
                    change_state(end_level_state, { has_won = false, next_level = curr_level })
                end)
                
            end
            state_transitionning = true
        end
    end

    local play_state = {
        on_start = function(option)
            if option and option.next_level and curr_level != option.next_level then
                curr_level = option.next_level
                level = new_level(curr_level)
            end
            state_transitionning = false
            level.init(player)
            goal = {
                get_center_pos = function()
                    return level.goal_pos()
                end
            }
            cam = new_camera(goal)
            scheduler:set_timeout(2, function() cam.set_target(player) end)
            music(1)
        end,

        on_stop = function()
            music(-1)
        end,

        update = function()
            level:update()

            if (level.is_ended()) then
                start_end_transition()
            else
                player.update(level)
                cam.update()
            end

            scheduler:update()
        end,

        draw = function()
            cls()
            camera(cam.get_offset())
            local viewport = level.get_viewport()
            map(viewport.left, viewport.top, 0, 0, viewport.right, viewport.bottom)
            level.draw()
            player.draw()
        end
    }

    return play_state
end
function require_player()
    local idle_sprite = 1
    local gravity = 0.5
    local jump_force = 5
    local fall_coef = 2
    local player_height = 8
    local map_cell_spr = 999

    local default_acc_x=0.5
    local default_dcc_x=0.05
    local default_max_dx = 2

    local shell_states = {
        ["naked"] = {
            frames = {0, 1},
            acc_x = 0.5,
            dcc_x = 0.05,
            max_dx = 2,
            action_push = nil,
            action_release = nil,
        },
        ["round_shell"] = {
            frames = {2, 3},
            acc_x = 0.5,
            dcc_x = 0,
            max_dx = 2,
            action_push = "round_shell_in_shell",
            action_release = nil,
        },
        ["round_shell_in_shell"] = {
            frames = {4, 5, 6, 7},
            acc_x = 0.1,
            dcc_x = 0.01,
            max_dx = 10,
            action_push = nil,
            action_release = "round_shell",
        },
        ["box_shell"] = {
            frames = {16, 17},
            acc_x = 0.5,
            dcc_x = 0,
            max_dx = 2,
            action_push = "box_shell_in_shell",
            action_release = nil,
        },
        ["box_shell_in_shell"] = {
            frames = {18},
            acc_x = 0,
            dcc_x = 1,
            max_dx = 2,
            invisible = true,
            action_push = nil,
            action_release = "box_shell",
        },
    }

    function new_player()
        local alive = true
        local pos_x = 2 * 8
        local pos_y = 10 * 8
        local animtick = 5
        local frames={0, 1}
        local acc_x = 0.5
        local dcc_x = 0.05
        local max_dx = 2
        local shell_state = shell_states["naked"]
        local sprite_idx = 1
        local flipx = false
        local pushed = false
        local is_grounded = false
        local velocity = {
            x = 0,
            y = 0,
        }
        local jump_pressed_before = false
        local action_pressed_before = false
        local display_shell_button = false

        local _change_state = function(new_state)
            alive = true
            shell_state = shell_states[new_state]
            frames=shell_state.frames
            sprite_idx = 1
            acc_x = shell_state.acc_x
            dcc_x = shell_state.dcc_x
            max_dx = shell_state.max_dx
        end

        local _die = function()
            alive = false
        end

        local collide_side = function(level)
            if velocity.x < 0 then
                collided_spr = level.sprite_at(pos_x / 8, pos_y / 8)
                if fget(collided_spr, 6) then
                    _die()
                elseif fget(collided_spr, 7) then
                    velocity.x = 0
                    pos_x = flr(pos_x / 8) * 8 + 8
                    return true
                end
            else
                collided_spr = level.sprite_at(pos_x / 8 + 1, pos_y / 8)
                if fget(collided_spr, 6) then
                    _die()
                elseif fget(collided_spr, 7) then
                    velocity.x = 0
                    pos_x = flr(pos_x / 8) * 8
                    return true
                end
                return false
            end
        end

        local move_x = function(level)
            if (btn(0)) then
                velocity.x -= acc_x
                flipx = true
            elseif (btn(1)) then
                velocity.x += acc_x
                flipx = false
            elseif not pushed then
                velocity.x *= dcc_x
            end

            velocity.x=mid(-max_dx,velocity.x,max_dx)
			pos_x+=velocity.x
            collide_side(level)
            pushed = false
        end

        local handle_jump_and_gravity = function(level)
            local jump_pressed = btn(4)

            if (is_grounded) then
                velocity.y = 0

                if (jump_pressed) then -- Jump (z)
                    velocity.y = -jump_force
                    sfx(0)
                end
            else
                if (velocity.y < 0 and jump_pressed_before and jump_pressed == false) then
                    velocity.y = 0
                elseif (velocity.y > 0) then -- Falling
                    velocity.y = velocity.y + gravity * fall_coef
                else
                    velocity.y = velocity.y + gravity
                end
            end

            if (jump_pressed) then
                jump_pressed_before = true
            else
                jump_pressed_before = false
            end

            pos_y = pos_y + velocity.y

            local left_feet_spr = level.sprite_at(pos_x / 8, (pos_y + 8) / 8);
            local right_feet_spr = level.sprite_at((pos_x + 7) / 8, (pos_y + 8) / 8);
            local collide_left = fget(left_feet_spr, 7)
            local collide_right = fget(right_feet_spr, 7)

            is_grounded = collide_left or collide_right

            if (is_grounded) then -- Fix y position
                pos_y = pos_y - pos_y % 8
            end
        end

        local handle_action = function()
            local action_pressed = btn(5)
            if (not action_pressed_before and action_pressed) then
                action_pressed_before = true
                if shell_state.action_push then
                    _change_state(shell_state.action_push)
                    sfx(1)
                end
            elseif (action_pressed_before and not action_pressed) then
                action_pressed_before = false
                if shell_state.action_release then
                    _change_state(shell_state.action_release)
                    sfx(2)
                end
            end
        end

        return {
            is_alive = function()
                return alive
            end,
            is_visible = function()
                return not shell_state.invisible
            end,
            die = function()
                _die()
            end,
            set_pos = function(x, y)
                pos_x = x
                pos_y = y
                velocity.x = 0
                velocity.y = 0
            end,
            push = function(x, y)
                velocity.x += x
                velocity.y += y
                pushed = true
            end,
            change_state = function(new_state)
                if new_state == "round_shell" or new_state == "box_shell" then
                    display_shell_button = true
                end

                _change_state(new_state)
            end,
            update = function(level)
                if alive then
                    move_x(level)
                    handle_jump_and_gravity(level)
                    handle_action()
                end

                if display_shell_button and btn(5) then
                    display_shell_button = false
                end
            end,
            draw = function()
                if alive then
                    animtick -= 1
                    if animtick <= 0 then
                        sprite_idx = (sprite_idx) % #frames + 1
                        animtick = 5
                    end
                    spr(frames[sprite_idx], pos_x, pos_y, 1, 1, flipx)
                else
                    spr(15, pos_x, pos_y, 1, 1, flipx)
                end

                if display_shell_button then
                    camera(0, 0)
                    draw_text("hold x to use your shell", 64, 64)
                end
            end,
            get_center_pos = function()
                return new_vec(pos_x + 4, pos_y + 4)
            end,
            get_width = function()
                return 8
            end
        }
    end

    return new_player
end
function require_scheduler()
    function new_scheduler()
        local scheduler = {
            coroutine = nil,
            update = function(self)
                if self.coroutine and costatus(self.coroutine) != 'dead' then
                    coresume(self.coroutine)
                else
                    self.coroutine = nil
                end
            end,
            set_timeout = function (self, delay_in_s, fn)
                self.coroutine = cocreate(function()
                    local tick_before_timeout = delay_in_s * 30

                    while (tick_before_timeout ~= 0) do
                        yield()
                        tick_before_timeout -= 1
                    end
                    fn()
                end)
            end
        };

        return scheduler
    end

    return new_scheduler
end
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
            printh('[2]', 'log');

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
function new_vec(x, y)
    return {
        x = x,
        y = y,
    }
end
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

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000808080000000000000000000000000
80000000008000000000000000000000000000000000000000000000000000000000000000000000001510008801100000888880000000000000000000000000
8000a0a00800a0a00110a0a00110a0a0000000000000000000000000000000001110a0a01110a0a000515000088a151000088800000110880000000000000000
880888008808880011118800111188000000000000000000000000000000000015511800155118000111110088881151001a8a100151a880000000000000a0a0
08888808888888001111880811118800000110000001100000011000000a1000151188081511880001a8a100088a15100011111015118888000000000008c8c0
08888880088888080118888001188808001a1a000011a100001111000011110001188880011888080088800088011000000515000151a880000000000888c8c0
00888808008888800088880800888880001111000011110000a1a100001a11000188880801888880088888000000000000015100000110880000000088888880
00080800008080080008080000808008000110000001a00000011000000110000008080000808008080808000000000000001000000000000000000080888808
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111a1a01111a1a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15511100155111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15111108151111000111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111118011111108015a1a1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888808008888800151111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080800008080080111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000aa0000a0000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001100000a11a000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001111000a1111a0a011110a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001111000a1111a0a011110a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001100000a11a000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000aa0000a0000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aa0aa0aa0aa0aa0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111111001111110a111111a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01551110a155111aa155111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01511110a151111a0151111a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111111001111110a111111a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aa0aa0aaa0aa0aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555555555999599955555555cc0000cc0000000000000000c000000000000000000000000000000c0000000000000000000000000555555005555550cccccccc
999999999999999999999999c003300c0444b44000000000099999999999999999999999999999900000000000000000000000000005500000055000cccccccc
9599959995999599959777990030330004444b4000000000099aaaaaaaaaaaaaaaaaaaaaaaaaa9900000000000000000000000000055550000555500cccccccc
999999999999999999777779c033330c0b4b44b00000000009aaaaaaaaaaaaaaaaaaaaaaaaaaaa90000000000000000000000000000aa000000aa000cc5ccc5c
9995999599959995997070750333033004444b40000000000999999999999999999aa9999999999000000000000000000000000000aaaa0000aaaa00c565c565
999999999999999999977799c033330c0444b440000000000999999999999999999aa999999999900000000000000000000000000aa7aaa00aa7aaa056665666
9959995999599959995999590030330004000040000000000999999999999999999aa999999999900000000000000000000000000aa7aaa0aa77aaaa56665666
999999999999999999977799c033330c040cc04000000000c000000000000000999aa9990000000c0000000000000000000000000aa7aaa0aa77aaaa55555555
555555555555555559995999cc0330cc0000000000000000099aa9990000000c099aa990c00000000000000000000000000000000aa7aaa0aa77aaaa00000000
599999955999999599999999c033330c044b444000000000099aa99999999990099aa990099999990000000000000000000000000aa7aaa0aa77aaaa00000000
5599959555999595959777990030330004b4444000000000099aaaaaaaaaa990099aa990099aaaaa0000000000000000000000000aa7aaa0aa77aaaa00000000
599999955999999599777779c033330c0b44b4b000000000099aaaaaaaaaa990099aa990099aaaaa0000000000000000000000000aa7aaa0aa77aaaa00000000
5995999559959995997070750333033004b444400000000009999999999aa990099aa990099aa9990000000000000000000000000aa7aaa0aa77aaaa00000000
599999955999999599977799c033330c044b44400000000009999999999aa990099aa990099aa9990000000000000000000000000aa7aaa0aa77aaaa00000000
59599955595999559959995900303300040000400000000009999999999aa990099aa990099aa9990000000000000000000000000aa7aaa0aa77aaaa00000000
599999955555555599977799c033330c040cc04000000000c0000000999aa990099aa990099aa9990000000000000000000000000aa7aaa0aa77aaaa00000000
599959995999599559995999cccccccc0000000000000000c000000000000000999aa9990000000c0000000000000000000000000aa7aaa0aa77aaaa00000000
599999999999999599997999cccccccc07777770000000000999999999999999999aa999999999900000000000000000000000000aa7aaa0aa77aaaa00000000
559995999599959595997799cccccccc0707707000000000099aaaaaaaaaaaaaaaaaaaaaaaaaa9900000000000000000000000000aa7aaa00aa7aaa000000000
599999999999999599979999cccccccc077777700000000009aaaaaaaaaaaaaaaaaaaaaaaaaaaa9000000000000000000000000000aaaa0000aaaa0000000000
599599959995999597759995cccccccc040000400000000009999999999999999999999999999990000000000000000000000000005aa500005aa50000000000
599999999999999599799999cccccccc047777400000000009999999999999999999999999999990000000000000000000000000005555000055550000000000
595999599959995599599959cccccccc040000400000000009999999999999999999999999999990000000000000000000000000000550000005500000000000
599999999999999599999999ccccccccc40cc04c00000000c000000000000000000000000000000c000000000000000000000000055555500555555000000000
555555555555555500000000000000004449944400000000444144411444144441444144999aa990000000000000000000000000000000000000000000000000
599999999999999500000000000000004499994400000000155455544555545144555544999aa990000000000000000000000000000000000000000000000000
559995999599959500000000000000004999999400000000455455544455455445455451aaaaa990000000000000000000000000000000000000000000000000
599999999999999500000000000000004515515400000000455444444544455415544554aaaaa990000000000000000000000000000000000000000000000000
59959995999599950000000000000000455555540000000044444551155444544554455499999990000000000000000000000000000000000000000000000000
59999999999999950000000000000000455155540000000015554554455455414545545499999990000000000000000000000000000000000000000000000000
59599959995999550000000000000000044444400000000045554554454555544455554199999990000000000000000000000000000000000000000000000000
5999999999999995000000000000000004400440000000004414441441444144144414440000000c000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc00000057500000000000000000000000000000000000000000000000000000000000000000000000000000000000747474740000
ccccccccccccc666666ccccc00555577750055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccc6677777766ccc005575cccc5575000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccc667777777766cc00057751157750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccc6677777766ccc0005775c657750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccccccccccccc666666ccccc00055566665550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc0005111ccccc15000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc005777c1cc11c7500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccc0051177711cc17500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccc7ccccccc7ccccccccccc05711177c1cc77500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc7a7ccccc787cccccccccc057111777c1175000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc37cccccc37ccccccccccc00571117777775000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc3ccccccc3ccccccccccccc0005111c777750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cc3ccccccc3ccccccccccccc0005111c777750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ccc3ccccccc3ccccc5555ccc00051115555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111101111111111111111111111111111111111111111111111111111111111117111111111111111111111111111111111111111111111111111111
11111111111101111111111111111111111110111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11011111111000111111111111111111111100011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
10001111111101111111111111111111111000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11011111100000001111111111111111110000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000111111101111111111111111111100000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11011111000000000111111111111111000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000011111101111111111111111110000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11011111000000000001111111111100000000000000011111111111111111111111111111111111111111111111111111111111111111111117111111111111
00000001111001111111111111111000000000000000001111111111111111111111111111111111111111111111111111111111111111111111111111111111
00001110000000000000111111111000000000000000000111111111111111111100011111111111111111111110000011111111111111111111111100000000
00001111100000011110000011000000000000000000000011111111111111110000001111101110001111111000000000000000000000000000000000000000
00000111000000001100000000000000000000000000000001111100011111000000000111101100000111110000000000000000000000000000000000000000
00000011000000000000000000000000000000000000000000110000001100000000000001101000000011100000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000077777777777777000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000566677666666766700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000556666666566666700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000556665555556666700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000566675777775666700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000556675666675666700000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000aa000000566a75556675666700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000a99a0000006a9a7776675666700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000a99900080069995666575667700000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000a9988999889a9995555555666700000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000a9809888999a9997777776667700000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000a98098889988999aa66666667700000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000099800888988899a9966666666700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000009800008888889899896655666700000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000800000888888889585555555000000000000000000000000000000000000000000000000000000000000000000000000000
07777777777777007777777777777777777777777777777777777777777777777700000077777777777777777777777777777777777777777777777000000000
56666666666666705666666666666666666666666666666666666666666666666670000566666666666666666666666666666666666666666666666700000000
00000000000566705667000000000000000000000000000000000000000000006670000566700566700000000000000000000056600000000000000000000000
00000000000566777667005666666705666066670566606660666700566670566666700566700000056660666705666666700056606667000000000000000000
00000000000566666667005667566700566676670056660666066700056670056670000566700000005666066700000566700056665667000000000000000000
00000000000566705667005666666700566706670056605660566700056670056670000566700000005667066705666666700056605667000000000000000000
07700077000566705667005667000000566700000056605660566700056670056670000566700000005667000005660566700056605667007700077000000000
56670566700566705667005667056700566700000056605660566700056670056676700566700056705667000005660566700056605667056670566700000000
56670566705666705666705666666705666670000566605660566670566667056666700566666666756666700005666666670566666667056670566700000000
__gff__
0101010103030303010101010101000101010100000000000000000000000000000000000000000000000000000000000101010000000000000000000000000080808080000080808080000000c0c0408080808000008080808000000040400080808000000080808080000000c0c00080800000000080808080000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
8080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808043
8080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808053
8080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808081828080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808053
8080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080804380808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808053
8080808080808080808080808080808080808080808080808182808080808080808080808080808080808080808080808080808080808080805380808080808080808080808080808081828080808080808080808080808080808080808080808080808080808080808080808080808080808080808182808080808080808053
4380808080808182808080808080808080808080808080808080808080808080808080808080808080808070404040407180808080808070404071808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808053
5380808080808080808080808080808080808080808080808080808080808080808080818280808080808080808080808080808080808060414161928080918080808080808080808080808080808080808080808080808080808080808080808080808080808080808080818280808080808080808080808080809080808053
5380808080808080808080808080808182808080808080808080808080808080808080808080807040718080808080808080808080808060414141404242427180808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080807040404040
5380808080808080808080808080808080808080808080808080808080808080808080808080806041618080808080808080808080808060414141414141416180808080808080808080808080808080808080808080818280808080808080808080808080808080808080808080808080808080808080808080806041414141
5380808080808080808080808080808080808080808080808080808080808080808080808080704141619180808080808080808080808060414141414141526180808080808080808080808080808080808080808080808080808080808080808081828080808080808080808080808080808080808080808091806041414141
538080808080808080808080808080707180808080808080808080808080808080808080808060414141718080808080818280808080806041414141414141614f4f4f4f4f4f7071808080808080808080808080808080808080808080438080808080808080808080808080808080808080808080808080504f4f6041414141
5380808080808080808080918080806061808080808080808080808080808080808080808070414141416180438080808080808080808060414141415241414140424040424041618080808080808080808080808080808080808080805380808080808080808080808080808080808182808092808080806041424141414141
5380808044804480448080438080906061808080808080808080804380808080909090808060414141416180539180808080449180915460414141414141524162626262626241414040404040404042427180808080808080808070424140404040404040404271808080808080808080807071808092806041416241414141
404040404040404040404041404040414140404040718080704040614f4f704040404040404141414141414040404040404040404040404141414141414141416262626262624141624141624162414141614f4f4f4f4f4f4f4f4f604141414141414141414141614f4f4f4f4f4f4f4f4f4f60614f4f504f6041414141414141
4141414141414141414141414141414141414141414140404141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141624141414162414140424042404042424241414141414141414141414141424242424242424242424141424241424162414141414141
4141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414141414162416241414141414162414141414141414141414141414141414141414141414141414141414141414141414141
5880808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808046484980808080808080808080808080808080808080808080808080808059485780808080808080808080808080808080808059
5880808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808046684980808080808080808080808080808080808080808080805947474779567980808080808080808080808080808080808058
5880808080808080808080808080808080808080808080808080808080808080808080808080818280808080808080808080808080808080808080808080808080808080808046474980808080808080808080808080808080808080808080808080808046477980808080808080808080808080808080808080808080808058
5880808080808080818280808080808080808080808080808182808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808081828080808080808080808182808080808080808080808080808080808080909158
5880808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080804657404058
5880808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080818280808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808182808080808056484779
5880808080808080808080808080808080808080808080805947578080808080808080808080808080808080808080808080808080808080818280808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080804648498080465780808080808080808080808080565780
5880808080808080808080808080808080818280808080805880588080808081828080808080808080808080808076767680804648578080808080808080808080808080808080808080807676768080464857808080808080808080808080808080808080808080804668498080805880808080808080808080808080805657
5880808182808080808080808080808080808080808080805667798080808080808080808080808076767680808046474980808058588080808080808080808080808080807676768080804647498080805858808080808080818280808080808080804648498080808080808080805880808080808080808080808182808058
5880808080808080808080808080808080808080808080808080808080808080808080808080808046474980808080808080808058564980808080808080808080808080804647498080808080808080805858808080808080808080808080808080804668498080808080808080805657808080808080808080808080808058
5880808080808080808080808080808080808080808080808080808080808080808080808080808080808080808080808081828056485780808080808080808080808080808080808080808080808182805858595780808080808080808080808080808080808080808080808080808058808080808080808080808080808058
5880808080808080805949808080808080808080808080808080808080808080808080767676808080808080808080808080808058585657808080808080808076767680808080808080808080808080805858585880808080808080808046484980808080808080808080808080808058808080808080808080808080808058
58808080808080808058808080808080808080594980648080808080808080808080804648494f4f4647494f4f4f4647494f4f4f58565758808080808080808046484980808080808080808080808080805858585880808080808080808046684980808080808080808080808080808056578080808080808080808080808058
56484748474847484768474749767676767659684959497676767676464747474747474768474747474747474747474747474747684768684747474747474747476847474747474747474747474747474768686868474749767676767676464847474747474747474747474747474747477976767676764f4f4f464747474779
8058805880588058804647474747474747476857597959474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747684747474747474747474747474747474747474747474747474747474747474747
4668676867686768494647474747484747474958564879594747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474747474757
__sfx__
0001000000000000000e5500e5500f55010550125501355015550175501a5501d5502155027550015000350003500025000350001500015000150001500015000150003500025000150000500005000050000500
0001000014050180501b0501e050200502005022050220502205022050210501f0501c0501905015050110500f050000000000000000000000000000000000000000000000000000000000000000000000000000
0001000002050060500a0500c0500d0500e0500e0500e0500e0500d0500c0500a050080501100012000190001c000200000000000000000000000000000000000000000000000000000000000000000000000000
010800002175021700217500e70021750017002175021750217501c7001c7501c7501c750297001f7501f7501f7502170021750217501f7001f7501f700217502175021750217502175021750217502175021750
01100000217501c300207501f75011300133002175013300207501f7501230012300217501f100207501f75000000247502475024750217502175021750000000000003700000001a70019700000000170001700
01100000220522205220052200521e0521e0521b05219052190521b0521b0521e0521e05220052220522205220052200521e0521e0521b05219052190521b052190521b05222052200521e0521e0521e0521e052
0010040800073030731c6751c60005073000002867500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018752187521c7521f75223752237521f752237521f7522375224752237521f7521c7521a7521875218751187511875118751187001870018700187001f7002370024700237001f7001c7001a70018700
01100000187521c7521f75223752247522375224752237521f7521c752187521c7521875224752237521f7521f7511f7511f7511f751247002370024700237001f7001c7001a700187001a700187001870018700
01200010001520015207152071520b1520b1520715207152091520915200152001520715207152021520215202104021040010400104001000000000000000000000000000000000000000000000000000000000
0110000018754187541c7541f75423754237541f754237541f7542375424754237541f7541c7541a7541875418751187511875118751000040000000000000000000000000000000000000000000000000000000
01100000187541c7541f75423754247542375424754237541f7541c754187541c7541875424754237541f7541f7511f7511f7511f751000000000000000000000000000000000000000000000000000000000000
0120000004055090550405509055010550b055010550b05504055090550405509055010550b055010550b05504055090550405509055010550b055010550b05504055090550405509055010550b055010550b055
012000001811418112191221c1321d1421f1522015220152201521f1521d1521c1521d1521c15219152181521815218152191521c1521d1521f1522015220152201521f152201521f1521d1521c1521915218155
010700001b5531b5531a553195531755315553145531255311553105530f5530e5530d5530b5530a5530755305553045530355301553015020950208502075020750206501045000150000500005000050000500
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 47094344
01 48094344
00 07094344
00 08094344
00 07094344
02 08094344
00 0a094344
03 0b094344
01 0c424344
02 0c0d4344

