--
-- $Id$
--

module( "resmng" )
prop_rpg_battle_buffKey = {
ID = 1, VFXBuff = 2, Group = 3, lv = 4, EffectStart = 5, Tick = 6, TickEffect = 7, Event = 8, EventEffect = 9, RemoveEvent = 10, 
}

prop_rpg_battle_buff_TypeInfo = { VFXBuff = [[Maybe(OneOf(Addressable, List(Addressable)))]], }

prop_rpg_battle_buff = {

	[RPG_BATTLE_BUFF_INNER_FORCE_MOVE] = { ID = RPG_BATTLE_BUFF_INNER_FORCE_MOVE, VFXBuff = nil, Group = nil, lv = 1, EffectStart = nil, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_INNER_TAUNT] = { ID = RPG_BATTLE_BUFF_INNER_TAUNT, VFXBuff = nil, Group = 11, lv = 1, EffectStart = nil, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_INNER_TRANSFORM] = { ID = RPG_BATTLE_BUFF_INNER_TRANSFORM, VFXBuff = nil, Group = 27, lv = 1, EffectStart = nil, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_240131] = { ID = RPG_BATTLE_BUFF_240131, VFXBuff = nil, Group = 134, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_240132}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_240231] = { ID = RPG_BATTLE_BUFF_240231, VFXBuff = nil, Group = 134, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_240232}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1065200] = { ID = RPG_BATTLE_BUFF_1065200, VFXBuff = nil, Group = 3006, lv = 1, EffectStart = nil, Tick = 1000, TickEffect = {RPG_BATTLE_EFFECT_1065300}, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1113100] = { ID = RPG_BATTLE_BUFF_1113100, VFXBuff = nil, Group = 101, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1113200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1115200] = { ID = RPG_BATTLE_BUFF_1115200, VFXBuff = nil, Group = 111, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1115300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2033100] = { ID = RPG_BATTLE_BUFF_2033100, VFXBuff = nil, Group = 201, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_2033200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2034200] = { ID = RPG_BATTLE_BUFF_2034200, VFXBuff = {"ef_weiseer_rpg_spec1_line","ef_weiseer_rpg_spec1_spell"}, Group = 3001, lv = 1, EffectStart = nil, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2036100] = { ID = RPG_BATTLE_BUFF_2036100, VFXBuff = "ef_buff_rpg_baohuzhao", Group = 70, lv = 1, EffectStart = nil, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1094300] = { ID = RPG_BATTLE_BUFF_1094300, VFXBuff = nil, Group = 121, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1094400}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1095100] = { ID = RPG_BATTLE_BUFF_1095100, VFXBuff = nil, Group = 224, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1095200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2072100] = { ID = RPG_BATTLE_BUFF_2072100, VFXBuff = nil, Group = 234, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_2072200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2073100] = { ID = RPG_BATTLE_BUFF_2073100, VFXBuff = nil, Group = 1012, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_2073200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2074100] = { ID = RPG_BATTLE_BUFF_2074100, VFXBuff = nil, Group = 125, lv = 10, EffectStart = {RPG_BATTLE_EFFECT_2074300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1074300] = { ID = RPG_BATTLE_BUFF_1074300, VFXBuff = nil, Group = 234, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1074400}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1075200] = { ID = RPG_BATTLE_BUFF_1075200, VFXBuff = nil, Group = 134, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1075300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2062200] = { ID = RPG_BATTLE_BUFF_2062200, VFXBuff = nil, Group = 116, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_2062300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2064300] = { ID = RPG_BATTLE_BUFF_2064300, VFXBuff = nil, Group = 116, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_2064400}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2102100] = { ID = RPG_BATTLE_BUFF_2102100, VFXBuff = nil, Group = 3004, lv = 1, EffectStart = nil, Tick = 1000, TickEffect = {RPG_BATTLE_EFFECT_2102200}, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2105100] = { ID = RPG_BATTLE_BUFF_2105100, VFXBuff = nil, Group = 3004, lv = 1, EffectStart = nil, Tick = 1000, TickEffect = {RPG_BATTLE_EFFECT_2105200}, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1022100] = { ID = RPG_BATTLE_BUFF_1022100, VFXBuff = nil, Group = 3005, lv = 1, EffectStart = nil, Tick = 1000, TickEffect = {RPG_BATTLE_EFFECT_1022200}, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1023100] = { ID = RPG_BATTLE_BUFF_1023100, VFXBuff = nil, Group = 1011, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1023200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1025200] = { ID = RPG_BATTLE_BUFF_1025200, VFXBuff = nil, Group = 202, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1025300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1123100] = { ID = RPG_BATTLE_BUFF_1123100, VFXBuff = nil, Group = 1343, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1123200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1124300] = { ID = RPG_BATTLE_BUFF_1124300, VFXBuff = nil, Group = 202, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1124400}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1125200] = { ID = RPG_BATTLE_BUFF_1125200, VFXBuff = nil, Group = 134, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1125300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2132200] = { ID = RPG_BATTLE_BUFF_2132200, VFXBuff = nil, Group = 116, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_2132300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2133100] = { ID = RPG_BATTLE_BUFF_2133100, VFXBuff = nil, Group = 21351, lv = 10, EffectStart = {RPG_BATTLE_EFFECT_2133200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2134200] = { ID = RPG_BATTLE_BUFF_2134200, VFXBuff = nil, Group = 116, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_2134300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3124100] = { ID = RPG_BATTLE_BUFF_3124100, VFXBuff = "ef_hatuoer_rpg_skill_hit01", Group = 234, lv = 10, EffectStart = {RPG_BATTLE_EFFECT_3124300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3125200] = { ID = RPG_BATTLE_BUFF_3125200, VFXBuff = nil, Group = 201, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3125300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3033100] = { ID = RPG_BATTLE_BUFF_3033100, VFXBuff = nil, Group = 1011, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3033200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3035200] = { ID = RPG_BATTLE_BUFF_3035200, VFXBuff = nil, Group = 234, lv = 10, EffectStart = {RPG_BATTLE_EFFECT_3035300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2145200] = { ID = RPG_BATTLE_BUFF_2145200, VFXBuff = nil, Group = 116, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_2145300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1102100] = { ID = RPG_BATTLE_BUFF_1102100, VFXBuff = nil, Group = 101, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1102200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3153100] = { ID = RPG_BATTLE_BUFF_3153100, VFXBuff = nil, Group = 101, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3153200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3155200] = { ID = RPG_BATTLE_BUFF_3155200, VFXBuff = nil, Group = 201, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3155300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3075200] = { ID = RPG_BATTLE_BUFF_3075200, VFXBuff = nil, Group = 134, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3075300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3162100] = { ID = RPG_BATTLE_BUFF_3162100, VFXBuff = nil, Group = 101, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3162200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3163100] = { ID = RPG_BATTLE_BUFF_3163100, VFXBuff = nil, Group = 134, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3163200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3163300] = { ID = RPG_BATTLE_BUFF_3163300, VFXBuff = nil, Group = 1212, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3163400}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3165200] = { ID = RPG_BATTLE_BUFF_3165200, VFXBuff = nil, Group = 134, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3165300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2042200] = { ID = RPG_BATTLE_BUFF_2042200, VFXBuff = nil, Group = 125, lv = 10, EffectStart = {RPG_BATTLE_EFFECT_2042300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2043100] = { ID = RPG_BATTLE_BUFF_2043100, VFXBuff = nil, Group = 1021, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_2043200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2045200] = { ID = RPG_BATTLE_BUFF_2045200, VFXBuff = nil, Group = 102, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_2045300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2114300] = { ID = RPG_BATTLE_BUFF_2114300, VFXBuff = nil, Group = 102, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_2114400}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2115100] = { ID = RPG_BATTLE_BUFF_2115100, VFXBuff = nil, Group = 21151, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_2115200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_2125100] = { ID = RPG_BATTLE_BUFF_2125100, VFXBuff = nil, Group = 21251, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_2125200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3105200] = { ID = RPG_BATTLE_BUFF_3105200, VFXBuff = nil, Group = 101, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3105300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1035200] = { ID = RPG_BATTLE_BUFF_1035200, VFXBuff = nil, Group = 102, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1035300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3084200] = { ID = RPG_BATTLE_BUFF_3084200, VFXBuff = nil, Group = 111, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3084300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3085200] = { ID = RPG_BATTLE_BUFF_3085200, VFXBuff = nil, Group = 122, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3085300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3094300] = { ID = RPG_BATTLE_BUFF_3094300, VFXBuff = nil, Group = 233, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3094400}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3095200] = { ID = RPG_BATTLE_BUFF_3095200, VFXBuff = nil, Group = 1212, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3095300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3053100] = { ID = RPG_BATTLE_BUFF_3053100, VFXBuff = nil, Group = 101, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3053200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3054200] = { ID = RPG_BATTLE_BUFF_3054200, VFXBuff = nil, Group = 234, lv = 10, EffectStart = {RPG_BATTLE_EFFECT_3054300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3055200] = { ID = RPG_BATTLE_BUFF_3055200, VFXBuff = nil, Group = 224, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3055300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3143100] = { ID = RPG_BATTLE_BUFF_3143100, VFXBuff = nil, Group = 101, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3143200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3145200] = { ID = RPG_BATTLE_BUFF_3145200, VFXBuff = nil, Group = 225, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3145300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1085200] = { ID = RPG_BATTLE_BUFF_1085200, VFXBuff = nil, Group = 134, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1085300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1132100] = { ID = RPG_BATTLE_BUFF_1132100, VFXBuff = nil, Group = 101, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1132200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1134200] = { ID = RPG_BATTLE_BUFF_1134200, VFXBuff = nil, Group = 134, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1134200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1135200] = { ID = RPG_BATTLE_BUFF_1135200, VFXBuff = nil, Group = 202, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1135300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_1145200] = { ID = RPG_BATTLE_BUFF_1145200, VFXBuff = nil, Group = 134, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_1145300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3182200] = { ID = RPG_BATTLE_BUFF_3182200, VFXBuff = nil, Group = 101, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3182300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_3183100] = { ID = RPG_BATTLE_BUFF_3183100, VFXBuff = nil, Group = 101, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_3183200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_4034100] = { ID = RPG_BATTLE_BUFF_4034100, VFXBuff = nil, Group = 128, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_4034200}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_4044100] = { ID = RPG_BATTLE_BUFF_4044100, VFXBuff = nil, Group = 128, lv = 1, EffectStart = {RPG_BATTLE_EFFECT_4044300}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_2090] = { ID = RPG_BATTLE_ROUGUE_BUFF_2090, VFXBuff = nil, Group = nil, lv = 1, EffectStart = nil, Tick = nil, TickEffect = nil, Event = {4,{1,1},"RPG_OID==c.RPG_OID"}, EventEffect = {RPG_BATTLE_ROUGUE_EFFECT_2091}, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_2091] = { ID = RPG_BATTLE_ROUGUE_BUFF_2091, VFXBuff = nil, Group = 202, lv = 1, EffectStart = {RPG_BATTLE_ROUGUE_EFFECT_2092}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_2100] = { ID = RPG_BATTLE_ROUGUE_BUFF_2100, VFXBuff = nil, Group = nil, lv = 1, EffectStart = nil, Tick = nil, TickEffect = nil, Event = {4,{1,1},"RPG_OID==c.RPG_OID"}, EventEffect = {RPG_BATTLE_ROUGUE_EFFECT_2101}, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_2101] = { ID = RPG_BATTLE_ROUGUE_BUFF_2101, VFXBuff = nil, Group = 201, lv = 1, EffectStart = {RPG_BATTLE_ROUGUE_EFFECT_2102}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_2590] = { ID = RPG_BATTLE_ROUGUE_BUFF_2590, VFXBuff = nil, Group = nil, lv = 1, EffectStart = nil, Tick = nil, TickEffect = nil, Event = {4,{1,1},"RPG_OID==c.RPG_OID"}, EventEffect = {RPG_BATTLE_ROUGUE_EFFECT_2591}, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_2591] = { ID = RPG_BATTLE_ROUGUE_BUFF_2591, VFXBuff = nil, Group = 202, lv = 1, EffectStart = {RPG_BATTLE_ROUGUE_EFFECT_2592}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_2600] = { ID = RPG_BATTLE_ROUGUE_BUFF_2600, VFXBuff = nil, Group = nil, lv = 1, EffectStart = nil, Tick = nil, TickEffect = nil, Event = {4,{1,1},"RPG_OID==c.RPG_OID"}, EventEffect = {RPG_BATTLE_ROUGUE_EFFECT_2601}, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_2601] = { ID = RPG_BATTLE_ROUGUE_BUFF_2601, VFXBuff = nil, Group = 201, lv = 1, EffectStart = {RPG_BATTLE_ROUGUE_EFFECT_2602}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_3090] = { ID = RPG_BATTLE_ROUGUE_BUFF_3090, VFXBuff = nil, Group = nil, lv = 1, EffectStart = nil, Tick = nil, TickEffect = nil, Event = {4,{1,1},"RPG_OID==c.RPG_OID"}, EventEffect = {RPG_BATTLE_ROUGUE_EFFECT_3091}, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_3091] = { ID = RPG_BATTLE_ROUGUE_BUFF_3091, VFXBuff = nil, Group = 202, lv = 1, EffectStart = {RPG_BATTLE_ROUGUE_EFFECT_3092}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_3100] = { ID = RPG_BATTLE_ROUGUE_BUFF_3100, VFXBuff = nil, Group = nil, lv = 1, EffectStart = nil, Tick = nil, TickEffect = nil, Event = {4,{1,1},"RPG_OID==c.RPG_OID"}, EventEffect = {RPG_BATTLE_ROUGUE_EFFECT_3101}, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_3101] = { ID = RPG_BATTLE_ROUGUE_BUFF_3101, VFXBuff = nil, Group = 201, lv = 1, EffectStart = {RPG_BATTLE_ROUGUE_EFFECT_3102}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_4022] = { ID = RPG_BATTLE_ROUGUE_BUFF_4022, VFXBuff = nil, Group = 4001, lv = 1, EffectStart = {RPG_BATTLE_ROUGUE_EFFECT_4022}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_ROUGUE_BUFF_4032] = { ID = RPG_BATTLE_ROUGUE_BUFF_4032, VFXBuff = nil, Group = 4002, lv = 1, EffectStart = {RPG_BATTLE_ROUGUE_EFFECT_4032}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_COMMON_BUFF_1001] = { ID = RPG_BATTLE_COMMON_BUFF_1001, VFXBuff = nil, Group = 3002, lv = 1, EffectStart = nil, Tick = 1000, TickEffect = {RPG_BATTLE_COMMON_EFFECT_1001}, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_COMMON_BUFF_1002] = { ID = RPG_BATTLE_COMMON_BUFF_1002, VFXBuff = nil, Group = 3003, lv = 1, EffectStart = nil, Tick = 1000, TickEffect = {RPG_BATTLE_COMMON_EFFECT_1002}, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_COMMON_BUFF_1003] = { ID = RPG_BATTLE_COMMON_BUFF_1003, VFXBuff = nil, Group = 17, lv = 1, EffectStart = nil, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_COMMON_BUFF_1004] = { ID = RPG_BATTLE_COMMON_BUFF_1004, VFXBuff = "ef_buff_rpg_baohuzhao", Group = 70, lv = 1, EffectStart = nil, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_TEST_ATTR_ATK] = { ID = RPG_BATTLE_BUFF_TEST_ATTR_ATK, VFXBuff = nil, Group = 101, lv = nil, EffectStart = {RPG_BATTLE_EFFECT_TEST_ATTR_ATK}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_HALO_TEST_ATTR_ATK] = { ID = RPG_BATTLE_HALO_TEST_ATTR_ATK, VFXBuff = nil, Group = 101, lv = nil, EffectStart = {RPG_BATTLE_EFFECT_TEST_ATTR_ATK2}, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_TEST_SHARE_DAMAGE] = { ID = RPG_BATTLE_BUFF_TEST_SHARE_DAMAGE, VFXBuff = nil, Group = 66003, lv = nil, EffectStart = nil, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_TEST_SHIELD] = { ID = RPG_BATTLE_BUFF_TEST_SHIELD, VFXBuff = nil, Group = 66004, lv = nil, EffectStart = nil, Tick = nil, TickEffect = nil, Event = nil, EventEffect = nil, RemoveEvent = nil,},
	[RPG_BATTLE_BUFF_TEST_EVENT] = { ID = RPG_BATTLE_BUFF_TEST_EVENT, VFXBuff = nil, Group = 66005, lv = nil, EffectStart = nil, Tick = nil, TickEffect = nil, Event = {13, {"RPG_Hp"}, "RPG_Hp/RPG_HpMax < 0.5"}, EventEffect = {RPG_BATTLE_EFFECT_TEST_DAMAGE}, RemoveEvent = nil,},
}


function prop_rpg_battle_buff_byid(_key_id)
    local id_data = prop_rpg_battle_buff[_key_id]
    if id_data == nil then
        ERROR("[resmng] get_conf: invalid key %s for prop_rpg_battle_buff", _key_id)
        return
    end
    return id_data
end

