--
-- $Id$
--

module( "resmng" )
prop_rpg_event_poolKey = {
ID = 1, Pool = 2, 
}

prop_rpg_event_pool_TypeInfo = {}

prop_rpg_event_pool = {

	[RPG_EVENT_POOL_1] = { ID = RPG_EVENT_POOL_1, Pool = {{1001,1000},{1002,1000},{1003,1000},{1004,1000}},},
	[RPG_EVENT_POOL_2] = { ID = RPG_EVENT_POOL_2, Pool = {{1001,1000},{1002,1000},{1003,1000},{1004,1000}},},
	[RPG_EVENT_POOL_1001] = { ID = RPG_EVENT_POOL_1001, Pool = {{4101,2000},{4111,500},{4121,2000},{4131,500},{4141,2000},{4151,500},{4161,2000},{4171,500},{4181,2000},{4191,500}},},
}


function prop_rpg_event_pool_byid(_key_id)
    local id_data = prop_rpg_event_pool[_key_id]
    if id_data == nil then
        ERROR("[resmng] get_conf: invalid key %s for prop_rpg_event_pool", _key_id)
        return
    end
    return id_data
end

