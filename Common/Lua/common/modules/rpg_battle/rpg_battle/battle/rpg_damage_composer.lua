local table_insert = table.insert
local rpg_damage_composer = class2("rpg_damage_composer", function(self)
    self._map = {}
    self._list = {}
end)

function rpg_damage_composer:compose(ety , dmg)
    local pre = self._map[ety]
    if not pre then
        pre = 0
        table_insert(self._list, ety)
    end
    self._map[ety] = pre + dmg
end
