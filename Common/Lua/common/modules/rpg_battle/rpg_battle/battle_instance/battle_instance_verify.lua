local battle_instance_verify = class2("battle_instance_verify", T.battle_instance, function(self, battle_id, init_data, need_record)
    local code, data = T.rpg_init_mod.create_init_data(init_data)
    if code ~= resmng.E_OK then
        RPG_ERR('create_init_data failed, msg=%s', data)
        return
    end
    self._need_record = need_record
    T.battle_instance._ctor(self, battle_id, data)
end)

function battle_instance_verify:set_verify_data(data)
    self._init_data.action_list = data.action_list
    self._init_data.event_list = data.event_list
    self._init_data.result_data = data.result_data
end

function battle_instance_verify:start()
    if not self._init_data then
        RPG_ERR('start failed, no init_data')
        return
    end

    local rpg_debug_mod = T.rpg_debug_mod(self)
    self:add_mod(rpg_debug_mod)
    local physics_mod = T.physics_mod(self)
    self:add_mod(physics_mod)
    local battle_mod = T.battle_mod(self)
    self:add_mod(battle_mod)
    local statistic_mod = T.statistic_mod(self)
    self:add_mod(statistic_mod)
    if self._need_record then
        local record_mod = T.record_mod(self)
        self:add_mod(record_mod)
    end


    T.battle_instance.start(self)
    local action_list = self._init_data.action_list
    local fixed_dt = self._init_data.fixed_dt
    local max_real_time = self._init_data.max_battle_time

    local cur_action_idx = 1
    for rtime = fixed_dt, max_real_time, fixed_dt do
        self:update(fixed_dt)
        for i = cur_action_idx, #action_list do
            local action = action_list[i]
            if action.rtime <= rtime then
                -- RPG_DEBUG("[RPG]%s do_action_%s id=%s", self:log_str(), i, action.id)
                self:post_event(action)
                cur_action_idx = i+1
            else
                if action.rtime < rtime then
                    RPG_ERR("错误！！！！！！！")
                    return resmng.E_FAIL, 'rtime error'
                end
                break
            end
        end
    end

    -- TODO 校验容错空间
    -- local log_table = statistic_mod:log_table()
    -- local ret, result = table.cmp(log_table, self._init_data.result_data)
    -- if not ret then
    --     WARN('[battle_instance_verify] start, verify failed, \ncalc\n%s\nrecv\n%s'
    --     , stringify(result), stringify(self._init_data.result_data))
    -- end

    return resmng.E_OK
end
