local battle_instance_replay = class2("battle_instance_replay", T.battle_instance, function(self, battle_id, init_data)
    -- local code, data = T.rpg_init_mod.create_init_data(init_data)
    -- if code ~= resmng.E_OK then
    --     RPG_ERR('create_init_data failed, msg=%s', data)
    --     return
    -- end
    T.battle_instance._ctor(self, battle_id, init_data)
end)

function battle_instance_replay:set_verify_data(data)
    self._init_data.action_list = data.action_list
    self._init_data.event_list = data.event_list
end

function battle_instance_replay:set_battle_end_callback(callback)
    self._battle_end_callback = callback
end

function battle_instance_replay:start()
    if not self._init_data then
        RPG_ERR('start failed, no init_data')
        return
    end

    local battle_player_mod = T.battle_player_mod(self, RPG_PLAY_MODE.expedition)
    self:add_mod(battle_player_mod)
    self._battle_player_mod = battle_player_mod
    local statistic_mod = T.statistic_mod(self)
    self:add_mod(statistic_mod)

    T.battle_instance.start(self)
    self:post_event(self._init_data.init_event)
    return resmng.E_OK
end

function battle_instance_replay:skip()
    self._skip = true
    
    self:_finish_battle()
end

function battle_instance_replay:update(dt)
    -- 如果播放入场动画
    if self._battle_player_mod.is_play_entry_anim then
        return
    end

    local event_list = self._init_data.event_list

    local cur_action_idx = self.cur_action_idx or 1
    local rtime = self:get_rtime()
    for i = cur_action_idx, #event_list do
        local event = event_list[i]
        if event.rtime <= rtime then
            -- RPG_DEBUG("[RPG]%s do_action_%s id=%s", self:log_str(), i, action.id)
            self:post_event(event)
            cur_action_idx = i+1
        else
            if event.rtime < rtime then
                RPG_ERR("错误！！！！！！！")
                return resmng.E_FAIL, 'rtime error'
            end
            break
        end
    end
    self.cur_action_idx = cur_action_idx
    self._base.update(self, dt)

    if cur_action_idx >= #event_list and not self._is_finishing then
        self:_finish_battle()
    end
end

function battle_instance_replay:_finish_battle()
    if self._is_finishing then
        return
    end
    self._is_finishing = true
    self:post_event(self._init_data.end_event)
    -- self:finish()
    battle_end_cor = coroutine.start(
        function()
            coroutine.wait_sec(RPG_WIN_WAIT_SEC)
            if self._battle_end_callback then
                self._battle_end_callback (self._init_data.end_event)
            end
            -- VMState:push_item("ui_rpg_battle_result", T.ui_rpg_battle_result_arg(self._init_data.end_event))
        end
)
end