local rpg_bullet_line = class2("rpg_bullet_line", T.rpg_bullet, function(self, eff_env ,target_orient, bullet_param)
    T.rpg_bullet._ctor(self, eff_env, target_orient, bullet_param)
    local caster = eff_env.ety
    self._caster_eid = caster._eid
    self._bullet_range = self._param[2]

    if self._hit_effect then
        local hit_cfg = resmng.prop_rpg_battle_effect[self._hit_effect[1]]
        self.TargetType = hit_cfg.TargetType
        self.Range = self._bullet_range
    end

    self._hit_map = {}
    self._hit_list = {}
    self._battle_mod = caster._ins._battle_mod


    local speed = self._param[1]

    self._spos_x = target_orient._sx or caster._x
    self._spos_y = target_orient._sy or caster._y
    self._epos_x = target_orient._x
    self._epos_y = target_orient._y
    local dis = rpg_dis(self._spos_x ,self._spos_y, target_orient._x, target_orient._y)
    local time = math.floor(dis / speed * 1000)

    local dir_x, dir_y = target_orient._dir_x, target_orient._dir_y--rpg_dir(self._spos_x ,self._spos_y, target_orient._x, target_orient._y)

    self._orient = {
        _x = self._spos_x,
        _y = self._spos_y,
        _dir_x = dir_x,
        _dir_y = dir_y
    }

    self._st = self:get_time()
    self._et = self._st + time

    self._ins:post_event({
        id = RPG_EVENT_TYPE.BULLET, event_time = self:get_time(),
        oid = self._oid, pid = self._pid, eid = self._caster_eid,
        soid = self._eff_env.root_actor._oid,
        spos_x = self._spos_x, spos_y = self._spos_y,
        tpos_x = target_orient._x, tpos_y = target_orient._y,
        time = time
    })
end)
T.rpg_bullet.type_map[RPG_BULLET_TYPE.LINE] = rpg_bullet_line

function rpg_bullet_line:actor_pos()
    return self._orient
end

function rpg_bullet_line:update()
    local ctime = self:get_time()

    -- RPG_DEBUG("[RPG]%s rpg_bullet_line_update:%s", self._ins:log_str(), ctime)

    local hit_eff = self._hit_effect
    if hit_eff then
        local orient = self._orient
        local p = rpg_invlerp(self._st, self._et, ctime)
        orient._x, orient._y = rpg_lerp_pos(self._spos_x, self._spos_y, self._epos_x, self._epos_y, p)

        local env = self._eff_env
        local hit_list = self._hit_list
        local curIdx  = #hit_list
        local hit_map = self._hit_map

        self._battle_mod:search_targets(self, env, orient, hit_list, function(ety)
            return not hit_map[ety._eid]
        end)

        for i = curIdx + 1, #hit_list do
            local ety = hit_list[i]
            hit_map[ety._eid] = true
            local no_search = self._eff_env.no_search
            self._eff_env.no_search = true
            self:do_effect(hit_eff, ety)
            self._eff_env.no_search = no_search
        end
    end

    if ctime >= self._et then        
        local _ = self._effect and self:do_effect(self._effect)

        self._ins:post_event({
            id = RPG_EVENT_TYPE.BULLET_END, event_time = self:get_time(),
            oid = self._oid, pid = self._pid, eid = self._caster_eid })
        
        return true --finish
    end
end