local rpg_debug_wrapper = class2("rpg_debug_wrapper", function(self, class_name) 
    self._class_name = class_name
end)

function rpg_debug_wrapper:construct(...)
    local obj = T[self._class_name](...)
    self._obj = obj

    local t = {}
    local mt = {
        __index = function(t, k)
            local v = obj[k]
            if type(v) == "function" then
                local pre_hook = self[k .. "_pre"]
                local post_hook = self[k]
                if pre_hook or post_hook then
                    v = function(...)
                        if pre_hook then
                            pre_hook(...)
                        end
                        local ret = {v(...)}
                        if post_hook then
                            post_hook(...)
                        end
                        return unpack(ret)
                    end
                end
                return v
            end
        end,
        __newindex = function(t, k, v)
            obj[k] = v
        end,
    }
    setmetatable(t, mt)
    return t
end

