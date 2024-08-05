local rpg_pet = class2("rpg_pet",T.rpg_entity, function(self, battle_instance,team, init_data)
    T.rpg_entity._ctor(self,battle_instance,team, init_data)
    self._team = team
    self._pet_id = init_data.propid--init_data.hero_id
    self._dt = 0
    self._lv = init_data.lv

    local level_id = battle_instance._init_data.level_id
    local level_data = resmng.prop_rpg_battle_level[level_id]
    local map_data = resmng.prop_rpg_battle_map[level_data.Map];
    if battle_instance._init_data.map_id then
        map_data = resmng.prop_rpg_battle_map[battle_instance._init_data.map_id]
    end
    
    local cpos = map_data.PetPos[team._id]
    self._x = RPG_F2I(cpos[1])
    self._y = RPG_F2I(cpos[2])

    self._gx , self._gy = rpg_b2g(self._x, self._y)
    self._x, self._y = rpg_g2b(self._gx, self._gy)

    local dir = map_data.BornDir[team._tid == 1 and 1 or 6]
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
end)

function rpg_pet:init_props()

end

---------宠物的属性，必须要等到所有英雄的属性(包括被动技能)都计算完毕后才能计算
function rpg_pet:init_props_pet()
    local team = self._team
    local p = self._p
    local hero_count = #team._ety_list
    for _, ety in ipairs(team._ety_list) do
        local e_p = ety._p
        for _, k in ipairs(RPG_PROPERTY) do
            local v = e_p[k] 
            if v then
                p[k] = (p[k] or 0) + v
            end
        end

        -- for k, v in pairs(e_p) do
        --     if k ~= "base" then
        --         p[k] = (p[k] or 0) + v
        --     end
        -- end
    end
    local inv_hero_count = 1 / hero_count
    for k, v in pairs(p) do
        local fv = v * inv_hero_count
        p[k] = fv
    end
    self:set_extra_props()
end

function rpg_pet:start()
    self:init_props_pet()
    T.rpg_entity.start(self)
end

function rpg_pet:born_event()
    return { id = RPG_EVENT_TYPE.BORN,
             ety_type = RPG_ETY_TYPE.PET,
             event_time = self._time,
             eid = self._eid,
             pet_id = self._pet_id,
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
