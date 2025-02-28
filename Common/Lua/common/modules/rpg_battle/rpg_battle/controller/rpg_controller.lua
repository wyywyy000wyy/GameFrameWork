local rpg_controller = class2("rpg_controller", function(self,battle_instance, ety)
    self._ins = battle_instance
    self._ety_proxy = ety
end)

function rpg_controller:init()
    
end

function rpg_controller:auto_cast_anger()
    -- local ety = self._ety_proxy
    return true --ety._tid ~= RPG_TEAM_ID.TEAM_1 or self._ins._auto_skill
end

function rpg_controller:get_skill_to_cast(exclude_map_etys)
    local ety = self._ety_proxy
    local skills = ety._sorted_skills
    local battle_mod = self._ins._battle_mod
    local not_skill = true
    local target_orinet
    for _, sk in ipairs(skills) do
        local exclude_etys = exclude_map_etys[sk._id]
        if not exclude_etys then
            exclude_etys = {}
            exclude_map_etys[sk._id] = exclude_etys
        end
        if exclude_etys._exclude then
            goto continue
        end
        local cast_anger = self:auto_cast_anger()
        if (not sk:is_anger2() or cast_anger) and sk:can_cast() then
            not_skill = false
            target_orinet = battle_mod:search_target(sk._first_eff_cfg, ety, nil, exclude_etys) 
            if target_orinet then
                return sk, target_orinet
            end
        end
        exclude_etys._exclude = true
        ::continue::
    end
    return nil,nil, not_skill
end

function rpg_controller:post_skill_event(skill, target_orinet)
    local battle_mod = self._ins._battle_mod
    local ety = self._ety_proxy
    -- local target = target_orinet._eid and battle_mod:get_ety(target_orinet._eid)
    local action_data = target_orinet 
    action_data.eid = ety._eid
    action_data.id = skill:is_anger() and RPG_EVENT_TYPE.ACTION_SKILL_ANGER or RPG_EVENT_TYPE.ACTION_SKILL
    action_data.skill_id = skill._id
    -- Logger.LogerWYY2("action_move_on_exit set", ety._gx, ety._gy, ety._eid, ety._x, ety._y)
    self:check_post_event(action_data)
end

function rpg_controller:init_priority_skills()
    local ety = self._ety_proxy
    local list = {}
    local skills = ety._override_skills or ety._skills
    for _, sk in ipairs(skills) do
        if sk._cfg.Mode ~= RPG_SKILL_TYPE.PASSIVE and not sk._cfg._Event then
            table.insert(list, sk)
        end
    end
    table.sort(list, function(s1, s2) 
        return s1:priority() > s2:priority()
    end)
    ety._source_skills = skills
    ety._sorted_skills = list
end

function rpg_controller:check_post_event(action_data)
    local contructor = T.rpg_action[action_data.id]
    local action = contructor(self._ins, action_data)
    if self._ety_proxy:can_do_action(action) then
        self._ins:post_event(action_data)
    end
end

function rpg_controller:add_action_data(action_data)
    self._next_action_data = action_data
end

function rpg_controller:update()
end