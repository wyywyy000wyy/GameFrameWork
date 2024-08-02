local battle_instance_expedition_simulation = class2("battle_instance_expedition_simulation", T.battle_instance, function(self, battle_id, init_data)
    init_data.max_battle_time = 900000      -- 远征模拟战斗时间不限制
    T.battle_instance._ctor(self, battle_id, init_data)
end)

function battle_instance_expedition_simulation.on_ReqRpgCreate(id, data)
    if battle_instance_expedition_simulation.create_battle_data then
        -- data = battle_instance_expedition_simulation.create_battle_data()   -- 测试使用
    end
    
    local _, init_Data = T.rpg_init_mod.create_init_data(data)
    Logger.LogerWYY2("on_ReqRpgCreate",data)
    if RPG_SAVE_BATTLE_DATA then
        T.battle_instance_client.save_battle_data(id, init_Data, data)
    end
    local ins = battle_instance_expedition_simulation(id, init_Data)
    ins:start()
    models.rpg_battle_model.set_cur_battle(ins)    
    return ins
end

function battle_instance_expedition_simulation:start()
    local controller_mod = T.controller_mod(self)
    self:add_mod(controller_mod)
    self.controller = controller_mod

    local physics_mod = T.physics_mod(self)
    self:add_mod(physics_mod)

    local rpg_debug_mod = T.rpg_debug_mod(self)
    self:add_mod(rpg_debug_mod)
        
    local battle_mod = T.battle_mod(self)
    self:add_mod(battle_mod)
    
    if RPG_DEBUG_VIEW_MOD then
        local rpg_debug_view_mod = T.rpg_debug_view_mod(self)
        self:add_mod(rpg_debug_view_mod)
    end
    
    local battle_player_mod = T.battle_player_mod(self, RPG_PLAY_MODE.expedition_simulation)
    self:add_mod(battle_player_mod)
    self._battle_player_mod = battle_player_mod
    
    T.battle_instance.start(self)

    self:add_event_listener2(RPG_EVENT_TYPE.BATTLE_END, self, "on_battle_end")
end

function battle_instance_expedition_simulation:on_battle_end(event_data)
    models.rpg_battle_model.request_battle_result(nil)  -- 假战斗不需要结算结果
end


function battle_instance_expedition_simulation:update(dt)    
    if self._battle_player_mod.is_release_rage_skill then
        self._battle_player_mod:update(dt)  -- 大招期间只更新播放模块
        return
    end

    self._base.update(self, dt)
end

function battle_instance_expedition_simulation:stop()    
    self._base.stop(self)    
end

------------------------------ 单英雄技能测试 ----------------------------
--- 测试使用的英雄 --
local hero1_id = 206     -- 英雄Id
local hero1_skills = {
    2061100,
    2062100,
    2063100,
    2064100,
    2065100,
    2066100,
}  -- 英雄技能

local hero2_id = 207     -- 英雄Id
local hero2_skills = {
    2071100,
    2072100,
    2073100,
    2074100,
    2075100,
    2076100,
}  -- 英雄技能

local hero3_id = 111     -- 英雄Id
local hero3_skills = {
    1111100,
    1112100,
    1113100,
    1114100,
    1115100,
    1116100,
}  -- 英雄技能

local hero4_id = 106     -- 英雄Id
local hero4_skills = {
    1061100,
    1062100,
    1063100,
    1064100,
    1065100,
    1066100,
}  -- 英雄技能

local hero5_id = 109     -- 英雄Id
local hero5_skills = {
    1091100,
    1092100,
    1093100,
    1094100,
    1095100,
    1096100,
}  -- 英雄技能


-- 创建模拟战斗的假数据
function battle_instance_expedition_simulation.create_battle_data()
    return {
        inited = true,
        fixed_dt = 100,
        max_battle_time = 30000 * 1000,
        auto_skill = true,
        level_id = 10101, -- 关卡id prop_rpg_battle_level 中的Id
        battle = {
            teams = {
                [1] = {
                    heros = {
                        [1] = {
                            hero_id = hero1_id, fpos = 1, lv = 1,
                            attr = { RPG_Atk = 5 * 1000, RPG_Def = 2 * 1000, RPG_Hp = 80 * 1000 * 1000, RPG_Sp = 1, RPG_Dist = 0.5 * 1000, RPG_Anger = 1000 * 10000, RPG_AngerMax = 1000 * 1000, },
                            skills = hero1_skills
                        },
                        [2] = {
                            hero_id = hero2_id, fpos = 2, lv = 1,
                            attr = { RPG_Atk = 5 * 1000, RPG_Def = 2 * 1000, RPG_Hp = 80 * 1000 * 1000, RPG_Sp = 1, RPG_Dist = 0.5 * 1000, RPG_Anger = 1000 * 10000, RPG_AngerMax = 1000 * 1000, },
                            skills = hero2_skills
                        },
                        --[3] = {
                        --    hero_id = hero3_id, fpos = 3,lv = 1,
                        --    attr = { RPG_Atk = 5 * 1000, RPG_Def = 2 * 1000, RPG_Hp = 80 * 1000 * 1000, RPG_Sp = 1, RPG_Dist = 0.5 * 1000, RPG_Anger = 1000 * 10000, RPG_AngerMax = 1000 * 1000, },
                        --    skills = hero3_skills
                        --},
                        --[4] = {
                        --    hero_id = hero4_id, fpos = 4,lv = 1,
                        --    attr = { RPG_Atk = 5 * 1000, RPG_Def = 2 * 1000, RPG_Hp = 80 * 1000 * 1000, RPG_Sp = 1, RPG_Dist = 0.5 * 1000, RPG_Anger = 1000 * 10000, RPG_AngerMax = 1000 * 1000, },
                        --    skills = hero4_skills
                        --},
                        --[5] = {
                        --    hero_id = hero5_id, fpos = 5,lv = 1,
                        --    attr = { RPG_Atk = 5 * 1000, RPG_Def = 2 * 1000, RPG_Hp = 80 * 1000 * 1000, RPG_Sp = 1, RPG_Dist = 0.5 * 1000, RPG_Anger = 1000 * 10000, RPG_AngerMax = 1000 * 1000, },
                        --    skills = hero5_skills
                        --},
                    } --heros,
                },
                [2] = {
                    heros = {
                        [1] = {
                            hero_id = 102, fpos = 6,lv = 1,
                            attr = { RPG_Atk = 5 * 1000, RPG_Def = 2 * 1000, RPG_Hp = 80 * 1000 * 1000 * 1000, RPG_Sp = 1, RPG_Dist = 1 * 1000, RPG_Anger = 0, RPG_AngerMax = 1000, },
                            skills = {}
                        },
                        [2] = {
                            hero_id = 102, fpos = 7,lv = 1,
                            attr = { RPG_Atk = 5 * 1000, RPG_Def = 2 * 1000, RPG_Hp = 80 * 1000 * 1000 * 1000, RPG_Sp = 1, RPG_Dist = 1 * 1000, RPG_Anger = 0, RPG_AngerMax = 1000, },
                            skills = {}
                        },
                        [3] = {
                            hero_id = 102, fpos = 8,lv = 1,
                            attr = { RPG_Atk = 5 * 1000, RPG_Def = 2 * 1000, RPG_Hp = 80 * 1000 * 1000 * 1000, RPG_Sp = 1, RPG_Dist = 1 * 1000, RPG_Anger = 0, RPG_AngerMax = 1000, },
                            skills = {}
                        },
                        [4] = {
                            hero_id = 102, fpos = 9,lv = 1,
                            attr = { RPG_Atk = 5 * 1000, RPG_Def = 2 * 1000, RPG_Hp = 80 * 1000 * 1000 * 1000, RPG_Sp = 1, RPG_Dist = 1 * 1000, RPG_Anger = 0, RPG_AngerMax = 1000, },
                            skills = {}
                        },
                        [5] = {
                            hero_id = 102, fpos = 10,lv = 1,
                            attr = { RPG_Atk = 5 * 1000, RPG_Def = 2 * 1000, RPG_Hp = 80 * 1000 * 1000 * 1000, RPG_Sp = 1, RPG_Dist = 1 * 1000, RPG_Anger = 0, RPG_AngerMax = 1000, },
                            skills = {}
                        },
                    } --heros
                }
            },
            env = {}, rules = {}
        }
    }  -- 战斗实例
end

--
-------------------------------- 战斗数据播放 --------------------------------
--local test_data = {RpgDungeonData = {id = 1001000264, propid = 10104, teams = {{heros = {{attr = {RPG_Anger = 0.0, RPG_AngerHit = 1000.0, RPG_AngerKill = 200000.0, RPG_AngerMax = 1000000.0, RPG_Atk = 2060000.0, RPG_Def = 18000.0, RPG_Hp = 101263000.0, RPG_Sp = 1.0, RPG_StarFactor = 1000.0, RPG_StarValue = 0.0}, fpos = 4, hero_id = 202, skills = {2024100, 2021100}}}}}}, id = 1001000264}
---- 创建模拟战斗的假数据
--function battle_instance_expedition_simulation.create_battle_data()
--    return test_data.RpgDungeonData
--end