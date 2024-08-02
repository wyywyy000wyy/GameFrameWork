local rpg_buff_taunt = class2("rpg_buff_taunt", T.rpg_buff, function(self, battle_ins, owner, eff_env, dur) 
    T.rpg_buff._ctor(self, RPG_ETY_INNER_BUFF.TAUNT_ID, battle_ins, owner, eff_env, dur)
end)

function rpg_buff_taunt:on_enter()
    T.rpg_buff.on_enter(self)
    self._ety:set_redirect_actor(self)
end

function rpg_buff_taunt:on_exit()
    self._ety:remove_redirect_actor(self)
    T.rpg_buff.on_exit(self)
end

function rpg_buff_taunt:redirect_target()
    return self._caster
end