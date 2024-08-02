
local min = math.min
local action_move = class2("action_move", T.rpg_action, function(self, batlte_ins, action_data)
    T.rpg_action._ctor(self, batlte_ins)
    self._eid = action_data.eid
    self._cmd = RPG_CMD.MOVE
    -- self._tx = action_data.tx
    -- self._ty = action_data.ty
    self._ways = action_data.ways

end)

T.rpg_action[RPG_EVENT_TYPE.ACTION_MOVE] = action_move

function action_move:on_enter()
    local ety = self._ins._battle_mod:get_ety(self._eid)
    self._ety = ety
    self._idx = 1
    self._grid = self._ins._physics_mod._grid
    self._moved = 0
    self._total_dis = (#self._ways - 1) * RPG_F2I(hexWidth) 
    self._st = self._ins:get_btime()
    self._moved = 0
    self:post_event()
    self._ety:set_state(RPG_ENTITY_STATE.MOVE)

end

function action_move:is_finish()
    return self._finish--self._finish or self._ins:get_btime() >= self._et
end

function action_move:post_event()
    if self._idx >= #self._ways then
        return
    end
    local ety = self._ety
    local point = self._ways[self._idx + 1]
    if not point then
        local a = 1
        a = 2
    end
    local tx, ty = rpg_g2b(point[1], point[2])
    self._ins:post_event(
        { id = RPG_EVENT_TYPE.MOVE, event_time = self._time, eid = self._eid, sx = ety._x, sy = ety._y,tx = tx, ty = ty, sp = self._ety._p.RPG_Sp,
        ways = self._ways
    }
    )
end

function action_move:update_pos()
    local point = self._ways[self._idx]
    local gx, gy = point[1], point[2]
    local ety = self._ety
    ety._x,ety._y = rpg_g2b(gx, gy)
    -- local tgx, tgy = rpg_b2g(ety._x, ety._y)
    -- ety._gx, ety._gy = gx, gy
end

function action_move:update()
    if not self._ways then
        return
    end

    local speed = self._ety._p.RPG_Sp
    local t = self._ins:get_btime()
    local time = t - self._st

    self._moved = time * speed

    if self._moved >= self._total_dis then
        self._finish = true
        self._idx = #self._ways
        self:update_pos()
    else
        local pre_idx = self._idx
        self._idx = min(math.floor((self._moved + 0.5) / RPG_GRID_SIZE) + 1, #self._ways)
        if self._idx ~= pre_idx then
            self:update_pos()
            self:post_event()
        end
    end
end

function action_move:on_exit(next_action)
    if not self._finish and next_action and next_action._cls_name ~= self._cls_name then
        self._ins:post_event({ id = RPG_EVENT_TYPE.MOVE, event_time = self._time, eid = self._eid, tx = self._ety._x, ty = self._ety._y, sp = 0})
    end
    if self._ety._tid == 1 or true then
        local grid = self._ins._physics_mod._grid
        --Logger.LogerWYY2(self._ety._eid.."action_move_on_exit", self._eid, self._ety._gx, self._ety._gy, self._ety._x, self._ety._y, grid:is_empty(self._ety._gx, self._ety._gy))
    end
    self._ety:set_state(RPG_ENTITY_STATE.IDLE)
end