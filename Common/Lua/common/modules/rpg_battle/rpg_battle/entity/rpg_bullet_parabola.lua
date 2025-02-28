local rpg_bullet_parabola = class2("rpg_bullet_parabola", T.rpg_bullet, function(self, eff_env ,target_orient, bullet_param)
    T.rpg_bullet._ctor(self, eff_env, target_orient, bullet_param)
    local caster = eff_env.ety
    self._caster_eid = caster._eid
    local spos_x = caster._x
    local spos_y = caster._y

    local speed = self._param[1]
    self._orient = target_orient

    local dis = rpg_dis(spos_x,spos_y, target_orient._x, target_orient._y)
    local time = math.floor(dis / speed * 1000)

    self._st = self:get_time()
    self._et = self._st + time

    self._ins:post_event({
        id = RPG_EVENT_TYPE.BULLET, event_time = self._ins:get_btime(),
        oid = self._oid, pid = self._pid, eid = self._caster_eid,
        soid = self._eff_env.root_actor._oid,
        spos_x = spos_x, spos_y = spos_y,
        tpos_x = target_orient._x, tpos_y = target_orient._y,
        time = time
    })
end)

function rpg_bullet_parabola:actor_pos()
    return self._orient
end

T.rpg_bullet.type_map[RPG_BULLET_TYPE.PARABOLA] = rpg_bullet_parabola

function rpg_bullet_parabola:update()
    local ctime = self:get_time()
    if ctime >= self._et then
        self:do_effect(self._effect)

        self._ins:post_event({
            id = RPG_EVENT_TYPE.BULLET_END, event_time = self._ins:get_btime(),
            eff = self._eff_env.p_env.__eff_id,
            x = self._orient._x, y = self._orient._y,
            oid = self._oid, pid = self._pid, eid = self._caster_eid })

        return true --finish
    end
end
