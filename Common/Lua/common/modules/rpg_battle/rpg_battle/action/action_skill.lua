-- local action_skill = rpg_pool_class("action_skill", T.action_skill, function(self, batlte_ins)
-- end)

local action_skill = class2("action_skill", T.rpg_action, function(self, batlte_ins, action_data)
    T.rpg_action._ctor(self, batlte_ins)
    self._eid = action_data.eid
    self._id =action_data.skill_id
    self._target = action_data._eid
    self._target_orinet = action_data 
    local caster = self._ins._battle_mod:get_ety(self._eid)
    self._ety = caster
    self._sk = caster:get_skill(self._id)
    self._effs = self._sk._effs
    self._anger = self._sk:is_anger()
    self._dur = self._sk:get_dur()
    self._cmd = self._sk._cmd
    self._lock_targets =  (not self._sk._cfg.LockTarget) and {}
    self._sk._eff_env._lock_targets = self._lock_targets
    self._speed = self._sk:speed() / 1000

    if self._eid == action_data.eid and action_data._sx then
        self.update_start_pos = true
    end
    
end)

T.rpg_action[RPG_EVENT_TYPE.ACTION_SKILL] = action_skill


-- action_skill._type = RPG_ACTION_TYPE.SKILL

function action_skill:get_time()
    return self._ins:get_btime()
end

function action_skill:sk_time()
    return (self:get_time() - self._time) * self._speed
end

function action_skill:is_finish()
    return self:sk_time() >= self._dur--self:get_time() >= self._ftime
end


function action_skill:wait(dur, interrupt_type)
    if self._skill_wait_dur then
        local _ = RPG_DEBUG_MOD and RPG_ERR("[RPG] skill_wait 不可重入 skill=%d", self._id)
        return
    end
    self._skill_wait_st = self:get_time()
    self._skill_wait_dur = dur
    self._skill_wait_interrupt_type = interrupt_type

    self._time = self._time + dur
    self._ftime = self._ftime + dur
end

function action_skill:can_do(ety)
    if not self._sk:can_cast() then
        return false
    end
    return T.rpg_action.can_do(self, ety)
end

function action_skill:reset_wait()
    if not self._skill_wait_st then
        return
    end

    self._sk._past = 0
    local past = self:get_time() - self._skill_wait_st
    local dur = self._skill_wait_dur 
    local remain = dur - past

    self._time = self._time - remain
    self._ftime = self._ftime - remain

    self._skill_wait_st = nil
    self._skill_wait_dur = nil
    self._skill_wait_interrupt_type = nil
end

function action_skill:on_enter()
    self._st = self:get_time()
    self._time = self._st
    self._sk._action = self
    self._sk:on_enter()
    self._sk:cast()
    -- self._sk._cd = self._ins:get_btime() + self._sk:get_cd()
    self._cur_eff = 1 --
    self._ftime = self._time + (self._dur or 0)


    if self._target_orinet._dir_x then
    self._ety:set_dir(self._target_orinet._dir_x, self._target_orinet._dir_y)
    end

    self._ety:set_state(RPG_ENTITY_STATE.SKILL)


    local e = { id = RPG_EVENT_TYPE.SKILL_START, event_time = self._ins:get_btime(), eid = self._eid, skill_id = self._id, 
    oid = self._sk._oid,
    speed = self._speed,
    target = self._target,
    dir_x = self._target_orinet._dir_x,
    dir_y = self._target_orinet._dir_y,
    cd = self._sk:get_cd(),
    dur = self._dur}
    if self._anger then
        e.anger = true
    end

    self._ins:post_event(e)
    self:update()
    -- RPG_DEBUG("[RPG]%s action_skill on_enter type=%s, eid=%s, oid=%s, skill_id=%s, target=%s", self._ins:log_str(), self._type, self._eid, self._oid, self._id, self._target)
end

function action_skill:update()
    local sk_time = self:sk_time()
    local skill_effects = self._effs
    for i = self._cur_eff, #skill_effects do 
        local eff_que = skill_effects[i]
        if not eff_que or sk_time < eff_que[1] then
            break
        end

        if self._skill_wait_st then
            self._sk._past = self:get_time() - self._skill_wait_st
        end

        self._cur_eff = self._cur_eff + 1
        self._sk._eff_env._eff_idx = i
        if self.update_start_pos then
            self._target_orinet._sx = self._ety._x
            self._target_orinet._sy = self._ety._y
        end
        T.rpg_effect.do_effect_ids(eff_que[3] or self._sk._eff_env, self._target_orinet, eff_que[2], nil, self._lock_targets)
        if self._skill_wait_st then
            sk_time = self:sk_time()
        end
        local rpg_buff_force_move = self._ety._rpg_buff_force_move

        --------------------位移技能 会影响技能施法时间
        if rpg_buff_force_move and rpg_buff_force_move._move_type == RPG_FORCE_MOVE_TYPE.MOVE_TO_TARGET_POS then
        end
    end
end

function action_skill:on_exit()
    self._sk._action = nil
    self._sk:on_exit()
    self._ins:post_event({ id = RPG_EVENT_TYPE.SKILL_END,
                           event_time = self._ins:get_btime(),
                           eid = self._eid,
                           oid = self._sk._oid,
                           skill_id = self._id,
                           anger = self._anger,
                           dir_x = self._ety._dir_x,
                           dir_y = self._ety._dir_y,
                           target = self._target })
    self._ety:set_state(RPG_ENTITY_STATE.IDLE)
    -- RPG_DEBUG("[RPG]%s action_skill on_exit type=%s, eid=%s, oid=%s, skill_id=%s, target=%s",self._ins:log_str() , self._type, self._eid, self._oid, self._id, self._target)
end

