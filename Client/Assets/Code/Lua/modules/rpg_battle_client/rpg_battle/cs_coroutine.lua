local UnityEngine = CS.UnityEngine
local Hugula = CS.Hugula
local table = table
local setmetatable = setmetatable
local cs_coroutine_runner

local coroutine = coroutine
local function on_cort_end(cort)
    cort.cs_cort = nil
    cort.lua_cort = nil
    cort.Current = nil
end

local FUNC_END = -1
local generator_mt = {
    __index = {
        MoveNext = function(self)
            local succ, cur_ienum = coroutine.resume(self.lua_cort)
            if not succ then
                local msg = string.format("%s\n%s", cur_ienum, self.lua_cort)--table.concat(Logger.add_thread_traceback_href(self.lua_cort)))
                error(msg, 2)
            end
            if cur_ienum == FUNC_END then
                -- call_wait_cort(self)
                on_cort_end(self)
                return false
            else
                self.Current = cur_ienum
                return true
            end
        end,
        Reset = function(self, func)
            local wrap_func = function()
                func()
                return FUNC_END
            end
            self.lua_cort = coroutine.create(wrap_func)
        end
    }
}

local function gen_ienum(func)
    local ienum = {}
    setmetatable(ienum, generator_mt)
    ienum:Reset(func)
    return ienum
end

---------------------coroutine-------------------------

-- 开始
function coroutine.start(func)
    local ienum = gen_ienum(func)
    ienum.cs_cort = cs_coroutine_runner:StartCoroutine(ienum)
    return ienum
end

--停止协程
function coroutine.stop(cort)
    if cort and cort.cs_cort then
        cs_coroutine_runner:StopCoroutine(cort.cs_cort)
        on_cort_end(cort)
    end
end

-- 等几秒
function coroutine.wait_sec(seconds)
    seconds = seconds or 1
    coroutine.yield(CS.Main.GetWaitForSec(seconds)) --内存泄漏
end

-- 等几帧
function coroutine.wait_frame(frames)
    if not frames or frames == 1 then
        coroutine.yield()
    else
        coroutine.yield(CS.Main.GetWaitForFrame(frames))
    end
end


local function init()
    local go = UnityEngine.GameObject.Find("Main")
    cs_coroutine_runner = go:GetComponent(typeof(CS.Main))
end

init()
return coroutine
