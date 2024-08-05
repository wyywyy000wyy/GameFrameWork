

-- Task()
-- :persistent_load("table", "key")
-- :excute()

-- sss = "common/framework/type/string"
-- sss_folder = T.file_system.get_folder(sss)
-- LOG("sss", sss,  "folder", sss_folder)

-- local PlayerType = StructDef("Player", 
--     PD(String, "name", "default_name"),
--     PD(Int, "Lv", 1)
-- )

-- local guoguo = PlayerType("player_guoguo", 55)

-- task
-- :persistent_save("Player", 1, guoguo)
-- :persistent_load("Player", 1)
-- :call(function(t, tv1, tv2)
--     local result = t:pr()
--     LOG("persistent_load_call__", result)
-- end, 22, 33)
-- :excute()

-- local guoguo_data = cmsgpack.pack(guoguo)
-- local guoguo_table = cmsgpack.unpack(guoguo_data)
-- local a = 1
-- a  =2

local battle_id = 1
local battle_data = {
    battle = {
        teams = {
            {
                heros = {
                    {
                        attr = {
                            RPG_Anger = -200,
                            RPG_AngerHit = 1.0,
                            RPG_AngerKill = 200.0,
                            RPG_AngerMax = 1000.0,
                            RPG_Atk = 56.462501525879,
                            RPG_Block = 0,
                            RPG_Crit = 50.0,
                            RPG_CritAnti = 0,
                            RPG_CritEnhance = 0,
                            RPG_Def = 15.60000038147,
                            RPG_Hp = 119500.625,
                            RPG_Race = 1.0,
                            RPG_Sp = 4.0,
                            RPG_StarFactor = 1.0,
                            RPG_StarValue = 0
                        },
                        effs = {1003},
                        fpos = 4,
                        hero_id = 204,
                        lv = 6,
                        skills = {
                            -- 2044101,
                            -- 2042101,
                            2064101,
                            20611
                        },
                        star = 1
                    }
                },
                vpower = 8116.5155997033
            }, {
                heros = {
                    {
                        is_boss = true,
                        scale = 1.3,
                        hp_count = 5,
                        attr = {
                            RPG_Anger = 0,
                            RPG_AngerHit = 1.0,
                            RPG_AngerKill = 200.0,
                            RPG_AngerMax = 1000.0,
                            RPG_Atk = 135.358,
                            RPG_Block = 0,
                            RPG_Crit = 50.0,
                            RPG_CritAnti = 0,
                            RPG_CritEnhance = 0,
                            RPG_Def = 19.316,
                            RPG_Hp = 10.82,
                            RPG_Race = 2,
                            RPG_Sp = 4.0,
                            RPG_StarFactor = 1.0,
                            RPG_StarValue = 0
                        },
                        buffs = {},
                        cfgid = 200075,
                        fpos = 6,
                        hero_id = 109,
                        lv = 5,
                        skills = {1093101, 1092101, 1091100},
                        star = 1
                    }
                },
                vpower = 5066.5051537023
            }
        }
    },
    env = {},
    fixed_dt = 100,
    inited = true,
    level_id = 10209, --1003202,
    max_battle_time = 180000,
    rules = {}
}

local battle_ins = T.battle_instance_calc(battle_id, battle_data)
battle_ins._auto_skill = true
battle_ins:start()

LOG("RPG_LOG__ ", battle_ins._statistic_mod:log_str())