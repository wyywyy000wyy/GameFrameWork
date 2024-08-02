local min = math.min
local max = math.max
local rpg_buff_shield = class2("rpg_buff_shield", T.rpg_buff, 
function(self,buff_id, battle_ins, owner, eff_env, time, dmg_type, count, factor) 
    T.rpg_buff._ctor(self, buff_id, battle_ins, owner, eff_env, time)
    self._dmg_type = dmg_type
    self._count = count
    -- self._factor = factor
    battle_ins:post_event({ 
        id = RPG_EVENT_TYPE.SHIELD, 
        event_time = battle_ins:get_btime(), 
        eid = owner._eid, 
        caster = eff_env.ety._eid,
        shield = count,
    })
end)

function rpg_buff_shield:on_enter()
    self._ety:add_shield(self)
    rpg_buff_shield._base.on_enter(self)
    self._ety:update_shield_count(self)
end

function rpg_buff_shield:on_exit()
    self._ety:remove_shield(self)
    rpg_buff_shield._base.on_exit(self)
    self._ety:update_shield_count(self)
end

function rpg_buff_shield:shield(real_dmg)
    if self._finish then
        return real_dmg, 0
    end

    -- local shield_factor = self._factor
    -- local factor= (1-shield_factor)
    local shield_dmg = real_dmg --*shield_factor
    if shield_dmg <= 0 then
        return real_dmg, 0
    end

    local remain_shield = self._count
    local real_shield_dmg = min(shield_dmg, remain_shield)
    -- local f = real_shield_dmg/shield_dmg
    -- shield_factor = shield_factor * f
    -- factor= (1-shield_factor)

    self._count = remain_shield - real_shield_dmg
    -- if self._count <= 0 then
    --     self:finish()
    -- end
    
    return real_dmg - real_shield_dmg, real_shield_dmg--damage_without_defend * shield_factor
end