local rpg_debug_mod = class2("rpg_debug_mod", function(self, battle_instance)
    self._ins = battle_instance
    self._started = false
    self._init_data = battle_instance._init_data.battle
    self._init_completed = false

    self._oid_to_skill_id = {}
    self._oid_to_skill_oid = {}
    self._oid_to_buff_id = {}
end)

--模块数据初始化，战斗数据构造完成之后调用
function rpg_debug_mod:init()
    -- 各个模块根据战斗数据做初始化
    self._init_completed = true
end

-- 每帧检查
function rpg_debug_mod:init_finish()
    return self._init_completed
end

function rpg_debug_mod:start()
    
end

function rpg_debug_mod:on_damage_event(event)
    local damage_source = ""
    if self._oid_to_skill_id[event.oid] then
        damage_source = "skill_" .. self._oid_to_skill_id[event.oid]
    elseif self._oid_to_skill_oid[event.oid] then
        local soid = self._oid_to_skill_oid[event.oid]
        local skill_id = self._oid_to_skill_id[soid]
        damage_source = string.concat and string.concat("skill_" , skill_id ,  " bullet_" , soid    ) or "skill_" .. skill_id .. " bullet_" .. soid
    elseif self._oid_to_buff_id[event.oid] then
        damage_source = "buff_" .. self._oid_to_buff_id[event.oid]
    end
    RPG_DEBUG("[RPG] %s <color='#00FF00'>%s</color> 打了 <color='#00FFFF'>%s</color>   <color='#FFFF00'>%s</color>点伤害, oid=%s, damage_source=%s",
    self._ins:log_str() , event.eid, event.target, RPG_I2F(event.damage), event.oid, damage_source)
end

function rpg_debug_mod:on_action(event)
    RPG_DEBUG("[RPG]%s on_action eid=%s, id=%s",
    self._ins:log_str() , event.eid, RPG_EVENT_TYPE2[event.id])
    -- Logger.LogerWYY2("[RPG]", self._ins:log_str(),"on_action_"..(event.eid or "")..RPG_EVENT_TYPE2[event.id],event)
end


function rpg_debug_mod:on_dead_event(event)
    -- RPG_DEBUG("[RPG]%s event_dead eid=%s, oid=%s ",self._ins:log_str() , event.eid, event.oid)
end

function rpg_debug_mod:on_bullet_event(event)
    self._oid_to_skill_oid[event.oid] = event.soid
end

function rpg_debug_mod:on_buff_event(event)
    self._oid_to_buff_id[event.oid] = event.buff
end

function rpg_debug_mod:on_skill_event(event)
    -- RPG_DEBUG("[RPG]%s on_event %s ",self._ins:log_str() , RPG_EVENT_TYPE2[event.id])
    self._oid_to_skill_id[event.oid] = event.skill_id
    --.LogerWYY2("[RPG]", self._ins:log_str(),(event.eid or ""), "skill_" .. event.skill_id, RPG_EVENT_TYPE_STR[event.id] or "", event)
end

function rpg_debug_mod:on_event(event)
    -- RPG_DEBUG("[RPG]%s on_event %s ",self._ins:log_str() , RPG_EVENT_TYPE2[event.id])
    --Logger.LogerWYY2("[RPG]", self._ins:log_str(),(event.eid or ""),RPG_EVENT_TYPE_STR[event.id] or "", "on_event_"..(event.eid or "") .. " ".. RPG_EVENT_TYPE2[event.id],event)
end

function rpg_debug_mod:register_listener()
    if not RPG_DEBUG_MOD then
        return
    end
    self._ins:add_event_listener2(RPG_EVENT_TYPE.DAMAGE, self, "on_damage_event") -- 伤害
    self._ins:add_event_listener2(RPG_EVENT_TYPE.SKILL_START, self, "on_skill_event") -- 伤害
    self._ins:add_event_listener2(RPG_EVENT_TYPE.DEAD, self, "on_dead_event") -- 伤害
    self._ins:add_event_listener2(RPG_EVENT_TYPE.BULLET, self, "on_bullet_event") -- 伤害
    self._ins:add_event_listener2(RPG_EVENT_TYPE.BUFF, self, "on_buff_event") -- 伤害
    -- for i = RPG_EVENT_TYPE.BATTLE_ACTION_BEGIN , RPG_EVENT_TYPE.BATTLE_ACTION_END do
    --     self._ins:add_event_listener2(i, self, "on_action")
    -- end
    -- for _, evt_id in pairs(RPG_EVENT_TYPE) do
    --     self._ins:add_event_listener2(evt_id, self, "on_event") -- 伤害
    -- end
end

function rpg_debug_mod:remove_listener()
    
end

--有 update 会自己调用
function rpg_debug_mod:update(dt)
end

function rpg_debug_mod:stop()
end
