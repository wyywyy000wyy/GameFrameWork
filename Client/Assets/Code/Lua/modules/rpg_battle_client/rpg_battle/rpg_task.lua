local rpg_task = T.rpg_task
local setmetatable = setmetatable
local tasks

local function error_hander(h)
    Logger.LogError(string.format("lua:%s \r\n %s", h, debug.traceback()))
end

if not rpg_task then
    rpg_task = {
        tasks = {},
        task_instances = {}
    }
    local task_instances = rpg_task.task_instances
    rpg_task.__index = rpg_task
    local _mt = {
        __index = function(rpg_task_instance, task_name)
            local a = 1
            local func = rpg_task[task_name]
            if func then
                return func
            end
            return rpg_task.next_task(rpg_task_instance, task_name)
        end,
    }
    local mt_task = {
        __index = function(rpg_task_instance, task_name)
            local func = rawget(rpg_task, task_name)
            if func then
                return func
            end
            return rpg_task.next_task(rpg_task_instance, task_name)
        end,
        __call =  function(_, task_name)
            local rpg_task_instance = setmetatable({}, _mt)
            if task_name then
                task_instances[task_name] = rpg_task_instance
            end
            return rpg_task_instance
        end
    }
    setmetatable(rpg_task, mt_task)
    T.rpg_task = rpg_task
end
tasks = rpg_task.tasks


function rpg_task.task_safe_call(rpg_task_instance, func)
    if not func then
        return true
    end
    local params = rpg_task_instance._params or {}
    local sus, ret = xpcall(func, error_hander, rpg_task_instance, unpack(params))
    if not sus then
        local task_list = rpg_task_instance._task_list
        if task_list then
            task_list:cancel()
        end
    end
    return ret
end

function rpg_task.wrapper(on_excute, on_finish)
    return function(...)
        local task = rpg_task()
        task._params = {...}
        task.on_excute = on_excute
        task.on_finish = on_finish
        return task
    end
end

local task_safe_call = rpg_task.task_safe_call

function rpg_task.next_task(_, task_name)
    local task_class = tasks[task_name]
    if not task_class then
        return nil
    end
    return function(rpg_task_instance,...)
        local task_name_11 = task_name
        -- rpg_task_instance = rpg_task_instance2 or rpg_task_instance
        local task = task_class(...)
        task._task_name = task_name
        rpg_task_instance:task_list():add(task)
        return task
    end
end

function rpg_task.task_list(rpg_task_instance)
    local task_list = rpg_task_instance._task_list
    if not task_list then
        task_list = T.rpg_task_list("task_list")
        rpg_task_instance._task_list = task_list
        task_list:add(rpg_task_instance)
    end
    return task_list
end


function rpg_task.excute(rpg_task_instance)
    local task_list = rpg_task_instance:task_list()
    task_list:excute()
    return rpg_task_instance
end

function rpg_task.set_result(rpg_task_instance, ...)
    rpg_task_instance._task_list:set_result(...)
end

function rpg_task.get_result(rpg_task_instance, result_name)
    local task_list = rpg_task_instance._task_list
    local result = task_list:get_result(result_name)
    if result then
        return unpack(result)
    end
end

-- function rpg_task.finish_task(rpg_task_instance, task_name, ...)
--     local task_class = tasks[task_name]
--     return function(rpg_task_instance,...)
--         local task_name_11 = task_name
--         local task = task_class(...)
--         rpg_task_instance:task_list():add_finish_task(task)
--         return task
--     end
-- end

function rpg_task.cancel(rpg_task_instance)
    local task_list = rpg_task_instance._task_list
    task_list:cancel()
end

function rpg_task.restart(rpg_task_instance)
    local task_list = rpg_task_instance._task_list
    task_list:restart()
end

function rpg_task.finish(rpg_task_instance, result_1, ...)
    if rpg_task_instance._finish then
        return
    end
    if result_1 then
        rpg_task_instance._result = {result_1, ...}
    end
    if rpg_task_instance.on_finish then
        task_safe_call(rpg_task_instance, rpg_task_instance.on_finish)
    end
    rpg_task_instance._finish = true
    if rpg_task_instance._task_list then
        rpg_task_instance._task_list:do_next()
    end
end

local rpg_promise = class2("rpg_promise", function(self, p1, ...)
    self._params = p1 and {p1, ...}
end)

function rpg_promise:resolve()

end
