
local type = type
local math = math
local table = table
local PI = math.pi

lua_tween = {}
local lua_tween = lua_tween

local tween_map = {}
local cur_tm

local function create_tween(during, udpate_func, setting)
    local tween = {}
    setting = setting or {}
    tween.udpate_func = udpate_func
    tween.complete_func = setting.complete_func
    tween.ease = setting.ease
    tween.punch_count = setting.punch_count
    tween.from_tm = cur_tm + (setting.delay or 0)
    tween.end_tm = tween.from_tm + during
    return tween
end

local function get_key(arg)
    local key
    if type(arg) == "userdata" then
        key = arg:GetInstanceID()
    else
        key = arg
    end
    return key
end

-- 新增的tween都记录在tween_map里
function lua_tween.add(object, during, udpate_func, setting)
    -- utils.begin_sample("zbq lua_tween.add")
    local key = get_key(object)
    tween_map[key] = tween_map[key] or {}
    local tween = create_tween(during, udpate_func, setting)
    table.insert(tween_map[key], tween)
    -- utils.end_sample()
end

-- 统一移除key上面所有的tween，销毁obj之前需保证tween已经移除
function lua_tween.remove(object)
    local key = get_key(object)
    tween_map[key] = nil
end

-- 遍历tween_map，驱动update
local empty_keys = {}
function lua_tween.update() --内存泄漏？
    local time = E.Time.time
    -- utils.begin_sample("zbq lua_tween.update")
    cur_tm = time
    table.clear(empty_keys)
    -- 防止在回调中移除tween导致的迭代器异常
    for key, tween_list in pairs(tween_map) do
        for i = #tween_list, 1, -1 do
            local tween = tween_list[i]
            if tween.udpate_func and tween.from_tm < time then
                -- update
                local progress = (time - tween.from_tm) / (tween.end_tm - tween.from_tm)
                progress = math.clamp(1, 0, progress)
                if tween.punch_count then
                    -- sin曲线 在-1到1之前回弹count次
                    local rad = progress * tween.punch_count * PI
                    progress = math.sin(rad)
                elseif tween.ease then
                    -- 采样ease
                    progress = CS.LuaBehaviour.SampleEase(progress, tween.ease)
                end
                tween.udpate_func(progress)
            end
            if tween.end_tm <= time then
                -- 时间结束
                if tween.complete_func then
                    -- 回调
                    tween.complete_func()
                end
                table.remove(tween_list, i)
            end
        end
        -- 记录需要移除的tween
        if #tween_list == 0 then
            table.insert(empty_keys, key)
        end
    end
    for k, v in pairs(empty_keys) do
        tween_map[v] = nil
    end
    -- utils.end_sample()
end

function lua_tween.init()
    -- 注册
    if not lua_tween.CS then
        lua_tween.CS = CS.LuaBehaviour.Create({ Update = lua_tween.update }, "lua_tween") 
    end
end

lua_tween.init()

return lua_tween
