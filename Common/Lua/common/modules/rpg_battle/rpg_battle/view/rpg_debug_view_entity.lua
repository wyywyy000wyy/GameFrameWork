local rpg_debug_view_entity = class2("rpg_debug_view_entity", T.dungeon_game_unit, function(self, eid, battle_ins)
    self._ins = battle_ins
    self._ety = battle_ins._battle_mod:get_ety(eid)
    self._rpg_battle_scene = models.rpg_battle_model.cur_scene
    T.dungeon_game_unit._ctor(self, eid, self:get_logic_pos() , 0, 1)
    self.cast_skills = {}

    local RPG_ENTITY = E.GameObject.Find("RPG_ENTITY")
    if false and RPG_ENTITY then
    self._go = E.GameObject.Instantiate(RPG_ENTITY.gameObject)
    else
    self._go = E.GameObject()
    end

    self._go.name = "RPG_ETY_" .. eid .. "_VIEW"
    self._tgo = E.GameObject.Find("RPG_ETY_" .. eid)
    self._trans:set_transform(self._go.transform)
end)

function rpg_debug_view_entity:get_logic_pos()
    local pos = E.Vector3(RPG_I2F(self._ety._x), 0, RPG_I2F(self._ety._y))
    return self._rpg_battle_scene:b2w_point(pos)
end

rpg_debug_view_entity.range_map_func = {
    [RPG_RANGE_TYPE.CIRCLE] = function(rang_param,map_height, x, y, sx, sy)
        local result = {}
        result.type = SKILL_RANGE_TYPE.CIRCLE
        -- result.eid = center.eid
        result.pos = E.Vector3(sx / 1000,map_height,sy / 1000)
        result.radius = rang_param[2] / 1000
        return result
    end,
    [RPG_RANGE_TYPE.RECT] = function(rang_param,map_height, x, y, sx, sy)
        local result = {}
        result.type = SKILL_RANGE_TYPE.RECT
        result.pos = E.Vector3(sx / 1000,map_height,sy / 1000)
        result.width = rang_param[3]/ 1000
        result.length = rang_param[2]/ 1000
        result.dir = E.Vector3(x-sx, 0, y-sy)
        return result
    end,
    [RPG_RANGE_TYPE.SECTOR] = function(rang_param,map_height, x, y, sx, sy)
        local result = {}
        result.type = SKILL_RANGE_TYPE.SECT
        result.pos = E.Vector3(sx / 1000,map_height,sy / 1000)
        result.radius = rang_param[3] / 1000
        result.angle = rang_param[2]
        result.dir = E.Vector3(x-sx, 0, y-sy)
        return result
    end,
    [RPG_RANGE_TYPE.ALL] = function(rang_param,map_height, x, y, sx, sy)
        local result = {}
        result.type = SKILL_RANGE_TYPE.FULL_SCREEN
        return result
    end,
}

function rpg_debug_view_entity:update()
    self._trans:set_pos(self:get_logic_pos())
end

function rpg_debug_view_entity:on_skill_start(event)
    local cast_skills = self.cast_skills
    if cast_skills[event.oid] then
        self:end_skill(event.oid)
    end

    cast_skills[event.oid] = {
        skill_id = event.skill_id,
        effs = {}
    }
end

function rpg_debug_view_entity:on_skill_end(event)
    self:end_skill(event.oid)
end

function rpg_debug_view_entity:end_skill(skill_oid)
    local cast_skills = self.cast_skills
    local cast_skill = cast_skills and cast_skills[skill_oid]
    if cast_skill then
        for _, eff in pairs(cast_skill.effs) do
            lua_distribute(DIS_TYPE.HIDE_BATTLE_INDICATOR, eff[1], eff[2])
        end
        cast_skill.effs = {}
        cast_skills[skill_oid] = nil
    end
end

function rpg_debug_view_entity:on_skill_effect(event)
    local cast_skills = self.cast_skills
    local cast_info = cast_skills[event.oid]
    if not cast_info then
        return
    end
    local eff_id = event.eff_id
    local idx = #cast_info.effs

    local prop_rpg_battle_effect = resmng.prop_rpg_battle_effect[eff_id]
    local range = prop_rpg_battle_effect.Range
    local range_func = rpg_debug_view_entity.range_map_func[range[1]]
    if not range_func then
        return
    end

    local param = range_func(range, 0.1, event.x, event.y, event.sx or event.x, event.sy or event.y)
    if param.pos then
        param.pos = self._rpg_battle_scene:b2w_point(param.pos)
    end
    if param.dir then
        param.dir = self._rpg_battle_scene:b2w_euler(param.dir)
    end
    local key = string.format("eff_%s_%s_%d", event.oid, eff_id, idx)
    table.insert(cast_info.effs, {
        key,
        param,
    })
    lua_distribute(DIS_TYPE.BATTLE_INDICATOR, key, param)
end

function rpg_debug_view_entity:on_destroy()
    E.GameObject.Destroy(self._go)
    for oid, eff in pairs(self.cast_skills or {}) do
        self:end_skill(oid)
    end
end