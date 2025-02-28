local td_born_point = class2("born_point", function(self, point_data, prop_rpg_battle_map)
    self._center = point_data.center
    if point_data.range then
        -- self._w = point_data.range[1]
        -- self._l = point_data.range[2]
        self._range = {}
        self._range[1] = RPG_F2I(math.max(point_data.center[1] - point_data.range[1], -prop_rpg_battle_map.MapSize[1] + 1)) 
        self._range[2] = RPG_F2I(math.min(point_data.center[1] + point_data.range[1], prop_rpg_battle_map.MapSize[1] - 1) )
        self._range[3] = RPG_F2I(math.max(point_data.center[2] - point_data.range[2], -prop_rpg_battle_map.MapSize[2] + 1) )
        self._range[4] = RPG_F2I(math.min(point_data.center[2] + point_data.range[2], prop_rpg_battle_map.MapSize[2] + 1) )
    end
    -- self._range = 
    self._radius = point_data.radius
    self._monster_id = point_data.monster_id
    self._count = point_data.count -- * 5
    self._interval = point_data.interval
    self._wave = point_data.wave
    self._cur_wave = 0
    self._fresh_time = 0
    self._monster_id = point_data.monster_id
end)


local td_wave = class2("td_wave", function(self, wave_data, prop_rpg_battle_map)
    self._wave_data = wave_data
    self._interval = wave_data.interval
    self._points = {}
    for _, point_data in ipairs(wave_data.points) do
        local point = td_born_point(point_data, prop_rpg_battle_map)
        table.insert(self._points, point)
    end

end)

function td_wave:is_finish()
    return self._points == nil or #self._points == 0
end



local td_born_mod = class2("td_born_mod", T.mod_base,function(self, battle_instance)
    T.mod_base._ctor(self, battle_instance)
    self._init_completed = true
    self._waves = {}
    self._ins._td_born_mod = self

    local prop_rpg_battle_level = resmng.prop_rpg_battle_level[battle_instance._init_data.level_id]
    local prop_rpg_battle_map = resmng.prop_rpg_battle_map[prop_rpg_battle_level.Map];

    local born_data  = prop_rpg_battle_level.BornPoint or {}--battle_instance._init_data.born
    local start_time = 0
    for _, wave_data in ipairs(born_data) do
        local wave = td_wave(wave_data, prop_rpg_battle_map)
        wave._start_time = start_time + wave._interval
        start_time = start_time + wave._interval
        table.insert(self._waves, wave)
    end
    self._cur_wave = 1

    self._killed = 0
    self._buffs = table.copy(battle_instance._init_data.buffs)
    self._cur_buff = 1

    self._trigger_events ={}


    self._prop_rpg_battle_level = prop_rpg_battle_level
    self._prop_rpg_event_pool = resmng.prop_rpg_event_pool[prop_rpg_battle_level.EventPool]

    self._cur_event_idx = 1

    self._tborn = 0
end)

function td_born_mod:check_event()

    if self._random_events or not self._prop_rpg_battle_level.Events then
        return
    end

    for i = self._cur_event_idx, #self._prop_rpg_battle_level.Events do
        local event_info = self._prop_rpg_battle_level.Events[i]
        if event_info[2] <= self._killed then
            self:trigger_event(event_info)
            self._cur_event_idx = self._cur_event_idx + 1
            break
        else
            break
        end
    end

end



function td_born_mod:random_event(pool)
    local s_idx = self._rand:range(#pool)
    local t_prop_rpg_event = resmng.prop_rpg_event
    local r_event
    for i = 1, #pool do
        local idx = math.fmod(s_idx + i, #pool) + 1
        local event_info = pool[idx]
        local event_id = type(event_info) == "table" and event_info[1] or event_info
        local prop_rpg_event = t_prop_rpg_event[event_id]

        if prop_rpg_event.Privious then
            for _, pre_event_id in ipairs(prop_rpg_event.Privious) do
                if not self._trigger_events[pre_event_id] then
                    goto CONTINUE
                end
            end
        end

        if 1 then
            local trigger_count = self._trigger_events[event_id] or 0
            if prop_rpg_event.MaxCount and trigger_count >= prop_rpg_event.MaxCount then
                goto CONTINUE
            end
            r_event = event_id
            break
        end
        ::CONTINUE::
        -- local a
    end
    return r_event
end

function td_born_mod:trigger_event(event_info)
    local event_pool = event_info[4] or self._prop_rpg_event_pool.Pool

    local random_events = {}
    self._rand = self._rand or self._ins._battle_mod._rand

    for i = 1, event_info[3] do
        local event_id = self:random_event(event_pool)
        if not event_id then
            break
        end
        table.insert(random_events, event_id)
    end

    self._random_events = random_events

    self._ins:post_event({
        id = RPG_EVENT_TYPE.TD_SELECT_EVENT_START,
        effs = random_events
    })
end

function td_born_mod:start()
    self._fixed_update = function(dt)
        self:fixed_update(dt)
    end

    self._ins:add_fixed_update(self._fixed_update,"td_born_update")

    self._ins:add_event_listener(RPG_EVENT_TYPE.DEAD, function(event)
        if(event.tid ==2) then
            self:on_kill()
        end
    end)

    self._ins:add_event_listener(RPG_EVENT_TYPE.TD_SELECT_EVENT, function(event)
        self:select_event(event.buff_idx)
    end)
end

function td_born_mod:on_kill()
    self._killed = self._killed + 1
    -- self:check_event()
end

function td_born_mod:select_event(idx)
    if not self._random_events then
        return
    end
    local event_id = self._random_events[idx]
    local trigger_count = self._trigger_events[event_id] or 0
    self._trigger_events[event_id] = trigger_count + 1
    self._random_events = nil
    local prop_rpg_event = resmng.prop_rpg_event[event_id]
    if not prop_rpg_event then
        local a = 1
        a = 2
    end
    self._ins:post_event({
        id = RPG_EVENT_TYPE.TD_GLOBAL_EFFECT,
        eff = prop_rpg_event.Effect
    })

    -- if not cur_buff then
    --     return
    -- end
    -- if cur_buff[1] <= self._killed then
    --     if cur_buff.trigger ~= 2 then
    --         cur_buff.trigger = 2
    --         self._cur_buff = self._cur_buff + 1
    --         local effect_id = cur_buff[2][idx]
    --         self._ins:post_event({
    --             id = RPG_EVENT_TYPE.TD_GLOBAL_EFFECT,
    --             eff = effect_id
    --         })
    --     end
    -- end
end

function td_born_mod:is_finish()
    local last_wave = #self._waves

    return self._cur_wave == last_wave and #self._waves[last_wave]._points == 0
end

td_born_mod.monster_template = {
    {
    attr = {
      RPG_Anger = 0,
      RPG_AngerHit = 1.0,
      RPG_AngerKill = 200.0,
      RPG_AngerMax = 1000.0,
      RPG_Atk = 40,
      RPG_Atk_R = 0,
      RPG_Block = 0,
      RPG_Crit = 50.0,
      RPG_CritAnti = 0,
      RPG_CritEnhance = 0,
      RPG_Def = 23.2725,
      RPG_Def_R = -5000,
      RPG_Hp = 200,
      RPG_Hp_R = -5000,
      RPG_Job = 3,
      RPG_Race = 2,
      RPG_Sp = 400.0,
      RPG_StarFactor = 2.0,
      RPG_StarValue = 0
    },
    buffs = {},
    cfgid = 300025,
    fpos = 6,
    hero_id = 401,
    lv = 4,
    pid = 0,
    skills = {
      4012101,
      40111
    },
    star = 1
  },
  {
    attr = {
      RPG_Anger = 0,
      RPG_AngerHit = 1.0,
      RPG_AngerKill = 200.0,
      RPG_AngerMax = 1000.0,
      RPG_Atk = 450,
      RPG_Atk_R = 0,
      RPG_Block = 0,
      RPG_Crit = 50.0,
      RPG_CritAnti = 0,
      RPG_CritEnhance = 0,
      RPG_Def = 23.2725,
      RPG_Def_R = -5000,
      RPG_Hp = 2500,
      RPG_Hp_R = -5000,
      RPG_Job = 3,
      RPG_Race = 2,
      RPG_Sp = 250.0,
      RPG_StarFactor = 2.0,
      RPG_StarValue = 0
    },
    buffs = {},
    cfgid = 300025,
    fpos = 6,
    hero_id = 402,
    lv = 4,
    pid = 0,
    skills = {
      4012101,
      40111
    },
    star = 1
  },
  {
    attr = {
      RPG_Anger = 0,
      RPG_AngerHit = 1.0,
      RPG_AngerKill = 200.0,
      RPG_AngerMax = 1000.0,
      RPG_Atk = 450,
      RPG_Atk_R = 0,
      RPG_Block = 0,
      RPG_Crit = 50.0,
      RPG_CritAnti = 0,
      RPG_CritEnhance = 0,
      RPG_Def = 23.2725,
      RPG_Def_R = -5000,
      RPG_Hp = 5000,
      RPG_Hp_R = -5000,
      RPG_Job = 3,
      RPG_Race = 2,
      RPG_Sp = 100.0,
      RPG_StarFactor = 2.0,
      RPG_StarValue = 0
    },
    buffs = {},
    cfgid = 300025,
    fpos = 6,
    hero_id = 403,
    lv = 4,
    pid = 0,
    skills = {
      4032101,
      40311
    },
    star = 1
  },
}

function td_born_mod:fixed_update(dt)
    local battle_time = self._ins:get_btime()
    self:check_event()

    if self._cur_wave > #self._waves then
        return
    end

    local wave = self._waves[self._cur_wave]

    local next_wave = self._waves[self._cur_wave + 1]
    if next_wave and battle_time >= next_wave._start_time then
        self._cur_wave = self._cur_wave + 1
    end

    -- if wave:is_finish() then
    --     self._cur_wave = self._cur_wave + 1
    --     return
    -- end

    -- if not wave._start_time then
    --     wave._start_time = battle_time + wave._interval
    -- end

    if self._tborn > 1 then
        return
    end

    if battle_time < wave._start_time then
        return
    end

    local battle_mod = self._ins._battle_mod
    local team = battle_mod._team_list[2]
    local rand = battle_mod._rand

    for i = #wave._points, 1, -1 do
        local point = wave._points[i]
        if battle_time - point._fresh_time >= point._interval then
            point._fresh_time = battle_time
            point._cur_wave = point._cur_wave + 1
            for c = 1, point._count do
                local monstertmp = troop_util.make_rpg_monster_hero(point._monster_id, 6)
                local pos
                local range = point._range
                if range then
                    local x = rand:range2(range[1], range[2])
                    local y = rand:range2(range[3], range[4])
                    pos = {y, x}
                else
                    pos = {point._center[2], point._center[1]}
                end
                --local monstertmp = td_born_mod.monster_template[point._monster_id]

                -- local monster = table.copy(monstertmp )--or td_born_mod.monster_template)
                -- monster.pos = table.copy(point._center)
                -- monster.pos[1] = monster.pos[1] + rand:range(-point._radius, point._radius)
                -- monster.pos[2] = monster.pos[2] + rand:range(-point._radius, point._radius)
                -- self._ins:born_entity(monster)
                if self._tborn > 0 then
                    return
                end
                monstertmp.pos = pos
                team:create_hero(monstertmp)
                -- self._tborn = true
                -- self._tborn = self._tborn + 1
                
            end
            if(point._cur_wave >= point._wave) then
                table.remove(wave._points, i)
            end
        end
    end
end
