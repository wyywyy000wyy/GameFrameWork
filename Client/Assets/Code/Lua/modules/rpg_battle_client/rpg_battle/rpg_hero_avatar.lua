local rpg_hero_avatar = class2("rpg_hero_avatar", T.rpg_entity_avatar, function(self, eid, hero_pid, lv, pos_index, born_pos, born_dir,hero_data)
    self._hero_id = hero_pid   -- 配置表id
    self._hero_data = hero_data
    self._hero_prop = resmng.prop_hero_basicById(self._hero_id);
    self._pos_index = pos_index   -- 位置Index
    T.rpg_entity_avatar._ctor(self, eid, 
    pos_index <= 5 and 0 or 1, 
    lv, born_pos, born_dir)
end)

function rpg_hero_avatar:get_model_height()
    return self._hero_prop.RPG_ModelHeight or 3
end

function rpg_hero_avatar:get_model_path()
    local _path = self._hero_prop.RpgModel
    return _path
end

function rpg_hero_avatar:get_model_scale()
    return self._hero_prop.RpgModelScale
end

function rpg_hero_avatar:get_team_pos()
    return self._ins.scene._map_prop.TeamPos[self._pos_index] 
end
