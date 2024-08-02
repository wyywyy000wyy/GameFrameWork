local rpg_bullet = class2("rpg_bullet", T.rpg_effect_actor, function(self, eff_env, target_orient, param)
    local battle_ins = eff_env.ety._ins
    self._eff_env = {
        ins = battle_ins,
        ety = eff_env.ety,
        actor = self,
        root_actor = eff_env.root_actor,
        is_anger = eff_env.is_anger,
        level = eff_env.level + 1,
        p_env = eff_env
    }
    T.rpg_effect_actor._ctor(self, battle_ins,eff_env.ety)
    self._actor_type = RPG_EFFECT_ACTOR.BULLET
    self._target_orient = target_orient
    local bullet_type = param[1]
    local bullet_param = param[2]
    local effect = param[3]
    local hit_effect = param[4]
    self._type = bullet_type
    self._param = bullet_param
    self._effect = effect
    self._hit_effect = hit_effect
    self._is_anger = self._eff_env.is_anger
    self._pid = param.cfg.ID
    self._lv = eff_env.root_actor._lv

    local is_anger = self._eff_env.is_anger
    if is_anger then
        battle_ins._battle_mod:add_rupdate(self)
    else
        battle_ins._battle_mod:add_bupdate(self)
    end
end)

rpg_bullet.type_map = rpg_bullet.type_map or {}

function rpg_bullet:get_time()
    return self._is_anger and self._ins:get_rtime() or self._ins:get_btime()
end

function rpg_bullet:do_effect(eff_ids, target)
    T.rpg_effect.do_effect_ids(self._eff_env, target or self._target_orinet, eff_ids)
end

-----------------子弹目前不支持记录
function rpg_bullet:add_record(record)
end
