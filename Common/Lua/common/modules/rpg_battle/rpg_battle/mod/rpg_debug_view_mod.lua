
local rpg_debug_view_mod = class2("rpg_debug_view_mod", T.mod_base, function(self, battle_instance)
    battle_instance._debug_view_mod = self
    self._ins = battle_instance
    self._started = false

    self._etys = {}

    self._view_map = T.dungeon_map()
    self._view_map:start()

    --self.self_go = E.GameObject.Find("RPG_SELF_GO")
    --self.enemy_go = E.GameObject.Find("RPG_ENEMY_GO")
    --
    --self.self_go:SetActive(false)
    --self.enemy_go:SetActive(false)

    T.RPG_Entity.listenFunc = function(eid, listen)
        local ety_data = self._etys[eid]
        local ety = ety_data and ety_data.ety
        local RPG_Entity = ety_data and ety_data.RPG_Entity
        if ety then
            if listen then
                ety_data.listen_func = function(_, prop, value)
                    if value == nil then
                        return
                    end
                    
                    local title = prop
                    local multiple = 1

                    local bf_data = resmng.prop_effect_typeById(prop);
                    if bf_data then
                        title = bf_data.BuffName
                        multiple = bf_data.RPGType
                    end

                    RPG_Entity:UpdateProp(prop, value / multiple)
                end
                for _, field in ipairs(self.rpg_listen_field) do
                    ety:listen_prop(field, ety_data.listen_func)
                    ety_data.listen_func(nil, field, ety._p[field])
                end
                RPG_Entity:UpdateProp("GridX", ety._gx or -999)
                RPG_Entity:UpdateProp("GridY", ety._gy or -999)
            elseif ety_data.listen_func then
                for _, field in ipairs(self.rpg_listen_field) do
                    ety:remove_listen_prop(field, ety_data.listen_func)
                end
                ety_data.listen_func = nil
            end
        end
    end
end)


rpg_debug_view_mod.rpg_listen_field = RPG_PROPERTY
--{
--    "RPG_Hp",
--    "RPG_HpMax",
--}


function rpg_debug_view_mod:register_listener()
    self._ins:add_event_listener2(RPG_EVENT_TYPE.BORN, self, "on_born") -- 伤害
    self._ins:add_event_listener2(RPG_EVENT_TYPE.DEAD, self, "on_dead") -- 伤害
    self._ins:add_event_listener2(RPG_EVENT_TYPE.SKILL_START, self, "on_skill") -- 伤害
    self._ins:add_event_listener2(RPG_EVENT_TYPE.SKILL_END, self, "on_skill_end") -- 伤害
    self._ins:add_event_listener2(RPG_EVENT_TYPE.EFFECT, self, "on_skill_effect") -- 伤害
    self._ins:add_event_listener2(RPG_EVENT_TYPE.ACTION_MOVE, self, "on_move") -- 伤害
end

function rpg_debug_view_mod:on_born(event)
    local ety = self._view_map:get_unit(event.eid)
    if not ety then
        ety = T.rpg_debug_view_entity(event.eid, self._ins)
        self._view_map:add_unit(ety)
    end
end
function rpg_debug_view_mod:on_skill(event)
    T.ECSMarchingLineManager.instance:DeleteLine(event.eid)
    --Logger.LogerWYY2("__on_skill", event.eid, event.oid)
    local ety = self._view_map:get_unit(event.eid)
    if not ety then
        return
        -- ety = T.rpg_debug_view_entity(event.eid, self._ins)
        -- self._view_map:add_unit(ety)
    end
    ety:on_skill_start(event)
end

function rpg_debug_view_mod:on_skill_end(event)
    T.ECSMarchingLineManager.instance:DeleteLine(event.eid)
    --Logger.LogerWYY2("__on_skill_end", event.eid, event.oid)
    local ety = self._view_map:get_unit(event.eid)
    local _ = ety and ety:on_skill_end(event)
end

function rpg_debug_view_mod:on_skill_effect(event)
    -- T.ECSMarchingLineManager.instance:DeleteLine(event.eid)
    local ety = self._view_map:get_unit(event.eid)
    local _ = ety and ety:on_skill_effect(event)
end

function rpg_debug_view_mod:on_move(event)
    local ety = self._etys[event.eid]
    local scene =models and models.rpg_battle_model and  self._ins.scene
    if not ety or not scene then
        return
    end
    --
    --
    local roads = {}
    local ways = event.ways
    for i = 1, #ways do
        local way = ways[i]
        local x, y = rpg_g2b(way[1], way[2])
        local pos = E.Vector3(RPG_I2F(x),0.1, RPG_I2F(y))
       table.insert(roads, scene:b2w_point(pos))
    end

    T.ECSMarchingLineManager.instance:CreateLine(event.eid, ety.is_self and E.Color.green or E.Color.red, roads,9)
end

--function rpg_debug_view_mod:on_born(event)
--    local is_self = event.tid == 1
--
--    local newgo = E.GameObject.Instantiate(is_self and self.self_go or self.enemy_go)
--    local txt = newgo.transform:Find("txt"):GetComponent(typeof(E.TextMeshPro))
--    local RPG_Entity = newgo:GetComponent(typeof(T.RPG_Entity))
--    RPG_Entity.eid = event.eid
--    newgo:SetActive(true)
--    local ety = {
--        eid = event.eid,
--        is_self = is_self,
--        go = newgo,
--        ety = self._ins._battle_mod:get_ety(event.eid),
--        txt = txt,
--        RPG_Entity = RPG_Entity
--    }
--    self._etys[event.eid] = ety
--end

function rpg_debug_view_mod:on_dead(event)
    local ety = self._etys[event.eid]
    if ety then
        self._etys[event.eid] = nil
        --E.GameObject.Destroy(ety.go)
    end
end

function rpg_debug_view_mod:update()
    for _, view_ety in pairs(self._view_map._units) do
        view_ety:update()
    end

    --for _, data in pairs(self._etys) do
    --    local ety = data.ety
    --    local x = RPG_I2F(data.ety._x)
    --    local y = RPG_I2F(data.ety._y)
    --    data.txt.text = RPG_ENTITY_STATE2[ety._state]
    --    data.txt.text = ety._fpos .. "\n" .. ety._eid
    --    local trans = data.go.transform
    --    trans.position = E.Vector3(x, 0, y)
    --    trans.rotation = E.Quaternion.LookRotation(E.Vector3(ety._dir_x, 0, ety._dir_y))
    --end
end

function rpg_debug_view_mod:stop()
    T.RPG_Entity.listenFunc = nil
    self._view_map:release()
    --for _, data in pairs(self._etys) do
    --    E.GameObject.Destroy(data.go)
    --end
    --self.self_go:SetActive(true)
    --self.enemy_go:SetActive(true)
    self._etys = {}
end

--- @param target_go GameObject
--- @param eid string
function rpg_debug_view_mod:register_debug_target(target_go, eid, is_self)    
    local RPG_Entity = target_go:GetComponent(typeof(T.RPG_Entity))

    if T.LuaHelper.IsNull(RPG_Entity) then
        RPG_Entity = target_go:AddComponent(typeof(T.RPG_Entity))
    end 
    
    RPG_Entity.eid = eid
    
    local ety = {
        eid = eid,
        is_self = is_self,
        go = target_go,
        ety = self._ins._battle_mod:get_ety(eid),
        --txt = txt,
        RPG_Entity = RPG_Entity,
    }
    self._etys[eid] = ety

end


--- @param eid string
function rpg_debug_view_mod:unregister_debug_target(eid)
    self._etys[eid] = nil
end