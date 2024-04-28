-- local action = class("action",T.task)

function action_def(name, ...)
    local params = {}
    local _params = {...}
    for i, t in ipairs(_params) do
        params[i] = PD(t, "p" .. i)
    end

    local action_class = task_def(name, function(action, ...)
        local module = TM.actions[name]
        return module[name](module, action, ...)
    end, params)
    return action_class
end

AD = action_def
