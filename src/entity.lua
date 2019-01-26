function require_entity()

    local entities = {
        ["goal"] = {
            frames = {192},
            update = function(self, player, level)
            end,
            draw = function(self)
                spr(116, self.pos_x * 8, (self.pos_y + 1) * 8)
                spr(192, (self.pos_x + 1) * 8, self.pos_y * 8)
                spr(193, (self.pos_x + 2) * 8, self.pos_y * 8)
                spr(208, (self.pos_x + 1) * 8, (self.pos_y + 1) * 8)
                spr(209, (self.pos_x + 2) * 8, (self.pos_y + 1) * 8)
            end
        },
        ["round_shell"] = {
            frames = {33, 34},
            update = function(shell, player, level)

            end,
            draw = function(shell)
                shell.animtick -= 1
                if shell.animtick <= 0 then
                    shell.sprite_idx = (shell.sprite_idx) % #(shell.frames) + 1
                    shell.animtick = 5
                end
                spr(shell.frames[shell.sprite_idx], shell.pos_x * 8, shell.pos_y * 8)
            end
        }
    }

    local function new_entity(x, y, entity_type)
        local _factory = entities[entity_type]

        return {
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
