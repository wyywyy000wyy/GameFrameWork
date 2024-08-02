
--
--local ins = T.battle_instance.create_battle(
--    1,
--    {
--        fixed_dt = 500,
--        max_battle_time = 10000,
--
--        battle = {
--            teams = {
--                [1]={
--                    heros = {
--                        [1]={
--                            hero_id = 1,
--                            fpos = 1,
--                            attr = {
--                                atk = 5     *1000,
--                                def = 2     *1000,
--                                hp  = 100   *1000,
--                                sp  = 5     *1000
--                            },
--                            skills = {
--                                1001
--                            }
--                        }
--                    } --heros
--                }
--                
--            },
--            env = {
--
--            },
--            rules = {
--
--            }
--        }
--    }
--)
--
--ins:start()

RPG_CUSTOM = true

if RPG_CUSTOM then

g_custom_data = 
{
  battle = {
    teams = {
      {
        effs = {},
        heros = {
          {
            attr = {
              RPG_Anger = 0,
              RPG_AngerHit = 1.0,
              RPG_AngerKill = 200.0,
              RPG_AngerMax = 1000.0,
              RPG_Atk = 459.79998779297,
              RPG_Block = 0,
              RPG_Crit = 50.0,
              RPG_CritAnti = 0,
              RPG_CritEnhance = 0,
              RPG_Def = 75.23999786377,
              RPG_Hp = 5319.0498046875,
              RPG_Job = 2.0,
              RPG_Race = 2.0,
              RPG_Sp = 1000.0,
              RPG_StarFactor = 2.4800000190735,
              RPG_StarValue = 0
            },
            effs = {
              1003
            },
            fpos = 1,
            hero_id = 114,
            lv = 11,
            skills = {
              1144101,
              11411
            },
            star = 4
          },
          {
            attr = {
              RPG_Anger = 0,
              RPG_AngerHit = 1.0,
              RPG_AngerKill = 200.0,
              RPG_AngerMax = 1000.0,
              RPG_Atk = 344.95999145508,
              RPG_Block = 0,
              RPG_Crit = 50.0,
              RPG_CritAnti = 0,
              RPG_CritEnhance = 0,
              RPG_Def = 88.199996948242,
              RPG_Hp = 6236.7202148438,
              RPG_Job = 1.0,
              RPG_Race = 3.0,
              RPG_Sp = 1000.0,
              RPG_StarFactor = 2.6400001049042,
              RPG_StarValue = 0
            },
            effs = {
              1003
            },
            fpos = 2,
            hero_id = 210,
            lv = 5,
            skills = {
              2104101,
              21011
            },
            star = 5
          },
          {
            attr = {
              RPG_Anger = 0,
              RPG_AngerHit = 1.0,
              RPG_AngerKill = 200.0,
              RPG_AngerMax = 1000.0,
              RPG_Atk = 431.20001220703,
              RPG_Block = 0,
              RPG_Crit = 50.0,
              RPG_CritAnti = 0,
              RPG_CritEnhance = 0,
              RPG_Def = 70.559997558594,
              RPG_Hp = 4988.2001953125,
              RPG_Job = 2.0,
              RPG_Race = 2.0,
              RPG_Sp = 1000.0,
              RPG_StarFactor = 2.6400001049042,
              RPG_StarValue = 0
            },
            effs = {
              1003
            },
            fpos = 3,
            hero_id = 113,
            lv = 5,
            skills = {
              1134101,
              11311
            },
            star = 5
          }
        },
        vpower = 264952.24881834
      },
      {
        heros = {
          {
            attr = {
              RPG_Anger = 0,
              RPG_AngerHit = 1.0,
              RPG_AngerKill = 200.0,
              RPG_AngerMax = 1000.0,
              RPG_Atk = 367.9984,
              RPG_Atk_R = 300,
              RPG_Block = 0,
              RPG_Crit = 50.0,
              RPG_CritAnti = 0,
              RPG_CritEnhance = 0,
              RPG_Def = 94.0905,
              RPG_Def_R = 300,
              RPG_Hp = 6653.2438,
              RPG_Hp_R = 300,
              RPG_Job = 1,
              RPG_Race = 3,
              RPG_Sp = 1000.0,
              RPG_StarFactor = 2.64,
              RPG_StarValue = 0
            },
            buffs = {},
            cfgid = 300055,
            fpos = 6,
            hero_id = 209,
            lv = 7,
            pid = 0,
            skills = {
              2094101,
              20911
            },
            star = 5
          },
          {
            attr = {
              RPG_Anger = 0,
              RPG_AngerHit = 1.0,
              RPG_AngerKill = 200.0,
              RPG_AngerMax = 1000.0,
              RPG_Atk = 367.9984,
              RPG_Atk_R = 300,
              RPG_Block = 0,
              RPG_Crit = 50.0,
              RPG_CritAnti = 0,
              RPG_CritEnhance = 0,
              RPG_Def = 94.0905,
              RPG_Def_R = 300,
              RPG_Hp = 6653.2438,
              RPG_Hp_R = 300,
              RPG_Job = 1,
              RPG_Race = 2,
              RPG_Sp = 1000.0,
              RPG_StarFactor = 2.64,
              RPG_StarValue = 0
            },
            buffs = {},
            cfgid = 300056,
            fpos = 7,
            hero_id = 206,
            lv = 7,
            pid = 0,
            skills = {
              2064101,
              20611
            },
            star = 5
          },
          {
            attr = {
              RPG_Anger = 0,
              RPG_AngerHit = 1.0,
              RPG_AngerKill = 200.0,
              RPG_AngerMax = 1000.0,
              RPG_Atk = 574.9975,
              RPG_Atk_R = 300,
              RPG_Block = 0,
              RPG_Crit = 50.0,
              RPG_CritAnti = 0,
              RPG_CritEnhance = 0,
              RPG_Def = 60.6361,
              RPG_Def_R = 300,
              RPG_Hp = 4257.0724,
              RPG_Hp_R = 300,
              RPG_Job = 3,
              RPG_Race = 1,
              RPG_Sp = 1000.0,
              RPG_StarFactor = 2.64,
              RPG_StarValue = 0
            },
            buffs = {},
            cfgid = 300054,
            fpos = 9,
            hero_id = 302,
            lv = 7,
            pid = 0,
            skills = {
              3024101,
              30211
            },
            star = 5
          }
        },
        vpower = 331884.00671198
      }
    }
  },
  env = {},
  fixed_dt = 100,
  inited = true,
  level_id = 10209,
  max_battle_time = 120000,
  rules = {}
}
else
    g_custom_data = nil
end

local easy_data =
{
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
    level_id = RPG_DEFAULT_LEVEL_ID, --1003202,
    max_battle_time = 180000,
    rules = {}
}

g_custom_data2= {
  anger_pause = false,
  battle = {
    teams = {
      {
        effs = {},
        heros = {
          {
            attr = {
              RPG_Anger = 0,
              RPG_AngerHit = 1.0,
              RPG_AngerKill = 200.0,
              RPG_AngerMax = 1000.0,
              RPG_Atk = 1427.0400390625,
              RPG_Block = 0,
              RPG_Crit = 50.0,
              RPG_CritAnti = 0,
              RPG_CritEnhance = 0,
              RPG_Def = 796.76397705078,
              RPG_FinalIncrease = 30.0,
              RPG_Hp = 55499.96484375,
              RPG_Job = 1.0,
              RPG_Race = 1.0,
              RPG_Sp = 1000.0,
              RPG_StarFactor = 22.5,
              RPG_StarValue = 0
            },
            effs = {},
            fpos = 1,
            hero_id = 202,
            lv = 90,
            skills = {
              2024101,
              2022101,
              2023101,
              20211
            },
            star = 36
          }
        },
        vpower = 30226034.939786
      },
      {
        heros = {
          {
            attr = {
              RPG_Anger = 0,
              RPG_AngerHit = 1.0,
              RPG_AngerKill = 200.0,
              RPG_AngerMax = 1000.0,
              RPG_Atk = 307.8,
              RPG_Block = 0,
              RPG_Crit = 50.0,
              RPG_CritAnti = 0,
              RPG_CritEnhance = 0,
              RPG_Def = 171.855,
              RPG_Hp = 11970.855,
              RPG_Job = 1,
              RPG_Race = 2,
              RPG_Sp = 1000.0,
              RPG_StarFactor = 3.22,
              RPG_StarValue = 0
            },
            buffs = {},
            cfgid = 300361,
            fpos = 6,
            hero_id = 206,
            lv = 14,
            pid = 0,
            skills = {
              2064102,
              2062102,
              20611
            },
            star = 7
          },
          {
            attr = {
              RPG_Anger = 0,
              RPG_AngerHit = 1.0,
              RPG_AngerKill = 200.0,
              RPG_AngerMax = 1000.0,
              RPG_Atk = 307.8,
              RPG_Block = 0,
              RPG_Crit = 50.0,
              RPG_CritAnti = 0,
              RPG_CritEnhance = 0,
              RPG_Def = 171.855,
              RPG_Hp = 11970.855,
              RPG_Job = 1,
              RPG_Race = 3,
              RPG_Sp = 1000.0,
              RPG_StarFactor = 3.22,
              RPG_StarValue = 0
            },
            buffs = {},
            cfgid = 300362,
            fpos = 7,
            hero_id = 209,
            lv = 14,
            pid = 0,
            skills = {
              2094102,
              2092102,
              20911
            },
            star = 7
          },
          {
            attr = {
              RPG_Anger = 0,
              RPG_AngerHit = 1.0,
              RPG_AngerKill = 200.0,
              RPG_AngerMax = 1000.0,
              RPG_Atk = 705.375,
              RPG_Block = 0,
              RPG_Crit = 50.0,
              RPG_CritAnti = 0,
              RPG_CritEnhance = 0,
              RPG_Def = 74.385,
              RPG_Hp = 5222.34,
              RPG_Job = 3,
              RPG_Race = 1,
              RPG_Sp = 1000.0,
              RPG_StarFactor = 3.22,
              RPG_StarValue = 0
            },
            buffs = {},
            cfgid = 300363,
            fpos = 8,
            hero_id = 302,
            lv = 14,
            pid = 0,
            skills = {
              3024102,
              3022102,
              30211
            },
            star = 7
          },
          {
            attr = {
              RPG_Anger = 0,
              RPG_AngerHit = 1.0,
              RPG_AngerKill = 200.0,
              RPG_AngerMax = 1000.0,
              RPG_Atk = 881.71875,
              RPG_Block = 0,
              RPG_Crit = 50.0,
              RPG_CritAnti = 0,
              RPG_CritEnhance = 0,
              RPG_Def = 92.98125,
              RPG_Hp = 6527.925,
              RPG_Job = 3,
              RPG_Race = 2,
              RPG_Sp = 1000.0,
              RPG_StarFactor = 3.22,
              RPG_StarValue = 0
            },
            buffs = {},
            cfgid = 300360,
            fpos = 9,
            hero_id = 308,
            lv = 14,
            pid = 0,
            skills = {
              3084102,
              3082102,
              30811
            },
            star = 7
          },
          {
            attr = {
              RPG_Anger = 0,
              RPG_AngerHit = 1.0,
              RPG_AngerKill = 200.0,
              RPG_AngerMax = 1000.0,
              RPG_Atk = 564.3,
              RPG_Block = 0,
              RPG_Crit = 50.0,
              RPG_CritAnti = 0,
              RPG_CritEnhance = 0,
              RPG_Def = 59.508,
              RPG_Hp = 4177.872,
              RPG_Job = 3,
              RPG_Race = 3,
              RPG_Sp = 1000.0,
              RPG_StarFactor = 3.22,
              RPG_StarValue = 0
            },
            buffs = {},
            cfgid = 300364,
            fpos = 10,
            hero_id = 311,
            lv = 14,
            pid = 0,
            skills = {
              3114102,
              3112102,
              31111
            },
            star = 7
          }
        },
        vpower = 1057466.6926091
      }
    }
  },
  env = {},
  fixed_dt = 100,
  inited = true,
  level_id = 11001,
  max_battle_time = 120000,
  rules = {}
}
-- g_custom_data = easy_data
-- g_custom_data = nil