-- local rpg_event_base = rpg_pool_class("rpg_event_base", function(self)
-- end)

-- function rpg_event_base:reset()
--     self._id = nil
--     self._type = nil
-- end
rpg_evt = function(class_name, ...)
    local tclass = class2(class_name,T.rpg_pool_obj,...)
    local pool =  tclass._pool or T.rpg_pool(tclass)
    tclass._pool = pool
    tclass.new = function(battle_ins)
        local obj = tclass()
        obj._pool = pool
        obj._ins = battle_ins
        obj:reset()
        return obj
    end
    return tclass
end
local rpg_evt = rpg_evt

local function rpg_evt(name, type)
    local cls_evt = rpg_pool_class(name)
    cls_evt._type = type
    return cls_evt
end


local rpg_evt_battle_data_init = rpg_evt("rpg_evt_battle_data_init",RPG_EVENT_TYPE.BATTLE_DATA_INIT)
function rpg_evt_battle_data_init:reset(id)
    self._id = id
end
local rpg_evt_battle_start = rpg_evt("rpg_evt_battle_start",RPG_EVENT_TYPE.BATTLE_START)
function rpg_evt_battle_start:reset(id)
    self._id = id
end
local rpg_evt_battle_end = rpg_evt("rpg_evt_battle_end",RPG_EVENT_TYPE.BATTLE_END)
function rpg_evt_battle_end:reset(id)
    self._id = id
end
local rpg_evt_born = rpg_evt("rpg_evt_born",RPG_EVENT_TYPE.BORN)
function rpg_evt_born:reset(id, eid, tid)
    self._id = id
    self._eid = eid
    self._tid = tid
end

