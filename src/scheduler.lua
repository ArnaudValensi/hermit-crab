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
