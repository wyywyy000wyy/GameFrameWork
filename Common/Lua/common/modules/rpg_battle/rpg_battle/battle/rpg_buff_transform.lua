local ipairs = ipairs
local table_insert = table.insert
local rpg_buff_transform = class2("rpg_buff_transform", T.rpg_buff, function(self, battle_ins, owner, eff_env, dur, skill_ids) 
    T.rpg_buff._ctor(self, RPG_ETY_INNER_BUFF.TRANSFORM_ID, battle_ins, owner, eff_env, dur)

    local skill_lv = eff_env.root_actor._lv

    local skills = {}

    for _, skill_id in ipairs(skill_ids) do
        local sk = T.rpg_skill(skill_id + skill_lv, self._ins, self._ety)
        table_insert(skills, sk)
    end
    self._skills = skills
end)

function rpg_buff_transform:on_enter()
    T.rpg_buff.on_enter(self)
    self._ety:set_override_skills(self._skills)
end

function rpg_buff_transform:on_exit()
    self._ety:remove_override_skills(self._skills)
    T.rpg_buff.on_exit(self)
end
