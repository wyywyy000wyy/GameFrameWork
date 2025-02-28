local T = T
local next = next
local ipairs = ipairs
local pairs = pairs
local bor = bit.bor
local band = bit.band
local bnot = bit.bnot
local floor = math.floor
local ceil = math.ceil
local lshift = bit.lshift
local rpg_effect = T.rpg_effect
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local min = math.min
local max = math.max
local rpg_entity = class2("rpg_entity",T.rpg_object, function(self, battle_instance, team, init_data)
    T.rpg_object._ctor(self, battle_instance)
    self._eid = self._oid --battle_instance._battle_mod:new_eid()

    self._team = team
    self._tid = team._id

    self._data = init_data
    self._dt = 0
    self._x = 0
    self._y = 0
    self._state = RPG_ENTITY_STATE.IDLE
    self._status = 0
    self._status_source = {
        
    }
    self._shields = {}
    self._groups = 0
    self._group_source = {

    }

    self._immune_groups = {

    }

    self._redirect_actor = nil

    -- self._dmg_listener = {}
    self._record_dmg = 0  -------本场战斗收到的伤害

    self._buffs = {}
    self._rbuffs = {}
    self._skills = {}
    self._skill_map = {}

    self._override_skills = nil
    self._override_skills_map = nil


    self._is_reliving = false ---是否正在复活
    self._cur_action = nil

    self._b = {} --初始数值
    self._r = {} --真实数值， 可超过上下限
    self._p = {} --当前数值
    self._ap = {} --修改的属性 用作状态同步
    self._pl = {} --属性监听
    -- self:init_props()
end)

function rpg_entity:init()
end

function rpg_entity:set_redirect_actor(actor)
    self._redirect_actor = actor
end

function rpg_entity:remove_redirect_actor(actor)
    if self._redirect_actor == actor then
        self._redirect_actor = nil
    end
end

function rpg_entity:set_override_skills(skills)
    self._override_skills = skills
    self._override_skills_map = {}
    for _, skill in ipairs(skills) do
        self._override_skills_map[skill._id] = skill
    end
end

function rpg_entity:remove_override_skills(skills)
    if self._override_skills == skills then
        self._override_skills = nil
        self._override_skills_map = nil
    end
end

function rpg_entity:is_dead()
    return self._state == RPG_ENTITY_STATE.DEAD
end

function rpg_entity:is_dead2()  ----------是否真的死了， 没有在复活中 就是真的死了， 所有人死了会导致战斗结束
    return self._state == RPG_ENTITY_STATE.DEAD and not self._is_reliving
end

local function min_sort(a, b) return a < b end

function rpg_entity:add_immune_group(group_id, buff_actor)
    local count = self._immune_groups[group_id] or 0
    self._immune_groups[group_id] = count + 1

    local smap = self._group_source[group_id]
    if not smap or not next(smap) then
        return
    end

    ---------------------------排序 确保服务器 客户端 移除逻辑一致
    local t = {}
    for oid, actor in pairs(smap) do
        table_insert(t, oid)
    end
    table_sort(t, min_sort)

    self._group_source[group_id] = nil
    for _, oid in ipairs(t) do
        rpg_effect.add_group_interrupt(group_id, smap[oid], self)
    end
    local t =  bnot(lshift(1, group_id))
    self._groups = band(t, self._groups)
    local status_table = RPG_GROUP_CMDS[group_id]
    if status_table then
        for _, cmd in ipairs(status_table) do
            self:remove_status(cmd, buff_actor)
        end
    end
end

function rpg_entity:remove_immune_group(group_id, buff_actor)
    local count = self._immune_groups[group_id] or 0
    if count > 0 then
        self._immune_groups[group_id] = count - 1
    end
end

function rpg_entity:can_add_group(group_id, level)
    local smap = self._group_source[group_id]
    if not smap then
        return true
    end

    local prop_rpg_battle_group = resmng.prop_rpg_battle_group[group_id]
    local stack_type = prop_rpg_battle_group.Stack
    if stack_type ~= RPG_STACK_TYPE.REPLACE then
        return true
    end


end

function rpg_entity:can_add_buff(buff_id, buff)
    if buff_id == RPG_ETY_INNER_BUFF.FORCE_ID and buff then
        local target_orient = buff._target_orient
        local target = self._ins._battle_mod:get_ety(target_orient._eid)
        if not target or target._tid == 1 then
            return false
        end
    end 
    local prop_rpg_battle_buff = resmng.prop_rpg_battle_buff[buff_id]
    local group_id = prop_rpg_battle_buff.Group
    local buff_or_list = self._group_source[group_id]
    local buff_id = buff_or_list and next(buff_or_list)
    if not buff_id or not group_id then
        return true
    end

    local prop_rpg_battle_group = resmng.prop_rpg_battle_group[group_id]
    local stack_type = prop_rpg_battle_group.Stack
    if stack_type ~= RPG_STACK_TYPE.REPLACE then
        return true
    end
    local buff = buff_or_list[buff_id]
    if buff._cfg.lv < prop_rpg_battle_buff.lv then
        return true
    end
end

function rpg_entity:set_dir(dir_x,dir_y)
    
    local angle = math.atan(dir_y, dir_x) --* 180 / math.pi
    local angle2 = RPG_F2I(angle)
    
    self._dir_x = dir_x
    self._dir_y = dir_y

    self:alter_prop("RPG_DIR", angle2)

    -- self:alter_prop("RPG_DIR_X", dir_x)
    -- self:alter_prop("RPG_DIR_Y", dir_y)
end

function rpg_entity:add_group(group_id, buff_actor)
    -- local count = self._immune_groups[group_id] or 0
    -- if count > 0 then
    --     rpg_effect.add_group_failed(group_id, buff_actor, self)
    --     return
    -- end
    local smap = self._group_source[group_id]
    if not smap then
        smap = {}
        self._group_source[group_id] = smap
    end

    local source_buff_oid = buff_actor._oid
    if smap[source_buff_oid] then
        local _ = RPG_DEBUG_MOD and RPG_ERR("[RPG]%s add_group repeat status=%s oid=%s", self._ins:log_str(), group_id, source_buff_oid)
        return
    end
    local is_new = not next(smap)
    smap[source_buff_oid] = buff_actor
    if is_new then
        -- if group_id < 64 then
        --    self._groups = bor(lshift(1, group_id), self._groups)
        --    self:alter_prop("RPG_Groups", self._groups, buff_actor)
        -- end
        local status_table = RPG_GROUP_CMDS[group_id]
        if status_table then
            for _, cmd in ipairs(status_table) do
                self:add_status(cmd, buff_actor)
            end
        end
    end
end

function rpg_entity:remove_group(group_id, buff_actor)
    local smap = self._group_source[group_id]
    if not smap then
        return
    end
    local source_buff_oid = buff_actor._oid
    if not smap[source_buff_oid] then
        return
    end
    smap[source_buff_oid] = nil
    local is_remove = not next(smap)
    if is_remove then
        -- if group_id < 64 then
        --     local t =  bnot(lshift(1, group_id))
        --     self._groups = band(t, self._groups)
        --     self:alter_prop("RPG_Groups", self._groups, buff_actor)
        --  end
        local status_table = RPG_GROUP_CMDS[group_id]
        if status_table then
            for _, cmd in ipairs(status_table) do
                self:remove_status(cmd, buff_actor)
            end
        end
    end
end

------status 必须由buff挂载
function rpg_entity:add_status(rpg_ety_status_id, buff_actor)
    local count = self._status_source[rpg_ety_status_id] or 0
    self._status_source[rpg_ety_status_id] = count + 1
    if count <= 0 then
        self._status = bor(lshift(1, rpg_ety_status_id - 1), self._status)
        self:alter_prop("RPG_Status", self._status, buff_actor)
    end
end

function rpg_entity:remove_status(rpg_ety_status_id, buff_actor)
    local count = self._status_source[rpg_ety_status_id] or 0
    self._status_source[rpg_ety_status_id] = count - 1
    if count == 1 then
        local not_status_bit = bnot(lshift(1, rpg_ety_status_id - 1))
        self._status = band(not_status_bit, self._status)
        self:alter_prop("RPG_Status", self._status, buff_actor)
    end
end

function rpg_entity:born_event()
    return { id = RPG_EVENT_TYPE.BORN,
    event_time = self._time,
    eid = self._eid,
    tid = self._tid,
    attr = self:make_sync_attr(),
}
end

function rpg_entity:make_sync_attr()
    local attr = {}
    for attr_name, _ in pairs(RPG_BATTLE_PROPERTY_SYN) do 
        attr[attr_name] = self._p[attr_name]
    end
    return attr
end


function rpg_entity:set_state(state, force)
    -- RPG_DEBUG("set_state___%s  %s" , self._eid, state)
    if self:is_dead() and not force then
        return 
    end
    self._state = state
end

function rpg_entity:add_prop(prop, value, alter_actor)
    local pre = self._p[prop]
    self:alter_prop(prop, pre + value, alter_actor)
end

function rpg_entity:alter_prop(prop, value, alter_actor)
    value = floor(value)
    local pre = self._p[prop] or 0
    if pre == value then
        return
    end

    local range_func = RPG_PROPERTY_RANGE[prop]
    self._r[prop] = value
    value = range_func and range_func(value, self._p) or value
    if pre == value then
        return
    end
    self._p[prop] = value

    local syn = RPG_BATTLE_PROPERTY_SYN[prop]
    if syn then
        self._ap[prop] = value
        if syn > 1 then
            local ins = self._ins
            ins:post_event({ 
                id = RPG_EVENT_TYPE.PROP_CHANGE, 
                event_time = ins:get_btime(), 
                eid = self._eid, 
                prop = prop,
                value = value,
                oid = alter_actor._oid
            })
        end
    end
    local prop_listeners = self._pl[prop]
    if prop_listeners then
        for _,func in ipairs(prop_listeners) do
            func(self, prop, value, pre, alter_actor)
        end
    end
    return value - pre
end



function rpg_entity:set_extra_props()
    local _p = self._p
    _p.base = self._b
    _p.ety = self
    _p["RPG_OID"] = self._oid
    _p["RPG_TID"] = self._tid
    _p["RPG_DIR_X"] = self._dir_x
    _p["RPG_DIR_Y"] = self._dir_y
    _p.RPG_Status = 0
    setmetatable(_p, {__index = T.rpg_effect_interface})
    
end

function rpg_entity:init_props()
    local _b = self._b
    local _p = self._p

    local attr = self._data.attr
    for _, k in ipairs(RPG_PROPERTY) do
        if k == "__________RPG_BattleInter" then
            break;
        end

        local conf = resmng.prop_effect_type[k]
        if conf and conf.RPGType then
            _b[k] = (attr[k] or 0) * conf.RPGType
            -- _p[k] = effect_util.get_ef_val(k, nil, attr) * conf.RPGType
            _p[k] = _b[k]
        else
            _b[k] = attr[k] or 0
            _p[k] = attr[k] or 0
        end
    end

    for _, prop in ipairs(RPG_PROPERTY) do
        if prop == "__________RPG_BattleInter" then
            break;
        end
        -- local v = p_attr_b[prop] or p_attr[prop]
        _b[prop] = _b[prop] or 0
    end
    -- for n, v in pairs(self._data.attr) do
    --     _b[n] = v
    -- end 

    for k, source in pairs(RPG_BATTLE_PROPERTY_SOURCE) do
        _b[k] = _b[source]
        _p[k] = _p[source]
    end

    if attr.RPG_HpInit then
        local conf = resmng.prop_effect_type['RPG_Hp']
        if conf then
            _p.RPG_HpInit = attr.RPG_HpInit * conf.RPGType
            _p.RPG_Hp = _p.RPG_HpInit
        end
    end
    if attr.RPG_AngerInit then
        local conf = resmng.prop_effect_type['RPG_Anger']
        if conf then
            _p.RPG_AngerInit = attr.RPG_AngerInit * conf.RPGType
            _p.RPG_Anger = _p.RPG_AngerInit
        end
    end

    for prop, v in pairs(_b) do
        local limit_func = RPG_PROPERTY_RANGE[prop]
        if limit_func then
            _b[prop] = limit_func(v, _b)
            _p[prop] = limit_func(_p[prop], _p)
        end
    end
    local _r = self._r
    local _p = self._p
    for n, v in pairs(_b) do
        _p[n] = _p[n] or v 
        _r[n] = _p[n]
    end 

    self:listen_prop("RPG_Hp", self.on_hp_changed)
    self:listen_prop("RPG_HpMax", self.on_max_hp_changed)
    self:listen_prop("RPG_Status", self.on_status_changed)
    
    self:set_extra_props()
end

function rpg_entity:on_hp_changed(prop, value, pre, actor)
    if pre > value then
        if actor._actor_type ~= RPG_EFFECT_ACTOR.BUFF then
            local d =  (pre - value)
            local alter = d / self._p.RPG_HpMax * 1000
            local anger = ceil(self._p.RPG_AngerHit * alter)
            self:add_prop("RPG_Anger", anger, actor)
        end
    end
    if value <= 0 then
        self:on_dead(actor)
    end
    
end

function rpg_entity:on_max_hp_changed(prop, value, pre, actor)
    local greater = value > pre
    if not greater then
        return
    end
    local add_hp = (value - pre)
    self:add_prop("RPG_Hp", add_hp, actor)
end

---------技能打断
function rpg_entity:on_status_changed(prop, value, pre, actor)
    local cur_action = self._cur_action
    if cur_action and not cur_action:can_do(self) then
        cur_action:on_exit()
        self._cur_action = nil
    end
end

function rpg_entity:listen_prop(prop, func)
    local listeners = self._pl[prop]
    if not listeners then
        listeners = {}
        self._pl[prop] = listeners
    end
    table_insert(listeners, func)
end

function rpg_entity:remove_listen_prop(prop, func)
    local listeners = self._pl[prop]
    if not listeners then
        return
    end
    local end_idx = #listeners
    for i = 1, end_idx do
        local f = listeners[i]
        if f == func then
            listeners[i] = listeners[end_idx]
            table_remove(listeners, end_idx)
            break
        end
    end
end

function rpg_entity:tick_props()
    local btime = self._ins:get_btime()
    local dt = btime - (self._last_pt or 0)
    if dt <= 0 then
        return 
    end
    self._last_pt = btime

    local _p = self._p
    local energy_speed = _p.RPG_AngerSp
    local energy_max = _p.RPG_AngerMax
    local energy = _p.RPG_Anger
    if energy_speed and energy_speed ~= 0 and energy < energy_max then
        self._p.RPG_Anger = min(energy_max ,energy + energy_speed * dt)
    end
end

function rpg_entity:async_props()
    if not next(self._ap) then
        return
    end
    local ap = self._ap
    self._ap = {}
    local battle_ins = self._ins
    battle_ins:post_event({ 
        id = RPG_EVENT_TYPE.PROPS_CHANGED, 
        event_time = battle_ins:get_btime(), 
        eid = self._eid, 
        props = ap
    })
end

function rpg_entity:get_skill(skill_id)
    local sk = self._override_skills_map and self._override_skills_map[skill_id] or self._skill_map[skill_id]
    return sk
end

function rpg_entity:search_skill(skill_id)
    local sk = self:get_skill(skill_id)
    if sk then
        return sk
    end
    for _, s in pairs(self._skill_map) do
        if s:is_skill(skill_id) then
            return s
        end
    end
    if not self._override_skills_map then
        return
    end
    for _, s in pairs(self._override_skills_map) do
        if s:is_skill(skill_id) then
            return s
        end
    end
end


function rpg_entity:start()
    -- RPG_DEBUG("[RPG]%s rpg_entity start eid=%s",self._ins:log_str(),self._eid)
    local start_effts =  self._data.effs --{resmng.RPG_BATTLE_COMMON_EFFECT_1003}
    if start_effts then
        local rpg_enpty_actor =T.rpg_eff_actor_global(self._ins, self)
        rpg_enpty_actor:do_effect_ids(start_effts)
    end

    for _, sk in ipairs(self._skills) do
        if sk._cfg.Mode == RPG_SKILL_TYPE.PASSIVE and not sk._cfg.Event then
            sk:run_passive()
        end
    end
end

function rpg_entity:can_cmd(cmd)
    if band(self._status, cmd) > 0 then
        return false
    end
    return true
end

function rpg_entity:can_do_action(action)
    if self:is_dead() then
        return false
    end
    if not action:can_do(self) then
        return false
    end

    -- if action.id == RPG_EVENT_TYPE.ACTION_SKILL or  action.id == RPG_EVENT_TYPE.ACTION_SKILL_ANGER then
    --     local skill = self:get_skill(action.skill_id)
    --     if not skill then
    --         skill = self:get_skill(action.skill_id)
    --     end
    --     if not skill:can_cast() then
    --         return false
    --     end
    -- -- elseif action.id == RPG_EVENT_TYPE.ACTION_MOVE then
    -- --     if not self:can_cmd(RPG_CMD.MOVE) then
    -- --         return false
    -- --     end
    -- end
    return true
end

function rpg_entity:update()
    if self:is_dead() then
        return
    end

    self:tick_props()
    local cur_action = self._cur_action
    if cur_action then
        cur_action:update()
        if cur_action:is_finish() then
            cur_action:on_exit()
            self._cur_action = nil
        end
    end
    local btime = self._ins:get_btime()

    local bfs = self._buffs
    local tail = #bfs
    for i = tail, 1, -1 do
        local bf = bfs[i]
        if not bf then
            goto CONTINUE
        end
        if bf._tick_eff and bf._nt <= btime then
            bf._nt = bf._nt + bf._cfg.Tick
            bf:do_effect(bf._tick_eff)
        end
        local _ = bf.on_tick and bf:on_tick()
        if bf._finish or bf._et <= btime then
            bfs[i] = bfs[tail]
            bfs[tail] = nil
            tail = tail - 1
            bf:finish()
        end
        ::CONTINUE::
    end

    self:async_props()
end

-- function rpg_entity:_add_shield(buff, dmg_type)
--     local shield_list = self._shields[dmg_type]
--     if not shield_list then
--         shield_list = {}
--         self._shields[dmg_type] = shield_list
--     end
--     table_insert(shield_list, buff)
-- end

function rpg_entity:add_shield(buff)
    local shield_list = self._shields
    table_insert(shield_list, buff)
    -- self:_add_shield(buff,RPG_DAMAGE_TYPE.DAMAGE )

    -- if bit.band(buff._dmg_type, RPG_DAMAGE_TYPE.DAMAGE) > 0 then
    --     self:_add_shield(buff,RPG_DAMAGE_TYPE.DAMAGE )
    -- end
    -- if bit.band(buff._dmg_type, RPG_DAMAGE_TYPE.MAGIC) > 0 then
    --     self:_add_shield(buff,RPG_DAMAGE_TYPE.MAGIC )
    -- end
    -- if bit.band(buff._dmg_type, RPG_DAMAGE_TYPE.REAL) > 0 then
    --     self:_add_shield(buff,RPG_DAMAGE_TYPE.REAL )
    -- end
end

function rpg_entity:update_shield_count(actor)
    local shield_list = self._shields
    local shield_total = 0
    for _, buff in ipairs(shield_list) do
        shield_total = shield_total + buff._count
    end
    self:alter_prop("RPG_Shield", shield_total, actor)
end

function rpg_entity:remove_shield(buff)
    local shield_list = self._shields
    local list_end = #shield_list
    for i = 1, list_end do
        if shield_list[i] == buff then
            shield_list[i] = shield_list[list_end]
            table_remove(shield_list, list_end)
            break
        end
    end
    -- if bit.band(buff._dmg_type, RPG_DAMAGE_TYPE.DAMAGE) > 0 then
    --     self:_remove_shield(buff,RPG_DAMAGE_TYPE.DAMAGE )
    -- end
    -- if bit.band(buff._dmg_type, RPG_DAMAGE_TYPE.MAGIC) > 0 then
    --     self:_remove_shield(buff,RPG_DAMAGE_TYPE.MAGIC )
    -- end
    -- if bit.band(buff._dmg_type, RPG_DAMAGE_TYPE.REAL) > 0 then
    --     self:_remove_shield(buff,RPG_DAMAGE_TYPE.REAL )
    -- end
end

-- function rpg_entity:_remove_shield(buff, dmg_type)
--     local shield_list = self._shields[dmg_type]
--     if not shield_list then
--         return
--     end
--     local list_end = #shield_list
--     for i = 1, list_end do
--         if shield_list[i] == buff then
--             shield_list[i] = shield_list[list_end]
--             table_remove(shield_list, list_end)
--             break
--         end
--     end
-- end

---------伤害转移BUFF
function rpg_entity:add_share_damage(buff)
    local share_list = self._shares
    if not share_list then
        share_list = {}
        self._shares = share_list
    end
    local idx = #share_list + 1
    local grade = buff._grade
    for i = #share_list, 1, -1 do
        if share_list[i]._grade >= grade then
            idx = i + 1
        end
    end
    table_insert(share_list, idx, buff)
end

function rpg_entity:remove_share_damage(buff)
    local share_list = self._shares
    if not share_list then
        return
    end
    for i = #share_list, 1, -1 do
        if share_list[i] == buff then
            table_remove(share_list, i)
            break
        end
    end
end

function rpg_entity:add_buff(buff)
    if not self:can_add_buff(buff._id, buff) then
        return false
    end

    local group_id = buff._cfg.Group
    -- local buff_or_list = self._group_source[group_id]
    local prop_rpg_battle_group = group_id and resmng.prop_rpg_battle_group[group_id]
    if not group_id or not prop_rpg_battle_group then
    elseif prop_rpg_battle_group.Stack == RPG_STACK_TYPE.Default then
        -- local buff_list =  self._group_source[group_id]
        -- if not buff_list then
        --     buff_list = {}
        --     self._group_source[group_id] = buff_list
        -- end
        -- local group_changed = #buff_list == 0
        -- table_insert(buff_list, buff)
        -- local _ = group_changed and self:group_changed(group_id)
        -- self:add_group(group_id, buff)
    else
        local pre_buffs = self._group_source[group_id]
        local pre_buff_id = pre_buffs and next(pre_buffs)
        if pre_buff_id then
            local pre_buff = pre_buffs[pre_buff_id] 
            if prop_rpg_battle_group.Stack == RPG_STACK_TYPE.REPLACE then
                if buff._cfg.lv < pre_buff._cfg.lv then
                    return false
                end
                self:remove_buff(pre_buff)
                -- self:add_group(group_id, buff)
                -- self._group_source[group_id] = buff
            elseif prop_rpg_battle_group.Stack == RPG_STACK_TYPE.Time then
                pre_buff:stack()
                return false
            elseif prop_rpg_battle_group.Stack == RPG_STACK_TYPE.Grade then
                pre_buff:stack()
                return false
            end
        else
            -- self._group_source[group_id] = buff
            -- local _ = self:group_changed(group_id)
            -- self:add_group(group_id, buff)
        end
    end

    local buffs = buff.is_anger and self._rbuffs or self._buffs
    table_insert(buffs, buff)
    buff:on_enter()
    if buff.is_anger then
        local battle_mod = self._ins._battle_mod
        battle_mod:add_rupdate(buff)
    end
    return true
end

function rpg_entity:group_changed(group_id)
    local prop_rpg_battle_group = group_id and resmng.prop_rpg_battle_group[group_id]
end

function rpg_entity:remove_buff(buff)
    local bfs = buff.is_anger and self._rbuffs or self._buffs
    local tail = #bfs
    for i = tail, 1, -1 do
        local bf = bfs[i]
        if bf == buff then
            bfs[i] = bfs[tail]
            bfs[tail] = nil
            buff:on_exit()
            local group_id = buff._cfg.Group
            -- local buff_or_list = self._group_source[group_id]
            local prop_rpg_battle_group = group_id and resmng.prop_rpg_battle_group[group_id]

            if not group_id or not prop_rpg_battle_group then
            elseif prop_rpg_battle_group.Stack == RPG_STACK_TYPE.Default then
                local buff_list =  self._group_source[group_id]
                RPG_LIST_REMOVE(buff_list, bf)
            else
                self._group_source[group_id] = nil
            end
            return
        end
    end
end

function rpg_entity:do_action(action)
    if self:can_do_action(action) then
        if self._cur_action then
            self._cur_action:on_exit()
        end
        self._cur_action = action
        action:on_enter()
        return true
    end
end

function rpg_entity:hp_percent()
    local p = self._p
    return p.RPG_Hp / p.RPG_HpMax
end

function rpg_entity:damage(damage, eff_env, dmg_bit, eff_id, shield_damage)
    if RPG_DEBUG_DAMAGE_ONE then
        if damage < -1 then
            damage = -RPG_DEBUG_DAMAGE_ONE
        elseif damage > 1 then
            damage = RPG_DEBUG_DAMAGE_ONE
        end
    end


    local actor = eff_env.actor
    local ety = eff_env.ety
    local chp = self._p.RPG_Hp-damage

    local damage_event = 
    { 
        id = RPG_EVENT_TYPE.DAMAGE, 
        event_time = self._ins:get_btime(), 
        oid = actor._oid,
        eid = ety._eid, 
        dmg_bit = dmg_bit,
        target = self._eid,
        eff_id = eff_id,
        skill_id = eff_env.root_actor._id,
        -- pos_x = target_orient._x,
        -- pos_y = target_orient._y,
        damage = -damage,
        shield_damage = shield_damage}

    if damage > 0 then
        local lifesteal = ety._p.RPG_Lifesteal
        if lifesteal > 0 then
            local skill = ety:get_skill(eff_env.root_actor._id)
            if skill and skill:is_attack() then
                local steal = damage * RPG_I2F(lifesteal)
                local realSteal = ety:alter_prop("RPG_Hp", floor(ety._p.RPG_Hp + steal), actor)
                -- if steal then
                --     self._ins:post_event({ 
                --         id = RPG_EVENT_TYPE.DAMAGE, 
                --         event_time = self._ins:get_btime(), 
                --         oid = actor._oid,
                --         eid = ety._eid, 
                --         dmg_bit = RPG_DAMAGE_TYPE.HEAL,
                --         target = ety._eid,
                --         skill_id = eff_env.root_actor._id,
                --         damage = steal})
                -- end
                damage_event.steal = steal
            end
        end
    end
    self._ins:post_event(damage_event)
    local changed = self:alter_prop("RPG_Hp", chp, actor) or 0

    -----------不是治疗
    if band(dmg_bit, RPG_DAMAGE_TYPE.HEAL) == 0 then
        self._record_dmg = self._record_dmg - changed
    end

end

function rpg_entity:can_selected()
    return self._state ~= RPG_ENTITY_STATE.DEAD
end

function rpg_entity:on_born()
    self._ins:post_event(self:born_event())
end

function rpg_entity:on_dead(actor)
    if self._state == RPG_ENTITY_STATE.DEAD then
        return
    end

    local actor_acater = actor._eff_env.ety
    actor_acater:alter_prop("RPG_Anger", actor_acater._p.RPG_Anger + RPG_KILL_ANGER, actor)
    self._ins:post_event({ 
        id = RPG_EVENT_TYPE.SKILL_ANGER, 
        event_time = self._ins:get_btime(), 
        eid = actor_acater._eid, 
        anger = RPG_KILL_ANGER,
    })

    local bfs = self._buffs
    for _, bf in ipairs(bfs) do
        bf:finish()
    end
    self._buffs = {}

    local bfs = self._rbuffs
    for _, bf in ipairs(bfs) do
        bf:finish()
    end
    self._rbuffs = {}

    self:set_state(RPG_ENTITY_STATE.DEAD)
    local battle_ins = self._ins
    battle_ins:post_event({ 
        id = RPG_EVENT_TYPE.DEAD, 
        event_time = battle_ins:get_btime(), 
        oid = actor._oid,
        tid = self._tid,
        eid = self._eid})
end

function rpg_entity:stop()
end
