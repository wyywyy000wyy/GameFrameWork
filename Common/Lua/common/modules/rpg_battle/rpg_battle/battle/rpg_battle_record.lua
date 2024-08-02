local rpg_battle_record = class2("rpg_battle_record", function(self, ins,target,actor,record_name)
    self._ins = ins
    self._target = target
    self._actor = actor
    self._name = record_name
    self:start()
end)

rpg_battle_record.constructors = rpg_battle_record.constructors or {}

function rpg_battle_record:start()
    if self._started then
        return
    end
    self._started = true
    self._actor:add_record(self)
    local _ = self.on_start and self:on_start()
end


function rpg_battle_record:stop()
    if not self._started then
        return
    end
    self._started = false
    self._actor:remove_record(self)
    local _ = self.on_stop and self:on_stop()
end

function rpg_battle_record:get_record()
    return 0
end