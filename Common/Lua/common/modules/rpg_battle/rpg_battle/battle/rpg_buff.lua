local rpg_effect = T.rpg_effect
local rpg_get_value = rpg_get_value
local rpg_buff = class2("rpg_buff", T.rpg_effect_actor, function(self,buff_id, battle_ins, owner, eff_env, time, grade) 
    T.rpg_effect_actor._ctor(self, battle_ins, owner)
    self._actor_type = RPG_EFFECT_ACTOR.BUFF
    self._st = self:get_time()
    self._dur = time
    self._et = self._st + time
    self._id = buff_id
    self._grade = grade or 1
    local prop_rpg_battle_buff = resmng.prop_rpg_battle_buff[buff_id]
    self._cfg = prop_rpg_battle_buff
    self._ins = battle_ins
    self._ety = owner
    self._caster = eff_env.ety
    self._lv = eff_env.actor._lv
    self._eff_env = {
        ins = self._ins,
        ety = owner,
        actor = self,
        root_actor = eff_env.root_actor,
        is_anger = eff_env.is_anger,
        level = eff_env.level + 1,
        p_env = eff_env,
    }
    self._eff_inverse = {}
    self._tick_eff = prop_rpg_battle_buff and prop_rpg_battle_buff.TickEffect
    self._enter_eff = prop_rpg_battle_buff and prop_rpg_battle_buff.EffectStart
end)

function rpg_buff:actor_pos()
    return self._ety
end

function rpg_buff:stack(time)
    if self._cfg.Stack == RPG_STACK_TYPE.Time then
        self._dur = self._dur + time
        self._et = self._st + self._dur
        self:post_buff_event()
    elseif self._cfg.Stack == RPG_STACK_TYPE.Grade then
        local group_id = self._cfg.Group
        local prop_rpg_battle_group = group_id and resmng.prop_rpg_battle_group[group_id]
        if prop_rpg_battle_group then
            self._grade = math.min(self._grade + 1, prop_rpg_battle_group.MaxLevel)
        end
        self._et = self._st + self._dur
        self:post_buff_event()
    end
end

function rpg_buff:finish()
    if self._finish then
        return
    end
    self._real_finish = true
    self:on_exit()
end

function rpg_buff.new(battle_ins)

end

function rpg_buff:on_enter()
    self._enter = true
    -- Logger.LogerWYY2("[RPG] rpg_buff on_enter", self._id, self._ety._eid)
    T.rpg_effect_actor.on_enter(self)

    local cfg = self._cfg

    if cfg.Group then
        self._ety:add_group(cfg.Group, self)
    end

    if cfg._Event then
        local eff_env = self._eff_env
        local ety = self._ety
        self._event_remove_func = T.rpg_effect.init_event(cfg._Event,eff_env, ety, function(remove)
            eff_env.force_search = true
            rpg_effect.do_effect_ids(eff_env, ety, cfg.EventEffect)
            eff_env.force_search = false

            if remove then
                self:finish()
            end
        end)
        -- local param = cfg._Event
        -- local event_type = param[1]
        -- local event_params = param[2]
        -- local event_handle = T.rpg_effect.event_handles[event_type] or T.rpg_effect.event_handles[RPG_EVENT_TYPE.EVENT_DEFAULT]
        -- if event_handle then
        --     local eff_env = self._eff_env
        --     local ety = self._ety
        --     self._event_remove_func = event_handle(event_type, eff_env, ety, event_params, param[3], function(remove)
        --         rpg_effect.do_effect_ids(eff_env, ety, cfg.EventEffect)
        --         if remove then
        --             self:finish()
        --         end
        --     end)
        -- end
    end

    if cfg._RemoveEvent then
        T.rpg_effect.init_event(cfg._RemoveEvent,self._eff_env, self._ety, function()
            self:finish()
        end)
        -- local param = cfg._RemoveEvent
        -- local remove_type = param[1]
        -- local remove_params = param[2]
        -- local event_handle = T.rpg_effect.event_handles[remove_type]
        -- if event_handle then
        --     self._remove_func = event_handle(self._eff_env, self._ety, remove_params, param[3], function()
        --         self:finish()
        --     end)
        -- end
    end

    self:post_buff_event()
    
    local btime = self:get_time()
    self._nt = btime + (self._cfg.Tick or 100)
    local _ = self._enter_eff and self:do_effect(self._enter_eff)
end

function rpg_buff:post_buff_event()
    self._ins:post_event({ 
        id = RPG_EVENT_TYPE.BUFF, 
        event_time = self:get_time(), 
        oid = self._eff_env.p_env.actor._oid,
        owner = self._ety._eid,
        buff = self._id,
        ia_anger = self.is_anger,
        -- grade = self._grade > 1 and self._grade or nil,
        -- dur = self._dur
        et = self._et
    })
end

function rpg_buff:do_effect(effs)
    rpg_effect.do_effect_ids(self._eff_env, self._ety, effs)
end

-- function rpg_buff:on_tick()
--     T.rpg_effect.do_effect(self._ety, self, self._tick_eff, self._ety)
-- end
function rpg_buff:update()
    if self._finish then 
        return true
    end

    if self.on_tick then
        self:on_tick()
    end

    local cur_time = self:get_time()
    if self._tick_eff and self._nt <= cur_time then
        self._nt = self._nt + self._cfg.Tick
        self:do_effect(self._tick_eff)
    end

    if self._et <= cur_time then
        self:finish()
        return true
    end
end

function rpg_buff:get_time()
    return self.is_anger and self._ins:get_rtime() or self._ins:get_btime()
end

function rpg_buff:on_exit()
    if self._finish or not self._enter then
        return
    end
    self._enter = false
    self._finish = true

    local eff_invs = self._eff_inverse
    self._eff_inverse = nil
    if eff_invs then
        for i = #eff_invs, 1, -1 do
            local alter_info = eff_invs[i]
            T.rpg_effect.effects_inv[alter_info.eff](self._eff_env, alter_info)
        end
    end

    local cfg = self._cfg
    if cfg and cfg.Group then
        self._ety:remove_group(cfg.Group, self)
    end
    T.rpg_effect_actor.on_exit(self)
    self._ins:post_event({ 
        id = RPG_EVENT_TYPE.BUFF_END, 
        event_time = self._ins:get_btime(), 
        oid = self._eff_env.p_env.actor._oid,
        owner = self._ety._eid,
        buff = self._id,
        finish = true,
    })

    local remove_func = self._remove_func
    if remove_func then
        self._remove_func = nil
        remove_func()
    end

    local event_remove_func = self._event_remove_func
    if event_remove_func then
        self._event_remove_func = nil
        event_remove_func()
    end

    self._ety:remove_buff(self)
    -- local _ = self._exit_eff and self:do_effect(self._exit_eff)
end
