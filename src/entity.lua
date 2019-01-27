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
            frames = {192},
            update = function(self, player, level)
                local ppos = player.get_center_pos()
                if (is_point_in_box(ppos.x, ppos.y, self.pos_x * 8, self.pos_y * 8, 24, 16)) then
                    level.set_game_state('won')
                end
            end,
            draw = function(self)
                spr(116, self.pos_x * 8, (self.pos_y + 1) * 8)
                spr(192, (self.pos_x + 1) * 8, self.pos_y * 8)
                spr(193, (self.pos_x + 2) * 8, self.pos_y * 8)
                spr(208, (self.pos_x + 1) * 8, (self.pos_y + 1) * 8)
                spr(209, (self.pos_x + 2) * 8, (self.pos_y + 1) * 8)
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
