local rpg_bullet_chain = class2("rpg_bullet_chain", T.rpg_bullet, function(self, eff_env ,target_orient, bullet_param)
    T.rpg_bullet._ctor(self, eff_env, target_orient, bullet_param)
    local caster = eff_env.ety

    self._speed = self._param[1]
    self._cnt = self._param[2]
    self._hit_cnt = 0
    self._nt = self:get_time()
    self._caster_eid = caster._eid
    self._cur_x = caster._x
    self._cur_y = caster._y

    local target_ety = self._ins._battle_mod:get_ety(target_orient._eid)
    self._target_team = self._ins._battle_mod._team_list[target_ety._tid]

    self:next_target(target_orient)
end)

T.rpg_bullet.type_map[RPG_BULLET_TYPE.CHAIN] = rpg_bullet_chain

function rpg_bullet_chain:get_next_target()
    local cur_target = self._target
    return T.battle_mod.get_nearest_target(self._target_team, cur_target)
end

function rpg_bullet_chain:next_target(target)
    local cur_x,cur_y = self._cur_x,self._cur_y
    local dis = rpg_dis(self._cur_x,self._cur_y, target._x, target._y)
    self._target = target
    self._cur_x,self._cur_y = target._x, target._y
    local time = math.floor(dis / self._speed * 1000)
    self._ct = self._nt
    self._nt = self._ct + time

    self._ins:post_event({
        id = RPG_EVENT_TYPE.BULLET, event_time = self._ins:get_btime(),
        soid = self._eff_env.root_actor._oid,
        oid = self._oid, pid = self._pid, eid = self._caster_eid,
        spos_x = cur_x, spos_y = cur_y,
        tpos_x = target._x, tpos_y = target._y,
        time = time
    })
end

function rpg_bullet_chain:actor_pos()
    return self._target
end

function rpg_bullet_chain:update()
    local ct = self:get_time()
    while ct >= self._nt do
        self._hit_cnt = self._hit_cnt + 1
        self:do_effect(self._hit_effect, self._target)
        if self._hit_cnt >= self._cnt then
            self._ins:post_event({
                id = RPG_EVENT_TYPE.BULLET_END, event_time = self:get_time(),
                oid = self._oid, pid = self._pid, eid = self._caster_eid })
            
            return true
        end
        local target = self:get_next_target()
        if not target then
            self._ins:post_event({
                id = RPG_EVENT_TYPE.BULLET_END, event_time = self:get_time(),
                oid = self._oid, pid = self._pid, eid = self._caster_eid })            
            return true
        end
        self:next_target(target)
    end
end