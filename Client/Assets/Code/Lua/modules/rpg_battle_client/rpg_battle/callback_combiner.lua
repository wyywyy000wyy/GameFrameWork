---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by weizheng.
--- DateTime: 2023/1/4 13:39
--- 回调组合器
---     执行流程中有多个分支需要异步执行，所有逻辑执行完成之后给一个统一的回调

GN.NS_callback_combiner = GN.NS_callback_combiner or {}
local NS_callback_combiner = GN.NS_callback_combiner

NS_callback_combiner.callback_combiner = NS_callback_combiner.callback_combiner or {}
local callback_combiner = NS_callback_combiner.callback_combiner

local function gen_callBack(combiner)
    local callBack = function(callBack)
        table.remove_item(combiner.callback_list, callBack)
        if #combiner.callback_list == 0 and combiner.on_completed ~= nil then
            combiner.on_completed()
        end
    end

    table.insert(combiner.callback_list, callBack)
    return callBack
end

function callback_combiner.gen_combiner()
    local combiner = {}
    combiner.callback_list = {}
    combiner.on_completed = nil
    combiner.gen_callBack = gen_callBack
    return combiner
end

return callback_combiner