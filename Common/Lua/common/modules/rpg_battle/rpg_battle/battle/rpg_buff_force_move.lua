local rpg_buff_force_move = class2("rpg_buff_force_move", T.rpg_buff, function(self, battle_ins, owner, speed, dur, move_type, eff_env, target_orient, cross) 
    local caster = eff_env.ety
    self._sx, self._sy = owner._x, owner._y
    local dir_x, dir_y
    local physics_mod = battle_ins._physics_mod

    --if caster ~= owner then
    --    move_type = RPG_FORCE_MOVE_TYPE.TANGENT_DIR
    --end

    if move_type == RPG_FORCE_MOVE_TYPE.CASTER_TO_TARGET_DIR then --面朝释放者反朝向 
        dir_x, dir_y = rpg_dir(caster._x, caster._y, self._sx, self._sy)
        local dis = dur * speed
        local _ex = self._sx + dir_x * dis
        local _ey = self._sy+ dir_y * dis
        self._ex, self._ey = physics_mod:knockback(self._sx, self._sy, _ex, _ey, dis, owner._p.RPG_Radius, cross)
    elseif move_type == RPG_FORCE_MOVE_TYPE.CASTER_DIR then --释放者朝向
        dir_x, dir_y = caster._dir_x, caster._dir_y
        local dis = dur * speed
        local _ex = self._sx + dir_x * dis
        local _ey = self._sy+ dir_y * dis
        self._ex, self._ey =  physics_mod:knockback(self._sx, self._sy, _ex, _ey, dis, owner._p.RPG_Radius, cross)
    elseif move_type == RPG_FORCE_MOVE_TYPE.MOVE_TO_TARGET_POS then --
        local target = battle_ins._battle_mod:get_ety(target_orient._eid)
        self._target = target
        self.is_anger = eff_env.is_anger
        self._off_len_x = target_orient._off_len_x
        self._off_len_y = target_orient._off_len_y
        local _ex = self._target._x + target._dir_x * self._off_len_x
        local _ey = self._target._y + target._dir_y * self._off_len_y
        local end_gx, end_gy = rpg_b2g(_ex, _ey)
        if not physics_mod:empty(end_gx, end_gy, owner._eid, owner._p.RPG_Radius) then
            local tgx,tgy = rpg_b2g(target._x, target._y)
            local empty_x, empty_y = physics_mod:get_empty_pos(tgx,tgy)
            if empty_x then
                end_gx, end_gy = empty_x, empty_y
            end
        end
        self._ex, self._ey = rpg_g2b(end_gx, end_gy)
        local dis = rpg_dis(self._sx, self._sy, self._ex, self._ey)
        dur = dis/speed   ---------------------------位移到指定目标的时间是算出来的
        eff_env.actor:wait(dur)
    elseif move_type == RPG_FORCE_MOVE_TYPE.CASTER_POS then --
        local _ex, _ey = caster._x, caster._y
        local dis = rpg_dis(self._sx, self._sy, _ex, _ey)
        dis = dis - owner._p.RPG_Radius - caster._p.RPG_Radius
        self._ex, self._ey = physics_mod:knockback(self._sx, self._sy, _ex, _ey, dis, owner._p.RPG_Radius, cross)
    elseif move_type == RPG_FORCE_MOVE_TYPE.TANGENT_DIR then
        local rand = battle_ins._battle_mod._rand
        local dir_func = rand:range(2) == 1 and rpg_left_dir or rpg_right_dir
        dir_x, dir_y = dir_func(caster._dir_x, caster._dir_y)
        local dis = dur * speed
        local _ex = self._sx + dir_x * dis + caster._dir_x * 0.1
        local _ey = self._sy+ dir_y * dis + caster._dir_y * 0.1
        self._ex, self._ey =  physics_mod:knockback(self._sx, self._sy, _ex, _ey, dis, owner._p.RPG_Radius, cross)
    end
    local move_dir_x, move_dir_y = rpg_dir(self._sx, self._sy, self._ex, self._ey)
    owner:set_dir(move_dir_x, move_dir_y)

    T.rpg_buff._ctor(self, RPG_ETY_INNER_BUFF.FORCE_ID, battle_ins, owner, eff_env, dur)
    -- self._ety._x, self._ety._y = self._ex, self._ey
    self._speed = speed
    self._target_orient = target_orient
    self._move_type = move_type
end)

function rpg_buff_force_move:on_enter()
    -- Logger.LogerWYY2("[RPG] rpg_buff on_enter", self._id, self._ety._eid)
    self._ety:add_group(RPG_DEFAULT_GROUP.FORCE_MOVE, self)
    self._ety._rpg_buff_force_move = self

    local e = { 
        id = RPG_EVENT_TYPE.BUFF, 
        event_time = self:get_time(), 
        oid = self._eff_env.p_env.actor._oid,
        owner = self._ety._eid,
        buff = self._id,
        -- dur = self._dur,
        et = self._et,
        ex = self._ex,
        ey = self._ey,
        force_move = true,
    }

    -- if self._move_type == RPG_FORCE_MOVE_TYPE.MOVE_TO_TARGET_POS then
    --     e.target = self._target._eid
    --     e.off_len_x = self._off_len_x
    --     e.off_len_y = self._off_len_y
    -- end
    self._ins:post_event(e)
end

function rpg_buff_force_move:on_tick()
    local p = rpg_invlerp(self._st, self._et, self:get_time())
    -- if self._move_type == RPG_FORCE_MOVE_TYPE.MOVE_TO_TARGET_POS then
    --     local target = self._target
    --     self._ex = target._x + target._dir_x * self._off_len_x
    --     self._ey = target._y + target._dir_y * self._off_len_y
    -- end
    self._ety._x = rpg_lerp(self._sx, self._ex, p)
    self._ety._y = rpg_lerp(self._sy, self._ey, p)
end

function rpg_buff_force_move:on_exit()
    if self._finish then 
        return true
    end
    if self._real_finish then
        self._ety._x = self._ex
        self._ety._y = self._ey
    end
    self._finish = true
    -- Logger.LogerWYY2("[RPG] rpg_buff on_exit", self._id, self._ety._eid)
    self._ety:remove_group(RPG_DEFAULT_GROUP.FORCE_MOVE, self)
    self._ety._rpg_buff_force_move = nil
    self._ins:post_event({ 
        id = RPG_EVENT_TYPE.BUFF_END, 
        event_time = self:get_time(), 
        oid = self._eff_env.p_env.actor._oid,
        owner = self._ety._eid,
        buff = self._id,
        finish = true,
    })
    self._ety:remove_buff(self)
    -- local _ = self._exit_eff and self:do_effect(self._exit_eff)
end
