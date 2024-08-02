local rpg_controller_grid = class2("rpg_controller_grid",T.rpg_controller, function(self,battle_instance, ety)
    self._ins = battle_instance
    self._ety_proxy = ety
    self._start_attack = false
end)

function rpg_controller_grid:init()
    
end


function rpg_controller_grid:get_ety_target_pos(ety)
    if ety._state ~= RPG_ENTITY_STATE.MOVE then
        return ety._gx, ety._gy
    end
    local action_move = ety._cur_action
    local ways = action_move._ways
    local idx = #ways
    local point = ways[idx]
    return point[1], point[2]
end

function rpg_controller_grid:update()
    local ety = self._ety_proxy

    local cur_gx, cur_gy = rpg_b2g(ety._x, ety._y)
    ety._gx = cur_gx
    ety._gy = cur_gy
    if ety._pre_gx ~= cur_gx or ety._pre_gy ~= cur_gy then
        self._ins._physics_mod:clear(ety._eid)
    end
 
    if ety:is_dead() then
        if ety._gx then
            self._ins._physics_mod:clear(ety._eid)
            ety._gx = nil
            ety._gy = nil
        end
        return
    end

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

    if ety._state ~= RPG_ENTITY_STATE.IDLE then --and ety._state ~= RPG_ENTITY_STATE.MOVE then
        return 
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

function rpg_controller_grid:try_cast(exclude_map_etys)
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
        if not _physics_mod:empty(ety._gx, ety._gy, ety._eid, ety._p.RPG_Radius) then
            goto GOTO_NEAREST_TARGET
        end
        self:post_skill_event(skill, target_orinet)
        ety._pre_gx = ety._gx
        ety._pre_gy = ety._gy
        _physics_mod:set(ety._gx, ety._gy, ety._eid, ety._p.RPG_Radius)
        return 
    end

    if target then
        local target_gx, target_gy = self:get_ety_target_pos(target)
        if not target_gx then
            return
        end
        local target_x, target_y = rpg_g2b(target_gx, target_gy)
        local dis = rpg_dis(ety._x,ety._y, target_x, target_y)
        if dis <= skill_dis then
            return
        end
    end
    
    ::GOTO_NEAREST_TARGET::
    local path = self:find_path(tx, ty, skill_dis )

    if not path then
        if target then
            local exclude_list = exclude_map_etys[skill._id]
            exclude_list[target._eid] = true
            return true
        end
        return
    end

    local action_data = {
        id = RPG_EVENT_TYPE.ACTION_MOVE,
        eid = ety._eid,
        tx = tx,
        ty = ty,
        ways = --path,
        {
            path[1],
            path[2]
        }
    }
    self:check_post_event(action_data)
end

function rpg_controller_grid:find_path(tx, ty, max_dis)
    local physics_mod = self._ins._physics_mod
    local grid = physics_mod._grid
    local rx, ry = rpg_b2g(tx, ty)
    local ety = self._ety_proxy

    local grid_info = grid.map[ety._eid]
    if grid_info then
        grid:clear(ety._eid)
    end
    local x, y = self._ety_proxy._gx, self._ety_proxy._gy
    local path = nil
    if ety._p.RPG_Radius >= RPG_ENTITY_RADIUS2 then
        path = grid:find_path2(x, y, rx, ry, max_dis, {
            [rx] = {
                [ry] = true}
        })
    else
        path = grid:find_path(x, y, rx, ry, max_dis, {
            [rx] = {
                [ry] = true}
        }, ety._eid)
    end
    
    if grid_info then
        physics_mod:set(grid_info[1], grid_info[2], ety._eid, grid_info[3])
    end

    return path
end

function rpg_controller_grid:move_to(tx, ty)
    local ety = self._ety_proxy
    local action_data = {
        id = RPG_EVENT_TYPE.ACTION_MOVE,
        eid = ety._eid,
        tx = tx,
        ty = ty,
        ways = {
            ety._x,
            ety._y,
            tx,
            ty
        }
    }
    self:check_post_event(action_data)
end