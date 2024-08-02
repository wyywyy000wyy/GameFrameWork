local mod_base = class2("mod_base", function(self, battle_instance)
    self._ins = battle_instance
    self._started = false
    self._init_data = battle_instance._init_data.battle
    self._init_completed = false
end)

--模块数据初始化，战斗数据构造完成之后调用
function mod_base:init()
    -- 各个模块根据战斗数据做初始化
    self._init_completed = true
end

-- 每帧检查
function mod_base:init_finish()
    return self._init_completed
end

function mod_base:start()
    
end

function mod_base:register_listener()
    
end

function mod_base:remove_listener()
    
end

-- function mod_base:pause()
-- end

-- function mod_base:resume()
-- end

--有 update 会自己调用
function mod_base:update(dt)
end

-- function mod_base:fixed_update()
-- end

function mod_base:stop()
end