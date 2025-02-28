local rpg_bullet_target = class2("rpg_bullet_target", T.rpg_bullet, function(self, eff_env ,target_orient, bullet_param)
    T.rpg_bullet._ctor(self, eff_env, target_orient, bullet_param)
    local caster = eff_env.ety
    self._caster_eid = caster._eid
    local spos_x = caster._x
    local spos_y = caster._y

    local speed = self._param[1]
    local config_time = self._param[2]
    self._eff_env.no_search = true
    if self._param[2] then
        local to = {
            _x = target_orient._x,
            _y = target_orient._y,
            _dir_x = target_orient._dir_x,
            _dir_y = target_orient._dir_y,
            _sx = target_orient._sx,
            _sy = target_orient._sy,
            _seid = target_orient._seid,
            _eid = target_orient._eid,
            _off_len_x = target_orient._off_len_x,
            _off_len_y = target_orient._off_len_y,
        }
        target_orient = to
    end
    local dis = rpg_dis(spos_x,spos_y, target_orient._x, target_orient._y)
    local time = config_time or math.floor(dis / speed * 1000)

    self._st = self:get_time()
    self._et = self._st + time
    self._orient = target_orient
    self._ins:post_event({
        id = RPG_EVENT_TYPE.BULLET, event_time = self._ins:get_btime(), oid = self._oid,
        soid = self._eff_env.root_actor._oid,
        pid = self._pid, eid = self._caster_eid,
        target = target_orient._eid,
        spos_x = spos_x, spos_y = spos_y,
        tpos_x = target_orient._x, tpos_y = target_orient._y,
        time = time
    })    
end)

T.rpg_bullet.type_map[RPG_BULLET_TYPE.TARGET] = rpg_bullet_target

function rpg_bullet_target:actor_pos()
    return self._orient
end

function rpg_bullet_target:update()
    local ctime = self:get_time()
    if ctime >= self._et then
        local target = self._ins._battle_mod:get_ety(self._orient._eid)
        self._orient._sx = nil
        self._orient._sy = nil

        if target then
            self._orient._x = target._x
            self._orient._y = target._y
        end
        self:do_effect(self._effect, self._orient)

        self._ins:post_event({
            id = RPG_EVENT_TYPE.BULLET_END, event_time = self._ins:get_btime(),
            eff = self._eff_env.p_env.__eff_id,
            x = self._orient._x, y = self._orient._y,
            target = self._orient._eid,
            oid = self._oid, pid = self._pid, eid = self._caster_eid })

        return true --finish
    end
end
