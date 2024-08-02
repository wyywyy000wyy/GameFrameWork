local rpg_action = class2("rpg_action",function(self, battle_ins)
    -- T.rpg_pool_obj._ctor(self, battle_ins)
    self._ins = battle_ins
end)

rpg_action.action_map = rpg_action.action_map or {}

function rpg_action.create_action(action_data)
    local id = action_data.id
    local constructor = rpg_action.action_map[id]
    constructor(action_data)
end

function rpg_action:can_do(ety)
    return ety:can_cmd(self._cmd)
end

function rpg_action:on_enter()
end

function rpg_action:is_finish()
    return true
end

function rpg_action:update()
end

function rpg_action:on_exit()
end

function rpg_action:write()
    return {} --action_data
end

function rpg_action:read(action_data)
    return {}
end