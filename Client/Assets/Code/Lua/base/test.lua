

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
local battle_data = 
{
  anger_pause = false,
  battle = {
    teams = {
      {
        effs = {},
        heros = {
          {
            attr = {
              RPG_Anger = 0,
              RPG_AngerHit = 1,
              RPG_AngerKill = 200,
              RPG_AngerMax = 1000,
              RPG_Atk = 2106.5,
              RPG_Block = 0,
              RPG_Crit = 50,
              RPG_CritAnti = 0,
              RPG_CritEnhance = 0,
              RPG_Def = 344.70001220703,
              RPG_Hp = 24368.375,
              RPG_Job = 2,
              RPG_Race = 2,
              RPG_Sp = 1000,
              RPG_StarFactor = 11.920000076294,
              RPG_StarValue = 0
            },
            effs = {},
            fpos = 1,
            hero_id = 2402,
            lv = 90,
            skills = {
              24022101,
              24023101,
              24024101,
              240211
            },
            star = 25
          }
        },
        vpower = 8936168.4469094
      },
      {
        heros = {},
        vpower = 0
      }
    }
  },
  env = {},
  fixed_dt = 100,
  inited = true,
  level_id = 10101,
  max_battle_time = 120000,
  rules = {}
}	

-- local battle_ins = T.battle_instance_turned_calc(battle_id, battle_data)
-- battle_ins._auto_skill = true
-- battle_ins:start()

-- LOG("RPG_LOG__ ", battle_ins._statistic_mod:log_str())

local battle_ins = T.battle_instance_client(battle_id, battle_data)
battle_ins._auto_skill = true
battle_ins:start()