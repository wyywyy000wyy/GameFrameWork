--
-- $Id$
--

module( "resmng" )
prop_rpg_battle_groupKey = {
ID = 1, Type = 2, Stack = 3, MaxLevel = 4, Limit = 5, Immune = 6, VFXGroup = 7, Text = 8, 
}

prop_rpg_battle_group_TypeInfo = {}

prop_rpg_battle_group = {

	[RPG_BATTLE_GROUP_SILENCE] = { ID = RPG_BATTLE_GROUP_SILENCE, Type = 3, Stack = 4, MaxLevel = 1, Limit = {"MAGIC","ANGER"}, Immune = nil, VFXGroup = nil, Text = nil,},
	[RPG_BATTLE_GROUP_TAUNT] = { ID = RPG_BATTLE_GROUP_TAUNT, Type = 3, Stack = 4, MaxLevel = 1, Limit = {"SKILL","MAGIC","ANGER"}, Immune = nil, VFXGroup = "ef_aidehua_rpg_spec1_buff", Text = nil,},
	[RPG_BATTLE_GROUP_STUN] = { ID = RPG_BATTLE_GROUP_STUN, Type = 3, Stack = nil, MaxLevel = nil, Limit = {"ATTACK","SKILL","MAGIC","ANGER","MOVE"}, Immune = nil, VFXGroup = "ef_buff_rpg_xuanyun", Text = nil,},
	[RPG_BATTLE_GROUP_FROZEN] = { ID = RPG_BATTLE_GROUP_FROZEN, Type = 3, Stack = nil, MaxLevel = nil, Limit = {"ATTACK","SKILL","MAGIC","ANGER","MOVE"}, Immune = {"FORCE_MOVE"}, VFXGroup = nil, Text = nil,},
	[RPG_BATTLE_GROUP_TRANSFORM] = { ID = RPG_BATTLE_GROUP_TRANSFORM, Type = 0, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = nil, Text = nil,},
	[RPG_BATTLE_GROUP_70] = { ID = RPG_BATTLE_GROUP_70, Type = 0, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_baohuzhao", Text = nil,},
	[RPG_BATTLE_GROUP_101] = { ID = RPG_BATTLE_GROUP_101, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = LG_SKILL_ATTR_NAME_102900005,},
	[RPG_BATTLE_GROUP_102] = { ID = RPG_BATTLE_GROUP_102, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = LG_SKILL_ATTR_NAME_102900009,},
	[RPG_BATTLE_GROUP_111] = { ID = RPG_BATTLE_GROUP_111, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = LG_SKILL_ATTR_NAME_102900029,},
	[RPG_BATTLE_GROUP_112] = { ID = RPG_BATTLE_GROUP_112, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = LG_SKILL_ATTR_NAME_102900033,},
	[RPG_BATTLE_GROUP_113] = { ID = RPG_BATTLE_GROUP_113, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = nil,},
	[RPG_BATTLE_GROUP_114] = { ID = RPG_BATTLE_GROUP_114, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = nil,},
	[RPG_BATTLE_GROUP_115] = { ID = RPG_BATTLE_GROUP_115, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = LG_SKILL_ATTR_NAME_102900025,},
	[RPG_BATTLE_GROUP_116] = { ID = RPG_BATTLE_GROUP_116, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = LG_SKILL_ATTR_NAME_102900021,},
	[RPG_BATTLE_GROUP_121] = { ID = RPG_BATTLE_GROUP_121, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = LG_SKILL_ATTR_NAME_102900090,},
	[RPG_BATTLE_GROUP_122] = { ID = RPG_BATTLE_GROUP_122, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = LG_SKILL_ATTR_NAME_102900037,},
	[RPG_BATTLE_GROUP_123] = { ID = RPG_BATTLE_GROUP_123, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = LG_SKILL_ATTR_NAME_102900041,},
	[RPG_BATTLE_GROUP_124] = { ID = RPG_BATTLE_GROUP_124, Type = 1, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = nil,},
	[RPG_BATTLE_GROUP_125] = { ID = RPG_BATTLE_GROUP_125, Type = 1, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = nil,},
	[RPG_BATTLE_GROUP_126] = { ID = RPG_BATTLE_GROUP_126, Type = 1, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = nil,},
	[RPG_BATTLE_GROUP_127] = { ID = RPG_BATTLE_GROUP_127, Type = 1, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = nil,},
	[RPG_BATTLE_GROUP_128] = { ID = RPG_BATTLE_GROUP_128, Type = 1, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = nil,},
	[RPG_BATTLE_GROUP_129] = { ID = RPG_BATTLE_GROUP_129, Type = 1, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = nil,},
	[RPG_BATTLE_GROUP_131] = { ID = RPG_BATTLE_GROUP_131, Type = 1, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = nil, Text = nil,},
	[RPG_BATTLE_GROUP_132] = { ID = RPG_BATTLE_GROUP_132, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = nil, Text = nil,},
	[RPG_BATTLE_GROUP_133] = { ID = RPG_BATTLE_GROUP_133, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = nil, Text = nil,},
	[RPG_BATTLE_GROUP_134] = { ID = RPG_BATTLE_GROUP_134, Type = 1, Stack = 1, MaxLevel = 10, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_gjsuduup", Text = LG_SKILL_ATTR_NAME_102900135,},
	[RPG_BATTLE_GROUP_135] = { ID = RPG_BATTLE_GROUP_135, Type = 1, Stack = 1, MaxLevel = 10, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_teshusudu", Text = nil,},
	[RPG_BATTLE_GROUP_136] = { ID = RPG_BATTLE_GROUP_136, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_suduup", Text = nil,},
	[RPG_BATTLE_GROUP_1011] = { ID = RPG_BATTLE_GROUP_1011, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = LG_SKILL_ATTR_NAME_102900005,},
	[RPG_BATTLE_GROUP_1012] = { ID = RPG_BATTLE_GROUP_1012, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = LG_SKILL_ATTR_NAME_102900005,},
	[RPG_BATTLE_GROUP_1013] = { ID = RPG_BATTLE_GROUP_1013, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = LG_SKILL_ATTR_NAME_102900005,},
	[RPG_BATTLE_GROUP_1014] = { ID = RPG_BATTLE_GROUP_1014, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = LG_SKILL_ATTR_NAME_102900005,},
	[RPG_BATTLE_GROUP_1021] = { ID = RPG_BATTLE_GROUP_1021, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = LG_SKILL_ATTR_NAME_102900009,},
	[RPG_BATTLE_GROUP_1022] = { ID = RPG_BATTLE_GROUP_1022, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = LG_SKILL_ATTR_NAME_102900009,},
	[RPG_BATTLE_GROUP_1023] = { ID = RPG_BATTLE_GROUP_1023, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = LG_SKILL_ATTR_NAME_102900009,},
	[RPG_BATTLE_GROUP_1024] = { ID = RPG_BATTLE_GROUP_1024, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = LG_SKILL_ATTR_NAME_102900009,},
	[RPG_BATTLE_GROUP_1211] = { ID = RPG_BATTLE_GROUP_1211, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = LG_SKILL_ATTR_NAME_102900090,},
	[RPG_BATTLE_GROUP_1212] = { ID = RPG_BATTLE_GROUP_1212, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = LG_SKILL_ATTR_NAME_102900090,},
	[RPG_BATTLE_GROUP_1213] = { ID = RPG_BATTLE_GROUP_1213, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = LG_SKILL_ATTR_NAME_102900090,},
	[RPG_BATTLE_GROUP_1214] = { ID = RPG_BATTLE_GROUP_1214, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjiup", Text = LG_SKILL_ATTR_NAME_102900090,},
	[RPG_BATTLE_GROUP_1341] = { ID = RPG_BATTLE_GROUP_1341, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_suduup", Text = nil,},
	[RPG_BATTLE_GROUP_1342] = { ID = RPG_BATTLE_GROUP_1342, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_suduup", Text = nil,},
	[RPG_BATTLE_GROUP_1343] = { ID = RPG_BATTLE_GROUP_1343, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_suduup", Text = nil,},
	[RPG_BATTLE_GROUP_1344] = { ID = RPG_BATTLE_GROUP_1344, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_suduup", Text = nil,},
	[RPG_BATTLE_GROUP_1361] = { ID = RPG_BATTLE_GROUP_1361, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_suduup", Text = nil,},
	[RPG_BATTLE_GROUP_1362] = { ID = RPG_BATTLE_GROUP_1362, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_suduup", Text = nil,},
	[RPG_BATTLE_GROUP_1363] = { ID = RPG_BATTLE_GROUP_1363, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_suduup", Text = nil,},
	[RPG_BATTLE_GROUP_1364] = { ID = RPG_BATTLE_GROUP_1364, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_suduup", Text = nil,},
	[RPG_BATTLE_GROUP_201] = { ID = RPG_BATTLE_GROUP_201, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjidown", Text = LG_SKILL_ATTR_NAME_102900060,},
	[RPG_BATTLE_GROUP_202] = { ID = RPG_BATTLE_GROUP_202, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyudown", Text = LG_SKILL_ATTR_NAME_102900061,},
	[RPG_BATTLE_GROUP_211] = { ID = RPG_BATTLE_GROUP_211, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjidown", Text = LG_SKILL_ATTR_NAME_102900089,},
	[RPG_BATTLE_GROUP_212] = { ID = RPG_BATTLE_GROUP_212, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyudown", Text = nil,},
	[RPG_BATTLE_GROUP_213] = { ID = RPG_BATTLE_GROUP_213, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjidown", Text = nil,},
	[RPG_BATTLE_GROUP_214] = { ID = RPG_BATTLE_GROUP_214, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyudown", Text = nil,},
	[RPG_BATTLE_GROUP_215] = { ID = RPG_BATTLE_GROUP_215, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjidown", Text = nil,},
	[RPG_BATTLE_GROUP_216] = { ID = RPG_BATTLE_GROUP_216, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyudown", Text = LG_SKILL_ATTR_NAME_102900099,},
	[RPG_BATTLE_GROUP_221] = { ID = RPG_BATTLE_GROUP_221, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjidown", Text = nil,},
	[RPG_BATTLE_GROUP_222] = { ID = RPG_BATTLE_GROUP_222, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjidown", Text = nil,},
	[RPG_BATTLE_GROUP_223] = { ID = RPG_BATTLE_GROUP_223, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyudown", Text = LG_SKILL_ATTR_NAME_102900088,},
	[RPG_BATTLE_GROUP_224] = { ID = RPG_BATTLE_GROUP_224, Type = 2, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyudown", Text = nil,},
	[RPG_BATTLE_GROUP_225] = { ID = RPG_BATTLE_GROUP_225, Type = 2, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyudown", Text = nil,},
	[RPG_BATTLE_GROUP_226] = { ID = RPG_BATTLE_GROUP_226, Type = 2, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjidown", Text = nil,},
	[RPG_BATTLE_GROUP_227] = { ID = RPG_BATTLE_GROUP_227, Type = 2, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjidown", Text = nil,},
	[RPG_BATTLE_GROUP_228] = { ID = RPG_BATTLE_GROUP_228, Type = 2, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyudown", Text = nil,},
	[RPG_BATTLE_GROUP_229] = { ID = RPG_BATTLE_GROUP_229, Type = 2, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtgongjidown", Text = nil,},
	[RPG_BATTLE_GROUP_231] = { ID = RPG_BATTLE_GROUP_231, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = nil, Text = nil,},
	[RPG_BATTLE_GROUP_232] = { ID = RPG_BATTLE_GROUP_232, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = nil, Text = nil,},
	[RPG_BATTLE_GROUP_233] = { ID = RPG_BATTLE_GROUP_233, Type = 2, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = nil, Text = nil,},
	[RPG_BATTLE_GROUP_234] = { ID = RPG_BATTLE_GROUP_234, Type = 2, Stack = 1, MaxLevel = 10, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_sududown", Text = LG_SKILL_ATTR_NAME_102900136,},
	[RPG_BATTLE_GROUP_235] = { ID = RPG_BATTLE_GROUP_235, Type = 2, Stack = 1, MaxLevel = 10, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_sududown", Text = nil,},
	[RPG_BATTLE_GROUP_236] = { ID = RPG_BATTLE_GROUP_236, Type = 2, Stack = 1, MaxLevel = 10, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_sududown", Text = nil,},
	[RPG_BATTLE_GROUP_2361] = { ID = RPG_BATTLE_GROUP_2361, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_sududown", Text = nil,},
	[RPG_BATTLE_GROUP_2362] = { ID = RPG_BATTLE_GROUP_2362, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_sududown", Text = nil,},
	[RPG_BATTLE_GROUP_2363] = { ID = RPG_BATTLE_GROUP_2363, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_sududown", Text = nil,},
	[RPG_BATTLE_GROUP_2364] = { ID = RPG_BATTLE_GROUP_2364, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_sududown", Text = nil,},
	[RPG_BATTLE_GROUP_3001] = { ID = RPG_BATTLE_GROUP_3001, Type = 0, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = nil, Text = nil,},
	[RPG_BATTLE_GROUP_3002] = { ID = RPG_BATTLE_GROUP_3002, Type = 2, Stack = 2, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_liuxue", Text = LG_MINBUFF_NAME_0028,},
	[RPG_BATTLE_GROUP_3003] = { ID = RPG_BATTLE_GROUP_3003, Type = 2, Stack = 3, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_zhongdu", Text = LG_MINBUFF_NAME_0038,},
	[RPG_BATTLE_GROUP_3004] = { ID = RPG_BATTLE_GROUP_3004, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_zhiliao", Text = MAIL_FIGHT_102200204,},
	[RPG_BATTLE_GROUP_3005] = { ID = RPG_BATTLE_GROUP_3005, Type = 1, Stack = 1, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_zhiliao", Text = MAIL_FIGHT_102200204,},
	[RPG_BATTLE_GROUP_3006] = { ID = RPG_BATTLE_GROUP_3006, Type = 2, Stack = 2, MaxLevel = 999, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_liuxue", Text = LG_MINBUFF_NAME_0028,},
	[RPG_BATTLE_GROUP_4001] = { ID = RPG_BATTLE_GROUP_4001, Type = 2, Stack = 4, MaxLevel = 1, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = nil,},
	[RPG_BATTLE_GROUP_4002] = { ID = RPG_BATTLE_GROUP_4002, Type = 1, Stack = 2, MaxLevel = 10, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = nil,},
	[RPG_BATTLE_GROUP_21151] = { ID = RPG_BATTLE_GROUP_21151, Type = 1, Stack = 2, MaxLevel = 6, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = nil,},
	[RPG_BATTLE_GROUP_21251] = { ID = RPG_BATTLE_GROUP_21251, Type = 1, Stack = 2, MaxLevel = 7, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = nil,},
	[RPG_BATTLE_GROUP_21351] = { ID = RPG_BATTLE_GROUP_21351, Type = 1, Stack = 2, MaxLevel = 5, Limit = nil, Immune = nil, VFXGroup = "ef_buff_rpg_dtfangyuup", Text = nil,},
}


function prop_rpg_battle_group_byid(_key_id)
    local id_data = prop_rpg_battle_group[_key_id]
    if id_data == nil then
        ERROR("[resmng] get_conf: invalid key %s for prop_rpg_battle_group", _key_id)
        return
    end
    return id_data
end

