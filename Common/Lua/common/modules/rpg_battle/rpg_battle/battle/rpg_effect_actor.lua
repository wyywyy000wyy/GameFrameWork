local rpg_effect_actor = class2("rpg_effect_actor",T.rpg_object, function(self, battle_ins, ety)
    T.rpg_object._ctor(self, battle_ins)
    self._ety = ety
    self._records = {}
    self._record_map = {}
end)

function rpg_effect_actor:add_record(record)
    if self._record_map[record._name] then
        local _ = RPG_DEBUG_MOD and RPG_ERR("[RPG] 重复 add_record %s oid=%s", record._name, record._actor._oid)
        return
    end
    table.insert(self._records, record)
    self._record_map[record._name] = record
    record:start()
end

function rpg_effect_actor:remove_record(record)
    if not self._record_map[record._name] then
        return
    end
    self._record_map[record._name] = nil
    for i, r in ipairs(self._records) do
        if r == record then
            table.remove(self._records, i)
            record:stop()
            return
        end
    end
end

function rpg_effect_actor:record(record_name)
    return self._record_map[record_name]:get_record()
end

function rpg_effect_actor:on_enter()
end

function rpg_effect_actor:actor_pos()
    return nil
end

function rpg_effect_actor:redirect_target()
end

function rpg_effect_actor:on_exit()
    local records = self._records
    for i = #records , 1, -1 do
        local record = records[i]
        record:stop()
    end
end