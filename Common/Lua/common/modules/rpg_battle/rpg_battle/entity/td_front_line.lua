local td_front_line = class2("td_front_line",T.rpg_hero, function(self, battle_instance,team, init_data)
    T.rpg_hero._ctor(self,battle_instance,team, init_data)
    self._front = true
end)


function td_front_line:on_born(actor)
    T.rpg_hero.on_born(self,actor)
    local physics_mod = self._ins._physics_mod
    local hexagonal_grid = physics_mod._grid
    
    local _, g_pos_y = rpg_b2g(self._x, self._y)
    for i = 0, hexagonal_grid.halfMaxCol do
        physics_mod:set(i, g_pos_y, self._eid, RPG_ENTITY_RADIUS)
        physics_mod:set(-i, g_pos_y, self._eid, RPG_ENTITY_RADIUS)
    end
end

function td_front_line:on_dead(actor)
    T.rpg_hero.on_dead(self,actor)
    self._ins:post_event({etype = RPG_EVENT_TYPE.DEFENSIVE_LINE_DEAD, actor = self})

    local physics_mod = self._ins._physics_mod
    physics_mod:clear(self._eid)
end

function td_front_line:dis(x, y)
    return rpg_dis(x, self._y, x, y)
end