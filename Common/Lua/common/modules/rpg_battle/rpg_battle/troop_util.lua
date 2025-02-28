
module('troop_util', package.seeall)

-- [ 根据arm_id取nav_id ]
function get_nav_id(arm_id)
    local conf = resmng.get_conf('prop_hero_arm', arm_id, false)
    return conf and conf.NavId or 0
end

-- [ 根据arm_id取soldier_type ]
function get_soldier_type(arm_id)
    local conf = resmng.get_conf('prop_hero_arm', arm_id, false)
    return conf and conf.Type or 0
end

-- [ 根据arm_id取arm_class ]
function get_arm_class(arm_id)
    local conf = resmng.get_conf('prop_hero_arm', arm_id)
    return conf and conf.Class or 0
end

-- [ 构造soldier_id ]
function make_soldier_id(arm_id, lv)
    local conf = resmng.get_conf('prop_hero_arm', arm_id)
    if not conf then
        return make_soldier_id(resmng.ARM_DEFAULT_ID, lv)
    end
    assert(conf)
    return arm_id * 1000 + lv
end

-- [ 解析soldier_id ]
function parse_soldier_id(id)
    return {
        arm_id = math.floor(id / 1000),
        lv = id % 1000,
    }
end

-- [ 计算12宫格的布阵中, 部队所在的spawn_point的idx]
function calc_pos_idx_in12(idx, is_atk)
    if is_atk then
        return idx
    else
        return idx + 6
    end
end

-- SLG hero data
function make_hero(hero, idx)
    local ef = table.copy(hero.slg_attr)
    local hero_ef = hero.get_slg_effect and hero:get_slg_effect()
    table.addM(ef, hero_ef)

    local ret = {
        propid = hero.propid,
        lv = hero.lv,
        star = hero.star,
        skills = hero_util.get_combat_skills(hero),
        arm_skills = hero_util.get_arm_skills(hero, hero.army_skill_unlock),
        buffs = hero_util.get_combat_buffs(hero),
        ef = ef,
        power = hero.battle_power or 0,
        equips = hero.get_equip_report_info and hero:get_equip_report_info() or {},
        god_equip = hero.god_equip,
    }
    return ret
end

-- Hx@2023-02-09: 构建rpg英雄数据
function make_rpg_hero_by_data(hero, fpos)
    local attr = {}

    local conf = resmng.prop_hero_basic_byid(hero.propid)
    attr.RPG_Sp = conf.RPG_Sp
    attr.RPG_Anger = 0
    attr.RPG_AngerMax = conf.RPG_Anger
    attr.RPG_AngerHit = conf.RPG_AngerHit
    attr.RPG_AngerKill = conf.RPG_AngerKill
    attr.RPG_Race = conf.RaceType
    attr.RPG_Job = conf.CareerType
    attr.RPG_Crit = conf.Crit
    attr.RPG_Block = conf.Block
    attr.RPG_CritAnti = conf.AntiBlock
    attr.RPG_CritEnhance = conf.CritEnhance
    attr.RPG_CritReduce = conf.CriteReduce
    attr.RPG_Radius = conf.RPG_Radius

    -- local conf_star = resmng.get_conf('prop_hero_star_up', hero.star)
    -- attr.RPG_StarFactor = conf_star and conf_star.StarPropertyFactor
    -- attr.RPG_StarValue = conf_star and conf_star.StarPropertyValue

    table.addM(attr, hero.add_attr)

    local skills = {}

    for _, id in ipairs(hero.basic_skill) do
        if resmng.prop_rpg_battle_skill[id] then
            table.insert(skills, id)
        end
    end

    -- Hx@2023-02-28: RPG专有，普攻是个技能
    if conf.BasicAttack then
        table.insert(skills, conf.BasicAttack)
    end

    table.appendM(skills, hero.add_skills)

    local ret = {
        -- 英雄id
        hero_id = hero.propid,
        -- 英雄所属玩家
        pid = hero.pid or 0,
        -- 等级
        lv = hero.lv,
        -- 星级
        star = hero.star,
        -- 属性
        attr = attr,
        -- 技能
        skills = skills,
        -- buff
        buffs = {},
        -- 站位
        fpos = fpos,
        -- 效果
        effs = nil,
    }
    return ret
end

local ATTR_CALC_FUNC =
{
    [ "RPG_Atk" ] = 1,
    [ "RPG_Def" ] = 1,
    [ "RPG_Hp" ] = 1,
    [ "RPG_AtkSp" ] = 1,
}

-- 创建动态属性的rpg怪物
function make_rpg_robot_hero_by_obj(monster_info, fpos)

    local hero = hero_util.make_rpg_robot_hero( monster_info )

    local attr = rpg_attr_into_ef(hero)

    local conf = resmng.prop_hero_basic_byid(hero.propid)
    attr.RPG_Sp = conf.RPG_Sp
    attr.RPG_Anger = conf.RPG_Anger
    attr.RPG_AngerMax = conf.RPG_Anger
    attr.RPG_AngerHit = conf.RPG_AngerHit
    attr.RPG_AngerKill = conf.RPG_AngerKill
    attr.RPG_Race = conf.RaceType
    attr.RPG_Job = conf.CareerType
    attr.RPG_Crit = conf.Crit
    attr.RPG_Block = conf.Block
    attr.RPG_CritAnti = conf.AntiBlock
    attr.RPG_CritEnhance = conf.CritEnhance
    attr.RPG_CritReduce = conf.CriteReduce
    attr.RPG_Radius = conf.RPG_Radius

    -- prop_hero_base的基础属性替换
    local hero_base_type = ( hero.hero_base_type and 0 ~= hero.hero_base_type ) and hero.hero_base_type or conf.RobotProp
    if hero_base_type then
        local conf_robot_type_map = resmng._prop_hero_base_type_map[ hero_base_type ]
        if conf_robot_type_map and conf_robot_type_map[ monster_info.gen_lv or monster_info.lv ] then
            local prop_rpg_hero_base_attr_map = resmng._prop_rpg_hero_base_attr_map
            for k, v in pairs( conf_robot_type_map[ monster_info.gen_lv or monster_info.lv ] ) do
                if prop_rpg_hero_base_attr_map[ k ] then
                    attr[ k ] = ( attr[ k ] or 0 ) + v
                end
            end
        end
    end

    local prop_rpg_hero_factor_attr_map = resmng._prop_rpg_hero_factor_attr_map
    -- prop_hero_basic中factor的属性修正
    if conf.PropertyAdjust then
        local factor_conf = resmng.prop_rpg_hero_factor[ conf.PropertyAdjust ]
        for k, v in pairs( factor_conf or {} ) do
            if prop_rpg_hero_factor_attr_map[ k ] then
                local old = attr[ k ] or 0
                if ATTR_CALC_FUNC[k] then
                    -- 2024.4.12改成直接乘以
                    -- attr[ k ] = old * ( 1 + v / 10000 )
                    attr[k] = old * (v / 10000)
                else
                    attr[k] = old + v / 10
                end
            end
        end
    end

    -- prop_rpg_robot_team中factor的属性修正
    if hero.factor_prop_id and 0 ~= hero.factor_prop_id then
        local factor_conf = resmng.prop_rpg_hero_factor[ hero.factor_prop_id ]
        for k, v in pairs( factor_conf or {} ) do
            if prop_rpg_hero_factor_attr_map[ k ] then
                local old = attr[ k ] or 0
                if ATTR_CALC_FUNC[k] then
                    -- 2024.4.12改成直接乘以
                    -- attr[ k ] = old * ( 1 + v / 10000 )
                    attr[k] = old * (v / 10000)
                else
                    attr[k] = old + v / 10
                end
            end
        end
    end

    -- ratio
    if hero.attr_ratio then
        for k, v in pairs(attr) do
            if k == "RPG_Atk" or k == "RPG_Def" or k == "RPG_Hp" then -- 暂时只对这3个属性生效
                attr[k] = v * (hero.attr_ratio / 10000)
            end
        end
    end

    local skills = hero_util.get_combat_skills(hero)

    if conf.BasicAttack then
        table.insert(skills, conf.BasicAttack)
    end

    local ret = {
        -- 英雄id
        hero_id = hero.propid,
        -- 英雄所属玩家
        pid = hero.pid,
        -- 等级
        lv = hero.lv,
        -- 属性
        attr = attr,
        -- 技能
        skills = skills,
        -- buff
        buffs = hero_util.get_combat_buffs(hero),
        -- 站位
        fpos = fpos,
        -- 效果
        effs = nil,
    }
    return ret
end

-- Hx@2023-06-05: 获取最大血量
function get_rpg_hero_max_hp(hero)
    return effect_util.get_ef_val('RPG_Hp', nil, hero.attr)
end

-- Hx@2023-06-05: 设置当前血量
-- 需要为整数
function set_rpg_hero_hp(hero, hp)
    hero.attr.RPG_HpInit = hp
end

function get_rpg_hero_hp(hero)
    return hero.attr.RPG_HpInit or get_rpg_hero_max_hp(hero)
end

-- Hx@2023-06-05: 获取怒气上限
function get_rpg_hero_max_anger(hero)
    return effect_util.get_ef_val('RPG_AngerMax', nil, hero.attr)
end

-- Hx@2023-06-05: 设置当前怒气
function set_rpg_hero_anger(hero, anger)
    hero.attr.RPG_AngerInit = anger
end

function get_rpg_hero_anger(hero)
    return hero.attr.RPG_AngerInit or get_rpg_hero_max_anger(hero)
end

-- Hx@2023-02-09: 构建rpg英雄数据
-- 客户端也会调用
function make_rpg_hero_by_obj(hero, fpos, mode)
    local add_skills = hero.get_god_rpg_skills and hero:get_god_rpg_skills() or {}

    local add_attr = rpg_attr_into_ef(hero)
    --if extra_add_attr then
    --    table.addM(add_attr, extra_add_attr)
    --end
    if hero.get_rpg_effect then
        table.addM(add_attr, hero:get_rpg_effect(mode))
    end

    local data = {
        propid = hero.propid,
        lv = hero.lv,
        star = hero.star,
        basic_skill = hero.basic_skill,
        add_skills = add_skills,
        add_attr = add_attr,
        pid = hero.pid,
    }

    return make_rpg_hero_by_data(data, fpos)
end

local function make_extend_id(id, lv)
    return id * 100 + (lv or 1)
end


local function prepare_basic_skills(hero, skilllvs)
    skilllvs = skilllvs or {}
    local hero_cfg = resmng.get_conf('prop_hero_basic', hero.propid)
    for k, v in pairs(hero_cfg.BasicSkill) do
        if hero.star >= v[2] then
            hero.basic_skill[k] = make_extend_id(v[1], skilllvs[k])
        end
    end
end


-- Hx@2023-02-13: 构建rpg怪物数据
function make_rpg_monster_hero(cfgid, fpos)
    local prop = resmng.get_conf('prop_rpg_battle_monster', cfgid)
    if not prop then
        return nil
    end

    local prop_hero = resmng.prop_hero_basic_byid(prop.HeroBasic)

    local basic = {
        power = prop_hero.Power + prop_hero.PowerGrowth ,
        defence = prop_hero.Protect + prop_hero.ProtectGrowth,
        physique = prop_hero.Constitution + prop_hero.ConstitutionGrowth,
    
    }
    
    -- hero_util.recalc_rpg_basic_attr(prop.HeroBasic, prop.Level, prop.Star, {})
    local add_attr = rpg_attr_into_ef(basic)
    -- Hx@2023-02-09: 属性修正
    if prop.Effect then
        table.addM(add_attr, prop.Effect)
    end

    local t = {
        propid = prop.HeroBasic,
        lv = prop.Level,
        star = prop.Star,
        basic_skill = {},
        add_skills = {},
        add_attr = add_attr
    }
    prepare_basic_skills(t, prop.SkillLvs)

    local data = make_rpg_hero_by_data(t, fpos)
    data.cfgid = prop.ID

    return data
end

function has_pet(pet)
    return pet and (pet.propid or 0) ~= 0
end

local pet_data_keys = {
    propid = 1,
    lv = 1,
    facade = 1,
    refinement_lv = 1,
    refinement_ef = 1,
}
function make_pet_data(pet, mode)
    local data = {}
    data.skills = pet_t.get_skills(pet, mode)
    for k, _ in pairs(pet_data_keys) do
        data[k] = pet[k]
    end
    data.power = pet.pow
    return data
end

-- Hx@2022-11-16: slg 队伍宠物数据
function make_slg_pet(pet)
    return make_slg_pet_by_data(make_pet_data(pet, BattleMode.Slg))
end

function make_slg_treasure(treasures, arm_id)
    local data = {}
    for id, t in pairs(treasures) do
        local skills, ratio = t:get_skill_data(arm_id)
        if skills then
            table.insert(data, {
                id = id,
                lv = t.lv,
                ratio = ratio,
                skills = skills
            })
        end
    end
    return data
end


-- Hx@2023-06-14: rpg 队伍宠物数据
function make_rpg_pet_by_obj(pet)
    return make_rpg_pet_by_data(make_pet_data(pet, BattleMode.Rpg))
end

-- {
--     propid = 0,
--     lv = 0,
-- }
function make_slg_pet_by_data(pet)
    local conf = pet_t.get_conf_lvup(pet.propid, pet.lv)
    if not conf then
        ERROR("[%s], make_slg_pet_by_data, nil conf, propid,%s, lv,%s", _NAME, pet.propid, pet.lv)
        return nil
    end

    local ef = calc_slg_pet_ef(pet.propid, pet.lv, pet.refinement_lv, pet.refinement_ef)

    local pet_skills = pet.skills
    local skills = {}
    for id, _ in pairs(pet_skills) do
        local conf = resmng.prop_skill[id]
        if conf then
            table.insert(skills, id)
        end
    end

    local ret = {
        propid = pet.propid,
        lv = pet.lv,
        skills = skills,
        ef = ef,
        facade = pet.facade,
        refinement_lv = pet.refinement_lv,
        power = pet.power,
    }
    return ret
end

function calc_slg_pet_ef(propid, lv, refinement_lv, refinement_ef)
    local conf_pet = resmng.prop_pet_byid(propid)
    local conf_lv = pet_t.get_conf_lvup(propid, lv)

    if not conf_pet or not conf_lv then
        ERROR("[%s], calc_slg_pet_ef, nil conf, propid,%s, lv,%s, confpet,%s, conflv,%s", _NAME, propid, lv, conf_pet, conf_lv)
        return {}
    end

    local mul = conf_lv.AttrCoefficient
    local ef = copyTab(refinement_ef) -- 临时属性
    for k, v in pairs(conf_pet.BaseAttr) do
        ef[k] = (ef[k] or 0) + v * (1 + mul)
    end
    DEBUG("[%s], calc_slg_pet_ef, succ, propid,%s, lv,%s, efs,%s", _NAME, propid, lv, stringify(ef))
    return ef
end

function rpg_attr_into_ef(attr)
    -- Hx@2023-02-09: 基础属性 1:1 转换
    local ef = {
        RPG_Atk = attr.power,
        RPG_Def = attr.defence,
        RPG_Hp = attr.physique,
    }
    return ef
end

-- Hx@2023-06-14:
-- {
--     propid = 0,
--     lv = 0,
-- }
function make_rpg_pet_by_data(pet)
    assert(false, "the rpg mode of pet had been discarded")
    local conf = pet_t.get_conf_lvup(pet.propid, pet.lv)
    if not conf then
        return nil
    end

    -- Hx@2023-08-12: 宠物还是用的旧属性配置
    local attr = calc_slg_pet_ef(pet.propid, pet.lv, pet.refinement_lv, pet.refinement_ef)

    local pet_skills = pet.skills
    local skills = {}
    for id, _ in pairs(pet_skills) do
        local conf = resmng.prop_rpg_battle_skill[id]
        if conf then
            table.insert(skills, id)
        end
    end

    local ret = {
        -- 配置id
        propid = pet.propid,
        -- 等级
        lv = pet.lv,
        -- 技能
        skills = skills,
        -- 形态
        facade = pet.facade,
        -- 属性
        attr = attr,
    }
    return ret
end

-- SLG monster hero
function make_monster_hero(cfgid, idx)
    local conf = resmng.get_conf('prop_monster_hero', cfgid)
    local skills = table.map(conf.Skills or {}, skill_util.calc_skill_id, conf.SkillLv)

    -- Hx@2024-05-16: 理论上可以删了，这里只是暂时保留
    -- 不确定那些地方还在用
    local slg_attr = {
        Atk_R = conf.Power,
        Hp_R = conf.Constitution,
        Def_R = conf.Protect,
        Siege = conf.Knowledge,
    }

    return make_hero({
        propid = conf.HeroBasic,
        lv = conf.Lv,
        star = conf.Star,
        slg_attr = slg_attr,
        basic_skill = skills,
        is_fake_hero = true,
    }, idx)
end

function make_army(data)
    data._id = data._id or getId("army")

    if data.pid and data.pid > 0 then
        local ply = getPlayer(data.pid)
        if ply then
            data.photo = ply.photo
            data.photo_bg = ply.photo_bg
        end
    end

    if cskit.is_server() then
        return troop_util.make_army_1(data)
    else
        local army = {
            _id = data._id,
            index = data.index,
            nav_id = data.nav_id or 0,
            tm_join = data.tm_join or 0,
            kind = data.kind or TroopKind.COMBAT,
            pid = data.pid or 0,
            name = data.name or "",
            eid = data.eid or 0,
            power = data.power or 0,
            arm_id = data.arm_id or 0,
            fight_power = 0,
            heros = data.heros or {},
            soldiers = data.soldiers,
            injured = make_injured(),
            action = nil,
            fake = data.fake, -- 假army
            internal = data.internal,
            pre_troop_idx = data.pre_troop_idx,
            -- Hx@2022-11-16: 宠物
            pet = data.pet,
            treasures = data.treasures,
            is_local = data.is_local,
            dungeon_id = data.dungeon_id,
            photo = data.photo,
            photo_bg = data.photo_bg,
        }

        army.arm_id = troop_util.get_arm_id(army)
        army.buffs = skill_util.make_buffs(army)
        army.skills = skill_util.make_skills(army)
        army.nav_id = troop_util.get_nav_id(army.arm_id)
        army.fight_power = troop_util.get_fight_power(army)

        return army
    end
end

function update_arm_id(army)
    army.arm_id = troop_util.get_arm_id(army)
    return army.arm_id
end

function get_arm_id(army)
    -- Hx@2023-05-23:
    -- 如果有 hero，arm_id 强制为 hero 定义的，
    -- 如果没有 hero 但是有 soldiers，arm_id 为 soldier_id parse出来的 arm_id
    -- 如果都没有，使用默认的

    local arm_id = resmng.ARM_DEFAULT_ID
    local hero = army.heros[1]
    if hero then
        local _arm_id = hero_util.get_arm_id(hero.propid)
        if _arm_id then
            arm_id = _arm_id
        end
    elseif table.not_empty(army.soldiers) then
        local t = troop_util.parse_soldier_id(next(army.soldiers))
        arm_id = t.arm_id
    end
    return arm_id
end

-- army 兵力战力
function get_fight_power(army)
    local soldiers = table.copy(army.soldiers)
    for k, v in pairs(army.injured) do
        table.addM(soldiers, v)
    end
    local pow = 0
    for id, num in pairs(soldiers) do
        local attr = troop_util.get_army_soldier_attr(army, id)
        pow = pow + ((attr.Pow or 0) * num)
    end
    return pow
end

-- army剩余兵力战力
function get_current_fight_power(army)
    local pow = 0
    for id, num in pairs(army.soldiers) do
        local attr = troop_util.get_army_soldier_attr(army, id)
        pow = pow + ((attr.Pow or 0) * num)
    end
    return pow
end

-- 总战力
function get_power(army)
    local power = get_fight_power(army)
    for k, v in pairs(army.heros) do
        power = power + v.power
    end
    if army.pet and army.pet.propid ~= 0 then
        power = power + (army.pet.power or 0)
    end
    return math.ceil(power)
end

--[[
data = {
    kind = 0,      -- 队伍类型
    pid = 0,       -- 玩家pid
    heros = 0,     -- 英雄
    soldiers = {}, -- 士兵
    pet = nil,      -- 宠物 : Option(ArmyPet)

    pre_troop_idx = 0, -- 编组idx
    internal = false, -- 存储在ety上
}

--]]
function make_army_1(data, opt)
    if not data.kind then
        data.kind = TroopKind.COMBAT
    elseif data.kind == 0 then
        ERROR('[%s] make_army_1, kind == 0, from=%s', _NAME, debug.stack())
        data.kind = TroopKind.COMBAT
    end
    table.mergeM(data, opt or {})

    if data.internal or (not data.pid or data.pid == 0) or (not data.index or data.index == 0) then
        if data.is_local then
            return ety_army_local_t.new(data)
        end
        return ety_army_t.new(data)
    end

    if data.kind == TroopKind.COMBAT then
        return ety_army_combat_t.new(data)
    elseif data.kind == TroopKind.RECON then
        return ety_army_player_t.new(data)
    elseif data.kind == TroopKind.OUT_BUILD_WORKER then
        return ety_army_player_t.new(data)
    end

    assert(false, string.format('[%s] make_army_1, failed, %s', _NAME, stringify(data)))
end

function calc_soldiers_power(soldiers)
    local pow = 0
    for propid, num in pairs(soldiers or {}) do
        pow = pow + num
        -- TODO 2.0 pow calc
        -- local conf = resmng._prop_arm_attr[propid]
        -- if conf then
        --     pow = pow + conf.Pow * num
        -- end
    end
    return pow
end

function make_injured()
    return {
        [InjuryDegree.MINOR] = {},
        [InjuryDegree.MAJOR] = {},
        [InjuryDegree.DEAD]  = {},
    }
end

function calc_heal(chgs)
    local injured = make_injured()
    for propid, num in pairs(chgs) do
        injured[InjuryDegree.MINOR][propid] = (injured[InjuryDegree.MINOR][propid] or 0) - num
    end
    return injured
end

function merge_injured(injured, chgs)
    for k, t in pairs(chgs) do
        for i, v in pairs(t) do
            injured[k][i] = (injured[k][i] or 0) + v
        end
    end
end

function make_tower(tower)
    return ety_tower_factory.create({propid=tower.propid, kind=TowerKind.Defense})
end

-- [ 组织 CombatData ]
function make_combat_data(ety)
    local ret = {
        attrs = ety.attrs,
        heros = ety.heros,
        soldiers = ety.soldiers,
        target = ety.target,
        in_battle = ety.in_battle,
        army_facade_id = ety.army_facade_id,
        army_display_id = ety.army_display_id,
    }
    local sprite = ety.sprite
    if sprite then
        ret.buffs = sprite:pack_buff()
        ret.warns = sprite:pack_warning()
    end
    return ret
end

function cal_nav_id(armies)
    -- Hx@2021-05-23: TODO: 获得最终的导航类型
    local nav_id
    for _, army in pairs(armies) do
        if not nav_id then
            nav_id = army.nav_id
        else
            nav_id = math.min(nav_id, army.nav_id)
        end
    end
    return nav_id or 0
end

function get_conf_arm_count(nav_id, num)
    local confs = resmng.get_conf_total('prop_army_count')
    if nav_id == TerrainType.Land then
        local idx = 1
        for k, conf in ipairs(confs) do
            if not conf.Land then
                break
            elseif num >= conf.Land then
                idx = k
            else
                break
            end
        end
        return confs[idx]
    elseif nav_id == TerrainType.Fly then
        local idx = 1
        for k, conf in ipairs(confs) do
            if not conf.Fly then
                break
            elseif num >= conf.Fly then
                idx = k
            else
                break
            end
        end
        return confs[idx]
    else
        assert(false, nav_id or -1)
    end
end

-- Hx@2023-02-23: 2.0 计算攻击距离
-- ety的主英雄主导
function calc_ety_atk_dist(ety)
    local dist = {far = 0, fit = 0}
    local nums = troop_util.revert_soldiers(ety.soldiers)
    for lv, num in pairs(nums) do
        local attr = get_ety_reserves_attr(ety, lv)
        if attr.AtkDist then
            if dist.fit == 0 then
                dist.fit = attr.AtkDist
            else
                dist.fit = math.min(dist.fit, attr.AtkDist)
            end
        end
        if attr.MaxAtkDist then
            if dist.far == 0 then
                dist.far = attr.MaxAtkDist
            else
                dist.far = math.min(dist.far, attr.MaxAtkDist)
            end
        end
    end

    dist.fit = math.floor(dist.fit + ety.size)
    dist.far = math.floor(dist.far + ety.size)

    return dist
end

function cal_basic_attr(ety)
    local stats = {}
    for _, field in pairs(ARM_ATTR_FIELDS) do
        stats[field] = {}
    end

    for id, num in pairs(ety.soldiers) do
        local attr = troop_util.get_ety_soldier_attr(ety, id)
        for field, t in pairs(stats) do
            table.insert(t, attr[field])
        end
    end

    local ret = table.map(stats, function(v)
        if next(v) then
            return math.min(table.unpack(v))
        else
            return 0
        end
    end)
    LOG("[%s] cal_basic_attr: %s, basic=%s", _NAME, ety.label, stringify(ret))

    return ret
end

function init_armies_attrs(target)
    calc_ety_attr(target)
    target.nav_id = cal_nav_id(target.armies)
end

-- [ 计算部队属性 ]
function calc_ety_attr(target)
    fix_main_id(target)

    local attr = {main_id=target.main_id, anger=0, max_anger=0}
    local stats = {alive=0, wounded=0}
    for _, army in pairs(target.armies) do
        stats.alive = stats.alive + table.sum(army.soldiers)
        stats.wounded = stats.wounded + table.sum(table.map(army.injured, table.sum))
    end
    attr.hp = stats.alive
    attr.max_hp = stats.alive + stats.wounded

    if target.skills then
        for _, skill in ipairs(target.skills) do
            local cfg = conf_util.get_skill_cfg(skill.propid, skill.source.coeff)
            if cfg and cfg.Mode == SkillMode.ANGER then
                attr.max_anger = cfg.Anger or 0
                break
            elseif not cfg then
                ERROR('[%s] calc_ety_attr, no cfg skill, %s, %s', _NAME, target.label, skill.propid)
            end
        end
    end
    attr.anger = math.min(target.anger or 0, attr.max_anger)

    -- Hx@2024-09-03: 队长传递兵种皮肤
    local main_army = target.armies[target.main_id]
    if main_army then
        attr.army_facade_id = main_army.army_facade_id
        attr.army_display_id = main_army.army_display_id
    end

    table.update(target, attr)
    -- LOG('[troop_util] calc_ety_attr: %s, arm_type=%s, attr=%s, from=%s'
    -- , target.label, target.arm_type, stringify(attr), debug.stack())
    return attr
end

function is_empty_soldiers(ety)
    for idx, army in pairs(ety.armies) do
        if troop_util.is_valid_army(army) then
            return false
        end
    end
    return true
end

function is_valid_army(army)
    return table.not_empty(army) and table.not_empty(army.soldiers)
end

local function sort_army(a, b)
    return a.tm_join < b.tm_join
end

local function can_be_main_army(army)
    if army and army.kind == TroopKind.COMBAT then
        -- 战斗部队优先成为队长
        return true
    end
    return false
end

function fix_main_id(target)
    local armies = target.armies
    local main_army = armies[target.main_id]

    if can_be_main_army(main_army) then
        return
    end
    if target.main_id == 0 and table.empty(armies) then
        return
    end

    local pid = target.pid
    local owner_armies = {}
    local valid_armies = {}
    local invalid_armies = {}
    for _, army in pairs(target.armies) do
        if can_be_main_army(army) then
            if pid ~= 0 and pid == army.pid then
                table.insert(owner_armies, army)
            else
                table.insert(valid_armies, army)
            end
        else
            table.insert(invalid_armies, army)
        end
    end
    table.sort(owner_armies, sort_army)
    table.sort(valid_armies, sort_army)
    local army = (owner_armies[1] or valid_armies[1] or invalid_armies[1])
    target.main_id = army and army._id or 0
end

function pipe(target)
    return {
        capacity = target.capacity,
        cfgid = target.cfgid,
        action = target.action,
        moving = target.moving,
        pre_troop_idx = target.pre_troop_idx,
        troop_hangup = target.troop_hangup,
        out_build_id = target.out_build_id,
        trigger_areas = target.trigger_areas,
        index = target.main_army and target.main_army.index,
        troop_hangup_target = target.troop_hangup_target,
        troop_mass_wait = target.troop_mass_wait,
        move_target_info = target.move_target_info,
        city_heir = target.city_heir,
    }
end

function calc_injured_soldiers(old_injured, new_injured)
    local major = {}
    local old_major = old_injured[InjuryDegree.MAJOR]
    for propid, num in pairs(new_injured[InjuryDegree.MAJOR]) do
        local diff = num - (old_major[propid] or 0)
        if diff > 0 then
            major[propid] = diff
        end
    end
    return major
end

function army_diff_injured(old_army, new_army)
    local res = make_injured()
    for k, t in pairs(new_army.injured) do
        for id, num in pairs(t) do
            local diff = num - (old_army.injured[k][id] or 0)
            if diff > 0 then
                res[k][id] = diff
            end
        end
    end
    return res
end

-- [ 守城士兵转预备兵 ]
function revert_soldiers(soldiers)
    local reserves = {}
    for propid, count in pairs(soldiers or {}) do
        local lv = propid % 1000
        reserves[lv] = (reserves[lv] or 0) + count
    end
    return reserves
end

-- [ 预备兵转守城士兵 ]
function convert_soldiers(conv_opt, reserves)
    local ratio_sum = table.sum(conv_opt)
    local soldiers = {}
    for lv, count in pairs(reserves) do
        local left = count
        for arm_id, ratio in pairs(conv_opt) do
            if left <= 0 then break end
            local soldier_id = troop_util.make_soldier_id(arm_id, lv)
            local soldier_num = math.min(math.ceil((ratio / ratio_sum) * count), left)
            left = left - soldier_num
            soldiers[soldier_id] = soldier_num
        end
    end
    return soldiers
end

-- 预备兵转出征士兵
function transact_soldiers(arm_id, soldiers)
    local res = {}
    for lv, count in pairs(soldiers) do
        local soldier_id = troop_util.make_soldier_id(arm_id, lv)
        res[soldier_id] = count
    end
    return res
end
