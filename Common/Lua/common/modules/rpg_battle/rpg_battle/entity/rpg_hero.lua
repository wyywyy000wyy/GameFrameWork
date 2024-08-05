local rpg_hero = class2("rpg_hero",T.rpg_entity, function(self, battle_instance,team, init_data)
    T.rpg_entity._ctor(self,battle_instance,team, init_data)
    self._team = team
    self._hero_id = init_data.hero_id--init_data.hero_id
    self._dt = 0
    self._fpos = init_data.fpos
    self._fpos2 = math.fmod(init_data.fpos + 4, 5) + 1

    local level_id = battle_instance._init_data.level_id
    local level_data = resmng.prop_rpg_battle_level[level_id]
    local map_data = resmng.prop_rpg_battle_map[level_data.Map]
    if battle_instance._init_data.map_id then
        map_data = resmng.prop_rpg_battle_map[battle_instance._init_data.map_id]
    end
    
    local cpos = map_data.BornPos[self._fpos]
    self._x = RPG_F2I(cpos[1])
    self._y = RPG_F2I(cpos[2])

    self._gx , self._gy = rpg_b2g(self._x, self._y)
    -- if self._tid == 2 then
    --     self._gx = self._gx - 1
    --     self._gy = self._gy - 1
    -- end
    self._x, self._y = rpg_g2b(self._gx, self._gy)

    local dir = map_data.BornDir[self._fpos]
    self._dir_x, self._dir_y = rpg_normalize(RPG_F2I(dir[1]), RPG_F2I(dir[3]))

    self._buffs = {}
    self._skills = {
    }

    for _, skill_id in ipairs(init_data.skills) do
        if resmng.prop_rpg_battle_skill[skill_id] then
            local sk = T.rpg_skill(skill_id, self._ins, self)
            table.insert(self._skills, sk)
            self._skill_map[skill_id] = sk
        end
    end
    self:init_props()
    -- self._ins._physics_mod:add_ety(self._eid, self._x, self._y, 1)
end)


function rpg_hero:born_event()
    return { id = RPG_EVENT_TYPE.BORN,
             ety_type = RPG_ETY_TYPE.HERO,
             event_time = self._time,
             eid = self._eid,
             hero_id = self._hero_id,
             lv = self._data.lv,
             star = self._data.star,
             fpos = self._fpos,
             x = self._x,
             y = self._y,
             dir_x = self._dir_x,
             dir_y = self._dir_y,
             tid = self._tid,
             attr = self:make_sync_attr(),
    }
end
