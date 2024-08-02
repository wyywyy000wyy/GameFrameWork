local rpg_init_mod = class2("rpg_init_mod", T.mod_base,function(self, battle_instance)

end)

rpg_init_mod.apply_race_buff = function(team)    
    local race_table = {};
    for _, value in pairs(resmng.RACE) do
        race_table[value] = 0
    end

    -- 遍历统计种族数量
    for _, hero in pairs(team.heros) do
        local hero_data = resmng.prop_hero_basic[hero.hero_id]
        race_table[hero_data.RaceType] = race_table[hero_data.RaceType] + 1
    end

    local race_number_table = {}
    for k, v in pairs(race_table) do
        table.insert(race_number_table, { k, v })
    end

    -- 根据数量排序
    table.sort(race_number_table, function(s1, s2)
        return s1[2] > s2[2]
    end)

    local race_buff = nil
    if race_number_table[1][2] == 5 then
        race_buff = resmng.BATTLE_RPG_RACE_BUFF[4]  -- 5个同种族
    elseif race_number_table[1][2] == 4 then
        race_buff = resmng.BATTLE_RPG_RACE_BUFF[3]  -- 4个同种族        
    elseif race_number_table[1][2] == 3 then
        race_buff = resmng.BATTLE_RPG_RACE_BUFF[2]  -- 3 + 2        
    elseif race_number_table[2][2] == 2 then
        race_buff = resmng.BATTLE_RPG_RACE_BUFF[1]  -- 3
    end

    if race_buff == nil then
        return
    end
    
    for _, hero in pairs(team.heros) do
        for k, v in pairs(race_buff) do
            hero.attr[k] = hero.attr[k] or 0 + v
        end
    end
end

-- Hx@2023-05-17: 添加副本站位ef
rpg_init_mod.apply_pos_buf = function(teams, efs)
    if not efs then
        return
    end
    local fpos_heros = {}
    for _, team in pairs(teams) do
        for _, hero in pairs(team.heros) do
            fpos_heros[hero.fpos] = hero
        end
    end
    for _, prop in pairs(efs) do
        local fpos, effs = table.unpack(prop)
        local hero = fpos_heros[fpos]
        if hero then
            table.appendM(table.acquire(hero, 'effs'), effs)
        end
    end
end

-- Hx@2023-08-12: 添加 boss 外显
rpg_init_mod.apply_boss_station = function(teams, conf)
    if not conf.BossStation then
        return
    end
    local fpos = conf.BossStation + RPG_MAX_FORMATION_POS
    local team = teams[2]

    local boss = nil
    for _, mons in pairs(team.heros) do
        if mons.fpos == fpos then
            boss = mons
            break
        end
    end
    if not boss then
        return
    end
    
    boss.is_boss = true
    boss.attr.RPG_Radius = conf.RPG_Radius
    boss.scale = conf.BossScale
    boss.hp_count = conf.RpgHpCount
end

-- Hx@2023-08-12: 计算最终进战斗的属性
-- 所有属性计算出来，作为战斗初始属性
-- 处理宠物属性叠加
rpg_init_mod.collapse_attr = function(teams)
    for _, team in pairs(teams) do
        local pet_coll_attr = {}

        -- 宠物养成属性
        if team.pet then
            local attr = team.pet.attr or {}
            for k, v in pairs(attr) do
                if resmng.prop_effect_type[k] then
                    pet_coll_attr[k] = effect_util.get_ef_val(k, nil, attr)
                else
                    pet_coll_attr[k] = v
                end
            end
        end

        -- 英雄战斗属性 = 英雄养成属性 + 宠物养成属性
        for _, hero in pairs(team.heros) do
            local collattr = {}
            for k, v in pairs(hero.attr) do
                if resmng.prop_effect_type[k] then
                    collattr[k] = effect_util.get_ef_val(k, nil, hero.attr)
                else
                    collattr[k] = v
                end
            end
            for _, name in pairs(RPG_TEAM_ATTR) do
                collattr[name] = (collattr[name] or 0) + (pet_coll_attr[name] or 0)
            end
            hero.attr = collattr
        end

        -- 宠物战斗属性 = AVG(英雄战斗属性)
        if team.pet then
            local n = table.len(team.heros)
            for _, name in pairs(RPG_TEAM_ATTR) do
                local sum = 0
                for _, hero in pairs(team.heros) do
                    sum = sum + (hero.attr[name] or 0)
                end
                pet_coll_attr[name] = sum / n
            end
            team.pet.attr = pet_coll_attr
        end
    end
end

-- Hx@2023-08-16: 计算前置校验战力
-- 前置校验通过就不跑完整校验，节约性能
rpg_init_mod.calc_verify_power = function(teams)
    for _, team in pairs(teams) do
        local power = 0
        for _, hero in pairs(team.heros) do
            local hp = effect_util.get_ef_val('RPG_Hp', nil, hero.attr)
            local atk = effect_util.get_ef_val('RPG_Atk', nil, hero.attr)
            local def = effect_util.get_ef_val('RPG_Def', nil, hero.attr)
            local vp = hp / 10000 * (atk ^ 2) / (atk + 100) * (def * 5 + 100)
            power = power + vp
        end
        team.vpower = power
    end
end

rpg_init_mod.InitDataFunc = {
    -- [DungeonMode.RPG_EXPEDITION] = function(data)
    --     local conf = resmng.prop_rpg_battle_level[data.propid]

    --     local team1 = data.teams[1]
    --     if not team1 then
    --         return resmng.E_FAIL, 'no team'
    --     end

    --     rpg_init_mod.apply_race_buff(team1)
        
    --     -- Hx@2023-06-05: 优先使用服务器的初始化怪物数据
    --     local team2 = data.teams[2]
    --     if not team2 then
    --         local prop = conf.Monsters[1]
    --         local heros = {}
    --         for fpos, cfgid in pairs(prop.Mons) do
    --             -- 构建的敌方位置固定从第5个位置开始
    --             local data = troop_util.make_rpg_monster_hero(cfgid, fpos + RPG_MAX_FORMATION_POS)
    --             table.insert(heros, data)
    --         end
    --         team2 = {heros=heros}
    --     end

    --     local teams = {team1, team2}

    --     rpg_init_mod.apply_pos_buf(teams, conf.LevelEffect)
    --     rpg_init_mod.apply_boss_station(teams, conf)

    --     rpg_init_mod.collapse_attr(teams)
    --     rpg_init_mod.calc_verify_power(teams)

    --     local ret = {
    --         level_id = conf.ID,
    --         max_battle_time = conf.Time * 1000,
    --         fixed_dt = 100,
    --         battle = {
    --             teams = teams,
    --         },
    --         env = {},
    --         rules = {},
    --         anger_pause = conf.Type == DungeonMode.RPG_ARENA
    --     }
    --     return resmng.E_OK, ret
    -- end,
}

-- for mode, prop in pairs(RpgDungeonConfigHub) do
--     rpg_init_mod.InitDataFunc[mode] = rpg_init_mod.InitDataFunc[prop.battle_init]
-- end

-- RpgDungeonData -> InitData
function rpg_init_mod.create_init_data(data)
    if data.inited then
        return  resmng.E_OK, data
    end
    local conf = resmng.prop_rpg_battle_levelById(data.propid)
    if not conf then
        return resmng.E_FAIL, 'no conf'
    end
    local fn = rpg_init_mod.InitDataFunc[conf.Type]
    if not fn then
        return resmng.E_FAIL 'no init func'
    end
    local op, d=fn(data)
    if d then
        d.inited = true
    end
    return op, d
end
