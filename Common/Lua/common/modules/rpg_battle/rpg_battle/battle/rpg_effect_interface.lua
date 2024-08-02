local max = math.max
local min = math.min
local floor = math.floor
local rpg_effect_interface = class2("rpg_effect_interface", function(self) 
end)

function rpg_effect_interface.DISTANCE(props, props2)
    local ety1 = props.ety
    local ety2 = props2.ety
    local dis = rpg_dis(ety1._x, ety1._y, ety2._x, ety2._y)
    return rpg_dis(ety1._x, ety1._y, ety2._x, ety2._y)
end

function rpg_effect_interface.SKILL_TARGET(actor, target_type)
    return actor._eff_env.root_actor._lock_targets[target_type]._p
end
rpg_effect_interface.MAX = max
rpg_effect_interface.MIN = min
rpg_effect_interface.FLOOR = floor
