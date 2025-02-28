local battle_instance_client = class2("battle_instance_client", T.battle_instance, function(self, battle_id, init_data)
    T.battle_instance._ctor(self, battle_id, init_data)
    local cur_level_prop = resmng.prop_rpg_battle_level[init_data.level_id]
    self.scene = T.rpg_battle_scene(cur_level_prop.Map)
end)


function battle_instance_client.save_battle_data(id, data, param_data)
    local serpent = require("serpent")
    local msg = serpent.block(data, {numformat = "%s", comment = false, maxlevel = 16})
    local param_msg = serpent.block(param_data, {numformat = "%s", comment = false, maxlevel = 16})
    local file_name =  "battle_data_" .. id .."__" .. os.date("%Y_%m_%d_%H_%M_%S", os.time()) .. ".txt"
    require("services.persistent").save_local_string(file_name, string.format("init_data=%s\ninited_data=%s", param_msg, msg))
end

function battle_instance_client.on_ReqRpgCreate(id, data)  
    data = g_custom_data or data
    Logger.LogerWYY("on_ReqRpgCreate",data)
    local _, init_Data = T.rpg_init_mod.create_init_data(data)
    if RPG_SAVE_BATTLE_DATA then
        battle_instance_client.save_battle_data(id, init_Data, data)
    end
    Logger.LogerWYY2("on_ReqRpgCreate",data)
    Logger.LogerWYY2("on_ReqRpgCreate2",init_Data)
    local ins = battle_instance_client(id, init_Data)
    ins:start()
    models.rpg_battle_model.set_cur_battle(ins)    
    return ins
end

function battle_instance_client:start()
    self.on_update = function()
        self:update(E.Time.deltaTime * 1000)
    end
    self.CS = CS.LuaBehaviour.Create({ Update = self.on_update }, "battle_instance_client") 
    
    local cur_scene = self.cur_scene
    if cur_scene and cur_scene._map_prop and cur_scene._map_prop.Music then
        PM.module_audio:post_event(cur_scene._map_prop.Music)
        PM.module_audio:post_event(cur_scene._map_prop.EnvMusic)
    end


    local controller_mod = T.controller_mod(self)
    self:add_mod(controller_mod)
    self.controller = controller_mod

   -- local rpg_debug_view_mod = T.rpg_debug_view_mod(self)
    --self:add_mod(rpg_debug_view_mod)

    local physics_mod = T.physics_mod(self)
    self:add_mod(physics_mod)

    local rpg_debug_mod = T.rpg_debug_mod(self)
    self:add_mod(rpg_debug_mod)
    
    -- if RPG_DEBUG_VIEW_MOD then
    --     local debug_view_mod = T.rpg_debug_view_mod(self)
    --     self:add_mod(debug_view_mod)
    -- end

    local conf = resmng.prop_rpg_battle_level[self._init_data.level_id]
    if conf.Type == 1001 then
        local td_born_mod = T.td_born_mod(self)
        self._td_born_mod = td_born_mod
        self:add_mod(td_born_mod)
        self._is_td_battle = true
    end
    
    local battle_mod = T.battle_mod(self)
    self:add_mod(battle_mod)
    
    local battle_player_mod = T.battle_player_mod(self, RPG_PLAY_MODE.expedition)
    self:add_mod(battle_player_mod)
    self._battle_player_mod = battle_player_mod

    local record_mod = T.record_mod(self)
    self:add_mod(record_mod)

    local statistic_mod = T.statistic_mod(self)
    self:add_mod(statistic_mod)
    
    T.battle_instance.start(self)

    self:add_event_listener2(RPG_EVENT_TYPE.BATTLE_END, self, "on_battle_end")
end

function battle_instance_client:on_battle_end(event_data)
    -- local result = self._record_mod._record
    -- result.id = event_data.bid
    -- result.result_type = event_data.win == 1 and  BattleResult.WIN or  BattleResult.FAIL
    -- result.result_str = self._statistic_mod:log_str()
    -- result.result_data = {
    --     teams = {}
    -- }
    -- for tid, team in ipairs(self._battle_mod._team_list) do
    --     local team_data = {}
    --     result.result_data.teams[tid] = team_data
    --     for _, hero_ety in ipairs(team._ety_list) do
    --         local hero_data = {}
    --         hero_data.hero_id = hero_ety._data.hero_id
    --         hero_data.pid = hero_ety._data.pid
    --         hero_data.fpos = hero_ety._fpos
    --         hero_data.hp = from_rpg_attr("RPG_Hp", hero_ety._p.RPG_Hp)
    --         hero_data.max_hp = from_rpg_attr("RPG_HpMax", hero_ety._p.RPG_HpMax)
    --         hero_data.anger = from_rpg_attr("RPG_Anger", hero_ety._p.RPG_Anger)
    --         hero_data.max_anger = from_rpg_attr("RPG_AngerMax", hero_ety._p.RPG_AngerMax)
    --         table.insert(team_data, hero_data)
    --     end
    -- end
    -- --Logger.LogerWYY2("on_battle_end__",result.result_data)
    -- -- todo 数据太大，导致协议超过限制，暂时不发
    -- -- result.action_list = nil
    -- -- result.battle = nil
    -- result.event_list = nil


        
    -- 战斗结束之后等待角色死亡动画播放完成，再弹出结算界面
    battle_end_cor = coroutine.start(
            function()
                coroutine.wait_sec(RPG_WIN_WAIT_SEC)
                -- models.rpg_battle_model.set_battle_data(self._bid,self:get_result_data(true))

                local result = self:get_result_data(true)
                -- result.result_str = nil
                if not self._need_record then
                    result.event_list = nil
                    result._ety_infos = nil
                end

                if self._battle_end_callback then
                    return self._battle_end_callback(result)
                end

                -- -- 根据结算消息，弹结算面板
                -- Rpc:reqRpgResult(result, function(data)
                --     -- models.rpg_battle_model.net_disconnect()
                --     models.rpg_battle_model.request_battle_result(data)
                -- end,function()
                --     models.rpg_battle_model.net_disconnect()
                -- end)
            end
    )
    
end

function battle_instance_client:set_battle_end_callback(callback)
    self._battle_end_callback = callback
end


function battle_instance_client:stop()
    -- 没有结算
    if self.CS then
        CS.LuaBehaviour.Delete(self.CS)
        self.CS = nil
    end
    if not self._battle_mod._bfin then
        local result = {}
        result.result_type = BattleResult.NONE     
        result.id = self._bid
        Rpc:reqRpgResult(result)
    end
    PM.module_audio:post_event("Stop_Amb_Expedition")
    self._base.stop(self)  
    local result = self:get_result_data(true)  
    models.rpg_battle_model.set_battle_data(self._bid,result)
end

function battle_instance_client:update(dt)
    -- 如果播放入场动画
    if self._battle_player_mod.is_play_entry_anim then
        return
    end
        
    self._base.update(self, dt)
end

-- function battle_instance_client:update(dt)
-- end

-- function battle_instance_client:update(dt)

-- end

