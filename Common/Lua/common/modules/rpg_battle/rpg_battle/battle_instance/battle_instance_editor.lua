local battle_instance_editor = class2("battle_instance_editor", T.battle_instance, function(self, battle_id, init_data)
    T.battle_instance._ctor(self, battle_id, init_data)

    self.on_update = function()
        self:update(RPG_F2I(E.Time.deltaTime))
    end

    self.CS = T.LuaBehaviour.Create({ Update = self.on_update }, "battle_instance_editor")    
end)

function battle_instance_editor:start()
    local rpg_debug_mod = T.rpg_debug_mod(self)
    self:add_mod(rpg_debug_mod)

    local rpg_debug_view_mod = T.rpg_debug_view_mod(self)
    self:add_mod(rpg_debug_view_mod)

    local physics_mod = T.physics_mod(self)
    self:add_mod(physics_mod)

    local controller_mod = T.controller_mod(self)
    self:add_mod(controller_mod)

    local battle_mod = T.battle_mod(self)
    self:add_mod(battle_mod)

    local record_mod = T.record_mod(self)
    self:add_mod(record_mod)

    local statistic_mod = T.statistic_mod(self)
    self:add_mod(statistic_mod)

    -- local battle_player_mod = T.battle_player_mod(self)
    -- self:add_mod(battle_player_mod)

    T.battle_instance.start(self)

    -- local fixed_dt = self._fixed_dt
    -- local max_battle_time = self._init_data.max_battle_time
    -- while not battle_mod._bfin do
    --     self:update(fixed_dt)
    -- end

    -- if not self._finish then
    --     self:stop()
    -- end
    -- while self._finish do
    --     self:update(fixed_time)
    -- end


end

function battle_instance_editor:stop()
    T.battle_instance.stop(self)
    if self.CS then
        CS.Hugula.Framework.LuaBehaviour.Delete(self.CS)
        self.CS = nil
    end
end