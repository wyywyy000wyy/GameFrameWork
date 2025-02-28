local rpg_super_weapon = class2("rpg_super_weapon",T.rpg_entity, function(self, battle_instance,weapon_id, weapon_idx)
    local battle_mod = battle_instance._battle_mod
    local team = battle_mod._team_list[1]
    local battle_data = battle_instance._init_data.battle
    local team_data = battle_data.teams[1]
    local attr = {}
    for _, hero_data in ipairs(team_data.heros) do
        local h_attr = hero_data.attr
        for k, v in pairs(h_attr) do
            attr[k] = (attr[k] or 0) + v
        end
    end

    T.rpg_entity._ctor(self,battle_instance,team, {
        attr = attr,
    })
    self._team = team
    self._hero_id = weapon_id--init_data.hero_id
    self._dt = 0

    local fpos = -weapon_idx

    self._fpos = fpos
    self._fpos2 = fpos

    local level_id = battle_instance._init_data.level_id
    local level_data = resmng.prop_rpg_battle_levelById(level_id)
    local map_data = resmng.prop_rpg_battle_mapById(level_data.Map);
    if battle_instance._init_data.map_id then
        map_data = resmng.prop_rpg_battle_mapById(battle_instance._init_data.map_id);
    end
    
    local cpos = map_data.WeaponPos[weapon_idx]
    self._x = RPG_F2I(cpos[1])
    self._y = RPG_F2I(cpos[2])

    self._gx , self._gy = rpg_b2g(self._x, self._y)
    -- if self._tid == 2 then
    --     self._gx = self._gx - 1
    --     self._gy = self._gy - 1
    -- end
    self._x, self._y = rpg_g2b(self._gx, self._gy)

    self._dir_x, self._dir_y = 0,1000

    self._buffs = {}
    self._skills = {
    }

    local hero_basic = resmng.prop_hero_basic[weapon_id]

    for _, skill_info in ipairs(hero_basic.BasicSkill) do
        local base_skill_id = skill_info[1]
        local skill_id = skill_util.calc_skill_id(base_skill_id, 1)
        if resmng.prop_rpg_battle_skill[skill_id] then
            local sk = T.rpg_skill(skill_id, self._ins, self)
            table.insert(self._skills, sk)
            self._skill_map[skill_id] = sk
        end
    end
    self:init_props()
    -- self._ins._physics_mod:add_ety(self._eid, self._x, self._y, 1)
end)

function rpg_super_weapon:can_selected()
    return false
end

function rpg_super_weapon:born_event()
    return { id = RPG_EVENT_TYPE.BORN,
             ety_type = RPG_ETY_TYPE.SWEAPON,
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
