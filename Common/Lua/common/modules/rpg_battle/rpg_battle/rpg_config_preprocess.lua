-- -- [ 计算展开值 ]
-- function rpg_do_extend(idx, args)
--     if lua_types.is_string(idx) then
--         local key = resmng[idx]
--         local cfg = resmng.prop_skill_extend[key]
--         if not cfg or not cfg._Rule then
--             ERROR("[%s] do_extend: invalid extend rule. ID=%s", _NAME, idx)
--         else
--             return cfg._Rule(args)
--         end
--     end
--     return idx
-- end

function extend_prop_rpg_skill()
    local table = table
    local pairs = pairs
    local ipairs = ipairs
    local unpack = unpack or table.unpack
    local setmetatable = setmetatable

    local lua_types = lua_types
    local prop = resmng.prop_rpg_battle_skill
    local BASIC_SKILL_MAX_LV = BASIC_SKILL_MAX_LV
    local RPG_SKILL_EXTEND_FIELDS = resmng.RPG_SKILL_EXTEND_FIELDS or {}

    local _meta = {
        __index = function(cfg, key)
            return resmng.prop_rpg_battle_skill[cfg._ID][key]
        end
    }
    local conf, copy, cond, factor, buffs
    local args = {}
    for _, idx in ipairs(table.keys(prop)) do
        if idx == 1074100 then
            local a =1
            a = 2
        end
        conf = prop[idx]
        local skill_id_lv0 = idx * 100
        -- conf.Lv = conf.Lv or 0
        for lv = 0, BASIC_SKILL_MAX_LV do
            local copy = {_ID = idx, ID = skill_id_lv0 + lv, Lv = lv, Event = conf.Event, _Event = conf.Event and extend_event(conf.Event)}
            setmetatable(copy, _meta)
            prop[copy.ID] = copy
            args.lv = lv
            -- for _, field in ipairs(RPG_SKILL_EXTEND_FIELDS) do
            --     copy[field] = rpg_do_extend(conf[field], args)
            -- end

            -- if table.not_empty(conf.SkillEffect) then
            --     copy.SkillEffect = table.copy(conf.SkillEffect)
            --     for _, effect in ipairs(copy.SkillEffect) do
            --         cond, factor, buffs = unpack(effect)
            --         factor[3] = do_extend(factor[3], args)
            --         factor[4] = do_extend(factor[4], args)
            --         for _, buff in ipairs(buffs) do
            --             buff[1] = do_extend(buff[1], args)
            --             buff[2] = do_extend(buff[2], args)
            --         end
            --     end
            -- end
        end
    end
end

function rpg_get_effect_extend(lv, src, t, a)

end

function extend_field(config, is_attr)
    if not config then
        return
    end
    local tp = type(config)
    if tp == "number" then
        return config
    elseif tp == "string" then
        -- if string.starts_with(config, "SKILL_EXTEND_") then
        --     local rules = resmng.prop_skill_extend[resmng[config]].Rule
        --     local f = function(lv)
        --         return rules[lv]
        --     end
        --     return f
        -- end
        local code = 'local function fn(lv, src, t, a, c) _env=src return ' .. config .. ' end\nreturn fn'
        local env = setmetatable({ _env = {}}, {
            __index = function(t, k)
                local v = t._env[k]
                if v ~= nil then
                    return v
                end
                return _G[k]
            end,
        })
        local fn, errmsg = load(code, nil, nil, env)
        if fn then
            return fn()
        else
            RPG_ERR("[RPG] extend_field code error code=%s %s", config, errmsg)
            return {"ERROR"}
        end
    elseif tp == "table" then
        local t = {}
        if is_attr then
            for _, conf in ipairs(config) do
                local tt = {}
                tt[1] = conf[1]
                tt[2] = extend_field(conf[2])
                table.insert(t, tt)
            end
            -- t[1] = config[1]
            -- for i = 2, #config do
            --     local v = config[i]
            --     t[i] = extend_field(v)
            -- end
        else
            for i, v in pairs(config) do
                t[i] = extend_field(v)
            end 
        end
        return t
    else
        RPG_ERR("[RPG] extend_field type error ")
        return {"ERROR"}
    end
end

function extend_event(Event)
    return {
        [1] = Event[1],
        [2] = Event[2],
        [3] = extend_field(Event[3]),
        [4] = Event[4],
    }
end

function preprocess_rpg_battle_buff()
    local prop = resmng.prop_rpg_battle_buff
    local conf
    for _, idx in ipairs(table.keys(prop)) do
        conf = prop[idx]
        if conf.Event then
            conf._Event = extend_event(conf.Event)
        end
        if conf.RemoveEvent then
            conf._RemoveEvent = extend_event(conf.RemoveEvent)
        end
    end
end

function preprocess_rpg_battle_skill()
    local prop = resmng.prop_rpg_battle_buff
    local conf
    for _, idx in ipairs(table.keys(prop)) do
        conf = prop[idx]
        if conf.Event then
            conf._Event = extend_event(conf.Event)
        end
    end
end 

function preprocess_rpg_battle_effect()
    local prop = resmng.prop_rpg_battle_effect
    local conf
    for _, idx in ipairs(table.keys(prop)) do
        conf = prop[idx]
        local sus, ret = RPG_SAVE_CALL( extend_field, conf.EffectParam, conf.Effect == "ATTR")
        if not sus then
            RPG_ERR("[RPG]prop_rpg_battle_effect %s config error", idx)
            goto CONTINUE
        end
        conf._EffectParam =ret
        conf._EffectParam.src = conf.EffectParam
        conf._EffectParam.cfg = conf
        conf.select_dead = conf.Effect == "RELIVE"
        if conf.Filter then
            local func =  extend_field(conf.Filter)
            -- conf._Filter = function(ety) 
            --     return not func(nil, ety._p, nil, nil)  
            -- end
            conf._Filter = func
        end
        conf._Sort = extend_field(conf.Sort)

        ::CONTINUE::
    end
end

function preprocess_rpg_battle_group()
    RPG_GROUP_LIMIT_BITS = {}
    local prop = resmng.prop_rpg_battle_group
    local conf
    for _, idx in ipairs(table.keys(prop)) do
        conf = prop[idx]
        local Limit = conf.Limit
        if Limit then
            RPG_GROUP_LIMIT_BITS[conf.ID] = Limit
            --conf._Limit = extend_field(Limit)
        end
    end

    RPG_BUILD_RPG_GROUP_CMDS()
end

function rpg_get_value(prop, k, src, target, actor)
    local v = prop[k]
    return type(v) == "function" and v(actor._lv, src, target, actor) or v
end

function check_prop_rpg_skill()
    local prop = resmng.prop_rpg_battle_skill
end
 
function rpg_config_preprocess()
    preprocess_rpg_battle_group()
    extend_prop_rpg_skill()
    preprocess_rpg_battle_effect()
    preprocess_rpg_battle_buff()
    check_prop_rpg_skill()
end
 