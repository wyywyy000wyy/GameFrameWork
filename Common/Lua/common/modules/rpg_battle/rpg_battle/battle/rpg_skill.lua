local floor = math.floor
local band = bit.band
local rpg_skill = class2("rpg_skill", T.rpg_effect_actor, function(self, skill_id, battle_ins, owner) 
    T.rpg_effect_actor._ctor(self, battle_ins, owner)
    self._actor_type = RPG_EFFECT_ACTOR.SKILL
    self:reset()
    self._id = skill_id
    self._ins = battle_ins
    self._ety = owner
    local prop_skill = resmng.prop_rpg_battle_skill[self._id]
    self._effs = prop_skill.SkillEffect
    self._cfg = prop_skill
    self._skill_pause = prop_skill.SkillPause
    self._mode = prop_skill.Mode
    self._is_anger = prop_skill.Mode == RPG_SKILL_TYPE.ANGER
    self:init_skill_cmd();

    self._eff_env = {
        ins = self._ins,
        ety = owner,
        actor = self,
        root_actor = self,
        level = 1,
        is_anger = self:is_anger()
    }

    local start_idx = prop_skill.TargetEffectIdx or 1


    local first_eff_id = self._effs[start_idx][2][1]
    self._first_eff_cfg = resmng.prop_rpg_battle_effect[first_eff_id]
    self._lv = prop_skill.Lv
    self._search_cfg = {}
    self._cost_energy = (self._cfg.CostEnergy or 0)
    self._reply_energy = (self._cfg.ReplyEnergy or 0)

    self._cd = self._ins:get_btime() + (prop_skill.InitCd or 0)
    -- self._cd = Cd

    if self._cfg._Event then
        local cfg = self._cfg
        if cfg._Event then
            local eff_env = self._eff_env
            local ety = self._ety
            local battle_mod = self._ins._battle_mod
            self._event_remove_func = T.rpg_effect.init_event(cfg._Event,eff_env, ety, function(remove)
                if prop_skill.Mode == RPG_SKILL_TYPE.PASSIVE then
                    self:run_passive()
                else
                    local target_orinet = battle_mod:search_target(self._first_eff_cfg, ety) 
                    if target_orinet then
                        return
                        self:run_skill(target_orinet)
                    end
                end
                if remove then
                    self._event_remove_func()
                    self._event_remove_func = nil
                end
            end)
            -- local param = cfg._Event
            -- local event_type = param[1]
            -- local event_params = param[2]
            -- local event_handle = T.rpg_effect.event_handles[event_type] or T.rpg_effect.event_handles[RPG_EVENT_TYPE.EVENT_DEFAULT]
            -- if event_handle then
            --     local eff_env = self._eff_env
            --     local ety = self._ety
            --     local first_eff_cfg = self._first_eff_cfg
            --     -- local target = ety
            --     -- if first_eff_cfg.TargetType ~= RPG_TARGET_TYPE.SELF then
            --     --     target = nil
            --     -- end
            --     local battle_mod = self._ins._battle_mod
            --     self._event_remove_func = event_handle(event_type, eff_env, ety, event_params, param[3], function(remove)
            --         local target_orinet = battle_mod:search_target(self._first_eff_cfg, ety) 
            --         if not target_orinet then
            --             return
            --         end
            --         self:run_skill(target_orinet)
            --         if remove then
            --             self._event_remove_func()
            --             self._event_remove_func = nil
            --         end
            --     end)
            -- end
        end
    end

    -- table.insert(self._eff_que, {
    --     300,
    --     {"damage", RPG_F2I(25)}
    -- })
end)

function rpg_skill:is_skill(skill_id_without_lv)
    return math.floor(self._id/100) == skill_id_without_lv
end

function rpg_skill:init_skill_cmd()
    local cmd = RPG_CMD.SKILL
    if self:is_anger() then
        cmd = RPG_CMD.ANGER
    elseif self:is_attack() then
        cmd = RPG_CMD.ATTACK
    elseif self._cfg.Silent == 1 then
        cmd = RPG_CMD.MAGIC
    end
    self._cmd = cmd
end

function rpg_skill:wait(dur, interrupt_type)
    if not self._action then
        return
    end
    self._action:wait(dur, interrupt_type)
end

function rpg_skill:get_record(record_id)

end

function rpg_skill:add_effect(eff_id, time, eff_env)
    time = time or 0
    local copy_effs = self._copy_effs
    if not copy_effs then
        copy_effs = {}
        for _, eff_que in ipairs(self._effs) do
        table.insert(copy_effs, eff_que)
        end
        self._copy_effs = copy_effs
        self._effs = copy_effs
    end
    local new_que = {time, {eff_id}, eff_env}
    local idx = #copy_effs
    for i, eff_ue in ipairs(copy_effs) do
        if eff_ue[1] > time then
            idx = i
            break
        end
    end
    table.insert(copy_effs, idx, new_que)
end

function rpg_skill:reset()
    self._id = nil
    self._pt = nil
    self._st = nil --开始时间
    self._et = nil --持续时间
    self._cd = 0
    -- self._fcd = 0
    self._cfg = nil
    self._eff_que = {}
    self.cast_count = 0
end

function rpg_skill:run_skill(target_orinet)
    local action_data = {
        id = self:is_anger() and RPG_EVENT_TYPE.ACTION_SKILL_ANGER or RPG_EVENT_TYPE.ACTION_SKILL,
        eid = self._ety._eid,
        skill_id = self._id,
        target_eid =  target_orinet._eid,
        tx = target_orinet._x,
        ty = target_orinet._y,
        dir_x = target_orinet._dir_x,
        dir_y = target_orinet._dir_y,
    }
    self._ins._battle_mod:excute_action(action_data)
end

function rpg_skill.new(battle_ins)
    return T.rpg_skill()
end

function rpg_skill:priority()
    return self._cfg.Priority or 0
end

function rpg_skill:is_anger2()
    return self._is_anger
end

function rpg_skill:is_anger()
    return not self._ins._anger_pause and self._is_anger and self._ety._tid == 1
end

function rpg_skill:is_attack()
    return self._mode == RPG_SKILL_TYPE.NORMAL
end

function rpg_skill:is_cooldown()
    return self._ins:get_btime() >= self._cd
end

function rpg_skill:cost_enough()
    local energy = self._cost_energy
    return self._ety._p.RPG_Anger >= energy
end

function rpg_skill:speed()
    local p = self._ety._p
    local speed = 1000
    if self:is_attack() then
        speed = speed + p.RPG_AtkSp + p.RPG_SkillSp
    else
        speed = speed + p.RPG_SkillSp
    end
    return speed
end

function rpg_skill:cast()
    self.cast_count = self.cast_count + 1

    self._ety:alter_prop("RPG_Anger", self._ety._p.RPG_Anger - self._cost_energy + self._reply_energy, self)

    local cd = self:get_cd()
    local speed = self:speed()
    cd =  floor(cd * 1000 / speed)
    self._cd = self._ins:get_btime() + cd
end


-----------被动技能
function rpg_skill:run_passive()
    if not self:can_cast(true) then
        return
    end
    self:cast()
    local skill_effects = self._effs
    for i = 1, #skill_effects do 
        local eff_que = skill_effects[i]
        -- T.rpg_effect.do_effect_ids(self._eff_env, target_orinet or self._ety, eff_que[2])
        T.rpg_effect.do_effect_ids(self._eff_env, nil, eff_que[2])
    end
end

function rpg_skill:get_dis()
    return self._cfg.Dist
end

function rpg_skill:get_dur()
    return self._cfg.Duration
end

function rpg_skill:get_cd()
    return self._cfg.Cd or 0
end

function rpg_skill:can_cast(not_check_cmd)
    local max_cast_count = self._cfg.MaxCastCount
    if max_cast_count and self.cast_count >=max_cast_count then
        return false
    end
    if not self:is_cooldown() then
        return false
    end
    if not self:cost_enough() then
        return false
    end

    if not not_check_cmd and not self._ety:can_cmd(self._cmd) then
        return false
    end

    return true
end

function rpg_skill:get_skill_target()
    return nil
end