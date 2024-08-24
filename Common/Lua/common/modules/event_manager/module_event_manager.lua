local module_event_manager = module_def("module_event_manager")


DIS_TYPE = DIS_TYPE or {}
local DIS_TYPE_mt = {

}
DIS_TYPE_mt.__index = function(t, k)
    return string.lower(k)
end

setmetatable(DIS_TYPE, DIS_TYPE_mt)

function module_event_manager:init()
    self._events = {}
end

function module_event_manager:post_event(event, ...)
    local t = self._events[event]
    if t then
        for i, v in ipairs(t) do
            v(event, ...)
        end
    end
end

function module_event_manager:add_event_handle(event, handle)
    self._events[event] = self._events[event] or {}
    table.insert(self._events[event], handle)
end

function module_event_manager:remove_event_handle(event, handle)
    if self._events[event] then
        for i, v in ipairs(self._events[event]) do
            if v == handle then
                table.remove(self._events[event], i)
                break
            end
        end
    end
end

function post_event(event, ...)
    PM.module_event_manager:post_event(event, ...)
end
