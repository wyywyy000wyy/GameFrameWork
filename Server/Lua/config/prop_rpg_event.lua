--
-- $Id$
--

module( "resmng" )
prop_rpg_event_TypeInfo = {}

prop_rpg_event = {

	[RPG_EVENT_1001] = { ID = RPG_EVENT_1001, Effect = 4041, Previous = nil, MaxCount = 1, Name = LG_RPG_ROGUE_NAME_1, Desc = LG_RPG_ROGUE_DESC_1, Quality = 5,},
	[RPG_EVENT_1002] = { ID = RPG_EVENT_1002, Effect = 4051, Previous = nil, MaxCount = 10, Name = LG_RPG_ROGUE_NAME_2, Desc = LG_RPG_ROGUE_DESC_2, Quality = 4,},
	[RPG_EVENT_1003] = { ID = RPG_EVENT_1003, Effect = 4061, Previous = nil, MaxCount = 10, Name = LG_RPG_ROGUE_NAME_3, Desc = LG_RPG_ROGUE_DESC_3, Quality = 3,},
	[RPG_EVENT_1004] = { ID = RPG_EVENT_1004, Effect = 4071, Previous = nil, MaxCount = 10, Name = LG_RPG_ROGUE_NAME_4, Desc = LG_RPG_ROGUE_DESC_4, Quality = 5,},
	[RPG_EVENT_4101] = { ID = RPG_EVENT_4101, Effect = 4101, Previous = nil, MaxCount = 10, Name = LG_RPG_ROGUE_NAME_4101, Desc = LG_RPG_ROGUE_DESC_4101, Quality = 3,},
	[RPG_EVENT_4111] = { ID = RPG_EVENT_4111, Effect = 4111, Previous = nil, MaxCount = 10, Name = LG_RPG_ROGUE_NAME_4101, Desc = LG_RPG_ROGUE_DESC_4111, Quality = 4,},
	[RPG_EVENT_4121] = { ID = RPG_EVENT_4121, Effect = 4121, Previous = nil, MaxCount = 10, Name = LG_RPG_ROGUE_NAME_4121, Desc = LG_RPG_ROGUE_DESC_4121, Quality = 3,},
	[RPG_EVENT_4131] = { ID = RPG_EVENT_4131, Effect = 4131, Previous = nil, MaxCount = 10, Name = LG_RPG_ROGUE_NAME_4121, Desc = LG_RPG_ROGUE_DESC_4131, Quality = 4,},
	[RPG_EVENT_4141] = { ID = RPG_EVENT_4141, Effect = 4141, Previous = nil, MaxCount = 10, Name = LG_RPG_ROGUE_NAME_4141, Desc = LG_RPG_ROGUE_DESC_4141, Quality = 4,},
	[RPG_EVENT_4151] = { ID = RPG_EVENT_4151, Effect = 4151, Previous = nil, MaxCount = 10, Name = LG_RPG_ROGUE_NAME_4141, Desc = LG_RPG_ROGUE_DESC_4151, Quality = 5,},
	[RPG_EVENT_4161] = { ID = RPG_EVENT_4161, Effect = 4161, Previous = nil, MaxCount = 10, Name = LG_RPG_ROGUE_NAME_4161, Desc = LG_RPG_ROGUE_DESC_4161, Quality = 4,},
	[RPG_EVENT_4171] = { ID = RPG_EVENT_4171, Effect = 4171, Previous = nil, MaxCount = 10, Name = LG_RPG_ROGUE_NAME_4161, Desc = LG_RPG_ROGUE_DESC_4171, Quality = 5,},
	[RPG_EVENT_4181] = { ID = RPG_EVENT_4181, Effect = 4181, Previous = nil, MaxCount = 10, Name = LG_RPG_ROGUE_NAME_4181, Desc = LG_RPG_ROGUE_DESC_4181, Quality = 4,},
	[RPG_EVENT_4191] = { ID = RPG_EVENT_4191, Effect = 4191, Previous = nil, MaxCount = 10, Name = LG_RPG_ROGUE_NAME_4181, Desc = LG_RPG_ROGUE_DESC_4191, Quality = 5,},
}


function prop_rpg_event_byid(_key_id)
    local id_data = prop_rpg_event[_key_id]
    if id_data == nil then
        ERROR("[resmng] get_conf: invalid key %s for prop_rpg_event", _key_id)
        return
    end
    return id_data
end

