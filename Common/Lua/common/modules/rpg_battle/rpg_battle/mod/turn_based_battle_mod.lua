local turn_based_battle_mod = class2("turn_based_battle_mod", T.battle_mod, function(self, battle_instance)
    T.battle_mod._ctor(self, battle_instance)

    self.action_map = {}
end)

function turn_based_battle_mod:fixed_update(dt)
    self:check_rule()
    if self._real_time >= self._ins._init_data.max_battle_time * 3 then
        self._bfin = true
        return
    end
    if self._bfin then
        return
    end
    self._real_time = self._real_time + dt
    self._ins:make_log_str()
    if self._ins._bpause then
        self:check_timeout()
        return
    end

    -- self:sort_ety_list()
    local action_list = {}
    for _, ety in pairs(self._ety_list) do
        local action_data = self:get_action(ety._eid)
        if (action_data) then
            table.insert(action_list, action_data)
        end
    end
    self.cur_action_list = action_list
    local max_trun = 1000
    while #action_list > 0 do
        local action_data = action_list[#action_list]
        table.remove(action_list, #action_list)
        local contructor = T.rpg_action[action_data.id]
        local action = contructor(self._ins, action_data)
        action:on_enter()
        action:update()
        action:on_exit()
        max_trun = max_trun - 1
        if max_trun <= 0 then
            break
        end
    end 

    if self:check_timeout() then
        return
    end

    self.action_map = {}
end

function turn_based_battle_mod:excute_action(action_data)
    self.action_map[action_data._eid] = action_data
end

function turn_based_battle_mod:get_action(eid)
    local action_data = self.action_map[eid]
    -- if action_data == nil then
    --     action_data = T.action_data(self, eid)
    -- end
    return action_data
end