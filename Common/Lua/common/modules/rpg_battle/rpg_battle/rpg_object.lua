local rpg_object = class2("rpg_object", function(self, battle_ins)
    self._ins = battle_ins
    self._oid = battle_ins:new_oid()
end)

function rpg_object:can_selected()
    return false
end