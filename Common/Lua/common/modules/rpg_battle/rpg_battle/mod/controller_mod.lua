

-- local ORCAScene = CS.ORCAScene

local controller_mod = class2("controller_mod", T.mod_base,function(self, battle_instance)
    T.mod_base._ctor(self, battle_instance)

    self._ai_etys = {}

end)

--模块数据初始化，战斗数据构造完成之后调用
function controller_mod:init()
    -- 各个模块根据战斗数据做初始化
    self._init_completed = true
end

function controller_mod:register_listener()
    self._on_ety_born = function(born_event)
        self:on_ety_born(born_event)
    end

    self._ins:add_event_listener(RPG_EVENT_TYPE.BORN, self._on_ety_born) -- 战斗开始

end

-- 暂停战斗
function controller_mod:switch_auto_skill()
    self._ins._auto_skill = not (self._ins._auto_skill or false)
end

function controller_mod:do_skill(eid, skill_id)
    local battle_mod = self._ins._battle_mod
    local ety = battle_mod:get_ety(eid)
    local anger_skill = nil
    for _, skill in ipairs(ety._skills) do
        if skill:is_anger2() or skill_id and skill_id == skill._id then
            anger_skill = skill
            break
        end
    end
    if anger_skill == nil then
        return
    end
    local target_orient = battle_mod:search_target(anger_skill._cfg, ety)
    if target_orient == nil then
        return
    end
    -- target_orient._eid = target._eid
     
    local controller = nil
    for _, ai in ipairs(self._ai_etys) do
        if ai._ety_proxy._eid == eid then
            controller = ai
        end
    end

    local action_data = target_orient
    --action_data.id = RPG_EVENT_TYPE.ACTION_SKILL_ANGER
    action_data.id = anger_skill:is_anger() and RPG_EVENT_TYPE.ACTION_SKILL_ANGER or RPG_EVENT_TYPE.ACTION_SKILL    -- 临时使用
    action_data.skill_id = anger_skill._id
    action_data.eid = ety._eid

    -- action_data._eid = anger_skill._id

    -- controller:add_action(T.action_skill_anger(self._ins, eid, anger_skill._id, eid, target_orient))

    if controller ~= nil then
        controller:add_action_data(action_data)
    end
end

function controller_mod:on_ety_born(born_event)
    if born_event.ety_type == RPG_ETY_TYPE.MDOOR then
        return
    end

    local ety = self._ins._battle_mod:get_ety(born_event.eid)
    local ai_ety = nil 

    if self._ins._is_td_battle then
        if born_event.tid == 1 then
            ai_ety = T.td_controller_defend(self._ins, ety, self._scene)
        else
            ai_ety = T.td_controller_monster(self._ins, ety, self._scene)
            -- ai_ety = T.rpg_controller_grid(self._ins, ety)
        end
    else
        ai_ety = T.rpg_controller_grid(self._ins, ety)
    end

    -- if born_event.ety_type == RPG_ETY_TYPE.PET then
    --     ai_ety = T.rpg_controller_pet(self._ins, ety)
    -- else
    --     ai_ety = T.rpg_controller_grid(self._ins, ety)
    -- end
    ai_ety:init()
    table.insert(self._ai_etys ,ai_ety)
end

function controller_mod:remove_listener()
end

-- 每帧检查
function controller_mod:init_finish()
    return self._init_completed
end

function controller_mod:start()
    local battle_instance = self._ins
    local level_id = battle_instance._init_data.level_id
    local level_data = resmng.prop_rpg_battle_levelById(level_id)
    local map_data = resmng.prop_rpg_battle_mapById(level_data.Map);
    if battle_instance._init_data.map_id then
        map_data = resmng.prop_rpg_battle_mapById(battle_instance._init_data.map_id);
    end

    local mapSize = map_data.MapSize

    -- local width = 50 * 1000--(mapSize and mapSize[1] or 11) * 1000
    local length = 3 --(mapSize and mapSize[2] or 14) * 1000
    local width = 10-- (mapSize and mapSize[1] or 11) 
    -- local length = (mapSize and mapSize[2] or 14) * 1000
    self._grid = T.hexagonal_grid(width, length)
    self._obj_pos = {}

    local g_scene = E.GameObject("ORCAScene")
    T.LuaHelper.AddComponent(g_scene, typeof(CS.ORCAScene))
    local scene = g_scene:GetComponent(typeof(CS.ORCAScene))
    scene.width = 500 --width 
    scene.length = 11
    scene.thickness = 3
    self._scene = scene
    scene:GenerateScene()

    self._ins:add_fixed_update(function() 
        self:fixed_update()
    end,"controller_fixed_update")
end

function controller_mod:fixed_update()
    if self._scene then
        self._scene:DoUpdate(RPG_I2F(self._ins._fixed_dt))
    end
    -- INFO("[RPG]%s controller_mod_fixed_update ", self._ins:log_str())
    for _, ai in ipairs(self._ai_etys) do
        ai:update()
    end
end

function controller_mod:stop()
    if self._scene then
        E.GameObject.Destroy(self._scene.gameObject)
        self._scene = NIL
    end
end