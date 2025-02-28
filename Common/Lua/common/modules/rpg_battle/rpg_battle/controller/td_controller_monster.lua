local td_controller_monster = class2("td_controller_monster",T.rpg_controller, function(self,battle_instance, ety, ai_scene)
    self._ins = battle_instance
    self._ety_proxy = ety
    self._start_attack = false

    self._ai_id = ai_scene:AddAgent(E.Vector3(RPG_I2F(ety._x), 0, RPG_I2F(ety._y)), RPG_I2F(ety._p.RPG_Radius), 0)
    self._ai_agent = ai_scene:GetAgent(self._ai_id)
    local tpos = self._ai_agent.pos
    self._btime = battle_instance:get_btime()
    self._ai_agent.radiusObst = self._ai_agent.radius + 0.1
    self._ai_agent.neighborDist = 10
    self._ai_agent.timeHorizon = 0.1
end)

function td_controller_monster:init()
    
end


function td_controller_monster:get_ety_target_pos(ety)
    if ety._state ~= RPG_ENTITY_STATE.MOVE then
        return ety._gx, ety._gy
    end
    local action_move = ety._cur_action
    local ways = action_move._ways
    local idx = #ways
    local point = ways[idx]
    return point[1], point[2]
end

function td_controller_monster:update()
    local ety = self._ety_proxy

    local cur_gx, cur_gy = rpg_b2g(ety._x, ety._y)
    ety._gx = cur_gx
    ety._gy = cur_gy
    if ety._pre_gx ~= cur_gx or ety._pre_gy ~= cur_gy then
        self._ins._physics_mod:clear(ety._eid)
    end
 
    if ety:is_dead() then
        self._ai_agent.collisionEnabled = false
        self._ai_agent.navigationEnabled = false
        if ety._gx then
            self._ins._physics_mod:clear(ety._eid)
            ety._gx = nil
            ety._gy = nil

        end
        return
    end
    self._ai_agent.collisionEnabled = true
    self._ai_agent.navigationEnabled = true
    if self._next_action_data then
        local action_data = self._next_action_data
        self._next_action_data = nil
        -- self._ins._battle_mod:post_action(action)
        self:check_post_event(action_data)
        return
    end



    if ety._override_skills then ----变身后会替换技能
        if ety._source_skills ~= ety._override_skills then
            self:init_priority_skills()
        end
    elseif ety._source_skills ~= ety._skills then
        self:init_priority_skills()
    end

    local x, y = self._ai_agent.pos.x, self._ai_agent.pos.z
    ety._x, ety._y = RPG_F2I(x), RPG_F2I(y)


    if ety._state ~= RPG_ENTITY_STATE.IDLE and ety._state ~= RPG_ENTITY_STATE.MOVE then --and ety._state ~= RPG_ENTITY_STATE.MOVE then
        -- self._ai_agent.navigationEnabled = true
        return 
    end

    local btime = self._ins:get_btime()
    if btime < self._btime then
        return
    end
    -- self._ai_agent.navigationEnabled = true


    if ety._state == RPG_ENTITY_STATE.MOVE then
        self._btime = btime + 500
    end

    

    local exclude_map_etys = {}
    local aaa = 1
    local exclude_test_count = 6 * #ety._sorted_skills
    while self:try_cast(exclude_map_etys) do
        aaa = aaa + 1
        if aaa > exclude_test_count then
            return
        end
    end
end

function td_controller_monster:try_cast(exclude_map_etys)
    local ety = self._ety_proxy

    local skill , target_orinet, not_skill = self:get_skill_to_cast(exclude_map_etys)
    if not skill or not target_orinet then
        if not_skill then
        end
        return 
    end
    local _physics_mod = self._ins._physics_mod
    local battle_mod = self._ins._battle_mod
    local tx = target_orinet._x
    local ty = target_orinet._y
    local target = target_orinet._eid and battle_mod:get_ety(target_orinet._eid)
    
    if target then
        tx = target._x
        ty = target._y
    end

    local dis = rpg_dis(ety._x,ety._y, tx, ty)
    local skill_dis = skill:get_dis() or 0
    skill_dis = skill_dis + ety._p.RPG_Radius
    if target then
        skill_dis = skill_dis + target._p.RPG_Radius
    end

    if dis <= skill_dis then
        self._start_attack = true;
        -- if not _physics_mod:empty(ety._gx, ety._gy, ety._eid, ety._p.RPG_Radius) then
        --     goto GOTO_NEAREST_TARGET
        -- end
        self:post_skill_event(skill, target_orinet)
        -- ety._pre_gx = ety._gx
        -- ety._pre_gy = ety._gy
        -- _physics_mod:set(ety._gx, ety._gy, ety._eid, ety._p.RPG_Radius)
        return 
    end

    if target then
        -- local target_gx, target_gy = self:get_ety_target_pos(target)
        -- if not target_gx then
        --     return
        -- end
        -- local target_x, target_y = rpg_g2b(target_gx, target_gy)
        local dis = rpg_dis(ety._x,ety._y, target._x, target._y)
        if dis <= skill_dis then
            return
        end
    end
    
    ::GOTO_NEAREST_TARGET::
    -- local path = self:find_path(tx, ty, skill_dis )

    -- if not path then
    --     if target then
    --         local exclude_list = exclude_map_etys[skill._id]
    --         exclude_list[target._eid] = true
    --         return true
    --     end
    --     return
    -- end

    
    if ety._cur_action and ety._cur_action._cmd == RPG_CMD.MOVE then
        ety._cur_action._tx = tx
        ety._cur_action._ty = ty
        return
    end

    ::move::
    -- self:move()
    local action_data = {
        id = RPG_EVENT_TYPE.ACTION_AI_MOVE,
        eid = ety._eid,
        agent = self._ai_agent,
        tx = tx,
        ty = ty
    }
    self:check_post_event(action_data)
end

function td_controller_monster:move(tx, ty)
    local action_data = {
        id = RPG_EVENT_TYPE.ACTION_AI_MOVE,
        eid = ety._eid,
        agent = self._ai_agent,
        tx = tx,
        ty = ty
    }
    self:check_post_event(action_data)
end
