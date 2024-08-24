local task_safe_call = T.rpg_task.task_safe_call
local rpg_task_list = class2("rpg_task_list", function(self, task_name, ...)
    self._task_name = task_name
    self._task_queue = {...}
    -- self._finish_queue = {}
    self._cur_task_idx = 1
end)

function rpg_task_list:excute()
    if self._finish then
        return
    end
    self._started = true
    self._is_excute = true
    
    while true do
        local task = self._task_queue[self._cur_task_idx]
        if not task then
            self:finish()
            break
        end
        Logger.LogerWYY2("rpg_task_excute", self._task_name, self._cur_task_idx, task._task_name)
        if not task_safe_call(task, task.on_excute) then
            break 
        end
        if self._finish or self._is_restart then
            break
        end
        self._cur_task_idx = self._cur_task_idx + 1
    end

    self._is_excute = false
    if self._is_restart then
        self:restart()
    end
end

function rpg_task_list:do_next()
    if self._is_excute then
        return
    end
    self._cur_task_idx = self._cur_task_idx + 1
    self:excute()
end

function rpg_task_list:pre()
    return self._task_queue[self._cur_task_idx - 1]
end

function rpg_task_list:add(task)
    if self._started then
        table.insert(self._task_queue,self._cur_task_idx + 1, task)
    else
        table.insert(self._task_queue, task)
    end

    task._task_list = self
end

function rpg_task_list:add_finish_task(task)
    local finish_task_list = self._finish_task_list
    if not finish_task_list then
        finish_task_list = T.rpg_task_list("finish_task_list")
        self._finish_task_list = finish_task_list
    end
    finish_task_list:add(task)
end

function rpg_task_list:get_result(result_name)
    return self._result_map and self._result_map[result_name]
end

function rpg_task_list:set_result(result_name, ...)
    local result_map = self._result_map
    if not result_map then
        result_map = {}
        self._result_map = result_map
    end
    result_map[result_name] = {...}
end

function rpg_task_list:cancel()
    self:finish()
end

function rpg_task_list:_restart()
    self._finish = false
    self._cur_task_idx = 1
    self._result_map = nil
    for _, task in ipairs(self._task_queue) do
        task._finish = false
    end
end

function rpg_task_list:restart()
    if self._is_excute then
        self._is_restart = true
        return 
    end
    self:cancel()
    self._is_restart = false
    Logger.LogerWYY2("rpg_task_excute", self._task_name, "restart")

    self:_restart()

    local finish_task_list = self._finish_task_list
    if finish_task_list then
        finish_task_list:_restart()
    end
    self:excute()
end


function rpg_task_list:finish()
    if self._finish then
        return
    end
    Logger.LogerWYY2("rpg_task_excute", self._task_name, "finish")
    self._finish = true
    local finish_task_list = self._finish_task_list
    if finish_task_list then
        self._finish_task_list = nil
        finish_task_list:excute()
    end
end