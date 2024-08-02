local battle_instance_calc = class2("battle_instance_calc", T.battle_instance, function(self, battle_id, init_data)
    if init_data then
        local code, data = T.rpg_init_mod.create_init_data(init_data)
        init_data = data
    end

    init_data = init_data or {
        fixed_dt = 500,
        max_battle_time = 10*1000,
        level_id = 10101,   -- 关卡id prop_rpg_battle_level 中的Id
        battle = {
            teams = {
                [1] = {
                    heros = {
                        [1] = {
                            --hero_id = 1,
                            hero_id = 2111001, -- prop_hero_basic 英雄配置表id
                            fpos = 1,
                            attr = {
                                RPG_Atk = 5 * 1000,
                                RPG_Def = 2 * 1000,
                                RPG_Hp = 500 * 1000,
                                RPG_Sp = 1 * 1000 / 1000, --ms
                                RPG_Dist = 0.5 * 1000,
                                RPG_Anger = 1000 * 1000,
                                RPG_AngerMax = 1000 * 1000,
                                RPG_AngerSp = 100,
                            },
                            skills = {
                                resmng.RPG_BATTLE_SKILL_10001,
                                resmng.RPG_BATTLE_SKILL_50001,
                                -- 10010101
                            }
                        },
                        [2] = {
                            --hero_id = 1,
                            hero_id = 2111001, -- prop_hero_basic 英雄配置表id
                            fpos = 2,
                            attr = {
                                RPG_Atk = 5 * 1000,
                                RPG_Def = 2 * 1000,
                                RPG_Hp = 500 * 1000,
                                RPG_Sp = 1 * 1000 / 1000, --ms
                                RPG_Dist = 0.5 * 1000,
                                RPG_Anger = 960 * 1000,
                                RPG_AngerMax = 1000 * 1000,
                                RPG_AngerSp = 100,
                            },
                            skills = {
    
                            }
                        },
                        -- [3] = {
                        --     --hero_id = 1,
                        --     hero_id = 2111001, -- prop_hero_basic 英雄配置表id
                        --     fpos = 3,
                        --     attr = {
                        --         RPG_Atk = 5 * 1000,
                        --         RPG_Def = 2 * 1000,
                        --         RPG_Hp = 500 * 1000,
                        --         RPG_Sp = 1 * 1000 / 1000, --ms
                        --         RPG_Dist = 0.5 * 1000,
                        --         RPG_Anger = 960 * 1000,
                        --         RPG_AngerMax = 1000 * 1000,
                        --         RPG_AngerSp = 100,
                        --     },
                        --     skills = {
                        --         10010104,
                        --         -- 10010101
                        --     }
                        -- },
                        -- [4] = {
                        --     --hero_id = 1,
                        --     hero_id = 2111001, -- prop_hero_basic 英雄配置表id
                        --     fpos = 4,
                        --     attr = {
                        --         RPG_Atk = 5 * 1000,
                        --         RPG_Def = 2 * 1000,
                        --         RPG_Hp = 500 * 1000,
                        --         RPG_Sp = 1 * 1000 / 1000, --ms
                        --         RPG_Dist = 0.5 * 1000,
                        --         RPG_Anger = 960 * 1000,
                        --         RPG_AngerMax = 1000 * 1000,
                        --         RPG_AngerSp = 100,
                        --     },
                        --     skills = {
                        --         10010104,
                        --         -- 10010101
                        --     }
                        -- },
                        -- [5] = {
                        --     --hero_id = 1,
                        --     hero_id = 2111001, -- prop_hero_basic 英雄配置表id
                        --     fpos = 5,
                        --     attr = {
                        --         RPG_Atk = 5 * 1000,
                        --         RPG_Def = 2 * 1000,
                        --         RPG_Hp = 500 * 1000,
                        --         RPG_Sp = 1 * 1000 / 1000, --ms
                        --         RPG_Dist = 0.5 * 1000,
                        --         RPG_Anger = 960 * 1000,
                        --         RPG_AngerMax = 1000 * 1000,
                        --         RPG_AngerSp = 100,
                        --     },
                        --     skills = {
                        --         10010104,
                        --         -- 10010101
                        --     }
                        -- },
                    } --heros,
                },
                [2] = {
                    heros = {
                        [1] = {
                            --hero_id = 3,
                            hero_id = 2111001, -- prop_hero_basic 英雄配置表id
                            fpos = 6,
                            attr = {
                                RPG_Atk = 5 * 1000,
                                RPG_Def = 2 * 1000,
                                RPG_Hp = 1000 * 1000,
                                RPG_Sp = 5 * 1000 / 1000,
                                RPG_Dist = 1 * 1000,
                                RPG_Anger = 500 * 1000,
                                RPG_AngerMax = 1000 * 1000,
                                RPG_AngerSp = 200,
                            },
                            skills = {
                                resmng.RPG_BATTLE_SKILL_20001
                            }
                        },
                        [2] = {
                            --hero_id = 3,
                            hero_id = 2111001, -- prop_hero_basic 英雄配置表id
                            fpos = 7,
                            attr = {
                                RPG_Atk = 5 * 1000,
                                RPG_Def = 2 * 1000,
                                RPG_Hp = 1000 * 1000,
                                RPG_Sp = 5 * 1000 / 1000,
                                RPG_Dist = 1 * 1000,
                                RPG_Anger = 500 * 1000,
                                RPG_AngerMax = 1000 * 1000,
                                RPG_AngerSp = 200,
                            },
                            skills = {
                                resmng.RPG_BATTLE_SKILL_40001
                            }
                        },
                        -- [3] = {
                        --     --hero_id = 3,
                        --     hero_id = 2111001, -- prop_hero_basic 英雄配置表id
                        --     fpos = 8,
                        --     attr = {
                        --         RPG_Atk = 5 * 1000,
                        --         RPG_Def = 2 * 1000,
                        --         RPG_Hp = 1000 * 1000,
                        --         RPG_Sp = 5 * 1000 / 1000,
                        --         RPG_Dist = 1 * 1000,
                        --         RPG_Anger = 500 * 1000,
                        --         RPG_AngerMax = 1000 * 1000,
                        --         RPG_AngerSp = 200,
                        --     },
                        --     skills = {
                        --         10010101
                        --     }
                        -- },
                        -- [4] = {
                        --     --hero_id = 3,
                        --     hero_id = 2111001, -- prop_hero_basic 英雄配置表id
                        --     fpos = 9,
                        --     attr = {
                        --         RPG_Atk = 5 * 1000,
                        --         RPG_Def = 2 * 1000,
                        --         RPG_Hp = 1000 * 1000,
                        --         RPG_Sp = 5 * 1000 / 1000,
                        --         RPG_Dist = 1 * 1000,
                        --         RPG_Anger = 500 * 1000,
                        --         RPG_AngerMax = 1000 * 1000,
                        --         RPG_AngerSp = 200,
                        --     },
                        --     skills = {
                        --         10010101
                        --     }
                        -- },
                        -- [5] = {
                        --     --hero_id = 3,
                        --     hero_id = 2111001, -- prop_hero_basic 英雄配置表id
                        --     fpos = 10,
                        --     attr = {
                        --         RPG_Atk = 5 * 1000,
                        --         RPG_Def = 2 * 1000,
                        --         RPG_Hp = 1000 * 1000,
                        --         RPG_Sp = 5 * 1000 / 1000,
                        --         RPG_Dist = 1 * 1000,
                        --         RPG_Anger = 500 * 1000,
                        --         RPG_AngerMax = 1000 * 1000,
                        --         RPG_AngerSp = 200,
                        --     },
                        --     skills = {
                        --         10010101
                        --     }
                        -- },
                    } --heros
                }
    
            },
            env = {
    
            },
            rules = {
    
            }
        }
    }  -- 战斗实例
    T.battle_instance._ctor(self, battle_id, init_data)
end)

function battle_instance_calc:start()
    local rpg_debug_mod = T.rpg_debug_mod(self)
    self:add_mod(rpg_debug_mod)

    local physics_mod = T.physics_mod(self)
    self:add_mod(physics_mod)

    local controller_mod = T.controller_mod(self)
    self:add_mod(controller_mod)

    local battle_mod = T.battle_mod(self)
    self:add_mod(battle_mod)

    local record_mod = T.record_mod(self)
    self:add_mod(record_mod)

    local statistic_mod = T.statistic_mod(self)
    self:add_mod(statistic_mod)

    T.battle_instance.start(self)

    local fixed_dt = self._fixed_dt
    local max_battle_time = self._init_data.max_battle_time
    while not battle_mod._bfin do
        self:update(fixed_dt)
    end

    if not self._finish then
        self:stop()
    end
    -- while self._finish do
    --     self:update(fixed_time)
    -- end
end


