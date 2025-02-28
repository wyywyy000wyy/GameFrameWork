local RPG_F2I = RPG_F2I
local RPG_SAVE_CALL = RPG_SAVE_CALL
local battle_instance = class2("battle_instance", function(self, battle_id, init_data)
    self._bid = battle_id
    self._mods = {}
    self._init_data = init_data

    self._speed = 1 -- 战斗播放速度
    self._evt_listeners = {}
    self._time = 0
    self._init_finish = false
    self._pause = false
    self._skip = false -- 是否跳过战斗
    -- local conf = resmng.prop_rpg_battle_level[init_data.level_id]

    self._anger_pause = false --conf and conf.Type == DungeonMode.RPG_ARENA

    self._fixed_dt = init_data.fixed_dt
    self._fixed_time = 0
    self._fixed_list = {}
    self._fixed_list_order = {}
    self._update_list = {}
    self._auto_skill = init_data.auto_skill    

    self._oid_idx = 1000

    self._real_time = 0
    self._btime = 0


    self._finish = false
    self:make_log_str()
end)

function battle_instance:new_oid()
    self._oid_idx = self._oid_idx + 1
    return self._oid_idx
end

function battle_instance.init()
end

function battle_instance:make_log_str()
    self._log_str = string.format("bid=%s btime=%s rtime=%s", self._bid, self:get_btime(), self:get_rtime())
end

function battle_instance.create_main_level_data(level_id, player)
    -- return init_data {}
end

function battle_instance:log_str()
    -- return self._log_str

    -- local cstr = string.format("bid=%s btime=%s rtime=%s", self._bid, self:get_btime(), self:get_rtime())
    -- if self._log_str ~= cstr then
    --     RPG_ERR("[RPG]%s make_log_str err", cstr)
    -- end
    return self._log_str 
end

function battle_instance.create_battle(battle_id, param)
    return T.battle_instance_calc(battle_id, param)

    -- if param.run_type == RPG_RUN_TYPE.CLIENT then
    --     -- controller
    --     -- battle
    --     -- client_player
    --     rpg_ins = T.battle_instance_(param)
    --     battle_instance.create_client_battle(rpg_ins, param)
    -- elseif param.run_type == RPG_RUN_TYPE.SERVER then
    --     -- battle
    --     -- 统计模块
    --     -- record模块
    -- elseif param.run_type == RPG_RUN_TYPE.REPLAY then
    --     -- record模块
    --     -- client_player
    -- end
end

function battle_instance:listening(event_id)
    local list = self._evt_listeners[event_id]
    return list and next(list) and true 
end

function battle_instance:add_event_listener(event_id, func)
    self._evt_listeners[event_id] = self._evt_listeners[event_id] or {}
    table.insert(self._evt_listeners[event_id], func)
end

function battle_instance:add_event_listener2(event_id,listener,func_name)
    local f = function(event)
        listener[func_name](listener, event)
    end
    listener["ins_"..func_name] = f
    self:add_event_listener(event_id, f)
end

function battle_instance:remove_event_listener(event_id, func)
    local list = self._evt_listeners[event_id]
    if list then
        for i, f in ipairs(list) do
            if f == func then
                table.remove(list, i)
                break
            end
        end
    end
end

function battle_instance:remove_event_listener2(event, listener,func_name)
    local fn = "ins_"..func_name
    local f = listener[fn]
    listener[fn] = nil
    self:remove_event_listener(event, f)
end

function battle_instance:bpause(pause)
    self._bpause = pause
end

function battle_instance:post_event2(event_id, event)
    event.rtime = self:get_rtime()
    local listeners = self._evt_listeners[event_id]
    if listeners then
        for _, listen_func in ipairs(listeners) do
            RPG_SAVE_CALL(listen_func, event)
        end
    end
end

function battle_instance:post_event(event)
    event.rtime = self:get_rtime()
    local listeners = self._evt_listeners[event.id]
    if listeners then
        for _, listen_func in ipairs(listeners) do
            RPG_SAVE_CALL(listen_func, event)
        end
    end
end

function battle_instance:add_action_listener(action, func)

end

function battle_instance:remove_action_listener(action, func)

end

function battle_instance:post_action(action)
end


function battle_instance:add_mod(mod)
    table.insert(self._mods, mod)
end


function battle_instance:start()
    RPG_LOG("[RPG]%s battle_instance start", self:log_str())
    -- self:add_event_listener(finish_event_id, function(event)
    --     self:start()
    -- end
    -- )

    for k, mod in ipairs(self._mods) do
        -- if mod.fixed_update then
        --     self:add_fixed_update("", function (dt)  mod:fixed_update(dt) end)
        -- end
        RPG_LOG("[RPG]%s MOD_REG %s ", self:log_str(), mod._cls_name)
        mod:register_listener()
    end

    for k, mod in ipairs(self._mods) do
        RPG_LOG("[RPG]%s MOD_INIT %s ", self:log_str(), mod._cls_name)
        mod:init()
    end
end

-- 设置战斗播放速度
function battle_instance:set_speed(speed)
    if speed < 0 or speed > 20 then
        return
    end
    
    self._speed = speed
end

function battle_instance:stop()
    if self._finish then
        RPG_ERR("[RPG]%s battle_instance already finish", self:log_str())
        return
    end
    for k, mod in ipairs(self._mods) do
        RPG_LOG("[RPG]%s MOD_STOP %s ", self:log_str(), mod._cls_name)
        mod:stop()
    end
    self._finish = true
    RPG_LOG("[RPG]%s battle_instance stop", self:log_str())
end

function battle_instance:init_phase()
    if self._init_finish then
        return
    end

    if #self._mods == 0 then
        return
    end
    
    for _, mod in ipairs(self._mods) do
        if not mod:init_finish() then
            return
        end
    end
    self._init_finish = true
    for _, mod in ipairs(self._mods) do
        RPG_LOG("[RPG]%s MOD_START %s ", self:log_str(), mod._cls_name)
        mod._started = true
        mod:start()
    end
end

function battle_instance:pause()
    self._pause = true
end

function battle_instance:resume()
    self._pause = false
end

function battle_instance:add_fixed_update(update, order_name)
    if order_name then
        local order = _RPG_FIXED_UPDATE_MAP[order_name]
        self._fixed_list_order[update] = order;
        local pos = 0
        for i, func in ipairs(self._fixed_list) do
            local corder = self._fixed_list_order[func]
            if corder > order then
                break 
            end
            pos = i
        end
        table.insert(self._fixed_list , pos + 1, update)
    else
        self._fixed_list_order[update] = -1

        table.insert(self._fixed_list , update)
    end
end

function battle_instance:get_btime()
    return self._btime --self._battle_mod and self._battle_mod._time or -1
end

function battle_instance:get_rtime()
    return self._real_time --self._battle_mod and self._battle_mod._real_time or self._real_time
end


function battle_instance:get_result_data(copy)
    local result = table.clone(self._record_mod._record, copy)
    local event_list = result.event_list
    local finish_event_data = result.end_event
    if not finish_event_data then
        return nil
    end

    result.id = finish_event_data.bid
    result.result_type = finish_event_data.win == 1 and  BattleResult.WIN or  BattleResult.FAIL
    result.result_str = self._statistic_mod:log_str()
    result.result_data = {
        teams = {}
    }
    for tid, team in ipairs(self._battle_mod._team_list) do
        local team_data = {}
        result.result_data.teams[tid] = team_data
        for _, hero_ety in ipairs(team._ety_list) do
            local hero_data = {}
            hero_data.hero_id = hero_ety._data.hero_id
            hero_data.pid = hero_ety._data.pid
            hero_data.fpos = hero_ety._fpos
            hero_data.hp = from_rpg_attr("RPG_Hp", hero_ety._p.RPG_Hp)
            hero_data.max_hp = from_rpg_attr("RPG_HpMax", hero_ety._p.RPG_HpMax)
            hero_data.anger = from_rpg_attr("RPG_Anger", hero_ety._p.RPG_Anger)
            hero_data.max_anger = from_rpg_attr("RPG_AngerMax", hero_ety._p.RPG_AngerMax)
            table.insert(team_data, hero_data)
        end
    end
    result._ety_infos = self._statistic_mod._ety_infos
    --Logger.LogerWYY2("on_battle_end__",result.result_data)
    -- todo 数据太大，导致协议超过限制，暂时不发
    -- result.action_list = nil
    -- result.battle = nil
    -- result.event_list = nil
    -- result.result_str = nil
    return result
end

---dt = 5000
---50
--- 5000 / 50
function battle_instance:update(dt_ms)
    if self._finish then
        return
    end
    if not self._init_finish then
        self:init_phase()
        if not self._init_finish then
            return
        end
        self:post_event({ id = RPG_EVENT_TYPE.BATTLE_START, event_time = self:get_btime() })
    end

    if self._pause then
        return
    end
    local ms_dt = dt_ms * self._speed
    self._time = self._time + ms_dt
    
    -- RPG_DEBUG("[RPG]%s battle_instance update time=%s _fixed_time=%s", self:log_str(), self._time, self._fixed_time)
    while self._fixed_time < self._time do
        self._fixed_time = self._fixed_time + self._fixed_dt
        self._real_time = self._real_time + self._fixed_dt
        if not self._bpause then
            self._btime = self._btime + self._fixed_dt
        end
        -- RPG_DEBUG("[RPG]%s fixed_update fixed_time=%s", self:log_str(), self._fixed_time)
        for _, fixed_update in ipairs(self._fixed_list) do
            -- RPG_DEBUG("[RPG]%s fix_update__ %s time=%s", self:log_str(), fixed_update[2], self._fixed_time)
            fixed_update(self._fixed_dt)
        end 
    end

    for _, mod in ipairs(self._mods) do
        mod:update(ms_dt)
    end
    -- check 
end

-- 跳过战斗，直接结算
function battle_instance:skip()
    self._skip = true
    
    while not self._battle_mod._bfin do
        self:update(self._fixed_dt)
    end
end

-- 获取战斗结束倒计时时间
function battle_instance:get_count_down_time()
    return self._init_data.max_battle_time - self:get_btime()
end

-- client._logic_time = 0
-- client._display_time = 0
-- client._eventList = {}

-- ---dt = 5000
-- function client:update(dt)
--     -- client._logic_time = client._logic_time  + dt --5000

--     client._display_time = client._logic_time + x

--     for _,event in ipairs(client._eventList) do
--         if client._display_time  < event.startTime then
--             return
--         end 
--         clientlogic(event)
--     end
-- end
