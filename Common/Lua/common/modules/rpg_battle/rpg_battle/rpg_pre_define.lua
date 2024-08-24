
rpg_config_define = {
    "define_hero_basic",
    "define_rpg_battle_map",
    "define_rpg_battle_level",    
    "define_rpg_battle_group",
    "define_rpg_battle_effect",
    "define_rpg_battle_buff",
    "define_rpg_battle_skill",
    "define_rpg_battle_monster",
    "define_rpg_battle_group",
}
rpg_config = {
    "prop_hero_basic",
    "prop_effect_type",
    "prop_rpg_battle_map",
    "prop_rpg_battle_level",    
    "prop_rpg_battle_group",
    "prop_rpg_battle_effect",
    "prop_rpg_battle_buff",
    "prop_rpg_battle_skill",
    "prop_rpg_battle_monster",
    "prop_rpg_battle_group",
}

function client_load_define()
    for _, config_name in ipairs(rpg_config_define) do
        resmng.load_config(config_name)
    end
end

function client_load_config()
    client_load_define()
    for _, config_name in ipairs(rpg_config) do
        resmng.load_config(config_name)
    end
end

function rpg_load_configs()
    if cskit.is_server() then
        for _, name in ipairs(rpg_config_define) do
            resmng.load_conf('xls/' .. name, false)
            resmng.analy_conf( 'xls/' .. name, false )
        end
        for _, name in ipairs(rpg_config) do
            resmng.load_conf('xls/' .. name, false)
            resmng.analy_conf( 'xls/' .. name, false )
            local mod = resmng[name]
            resmng[name .. 'ById'] = resmng[name .. '_byid']
        end
    else
        client_load_config()
    end
    rpg_config_preprocess()
end
