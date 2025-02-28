
local min = math.min
local ORCAScene = CS and CS.ORCAScene
local SetDestination = ORCAScene and ORCAScene.SetDestination
local SetStop = ORCAScene and ORCAScene.SetStop

local action_ai_move = class2("action_ai_move", T.rpg_action, function(self, batlte_ins, action_data)
    T.rpg_action._ctor(self, batlte_ins)
    self._eid = action_data.eid
    self._cmd = RPG_CMD.MOVE
    self._tx = action_data.tx
    self._ty = action_data.ty
    self._agent = action_data.agent
end)

T.rpg_action[RPG_EVENT_TYPE.ACTION_AI_MOVE] = action_ai_move

function action_ai_move:on_enter()
    local ety = self._ins._battle_mod:get_ety(self._eid)
    self._ety = ety
    local agent = self._agent
    agent.maxSpeed = ety._p.RPG_Sp --* 2
    SetDestination(agent, RPG_I2F(self._tx), RPG_I2F(self._ty))
    self._moved = 0
    self._ins:post_event(
        { id = RPG_EVENT_TYPE.MOVE, event_time = self._time, eid = self._eid, agent = self._agent,sp = self._ety._p.RPG_Sp
}
    )
    self._ety:set_state(RPG_ENTITY_STATE.MOVE)

end

function action_ai_move:is_finish()
    return self._finish--self._finish or self._ins:get_btime() >= self._et
end


function action_ai_move:update()
    -- local speed = self._ety._p.RPG_Sp
    local x, y = self._agent.pos.x, self._agent.pos.z
    -- Logger.LogerWYY2("__agent", self._eid, self._agent.velocity, self._agent.pos)
    SetDestination(self._agent, RPG_I2F(self._tx), RPG_I2F(self._ty))
    self._ety._x, self._ety._y = RPG_F2I(x), RPG_F2I(y)
end

function action_ai_move:on_exit(next_action)
    -- if not self._finish and next_action and next_action._cls_name ~= self._cls_name then
        -- self._ins:post_event({ id = RPG_EVENT_TYPE.MOVE, event_time = self._time, eid = self._eid, tx = self._ety._x, ty = self._ety._y, sp = 0})
    -- end
    SetStop(self._agent)
    self._ety:set_state(RPG_ENTITY_STATE.IDLE)
end