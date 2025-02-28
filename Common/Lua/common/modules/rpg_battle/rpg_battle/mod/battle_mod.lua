local table_insert =  table.insert
local ipairs = ipairs
local table_sort = table.sort
local table_remove = table.remove
local RPG_ENTITY_RADIUS = RPG_ENTITY_RADIUS

local battle_mod = class2("battle_mod", T.mod_base,function(self, battle_instance)
    T.mod_base._ctor(self, battle_instance)
    battle_instance._battle_mod = self

    self._eid_idx = 0

    self._rule_list = {}
    self._ety_map = {}
    self._ety_list = {}
    self._combat_list = {}
    self._team_list = {}
    self._action_list = {}
    self._anger_actions = {}
    self._anger_stack = {}
    self._check_action_list = {}
    self._time = 0
    self._real_time = 0
    
    self._blist = {} --战斗时间update
    self._bmap = {}

    self._rlist = {} --真实时间update
    self._rmap = {}
    self._rand = T.rpg_random(battle_instance._bid)


end)

function battle_mod:new_eid()
    self._eid_idx = self._eid_idx + 1
    return self._eid_idx
end

function battle_mod:do_global_eff(event)
    local eff_id = event.eff
    self._global_eff_actor:do_effect_ids({eff_id})
end

--模块数据初始化，战斗数据构造完成之后调用
function battle_mod:init()
    local battle_data = self._ins._init_data.battle

    local teams = battle_data.teams
    for i, team_data in ipairs(teams) do
        self._team_list[i] = T.rpg_team(i, self._ins, team_data)
    end



    for i, team in ipairs(self._team_list) do
        team:init()
    end

    self._global_ety = T.rpg_entity(self._ins,self._team_list[1])
    self._global_eff_actor = T.rpg_eff_actor_global(self._ins, self._global_ety)

    -- 各个模块根据战斗数据做初始化
    self._init_completed = true

    -- 战斗数据初始化完成
    local team_list = {}
    for m, team in ipairs(self._team_list) do
        local team_data = {
            heros = {},
        }
        team_list[m] = team_data
        for n, ety in ipairs(team._ety_list) do
            team_data.heros[n] = {
                _eid = ety._eid,
                _hero_id = ety._hero_id,
                _fpos = ety._fpos,
                _lv = ety._data.lv,
                _x = ety._x,
                _y = ety._y,
                _dir_x = ety._dir_x,
                _dir_y = ety._dir_y,
                RPG_Hp = ety._p.RPG_Hp,
                RPG_HpMax = ety._p.RPG_HpMax,
                RPG_Anger = ety._p.RPG_Anger,
                RPG_AngerMax = ety._p.RPG_AngerMax,
                is_boss = ety._data.is_boss,
                scale = ety._data.scale,
                hp_count = ety._data.hp_count,
            }
        end
        if team._pet then
            local _pet = team._pet
            team_data.pet = {
                _eid = _pet._eid,
                _pet_id = _pet._pet_id,
                _lv = _pet._lv,
                _x = _pet._x,
                _y = _pet._y,
                _dir_x = _pet._dir_x,
                _dir_y = _pet._dir_y,
            }
        end
    end

    self._ins:post_event({ id = RPG_EVENT_TYPE.BATTLE_DATA_INIT, team_list = team_list })
end

-- 每帧检查
function battle_mod:init_finish()
    return self._init_completed
end


function battle_mod:start()
    for _, team in ipairs(self._team_list) do
        team:start()
    end

    for _, ety in ipairs(self._ety_list) do
        ety:start()
    end
    for _, ety in ipairs(self._ety_list) do
        ety:on_born()
    end

    self._fixed_update = function(dt)
        self:fixed_update(dt)
    end
    self._ins:add_fixed_update(self._fixed_update,"battle_fixed_update")

    -- self._post_update = function(dt)
    --     self:post_update(dt)
    -- end
    -- self._ins:add_fixed_update(self._post_update, "battle_post_update")
end

function battle_mod:register_listener()
    -- self._ins:add_event_listener2(RPG_EVENT_TYPE.DEAD, self, "check_rule") -- 伤害
    for i = RPG_EVENT_TYPE.BATTLE_ACTION_BEGIN , RPG_EVENT_TYPE.BATTLE_ACTION_END do
        self._ins:add_event_listener2(i, self, "excute_action") -- 伤害
    end

    self._ins:add_event_listener2(RPG_EVENT_TYPE.TD_GLOBAL_EFFECT, self, "do_global_eff") -- 伤害

end

function battle_mod:fixed_update(dt)
    self:check_rule()
    if self._real_time >= self._ins._init_data.max_battle_time * 3 then
        self._bfin = true
        return
    end
    if self._bfin then
        return
    end
    self._real_time = self._real_time + dt
    -- self._ins:post_event({ id = RPG_EVENT_TYPE.DEBUG_EVENT, event_time = self._ins:get_btime(), name="_real_time", real_time = self._real_time, dt = dt})
    self._ins:make_log_str()
    local rlist = self._rlist
    for i = #rlist, 1, -1 do
        local o = rlist[i]
        if o:update() then
            self:remove_rupdate(o)
        end
    end
    
    self:update_anger_action(dt)
    if self._ins._bpause then
        self:check_timeout()
        return
    end
    
    -- self._time = self._time + dt
    -- self._ins:make_log_str()

    local blist = self._blist
    for i = #blist, 1, -1 do
        local o = blist[i]
        if o:update() then
            self:remove_bupdate(o)
        end
    end
    if self:check_timeout() then
        return
    end
    self:update_etys()
end

function battle_mod:post_update(dt)
    if self._bfin then
        return
    end
    -- self:excute_action_list()

    -- -- 模拟一个远程技能
    --     if self._time > 500 * 3 then
    --         -- 测试代码 发送一个技能释放事件
    --         if self._time % 2000 == 0 then
    --             -- todo 这里暂时先用直接clone表的方式处理，后续定了消息传参规则再决定怎么传参数
    --             self._ins:post_event({ id = RPG_EVENT_TYPE.SKILL_Start, event_time = self._time, eid = 1, skill_id = 10010101, target_pos = CS.UnityEngine.Vector2(10, 8.21) })
    --         end
    --     end
        
    -- -- 测试代码 发送一个移动事件
    -- if self._time == 500 * 3 then

    --     -- todo 这里暂时先用直接clone表的方式处理，后续定了消息传参规则再决定怎么传参数
    --     self._ins:post_event({ id = RPG_EVENT_TYPE.MOVE, event_time = self._time, eid = 1, speed = 0.4, move_target = CS.UnityEngine.Vector2(10,8.21) })
    -- end

    -- if self._time > 500 * 15 then
    --     -- 测试代码 发送一个技能释放事件
    --     if self._time % 2000 == 0 then
    --         -- todo 这里暂时先用直接clone表的方式处理，后续定了消息传参规则再决定怎么传参数
    --         self._ins:post_event({ id = RPG_EVENT_TYPE.SKILL_Start, event_time = self._time, eid = 1, skill_id = 10010101 })
    --     end
    -- end

    -- self:dispath_pedding_action()
end

function battle_mod:post_action_data(action_data)
    -- local contructor = T.rpg_action[action_data.id]
    -- local action = contructor(self._ins, action_data)
    if action_data.id == RPG_EVENT_TYPE.ACTION_SKILL_ANGER then
        table.insert(self._anger_actions, action_data)
        return
    end
    table.insert(self._action_list, action_data)
end

function battle_mod:post_action(action)
    if action._anger then
        table.insert(self._anger_actions, action)
        return
    end
    table.insert(self._action_list, action)
end

function battle_mod:add_anger_action(action)
    table.insert(self._anger_stack, action)
    self._ins:bpause(true)
end

function battle_mod:add_bupdate(rpg_object)
    table.insert(self._blist, rpg_object) 
    self._bmap[rpg_object._oid] = #self._blist
end

function battle_mod:remove_bupdate(rpg_object)
    local b_idx = self._bmap[rpg_object._oid]
    local end_idx = #self._blist
    local end_obj = self._blist[end_idx] 

    self._bmap[end_obj._oid] = b_idx
    self._blist[b_idx] = end_obj

    self._bmap[rpg_object._oid] = nil
    table.remove(self._blist, end_idx)
end

function battle_mod:add_rupdate(rpg_object)
    table.insert(self._rlist, rpg_object) 
    self._rmap[rpg_object._oid] =  #self._rlist
end

function battle_mod:remove_rupdate(rpg_object)
    local b_idx = self._rmap[rpg_object._oid]
    local end_idx = #self._rlist
    local end_obj = self._rlist[end_idx] 
    self._rlist[b_idx] = end_obj
    self._rmap[end_obj._oid] = b_idx
    self._rmap[rpg_object._oid] = nil
    table.remove(self._rlist, end_idx)
end

function battle_mod:update_anger_action_one(dt)
    local tail = #self._anger_stack
    local action =  self._anger_stack[tail]
    action._remain_time = action._remain_time - dt
    action:update()
    if action:is_finish() then
        table.remove(self._anger_stack, tail)
        action:on_exit()
        if tail == 1 then
            self._ins:bpause(false)
        end
    end
end

function battle_mod:update_anger_action(dt)
    local tail = #self._anger_stack
    if tail == 0 then
        return
    end
    local need_pause = false
    for i = tail, 1, -1 do
        local action =  self._anger_stack[i]
        action._remain_time = action._remain_time - dt
    --     self._ins:post_event({ id = RPG_EVENT_TYPE.DEBUG_EVENT, 
    --     event_time = self._ins:get_btime(), 
    --     name="update_anger_action", 
    --     remain_time = action._remain_time, 
    --     dt = dt, 
    --     _cls_name = action._cls_name,
    --     _parse_time = action._parse_time,
    --     _dur = action._dur,
    --     skill_id = action._sk._id,
    --     _skill_pause = action._sk._skill_pause,
    -- })
        action:update()
        if action:is_finish() then
            table.remove(self._anger_stack, i)
            action:on_exit()
        elseif not need_pause and action:parse() then
            need_pause = true
        end
    end

    if not need_pause then
        self._ins:bpause(false)
    end
end

function battle_mod:excute_action(action_data)
    local contructor = T.rpg_action[action_data.id]
    local action = contructor(self._ins, action_data)
    local ety = self._ety_map[action._eid]
    if not ety:can_do_action(action) then
        return
    end

    if ety._cur_action then
        ety._cur_action:on_exit(action)
    end
    ety._cur_action = action
    if action._anger then
        self:add_anger_action(action)
        ety._cur_action = nil
    end
    action:on_enter()
end

function battle_mod:create_ety()
end

-----------non_combat 是否不参战 , 不参战的单位不会作为技能的目标
function battle_mod:add_ety(ety, non_combat)
    ety:init()
    if not non_combat then
        table_insert(self._combat_list, ety)
    end
    table_insert(self._ety_list, ety)
    self._ety_map[ety._eid] = ety
end

function battle_mod:dispatch_action() --
end

function battle_mod:update_etys()
    for _, ety in ipairs(self._ety_list) do
        ety:update()
    end
end

function battle_mod:rem_ety()
end

function battle_mod:get_ety(eid)
    return self._ety_map[eid]
end

battle_mod.pos_map = battle_mod.pos_map or {}
local pos_map = battle_mod.pos_map

battle_mod.pos_map[RPG_POS_TYPE.CASTER] = function(team, caster)
    return caster
end

battle_mod.pos_map[RPG_POS_TYPE.EVENT_TARGET] = function(team, caster)
    return caster._event_target
end

battle_mod.pos_map[RPG_POS_TYPE.EVENT_CASTER] = function(team, caster)
    return caster._event_caster
end

battle_mod.pos_map[RPG_POS_TYPE.ACTOR] = function(team, caster, eff_actor_pos)
    return eff_actor_pos
end


battle_mod.pos_map[RPG_POS_TYPE.NEAREST_CAN_SELECTED] = function(team, caster, eff_actor_pos, exclude_etys)
    local nearest_ety = nil
    local dis = nil
    local ety_list = team._ety_list
    local x = eff_actor_pos and eff_actor_pos._x or caster._x
    local y = eff_actor_pos and eff_actor_pos._y or caster._y
    -- local radius = caster._p.RPG_Radius  
    for i=1, #ety_list  do
        local ety = ety_list[i]
        if not ety:can_selected() or ety == caster or exclude_etys and exclude_etys[ety._eid] then
            goto CONTINUE
        end
        local td = nil 
        if ety._front then
            td = ety:dis(x, y)
        else
            td = rpg_dis(x, y, ety._x, ety._y)
            td = td - ety._p.RPG_Radius -- - radius
        end
        if not dis or td < dis then
            dis = td
            nearest_ety = ety
        end
        ::CONTINUE::
    end
    return nearest_ety
end

battle_mod.get_nearest_target = battle_mod.pos_map[RPG_POS_TYPE.NEAREST_CAN_SELECTED]

battle_mod.pos_map[RPG_POS_TYPE.NEAREST] = function(team, caster, eff_actor_pos)
    local nearest_ety = nil
    local dis = nil
    local ety_list = team._ety_list
    local x = eff_actor_pos and eff_actor_pos._x or caster._x
    local y = eff_actor_pos and eff_actor_pos._y or caster._y
    for i=1, #ety_list  do
        local ety = ety_list[i]
        if not ety:can_selected() then
            goto CONTINUE
        end
        local td = rpg_dis(x, y, ety._x, ety._y)
        td = td - ety._p.RPG_Radius -- - radius
        if not dis or td < dis then
            dis = td
            nearest_ety = ety
        end
        ::CONTINUE::
    end
    return nearest_ety
end

battle_mod.pos_map[RPG_POS_TYPE.FPOS] = function(team, caster)--, eff_actor_pos)
    return team._hero_map[caster._fpos]
end

battle_mod.pos_map[RPG_POS_TYPE.HP_PERRCENT_MIN] = function(team)--, caster, eff_actor_pos)
    local ret_ety = nil
    local percent = 2
    local ety_list = team._ety_list
    for i=1, #ety_list  do
        local ety = ety_list[i]
        local p = ety:hp_percent()
        if p < percent then
            percent = p
            ret_ety = ety
        end
        ::CONTINUE::
    end
    return ret_ety
end

battle_mod.pos_map[RPG_POS_TYPE.FARTHEST] = function(team, caster, eff_actor_pos)
    local ret_ety = nil
    local dis = nil
    local ety_list = team._ety_list
    local x = eff_actor_pos and eff_actor_pos._x or caster._x
    local y = eff_actor_pos and eff_actor_pos._y or caster._y
    for i=1, #ety_list  do
        local ety = ety_list[i]
        local td = rpg_dis(x, y, ety._x, ety._y)
        td = td - ety._p.RPG_Radius -- - radius
        if not dis or td > dis then
            dis = td
            ret_ety = ety
        end
        ::CONTINUE::
    end
    return ret_ety
end

battle_mod.pos_map[RPG_POS_TYPE.FPOS_1] = function(team)--, caster, eff_actor_pos)
    return team._hero_map[1]
end
battle_mod.pos_map[RPG_POS_TYPE.FPOS_2] = function(team)--, caster, eff_actor_pos)
    return team._hero_map[2]
end
battle_mod.pos_map[RPG_POS_TYPE.FPOS_3] = function(team)--, caster, eff_actor_pos)
    return team._hero_map[3]
end
battle_mod.pos_map[RPG_POS_TYPE.FPOS_4] = function(team)--, caster, eff_actor_pos)
    return team._hero_map[4]
end
battle_mod.pos_map[RPG_POS_TYPE.FPOS_5] = function(team)--, caster, eff_actor_pos)
    return team._hero_map[5]
end

battle_mod.range_filter = battle_mod.range_filter or {
}
local range_filter = battle_mod.range_filter

range_filter[RPG_RANGE_TYPE.CIRCLE] = function(ety, range_param, skill_orient)
    local circle_x = skill_orient._sx or skill_orient._x
    local circle_y = skill_orient._sy or skill_orient._y
    local radius = range_param[2] + ety._p.RPG_Radius
    return rpg_in_circle(ety._x, ety._y, circle_x, circle_y, radius)
end

range_filter[RPG_RANGE_TYPE.RECT] = function(ety, range_param, skill_orient)
    local x = skill_orient._sx or skill_orient._x
    local y = skill_orient._sy or skill_orient._y
    local normalized_dx = skill_orient._dir_x
    local normalized_dy = skill_orient._dir_y
    local ety_radius = ety._p.RPG_Radius
    local length = range_param[2] + ety_radius
    local width = range_param[3] + ety_radius * 2
    local ret = rpg_in_rect(ety._x, ety._y, x, y, normalized_dx, normalized_dy, width, length)
    return ret
end

range_filter[RPG_RANGE_TYPE.SECTOR] = function(ety, range_param, skill_orient)
    local circle_x = skill_orient._sx or skill_orient._x
    local circle_y = skill_orient._sy or skill_orient._y


    local normalized_dx, normalized_dy = rpg_normalize(skill_orient._dir_x, skill_orient._dir_y)

    -- local normalized_dx = skill_orient._dir_x
    -- local normalized_dy = skill_orient._dir_y
    local angle = range_param[2]
    local radius = range_param[3] + ety._p.RPG_Radius
    return rpg_in_sector(ety._x, ety._y, circle_x, circle_y, normalized_dx, normalized_dy, radius, angle)
end

range_filter[RPG_RANGE_TYPE.ALL] = function(ety, range_param, skill_orient)
    return true
end

range_filter[RPG_RANGE_TYPE.ROW_FRONT] = function(ety, range_param, skill_orient)
    local fpos = ety._fpos2
    return fpos < 3
end

range_filter[RPG_RANGE_TYPE.ROW_BACK] = function(ety, range_param, skill_orient)
    local fpos = ety._fpos2
    return fpos > 2
end

local target_search_cfg = {
----skill配置
    target_type = nil,
    target_pos = nil,
    range = nil,
    max_hit = nil
}

local search_param = {

    ----运行数据
    ety = nil, --技能释放者
    x = nil, --目标位置
    y = nil,
    dir_x = nil, --范围朝向
    dir_y = nil,
    filter_func = nil,
}

battle_mod.target2orient = battle_mod.target2orient or {}
local target2orient = battle_mod.target2orient

target2orient[RPG_TARGET_POS_DIR.TARGET] = function(target, pos_param)
    return {
        _eid = target._eid,
        _x = target._x,
        _y = target._y,
        _dir_x = target._dir_x,
        _dir_y = target._dir_y,
    }
end

target2orient[RPG_TARGET_POS_DIR.FRONT] = function(target, pos_param)
    local length = (pos_param[2] or 0)
    local x = math.floor(target._x + length * target._dir_x)
    local y = math.floor(target._y + length * target._dir_y)
    return {
        __eid = target._eid,
        _off_len_x = length,
        _off_len_y = length,
        _x = x,
        _y = y,
        _dir_x = target._dir_x,
        _dir_y = target._dir_y,
    }
end

target2orient[RPG_TARGET_POS_DIR.BACK] = function(target, pos_param)
    local length = (pos_param[2] or 0)
    local x = math.floor(target._x - length * target._dir_x)
    local y = math.floor(target._y - length * target._dir_y)
    return {
        __eid = target._eid,
        _off_len_x = -length,
        _off_len_y = -length,
        _x = x,
        _y = y,
        _dir_x = target._dir_x,
        _dir_y = target._dir_y,
    }
end

function battle_mod:search_target_orient(target_search_cfg, skill_target)
    local TargetOffset = target_search_cfg.TargetOffset
    local pos_offset = TargetOffset and TargetOffset[1] or RPG_TARGET_POS_DIR.TARGET
    local skill_orient = target2orient[pos_offset](skill_target, TargetOffset)
    return skill_orient
end

function battle_mod:use_actor_pos(cfg_pos, eff_actor)
    return cfg_pos == RPG_POS_TYPE.ACTOR or eff_actor._actor_type ~= RPG_EFFECT_ACTOR.SKILL
end

function battle_mod:_search_target(caster, pos_type, pos, eff_actor, exclude_etys, retarget_nearest, select_dead, lock_targets)
    local target = lock_targets and lock_targets[pos_type]
    if target then
        return target
    end

    local team = pos_type == RPG_TARGET_TYPE.SELF and self._team_list[caster._tid] or self:get_enemy_team(caster._tid)
    local actor_pos = eff_actor and self:use_actor_pos(pos, eff_actor) and eff_actor.actor_pos and eff_actor:actor_pos()
  
    ------------处理skill_effect_acotr, 其他 处理成actor的位置 而不是施法者位置，因为在此之前没有RPG_POS_TYPE.ACTOR类型
    target = pos_map[pos](team, caster, actor_pos)
    if exclude_etys and target and exclude_etys[target._eid] or 
    retarget_nearest and(not target or target.can_selected and not target:can_selected() and not select_dead) 
    then
        target = pos_map[RPG_POS_TYPE.NEAREST_CAN_SELECTED](team, caster, actor_pos, exclude_etys)
    end
    if lock_targets then
        lock_targets[pos_type] = target
    end
    return target
end

function battle_mod:search_target(target_search_cfg, caster, eff_actor, exclude_etys, lock_targets)
    local start_target
    local end_target
    local redirect_actor = caster._redirect_actor
    if redirect_actor and (not eff_actor or eff_actor._actor_type ~= RPG_EFFECT_ACTOR.SKILL or eff_actor._mode ~= RPG_SKILL_TYPE.PASSIVE) then
        start_target = caster
        end_target = redirect_actor:redirect_target()
        if exclude_etys and end_target and exclude_etys[end_target._eid] then
            return
        end
    else
        local target_type = target_search_cfg.TargetType 
        local target_pos = target_search_cfg.TargetPos or RPG_POS_DEFAULT
        end_target = self: _search_target(caster, target_type, target_pos, eff_actor, exclude_etys,true,target_search_cfg.select_dead,lock_targets)

        local start_type = target_search_cfg.StartType 
        local start_pos = target_search_cfg.StartPos
        if start_type then
            start_target = self: _search_target(caster, start_type, start_pos, eff_actor, exclude_etys, true,nil,lock_targets)
        else
            start_target = caster
        end

    end
    if not end_target then
        return
    end

    local target_orient = self:search_target_orient(target_search_cfg, end_target)
    if start_target and start_target._eid ~= end_target._eid then
        target_orient._seid = start_target._eid
        target_orient._sx = start_target._x
        target_orient._sy = start_target._y
        target_orient._dir_x , target_orient._dir_y = rpg_dir(target_orient._sx, target_orient._sy, target_orient._x, target_orient._y)
    else
        target_orient._dir_x, target_orient._dir_y = caster._dir_x, caster._dir_y
    end
    return target_orient
end

-----------搜索技能目标, 搜索是技能目标时，位置判定采用释放者位置
-----------搜索buff,bullet目标时，需要将eff_actor_pos传入进来做位置判定


local self_ety = function(caster, ety)
    return ety._tid == caster._tid
end

local enemy_ety = function(caster, ety)
    return ety._tid ~= caster._tid
end

function battle_mod:search_targets(target_search_cfg, eff_env, skill_orient, result_list, filter_func)
    local entity = eff_env.ety
    local range_param = target_search_cfg.Range
    local range_type = range_param and range_param[1]
    if not range_type then
        local skill_target = self:get_ety(skill_orient._eid)
        if not skill_target then
            return
        end
        local _ = result_list and table_insert(result_list, skill_target)
        return 
    end

    local cfg_filter = target_search_cfg._Filter

    local team = target_search_cfg.TargetType == RPG_TARGET_TYPE.SELF and self._team_list[entity._tid] or self:get_enemy_team(entity._tid)
    local ety_list = team._ety_list

    local range_filter = range_filter[range_type]

    local max_count = target_search_cfg.MaxHit
    local sort_func = target_search_cfg._Sort

    if entity._eid == 1001 then
        local a = 1
        a = 2
    end
    for _, ety in ipairs(ety_list) do
        if not ety:can_selected() then
            goto CONTINUE
        end
        if filter_func and not filter_func(ety) then
            goto CONTINUE
        end

        if cfg_filter and not cfg_filter(nil, ety._p, nil, nil) then
            goto CONTINUE
        end

        if range_filter and not range_filter(ety, range_param, skill_orient) then
            goto CONTINUE
        end
        
        table_insert(result_list, ety)
        ::CONTINUE::
    end

    if sort_func then
        table_sort(result_list, function(a, b)
            return sort_func(nil, a._p, b._p, nil)
        end)
    end
    if max_count and max_count < #result_list then
        -- for i = #result_list, max_count, -1 do
        --     table_remove(result_list, i)
        -- end
        for i = 1, max_count do
            local t = self._rand:range(#result_list)
            local tv = result_list[i]
            result_list[i] = result_list[t]
            result_list[t] = tv
        end

        result_list[max_count+1] = nil
    end
end

function battle_mod:filter_target(ety, target_search_cfg, eff_env, skill_orient)
    local entity = eff_env.ety
    local range_param = target_search_cfg.Range
    local range_type = range_param and range_param[1]
    if not range_type then
        -- local _ = result_list and table_insert(result_list, skill_target)
        return 
    end

    local cfg_filter = target_search_cfg._Filter

    local team_filter = target_search_cfg.TargetType == RPG_TARGET_TYPE.SELF and self_ety or enemy_ety

    if not team_filter(entity, ety) then
        return false
    end

    if cfg_filter and not cfg_filter(nil, ety._p, nil, nil) then
        return false
    end

    local range_filter = range_filter[range_type]
    if range_filter and not range_filter(ety, range_param, skill_orient) then
        return false
    end

    return true
end

function battle_mod:get_enemy_team(teamid)
    if teamid == RPG_TEAM_ID.TEAM_1 then
        return self._team_list[RPG_TEAM_ID.TEAM_2]
    elseif teamid == RPG_TEAM_ID.TEAM_2 then
        return self._team_list[RPG_TEAM_ID.TEAM_1]
    end
end

function battle_mod:check_timeout()
    local btime = self._ins:get_btime()
    -- if btime >= 5 * 1000 then-- self._ins._init_data.max_battle_time then
    if  btime >= self._ins._init_data.max_battle_time then
        self:finish(BattleResult.WIN)
        return true
    end
end

function battle_mod:check_rule()
    local all_dead = true
    for _, hero in pairs(self._team_list[RPG_TEAM_ID.TEAM_1]._hero_map) do
        if not hero:is_dead2() then
            all_dead = false;
            break
        end
    end
    if all_dead then
        self:finish(BattleResult.WIN)
        return
    end
    all_dead = true
    for _, hero in ipairs(self._team_list[RPG_TEAM_ID.TEAM_2]._ety_list) do
        if not hero:is_dead2() then
            all_dead = false;
            break
        end
    end
    if all_dead then
        local td_born_mod = self._ins._td_born_mod
        if td_born_mod then
            if td_born_mod:is_finish() then
                self:finish(BattleResult.FAIL)
            end
        else
            self:finish(BattleResult.FAIL)
        end
        return
    end
end

function battle_mod:finish(win)
    if  self._bfin then
        return
    end 
    self._bfin = true
    self._ins.result = {
        win = win
    }
    self._ins:post_event({ id = RPG_EVENT_TYPE.BATTLE_END, bid = self._ins._bid, event_time = self._ins:get_btime(), win = win })
end

function battle_mod:add_rule()
end

function battle_mod:enable_rule()
end

function battle_mod:disable_rule()
end


function battle_mod:stop()
end
