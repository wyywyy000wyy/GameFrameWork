local rpg_halo = class2("rpg_halo", T.rpg_buff, function(self,buff_id, battle_ins, owner, eff_env, time) 
    T.rpg_buff._ctor(self, buff_id, battle_ins, owner, eff_env, time)

end)

function rpg_halo:on_enter()
    self._ins:add_event_listener2(RPG_EVENT_TYPE.BORN, self, "on_entity_born")
    T.rpg_buff.on_enter(self)

end

function rpg_halo:on_entity_born(event)
    if event.ety_type ~= RPG_ETY_TYPE.HERO then
        return
    end
    local battle_mod = self._ins._battle_mod
    local ety = battle_mod:get_ety(event.eid)
    for _, eff_id in ipairs(self._enter_eff) do
        local eff_cfg = resmng.prop_rpg_battle_effect[eff_id]
        local eff_func = T.rpg_effect.effects[eff_cfg.Effect]
        local eff_param = eff_cfg._EffectParam
        if battle_mod:filter_target(ety, eff_cfg, self._eff_env, ety) then
            eff_func(self._eff_env, ety, eff_param)
        end
    end
end

function rpg_halo:on_exit()
    T.rpg_buff.on_exit(self)
    self._ins:remove_event_listener2(RPG_EVENT_TYPE.BORN, self, "on_entity_born")
end