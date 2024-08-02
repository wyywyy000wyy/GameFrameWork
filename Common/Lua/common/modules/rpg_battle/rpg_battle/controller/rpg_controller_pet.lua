local rpg_controller_pet = class2("rpg_controller_pet",T.rpg_controller, function(self,battle_instance, ety)
    self._ins = battle_instance
    self._ety_proxy = ety
end)

function rpg_controller_pet:get_skill_to_cast()
    local ety = self._ety_proxy
    local skills = ety._sorted_skills
    local battle_mod = self._ins._battle_mod
    local target_orinet
    for _, sk in ipairs(skills) do
        local cast_anger = self:auto_cast_anger()
        if (cast_anger) and sk:can_cast() then
            target_orinet = battle_mod:search_target(sk._first_eff_cfg, ety) 
            if target_orinet then
                return sk, target_orinet
            end
        end
    end
end

function rpg_controller_pet:update()
    local ety = self._ety_proxy
    if ety._source_skills ~= ety._skills then
        self:init_priority_skills()
    end

    if self._next_action_data then
        local action_data = self._next_action_data
        self._next_action_data = nil
        self:check_post_event(action_data)
        return
    end

    if ety._state ~= RPG_ENTITY_STATE.IDLE then --and ety._state ~= RPG_ENTITY_STATE.MOVE then
        return 
    end

    local skill , target_orinet = self:get_skill_to_cast()
    if not skill then
        return 
    end
    self:post_skill_event(skill, target_orinet)
end