local rpg_battle_record_damage = class2("rpg_battle_record_damage",T.rpg_battle_record, function(self, ins,target,actor,record_name)
    T.rpg_battle_record._ctor(self, ins,target,actor,record_name)
end)

T.rpg_battle_record.constructors[RPG_RECORD_TYPE.DAMAGE] = rpg_battle_record_damage

function rpg_battle_record_damage:on_start()
    self._record_dmg = self._target._record_dmg
end

function rpg_battle_record_damage:get_record()
    return self._target._record_dmg - self._record_dmg
end