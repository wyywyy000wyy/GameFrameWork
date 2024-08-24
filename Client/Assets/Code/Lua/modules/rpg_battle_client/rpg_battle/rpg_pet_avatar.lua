local rpg_pet_avatar = class2("rpg_pet_avatar", T.rpg_entity_avatar, function(self, eid, camp,pet_id, lv, born_pos, born_dir)
    self._pet_id = pet_id   -- 配置表id
    self._pet_prop = resmng.prop_pet[pet_id]
    T.rpg_entity_avatar._ctor(self, eid, camp, lv, born_pos, born_dir)
end)


function rpg_pet_avatar:get_model_height()
    return self._pet_prop.RPG_ModelHeight or 3
end

function rpg_pet_avatar:get_model_path()
    local _path = self._pet_prop.RpgModel
    return _path
end

function rpg_pet_avatar:get_model_scale()
    return self._pet_prop.RpgModelScale
end

function rpg_pet_avatar:get_team_pos()
    return self._ins.scene._map_prop.FormationPetPos[self._camp + 1] 
end

function rpg_pet_avatar:get_pet_skill()
    local propid = models.pet_model.get_lv_id(self._pet_id, self._lv)
    local prop_pet_lvup = resmng.prop_pet_lvup[propid]
    return prop_pet_lvup.RpgSkills and prop_pet_lvup.RpgSkills[1]
end

function rpg_pet_avatar:set_battle_instance(ins)
    T.rpg_entity_avatar.set_battle_instance(self, ins)
    local skill_id = self:get_pet_skill()
    if not skill_id then
        return
    end
    local initcd = resmng.prop_rpg_battle_skill[skill_id].InitCd
    self:set_skill_cd(skill_id, initcd)
end

function rpg_pet_avatar:get_pet_skill_cd()
    return self:get_skill_cd(self:get_pet_skill())
end
