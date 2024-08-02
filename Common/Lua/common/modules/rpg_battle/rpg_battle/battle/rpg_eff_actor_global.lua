local rpg_eff_actor_global = class2("rpg_eff_actor_global", T.rpg_effect_actor, function(self, battle_ins, ety)
    T.rpg_effect_actor._ctor(self, battle_ins,ety)
    self.rpg_tmp_effect_env = {
        ins = battle_ins,
        ety = ety,
        actor = self,
        root_actor = self,
        level = 1,
        no_search = true
    }

end)

function rpg_eff_actor_global:do_effect_ids(start_effts)
    local rpg_tmp_target_orient = self.rpg_tmp_effect_env.ety
    T.rpg_effect.do_effect_ids(self.rpg_tmp_effect_env,
    rpg_tmp_target_orient,
    start_effts,
    1)
end
