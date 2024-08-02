local ipairs = ipairs
local table_insert = table.insert
local table_remove = table.remove
local abs = math.abs
local floor = math.floor
local band = bit.band
local bor = bit.bor
local rpg_get_value = rpg_get_value
local T = T
local RPG_I2F = RPG_I2F
local RPG_EVENT_TYPE = RPG_EVENT_TYPE
local resmng = resmng
local max = math.max
local RPG_BASE_ACCURACY = RPG_BASE_ACCURACY

local rpg_effect = class2("rpg_effect", function()
end)

rpg_effect.effects = {

}

rpg_effect.effects_inv = {

}

function rpg_effect._do_effect_id(eff_env, target_orient, eff_id, peff_funcs, effs_idx, eff_idx, lock_targets)
    local caster = eff_env.ety
    local battle_mod = caster._ins._battle_mod

    -- RPG_DEBUG("[RPG]%s do_effect_id eid=%s oid=%s cfgid=%s env_lv=%s eff=%s", caster._ins:log_str(), caster._eid, eff_env.actor._oid, eff_env.actor._id, eff_env.level, eff_id)
    local eff_cfg = resmng.prop_rpg_battle_effect[eff_id]
    if eff_cfg.SusRate then
        if not battle_mod._rand:sus(eff_cfg.SusRate) then
            return
        end
    end
    local eff_func = rpg_effect.effects[eff_cfg.Effect]
    local eff_param = eff_cfg._EffectParam
    local is_aoe = eff_cfg.Range ~= nil

    if not is_aoe then
        -----------------BUFF的 单体效果默认给BUFF持有者 不重新搜索目标
        if not eff_env.no_search then
            if eff_env.force_search or eff_env.actor._actor_type ~= RPG_EFFECT_ACTOR.BUFF or not target_orient._eid then
                target_orient = battle_mod:search_target(eff_cfg, caster, eff_env.actor, nil, lock_targets)
                if not target_orient then
                    return
                end
            end
        end
        if eff_cfg.ChangeDir then
            caster:set_dir(target_orient._dir_x, target_orient._dir_y)
        end
        target_orient._eid = target_orient._eid or target_orient.__eid
        eff_env.__eff_id = eff_id
        local sus, f = RPG_SAVE_CALL(eff_func, eff_env, target_orient, eff_param, eff_id)
        if sus then
            local _ = f and f()
        else
            RPG_ERR("[RPG] rpg_effect config err eff=%d err=%s", eff_id, f)
        end
        -- local f = (eff_env, target_orient, eff_param)
        -- local _ = f and f()
        return
    end

    local result_list = {}
    local eff_funcs = peff_funcs or {}
    local no_search = eff_env.no_search
    if not no_search then
    target_orient = not no_search and battle_mod:search_target(eff_cfg, caster, eff_env.actor, nil, lock_targets)
        if not target_orient then
            return
        end
    end
    if eff_cfg.ChangeDir then
        caster:set_dir(target_orient._dir_x, target_orient._dir_y)
    end
    battle_mod:search_targets(eff_cfg, eff_env, target_orient, result_list)
    for i = 1, #result_list do
        local ety = result_list[i]
        if ety._eid == caster._eid then  ----------------自己的效果最后生效， 不然加的基于自身属性的效果会变多
            ety =  result_list[#result_list]
            result_list[i] = ety
            result_list[#result_list] = caster
        end
        eff_env.__eff_id = eff_id
        local sus, f = RPG_SAVE_CALL(eff_func, eff_env, ety, eff_param, eff_id)
        if sus then
            -- local _ = f and f()
            -- local f = eff_func(eff_env, ety, eff_param)
            local _ = f and table_insert(eff_funcs, f)
        else
            RPG_ERR("[RPG] rpg_effect config err eff=%d err=%s", eff_id, f)
        end
    end

    local ins = eff_env.ins
    ins:post_event({ id = RPG_EVENT_TYPE.EFFECT, 
    event_time = ins:get_btime(), 
    oid = eff_env.actor._oid,
    effs_idx = effs_idx,
    eff_idx = eff_idx,
    eff_id = eff_id,
    eid = caster._eid,
    x = target_orient._x,
    y = target_orient._y,
    sx = target_orient._sx,
    sy = target_orient._sy,
    --dir_x = target_orient._dir_x,
    --dir_y = target_orient._dir_y
    })

    if peff_funcs then
        return
    end
    for _, f in ipairs(eff_funcs) do
        f()
    end
end

function rpg_effect.do_effect_ids(eff_env, target_orient, eff_ids, effs_idx, lock_targets)
    if not target_orient then
        local first_eff_cfg = resmng.prop_rpg_battle_effect[eff_ids[1]]
        target_orient = eff_env.ins._battle_mod:search_target(first_eff_cfg, eff_env.ety, eff_env.actor, nil, lock_targets) 
        if not target_orient then
            return
        end
    end

    if eff_ids ~= nil then
        if #eff_ids == 1 then
            rpg_effect._do_effect_id(eff_env, target_orient, eff_ids[1],nil, effs_idx, 1,lock_targets)
            eff_env.tmp = nil
            return 
        end
        local eff_funcs = {}
        for i, eff_id in ipairs(eff_ids) do
            rpg_effect._do_effect_id(eff_env, target_orient, eff_id, eff_funcs,effs_idx, i,lock_targets)
        end
        
        for _, f in ipairs(eff_funcs) do
            f()
        end
    end
    eff_env.tmp = nil
end

rpg_effect_ENV = {
    dmg_factor = 2
}




--[[
{
    时间,
    {效果1, 效果2, ...},
}





单体伤害配置
{ "DAMAGE", 50,}


圆形群体伤害
{{ 300, { {"DAMAGE", 50,} } ,{Range = {2, 1000} } }}

]]


function rpg_effect.can_add_status()
end

function rpg_effect.add_group_failed(group_id, buff_actor, target)
end

function rpg_effect.add_group_interrupt(group_id, buff_actor, target)

end

rpg_effect.event_handles = rpg_effect.event_handles or {}
local event_handles = rpg_effect.event_handles

-- event_handles[RPG_EVENT_TYPE.DEAD] = function(eff_env, _, _, event_filter, handle)
--     local actor = eff_env.actor
--     local ety = eff_env.ety
--     local ep = ety._p
--     local ins = eff_env.ins
--     -- local tp = target._p
--     local listen_func = nil
--     local battle_mod = ins._battle_mod
--     local get_ety = battle_mod.get_ety
--     listen_func = function(e)
--         local target = get_ety(e.eid)
--         local filter, remove = event_filter(actor._lv, ep, target._p, actor)
--         if filter then
--             handle(remove)
--         end
--     end
--     ins:add_event_listener(RPG_EVENT_TYPE.DEAD, listen_func)
-- end

event_handles[RPG_EVENT_TYPE.EVENT_DEFAULT] = function(event_type, eff_env, _, _, event_filter, handle)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local ins = eff_env.ins
    -- local tp = target._p
    local listen_func = nil
    local battle_mod = ins._battle_mod
    local get_ety = battle_mod.get_ety
    listen_func = function(e)
        local target = get_ety(battle_mod, e.eid)
        local filter, remove = event_filter(actor._lv, ep, target._p, actor)
        if filter then
            handle(remove, target)
        end
    end

    local remove_func = function() 
        ins:remove_event_listener(event_type, listen_func)
    end

    ins:add_event_listener(event_type, listen_func)
    return remove_func
end


rpg_effect.event_damage_hanlde = rpg_effect.event_damage_hanlde or {}
local damage_event_filter_func = rpg_effect.event_damage_hanlde

damage_event_filter_func[RPG_DAMAGE_CATEGROTY.SKILL_TYPE] = function(ins, damage_event, skill_type)
    local skill_id = damage_event.skill_id
    local prop_rpg_battle_skill = resmng.prop_rpg_battle_skill[skill_id]
    return prop_rpg_battle_skill.Mode == skill_type
end

damage_event_filter_func[RPG_DAMAGE_CATEGROTY.DAMAGE_TYPE] = function(ins, damage_event, damage_type)
    -- local damage_type_bit = bit.lshift(1, damage_type)
    return bit.band(damage_event.dmg_bit, damage_type) > 0
end


event_handles[RPG_EVENT_TYPE.DAMAGE] = function(event_type, eff_env, ety, params, event_filter, handle)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    -- local tp = target._p
    local listen_func = nil
    local ins = eff_env.ins
    local battle_mod = ins._battle_mod
    local get_ety = battle_mod.get_ety

    local listen_kind = params[1]
    local listen_value = params[2]

    local handle_func = damage_event_filter_func[listen_kind]
    local ins = ety._ins

    listen_func = function(e)
        if not handle_func(ins, e, listen_value) then
            return
        end

        local target = get_ety(battle_mod, e.target)
        local event_caster = get_ety(battle_mod, e.eid)
        ep = ep or ety._p
        local tp = target._p
        local filter, remove = event_filter(actor._lv, ep, tp, actor, event_caster._p)
        if filter then
            handle(remove, target, event_caster)
        end
    end

    local remove_func = function() 
        ins:remove_event_listener(event_type, listen_func)
    end

    ins:add_event_listener(event_type, listen_func)
    return remove_func
end

event_handles[RPG_EVENT_TYPE.PROP_CHANGE] = function(event_type, eff_env, target, attrs, event_filter, handle)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p
    local listen_func = nil

    listen_func = function(_,_,_,_,alter_actor)
        local event_caster = alter_actor and alter_actor._ety
        local filter, remove = event_filter(actor._lv, ep, tp, actor, event_caster)
        if filter then
            handle(remove, target, event_caster)
        end
    end

    for _, attr in ipairs(attrs) do
        target:listen_prop(attr, listen_func)
    end

    local remove_func = function() 
        for _, attr in ipairs(attrs) do
            target:remove_listen_prop(attr, listen_func)
        end
    end

    return remove_func
end


-- RPG_OID = 监听事件的人
-- t.RPG_OID = 事件的目标(damage事件 就是被打那个人)
-- c.RPG_OID = 事件的发起者（damage事件 打人的那个人）
function rpg_effect.init_event(_Event,eff_env, ety, callback)
    local event_type = _Event[1]
    local event_params = _Event[2]
    local event_filter_func = _Event[3]
    local event_sus_rate = _Event[4]
    local rand
    if event_sus_rate then
        rand = ety._ins._battle_mod._rand
    end
    local cb = function(remove, event_target, event_caster)
        if not rand or rand:sus(event_sus_rate) then
            ety._event_target = event_target
            ety._event_caster = event_caster
            callback(remove, event_target, event_caster)
            ety._event_target = nil
            ety._event_caster = nil
        end
    end
    local event_handle = T.rpg_effect.event_handles[event_type] or T.rpg_effect.event_handles[RPG_EVENT_TYPE.EVENT_DEFAULT]
    local remove_func = event_handle(event_type, eff_env, ety, event_params, event_filter_func, cb)
    return remove_func
end

-----------------------{事件类型RPG_EVENT_TYPE , 事件参数目前只有PROP_CHANGE有用 ，事件过滤函数}
rpg_effect.effects["EVENT"] = function(eff_env, target_orient, param)
    local ins = eff_env.ins
    local target = ins._battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p
    local event_type = rpg_get_value(param, 1, ep, tp, actor)
    local params = rpg_get_value(param, 2, ep, tp, actor)
    local event_filter = param.src[3]
    local effs = rpg_get_value(param, 4, ep, tp, actor)
    local event_handle = event_handles[event_type]
    if not event_handle then
        local _ = RPG_DEBUG_MOD and RPG_ERR("[RPG] 错误的event_handle %s", event_type)
        return
    end

    return function()
        event_handle(eff_env, target, params, event_filter, function()
            rpg_effect.do_effect_ids(eff_env, target, effs)
        end)
    end
end


--FORCE_MOVE = {speed, time, move_type, cross} {速度， 时间ms, 移动类型, 是否穿人}
---move_type 1 面朝释放者朝向 -----------位移目标
---move_type 2 释放者朝向 -----------位移目标
---move_type 3 位移到目标 -----------位移施法者
rpg_effect.effects["FORCE_MOVE"] = function(eff_env, target_orient, param, aoe)
    local ins = eff_env.ins
    local target = ins._battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p
    local speed = rpg_get_value(param, 1, ep, tp, actor)
    local dur = rpg_get_value(param, 2, ep, tp, actor)
    local move_type = rpg_get_value(param, 3, ep, tp, actor)
    local cross = rpg_get_value(param, 4, ep, tp, actor)
    cross = cross and cross > 0 or false

    return function()
        local owner = target
        if move_type == RPG_FORCE_MOVE_TYPE.MOVE_TO_TARGET_POS then
            owner = ety
        end

        if owner._rpg_buff_force_move then
            owner._rpg_buff_force_move:finish()
        end

        local buff = T.rpg_buff_force_move(ins, owner, speed, dur, move_type, eff_env, target_orient, cross)
        owner:add_buff(buff)
    end
end

rpg_effect.effects["BUFF"] = function(eff_env, target_orient, param, aoe)
    local ins = eff_env.ins
    local target = ins._battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p
    local buff_id = rpg_get_value(param, 1, ep, tp, actor)
    local time = rpg_get_value(param, 2, ep, tp, actor)
    return function()
        local buff = T.rpg_buff(buff_id, ins, target, eff_env, time)
        target:add_buff(buff)
    end
end

rpg_effect.effects["HALO"] = function(eff_env, target_orient, param)
    local ins = eff_env.ins
    local target = ins._battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p
    local buff_id = rpg_get_value(param, 1, ep, tp, actor)
    local time = rpg_get_value(param, 2, ep, tp, actor)
    return function()
        local buff = T.rpg_halo(buff_id, ins, target, eff_env, time)
        target:add_buff(buff)
    end
end

--------------只能挂在buff上面
rpg_effect.effects["ATTR"] = function(eff_env, target_orient, param, eff_id)
    local buff_actor = eff_env.actor
    local ins = eff_env.ins
    local ety = eff_env.ety
    local ep = ety._p

    local target = ins._battle_mod:get_ety(target_orient._eid)
    local tp = target._p
    local real = target._r

    local attrs = {}
    for i = 1, 10 do
        local param_attrs = rpg_get_value(param, i, ep, tp, buff_actor)
        if not param_attrs then
            break
        end

        local attr = rpg_get_value(param_attrs, 1, ep, tp, buff_actor)
        -- if attr == "RPG_AtkSp" then
        --     local a = 1
        --     a = 2
        -- end
        local attr_value = floor(rpg_get_value(param_attrs, 2, ep, tp, buff_actor) )

        if RPG_DEBUG_CHECK then
            local pre_attr_value = real[attr] or 0
            local new_attr_value = pre_attr_value + attr_value
            RPG_DEBUG("[RPG]_ATTR eid=%s target=%s eff=%s attr=%s value=%s new=%s",ety._eid, target._eid, eff_env.__eff_id, attr, attr_value, new_attr_value)
            --if pre_attr_value > 0 and new_attr_value > pre_attr_value * 10 then
            --    RPG_ERR("[RPG] 属性溢出 eid=%s eff=%s attr=%s value=%s new_value=%s", target._eid, eff_env.__eff_id, attr, pre_attr_value, new_attr_value )
            --end
        end


        if abs(attr_value) < 1 then
            goto CONTINUE
        end

        table_insert(attrs, attr)
        table_insert(attrs, attr_value)
        ::CONTINUE::
    end

    return function()
        if buff_actor._eff_inverse then
            local alter_info = {
                eff = "ATTR",
                attrs = attrs,
                target = target,
            }
            table_insert(buff_actor._eff_inverse, alter_info)
        end

        for i = 1, #attrs -1, 2 do
            local attr = attrs[i]
            local attr_value = attrs[i+1]
            local rv = real[attr] or tp[attr]
            local new_prop = rv + attr_value
            if attr == "RPG_Anger" then
                ins:post_event({ 
                    id = RPG_EVENT_TYPE.SKILL_ANGER, 
                    event_time = ins:get_btime(), 
                    eid = target._eid, 
                    anger = attr_value,
                })
            end
            target:alter_prop(attr, new_prop, buff_actor)
        end


    end
end

rpg_effect.effects_inv["ATTR"] = function(eff_env, alter_info)
    local target = alter_info.target
    local real = target._r
    local attrs = alter_info.attrs
    for i = 1, #attrs -1 do
        local attr = attrs[i]
        local attr_value = attrs[i+1]
        local new_prop = real[attr] - attr_value
        target:alter_prop(attr, new_prop, eff_env.actor)
    end

end

----RPG_SHARE_DAMAGE_TYPE.SHARE              大家share受到伤害    {1,    释放者受到比例的比例}
--- RPG_SHARE_DAMAGE_TYPE.TRANSFER           施法者受到伤害 转移一部分由其他人承担
--- RPG_SHARE_DAMAGE_TYPE.GUARD              施法者代替 其他人承担部分伤害
---Factor 施法者比例
---buff_id
---time 持续时间
---{RPG_SHARE_DAMAGE_TYPE, Factor, buff_id, time, lv}
rpg_effect.effects["SHARE_DAMAGE"] = function(eff_env, target_orient, param)
    local ins = eff_env.ins
    local target = ins._battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p

    local tmp = eff_env.tmp
    if not tmp then
        tmp = {}
        eff_env.tmp = tmp
    end
    local share_type = rpg_get_value(param, 1, ep, tp, actor)
    local factor = rpg_get_value(param, 2, ep, tp, actor)
    factor = math.min(1, factor/100)
    local buff_id = rpg_get_value(param, 3, ep, tp, actor)
    local time = rpg_get_value(param, 4, ep, tp, actor)

    if not tmp.shareDamage then
        if not ety:can_add_buff(buff_id)then
            return
        else
            local main_buff = T.rpg_buff_share_damage(buff_id, ins, ety, eff_env, time, nil, share_type, factor)
            tmp.shareDamage = main_buff
            main_buff._main_ety = ety
            ety:add_buff(main_buff)
        end
    end

    if ety == target then
        return
    end

    return function()
        local main_buff = tmp.shareDamage
        local buff = T.rpg_buff_share_damage(buff_id, ins, target, eff_env, time, main_buff, share_type, factor)
        main_buff:add_child(buff)
        target:add_buff(buff)
    end
end

---Param1 count 护盾伤害
---Param2 factor 护盾抵伤系数
---Param3 damage_type 伤害类型
---Param4 buff_id 护盾BUFF_id
---Param5 time 护盾持续时间
rpg_effect.effects["SHIELD"] = function(eff_env, target_orient, param)
    local ins = eff_env.ins
    local target = ins._battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p

    local count = rpg_get_value(param, 1, ep, tp, actor)
    -- local factor = RPG_I2F(rpg_get_value(param, 2, ep, tp, actor) or 0)
    -- local damage_type = rpg_get_value(param, 3, ep, tp, actor)
    local buff_id = rpg_get_value(param, 4, ep, tp, actor)
    local time = rpg_get_value(param, 5, ep, tp, actor)

    if not target:can_add_buff(buff_id) or time <= 0 or count <= 0 then
        return
    end

    return function()
        local rpg_buff_shield = T.rpg_buff_shield(buff_id, ins, target, eff_env, time, 1, count, 1)
        target:add_buff(rpg_buff_shield)
    end
end

---Param1 count 回血系数 受治疗率 受治疗率加成
---Param2 final_count 固定回血
rpg_effect.effects["HEAL"] = function(eff_env, target_orient, param, eff_id)
    local ins = eff_env.ins
    local target = ins._battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p

    local count = rpg_get_value(param, 1, ep, tp, actor) 
    local final_count = rpg_get_value(param, 2, ep, tp, actor) or 0

    local heal = 1 + RPG_I2F(ep.RPG_Heal)
    local health = 1 + RPG_I2F(tp.RPG_Health)

    count = count * heal * health + final_count

    if count < 0 then
        count = 0
    end

    return function()
        target:damage(-count, eff_env, RPG_DAMAGE_TYPE.HEAL, eff_id)
    end
end

rpg_effect.dmg_miss = function(damage_bit, ep, tp, damage, rpg_rand)
    local RPG_Accuracy = (ep.RPG_Accuracy)
    local RPG_Dodge = (tp.RPG_Dodge)

    local a = RPG_Dodge -RPG_Accuracy -- max((RPG_Accuracy - RPG_Dodge) + 1000, RPG_BASE_ACCURACY)
    a = rpg_clamp(0,700,a)
    if rpg_rand:sus(a) then -----MISS
        damage_bit = bor(damage_bit, RPG_DAMAGE_TYPE.MISS)
        return 0, damage_bit
    end
    return damage,damage_bit
end

rpg_effect.dmg_crit = function(damage_bit, ep, tp, damage, rpg_rand)
    local RPG_Crit = ep.RPG_Crit
    local RPG_CritAnti = tp.RPG_CritAnti
    local a = max(RPG_Crit - RPG_CritAnti, 0)
    if rpg_rand:sus(a) then -----CRIT 
        damage_bit = bor(damage_bit, RPG_DAMAGE_TYPE.CRIT)
        local RPG_CritEnhance = ep.RPG_CritEnhance
        local RPG_CritReduce = tp.RPG_CritReduce
        local d = RPG_I2F(RPG_CritEnhance - RPG_CritReduce)
        local crit_factor = 2 + d * 0.005
        if d > 30 or d < 30 then
            crit_factor = crit_factor - 0.003 * 30
        end
        crit_factor = rpg_clamp(1.25,2.75,crit_factor) 
        damage = damage * crit_factor
    end
    return damage, damage_bit
end

rpg_effect.dmg_block = function(damage_bit, ep, tp, damage, rpg_rand)
    local RPG_BlockAnti = ep.RPG_BlockAnti
    local RPG_Block = tp.RPG_Block
    local a = max(RPG_Block - RPG_BlockAnti, 0)
    if rpg_rand:sus(a) then -----BLOCK 
        damage_bit = bor(damage_bit, RPG_DAMAGE_TYPE.BLOCK)
        damage = damage * RPG_BASE_BLOCK
    end
    return damage, damage_bit
end

---Param1 damageFactor 技能系数
---Param2 idamage 直接伤害
---Param3 damage_type 伤害类型
rpg_effect.effects["DAMAGE"] = function(eff_env, target_orient, param, eff_id)
    local ins = eff_env.ins
    local battle_mod = ins._battle_mod
    local target = battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p

    local damageFactor = RPG_I2F( rpg_get_value(param, 1, ep, tp, actor) )
    local idamage = rpg_get_value(param, 2, ep, tp, actor) or 0
    local damage_type = rpg_get_value(param, 3, ep, tp, actor) or RPG_DAMAGE_TYPE.REAL

    local damage = 0 --(damageFactor * ep.RPG_Atk) + idamage


    local rpg_rand = battle_mod._rand
    local damage_bit = damage_type
    local RPG_Atk = ep.RPG_Atk
    local RPG_Def = tp.RPG_Def
    
    if damage_type == RPG_DAMAGE_TYPE.REAL then
        damage = (damageFactor * ep.RPG_Atk) + idamage
        goto COUNT
    else
---------------------------基础攻防---------------------------
        local defend_factor = 1 / (1 + RPG_Atk/(5 * RPG_Def))
        damage = RPG_Atk * (1 - defend_factor) * damageFactor + idamage
    end

---------------------------闪避---------------------------
    if damage_type == RPG_DAMAGE_TYPE.DAMAGE then
        damage, damage_bit = rpg_effect.dmg_miss(damage_bit, ep, tp, damage, rpg_rand)
        if damage == 0 then
            goto COUNT
        end
    end
---------------------------暴击---------------------------
    damage, damage_bit = rpg_effect.dmg_crit(damage_bit, ep, tp, damage, rpg_rand)
---------------------------格挡---------------------------
    damage, damage_bit = rpg_effect.dmg_block(damage_bit, ep, tp, damage, rpg_rand)

---------------------------物理增减伤---------------------------
    if damage_type == RPG_DAMAGE_TYPE.DAMAGE then
        damage = damage * max(1 + RPG_I2F(ep.RPG_DamageIncrease - tp.RPG_DamageReduce), 0)
---------------------------魔法增减伤---------------------------
    elseif damage_type == RPG_DAMAGE_TYPE.MAGIC then
        damage = damage * max(1 + RPG_I2F(ep.RPG_MagicIncrease - tp.RPG_MagicReduce), 0)
    end
---------------------------最终增减伤---------------------------
    damage = damage * max(1 + RPG_I2F(ep.RPG_FinalIncrease - tp.RPG_FinalReduce), 0)

::COUNT::
    local shiled_damage = nil
    local shield_list = target._shields--[damage_type]
    if shield_list and #shield_list > 0 then
        -- local damage_without_defend = (damageFactor * ep.RPG_Atk) + idamage
        local pre_damage = damage
        local shield_damage
        local end_idx = nil
        for i, shield in ipairs(shield_list) do
            damage, shield_damage = shield:shield(damage)
            if shield_damage <= 0 then
                break
            end
            end_idx = shield._count <= 0 and i or end_idx
        end

        if end_idx and end_idx > 0 then
            for i = end_idx, 1, -1 do
                local shield = shield_list[i]
                shield:finish()
            end
        end

        -- ins:post_event({ 
        --     id = RPG_EVENT_TYPE.DAMAGE, 
        --     event_time = ins:get_btime(), 
        --     oid = actor._oid,
        --     eid = ety._eid, 
        --     dmg_bit = RPG_DAMAGE_TYPE.DAMAGE,
        --     target = target._eid,
        --     eff_id = eff_id,
        --     skill_id = eff_env.root_actor._id,
        --     -- pos_x = target_orient._x,
        --     -- pos_y = target_orient._y,
        --     damage = damage - pre_damage})
            shiled_damage = damage - pre_damage
            if shiled_damage < 0 then
                target:update_shield_count(actor)
            end
        -- if damage <= 0 then
        --     return
        -- end
    end

    local shares = target._shares
    local composer
    if damage_type ~= RPG_DAMAGE_TYPE.REAL and shares and #shares > 0 then
        composer = T.rpg_damage_composer()
        for _, share_damage in ipairs(shares) do
            damage = share_damage:share_damage(damage, composer)
        end
    end
    if RPG_DEBUG_MOD then
        RPG_LOG("[RPG] %s号位打了%s号位%s点伤害 技能效果=%s 伤害系数=%s 固定伤害=%s",ety._fpos, tp._fpos, damage, eff_id, damageFactor or 0, idamage)
    end
    return function()
        if composer then
            local dmg_map = composer._map
            for _, ety in ipairs(composer._list) do
                local dmg = dmg_map[ety]
                ety:damage(dmg, eff_env, RPG_DAMAGE_TYPE_SHARE_BIT, eff_id)
            end
        end
        target:damage(damage, eff_env, damage_bit, eff_id, shiled_damage)
    end
end
--[[
子弹 BULLET
 {
    RPG_BULLET_TYPE, --子弹类型
    {速度, ...}, --类型参数
    结束效果, --结束效果
    穿透效果, --穿透效果
}
]]
local bullet_type_map = T.rpg_bullet.type_map
rpg_effect.effects["BULLET"] = function(eff_env, target_orient, param)
    local bullet_type = param[1]
    local constructor = bullet_type_map[bullet_type]
    if constructor  then
        constructor(eff_env, target_orient, param)    
    end    
end

--[[
-----吟唱 {吟唱时间 ms, 打断类型 interrupt_type} 吟唱完之后 技能才会继续往后推进
---RPG_SKILL_INTERRUPT_TYPE = {
    INTERRUPT_AND_CAST = 1,        -----------------吟唱被打断并且继续释放
    INTERRUPT = 2, --------------------吟唱被打断 技能直接中断
    NOT_INTERRUPT = 3, --------------------吟唱过程中不可被打断·
}
]]
rpg_effect.effects["CHANT"] = function(eff_env, target_orient, param)
    local ins = eff_env.ins
    local battle_mod = ins._battle_mod
    local target = battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p

    local time = rpg_get_value(param, 1, ep, tp, actor)
    local interrupt_type = rpg_get_value(param, 2, ep, tp, actor)

    actor:wait(time, interrupt_type)
end


-----记录 {记录类型 record_type, 记录名 record_name}
--[[
---记录类型 
RPG_RECORD_TYPE = {
    DAMAGE = 1, -----------------收到的伤害
    }
记录名record_name  actor持续释放时间内唯一， 在其他效果中要用的该值得 通过记录名取值 a:record(record_name)
--]]
rpg_effect.effects["RECORD"] = function(eff_env, target_orient, param)
    local ins = eff_env.ins
    local battle_mod = ins._battle_mod
    local target = battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p

    local record_type = rpg_get_value(param, 1, ep, tp, actor)
    local record_name = rpg_get_value(param, 2, ep, tp, actor)


    local recorder_constructor = T.rpg_battle_record.constructors[record_type]
    local recorder = recorder_constructor(ins, target, actor, record_name)
    -- actor:add_record(recorder)
end

-----------------复活 relive {多少毫秒后复活, 复活后的当前生命值}
rpg_effect.effects["RELIVE"] = function(eff_env, target_orient, param)
    local ins = eff_env.ins
    local target = ins._battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p

    local relive_delay = rpg_get_value(param, 1, ep, tp, actor) or 0
    local hp_inherit_percent = RPG_I2F(rpg_get_value(param, 2, ep, tp, actor) or 1000) 

    ---------------没死就什么都不做
    if not target:is_dead() then
        return
    end

    target._is_reliving = true
    relive_delay = math.max(relive_delay, RPG_RELIVE_DELAY)

    local relive_func = function()
        -- target._is_reliving = false
        -- target:set_state(RPG_ENTITY_STATE.IDLE, true)
        target:alter_prop("RPG_Hp", tp.RPG_HpMax * hp_inherit_percent, actor)
        ins:post_event(target:born_event())
    end

    local relive_func2 = function()
        target._is_reliving = false
        target:set_state(RPG_ENTITY_STATE.IDLE, true)
        -- target:alter_prop("RPG_Hp", tp.RPG_HpMax * hp_inherit_percent, actor)
        -- ins:post_event(target:born_event())
    end


    if relive_delay > 0 then
        ins._battle_mod:add_bupdate(T.rpg_delay(ins,ins:get_btime() + relive_delay-RPG_RELIVE_DELAY,relive_func))
        ins._battle_mod:add_bupdate(T.rpg_delay(ins,ins:get_btime() + relive_delay,relive_func2))
    else
        return relive_func
    end
end

-----------------嘲讽
rpg_effect.effects["TAUNT"] = function(eff_env, target_orient, param)
    local ins = eff_env.ins
    local target = ins._battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p
    local dur = rpg_get_value(param, 1, ep, tp, actor)
    return function()
        local buff = T.rpg_buff_taunt(ins, target, eff_env, dur)
        target:add_buff(buff)
    end
end

-----------------变身
rpg_effect.effects["TRANSFORM"] = function(eff_env, target_orient, param)
    local ins = eff_env.ins
    local target = ins._battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p

    local dur = rpg_get_value(param, 1, ep, tp, actor)
    local skills = rpg_get_value(param, 2, ep, tp, actor)
    -- for i = 1, 10 do
    --     local skill_id = rpg_get_value(param, i, ep, tp, actor)
    --     if not skill_id then
    --         break
    --     end
    --     table_insert(skills, skill_id)
    -- end

    return function()
        local buff = T.rpg_buff_transform(ins, target, eff_env, dur, skills)
        target:add_buff(buff)
    end
end

rpg_effect.effects["ATTACK"] = function(eff_env, target_orient, param)
end

rpg_effect.effects["SKILL"] = function(eff_env, target_orient, param)
end

rpg_effect.effects["ANGER_SKILL"] = function(eff_env, target_orient, param)
end

rpg_effect.effects["MOVE"] = function(eff_env, target_orient, param)
end


rpg_effect.effects["DISPEL"] = function(eff_env, target_orient, param)
    local ins = eff_env.ins
    local target = ins._battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p

    local dtype = rpg_get_value(param, 1, ep, tp, actor)
    local count = rpg_get_value(param, 2, ep, tp, actor) or 99999999
    -- local skills = rpg_get_value(param, 2, ep, tp, actor)
    return function()
        local buffs = target._buffs
        if not buffs then
            return
        end
        for i = #buffs, 1, -1 do
            local buff = buffs[i]
            if not buff then
                goto CONTINUE
            end
            local group_id = buff._cfg.Group
            local prop_rpg_battle_group = group_id and resmng.prop_rpg_battle_group[group_id]
            if prop_rpg_battle_group and prop_rpg_battle_group.Type == dtype then
                count = count - 1
                ety:remove_buff(buff)
            end
            if count <= 0 then
                break
            end

            ::CONTINUE::
        end
    end
end

rpg_effect.effects["ADD_EFFECT"] = function(eff_env, target_orient, param)
    local ins = eff_env.ins
    local target = ins._battle_mod:get_ety(target_orient._eid)
    local actor = eff_env.actor
    local ety = eff_env.ety
    local ep = ety._p
    local tp = target._p

    local eff_id = rpg_get_value(param, 1, ep, tp, actor)
    local time = rpg_get_value(param, 2, ep, tp, actor)
    local skill_id = rpg_get_value(param, 3, ep, tp, actor)
    -- local eff_env =
    --  {
    --     ins = ins,
    --     ety = ety,
    --     actor = actor,
    --     root_actor = eff_env.root_actor,
    --     level = eff_env.level + 1,
    --     is_anger = eff_env.is_anger,
    -- }

    return function()
        local skill = target:search_skill(skill_id)
        if skill then
            skill:add_effect(eff_id, time, eff_env)
        end
    end
end