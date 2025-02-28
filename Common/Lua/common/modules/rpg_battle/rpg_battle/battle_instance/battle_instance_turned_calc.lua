local battle_instance_turned_calc = class2("battle_instance_turned_calc", T.battle_instance_turned, function(self, battle_id, init_data)
    if init_data then
        local code, data = T.rpg_init_mod.create_init_data(init_data)
        init_data = data
    end
    T.battle_instance._ctor(self, battle_id, init_data)
end)

function battle_instance_turned_calc:start()
    local rpg_debug_mod = T.rpg_debug_mod(self)
    self:add_mod(rpg_debug_mod)

    local physics_mod = T.physics_mod(self)
    self:add_mod(physics_mod)

    local controller_mod = T.controller_mod(self)
    self:add_mod(controller_mod)

    local battle_mod = T.turn_based_battle_mod(self)
    self:add_mod(battle_mod)

    local record_mod = T.record_mod(self)
    self:add_mod(record_mod)

    local statistic_mod = T.statistic_mod(self)
    self:add_mod(statistic_mod)

    T.battle_instance.start(self)

    local fixed_dt = self._fixed_dt
    local max_battle_time = self._init_data.max_battle_time
    while not battle_mod._bfin do
        self:update(fixed_dt)
    end

    if not self._finish then
        self:stop()
    end
    -- while self._finish do
    --     self:update(fixed_time)
    -- end
end


