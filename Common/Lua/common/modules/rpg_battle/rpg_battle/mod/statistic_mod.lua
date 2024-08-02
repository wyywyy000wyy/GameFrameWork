local band = bit.band
local statistic_mod = class2("statistic_mod", T.mod_base, function(self, battle_instance)
    T.mod_base._ctor(self, battle_instance)
    self._ins._statistic_mod = self

    self._event_count = 0
    self._skill_count = 0
    self._action_count = 0
    self._damage_count = 0
    self._total_damage = 0
    self._rtime = 0
    self._btime = 0
    self._win = -1
    self._ety_infos = {}
end)

function statistic_mod:log_str()
    local battle_mod = self._ins._battle_mod
    local hp_str = "\n"
    if battle_mod then
        local remain_hp = 0
        local strs = {}
        for _, ety in ipairs(battle_mod._ety_list) do
            local p = ety._p
            local hp = p.RPG_Hp
            remain_hp = remain_hp + hp
            if RPG_DEBUG then
                local ety_info = self._ety_infos[ety._eid]
                hp_str = hp_str .. string.format("team:%s\t fpos:%s\t eid:%s\t hp=%.2f\t dmg=%.2f\t hurt=%.2f\t heal=%.2f\n", ety._tid, ety._fpos, ety._eid, RPG_I2F(p.RPG_Hp), RPG_I2F(ety_info.damage), RPG_I2F(ety_info.hurt), RPG_I2F(ety_info.heal))
                -- table.insert(strs, )
            end
        end
        hp_str = hp_str .. string.format("remain_hp=%s\n", remain_hp)
        -- hp_str = string.pack("z", unpack(strs), string.format("remain_hp=%s\n", remain_hp))
    end

    return string.format("rtime=%s btime=%s act_cnt=%s evt_cnt=%s skill_cnt=%s dmg_cnt=%s total_dmg=%.2f %s", 
    self._rtime, self._btime, self._action_count, self._event_count, self._skill_count, self._damage_count, RPG_I2F(self._total_damage), hp_str)
end

function statistic_mod:log_table()
    -- local battle_mod = self._ins._battle_mod
    local strs = {
        rtime = self._rtime,
        btime = self._btime,
        act_cnt = self._action_count,
        evt_cnt = self._event_count,
        skill_cnt = self._skill_count,
        dmg_cnt = self._damage_count,
        total_dmg = RPG_I2F(self._total_damage),
        win = self._win,
        ety_infos = {},
    }
    -- if battle_mod then
    --     local remain_hp = 0
    --     for _, ety in ipairs(battle_mod._ety_list) do
    --         local p = ety._p
    --         local hp = p.RPG_Hp
    --         remain_hp = remain_hp + hp
    --         local ety_info = self._ety_infos[ety._eid]
    --         local info = {
    --             team = ety._tid,
    --             fpos = ety._fpos,
    --             eid = ety._eid,
    --             hp = RPG_I2F(p.RPG_Hp),
    --             dmg = RPG_I2F(ety_info.damage),
    --             hurt = RPG_I2F(ety_info.hurt),
    --             heal = RPG_I2F(ety_info.heal),
    --         }
    --         table.insert(strs.ety_infos, info)
    --     end
    --     -- hp_str = string.pack("z", unpack(strs), string.format("remain_hp=%s\n", remain_hp))
    -- end
    return strs
end

function statistic_mod:register_listener()
    for _, evt_id in pairs(RPG_EVENT_TYPE) do
        if evt_id > RPG_EVENT_TYPE.BATTLE_EVENT_BEGIN and evt_id < RPG_EVENT_TYPE.BATTLE_EVENT_END then
            self._ins:add_event_listener2(evt_id, self, "record_event")
        end
    end
    self._ins:add_event_listener2(RPG_EVENT_TYPE.BORN, self, "ety_born")
    self._ins:add_event_listener2(RPG_EVENT_TYPE.DAMAGE, self, "record_damage")
    self._ins:add_event_listener2(RPG_EVENT_TYPE.SHIELD, self, "record_shield")
    self._ins:add_event_listener2(RPG_EVENT_TYPE.BATTLE_END, self, "battle_end")

    for i = RPG_EVENT_TYPE.BATTLE_ACTION_BEGIN , RPG_EVENT_TYPE.BATTLE_ACTION_END do
        self._ins:add_event_listener2(i, self, "record_action")
    end
end

function statistic_mod:record_shield(shield_event)
    local shield_ety_info = self._ety_infos[shield_event.caster]
    if not shield_ety_info then
        return
    end
    shield_ety_info.shield = shield_ety_info.shield + (shield_event.shield)
end

function statistic_mod:ety_born(born_event)
    -- if born_event.ety_type ~= RPG_ETY_TYPE.HERO then
    --     return
    -- end

    self._ety_infos[born_event.eid] =
    { hero_id = born_event.hero_id, pet_id = born_event.pet_id, hero_lv = born_event.lv, hero_star = born_event.star, tid = born_event.tid, damage = 0, hurt = 0, heal = 0, shield = 0 }
end

function statistic_mod:record_damage(damage_event)
    local dmg = damage_event.damage

    -----治愈
    if band(damage_event.dmg_bit, RPG_DAMAGE_TYPE.HEAL) > 0 then
        local heal_ety_info = self._ety_infos[damage_event.eid]
        heal_ety_info.heal = heal_ety_info.heal + (dmg)
    else
        ---------伤害
        local dmg_ety_info = self._ety_infos[damage_event.eid]
        if not dmg_ety_info then
            return
        end
        dmg_ety_info.damage = dmg_ety_info.damage + -dmg
        local hurt_ety_info = self._ety_infos[damage_event.target]
        hurt_ety_info.hurt = hurt_ety_info.hurt + -dmg
    end

    self._damage_count = self._damage_count + 1
    self._total_damage = self._total_damage + math.abs(dmg)
end

function statistic_mod:record_event(e)
    if e.id== RPG_EVENT_TYPE.SKILL_START then
        self._skill_count = self._skill_count + 1
    end
    self._event_count = self._event_count + 1
end

function statistic_mod:record_action()
    self._action_count = self._action_count + 1
end

function statistic_mod:battle_end(event)
    self._rtime = self._ins:get_rtime()
    self._btime = self._ins:get_btime()
    self._win = event.win
end

