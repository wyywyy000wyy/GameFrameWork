local rpg_task = T.rpg_task
local tasks = rpg_task.tasks
local wrapper = rpg_task.wrapper
local lua_binding = lua_binding
local lua_unbinding = lua_unbinding

local rpg_task_class = function(task_name, ...)
    local task_class = class2(task_name, T.rpg_task, ...)
    tasks[task_name] = function(...)
        local task = task_class(...)
        return task
    end
    return task_class
end


local  rpg_task_open_ui = class2("rpg_task_open_ui", T.rpg_task, function(self, ui_name, p1, ...)
    self._ui_name = ui_name
    self._params = p1 and {p1, ...}
end)
tasks["open_ui"] = rpg_task_open_ui

local print_good = rpg_task_class("print_good", function(self, good_id)
    self._good_id = good_id
end)

function print_good:on_excute()
    Logger.LogerWYY2("print_good", self._good_id)
    return true
end

function rpg_task_open_ui:on_excute()
    local ui_name = self._ui_name
    local params = self._params
    VMState:push_item(ui_name, params and unpack(params))
    self._cb = function(name)
        if name == ui_name then
            self:finish()
        end
    end
    lua_binding(DIS_TYPE.DIALOG_OPEN_UI, self._cb)
    return false;
end
 
function rpg_task_open_ui:on_finish()
    lua_binding(DIS_TYPE.DIALOG_CLOSE_UI, self._cb)
end

tasks["name"] = wrapper(function(rpg_task_instance, task_name)
    rpg_task.task_instances[task_name] = rpg_task_instance
    return true
end)

tasks["print"] = wrapper(function(rpg_task_instance, ...)
    Logger.LogerWYY2(...)
    return true
end)

tasks["call"] = wrapper(function(task_instance,cb, ...)
    if cb then
        cb(task_instance, ...)
    end
    return true
end)

tasks["wait"] = wrapper(function(task_instance,cb, ...)
    return cb(task_instance, ...)
end)

tasks["ask_ety"] = wrapper(function(task_instance,eid)
    local ety = models.model.get_unit(eid)
    if ety then
        task_instance:set_result("ety", ety)
        return true
    else
        Rpc:askEty(eid, function(data)
            task_instance:set_result("ety", data)
            task_instance:finish()
        end, function (data)
            task_instance:cancel()
        end)
    end
    return false
end)

tasks["get_server_info"] = wrapper(function(task_instance,map_id)
    local server_info = models.server_raw_model:get_server_info_direct(map_id)
        if not server_info then
            models.server_raw_model:req_single_server_info(0, {map_id}, function ()
                -- 数据有才抛事件，如果还是没有数据则不管
                task_instance:finish()
            end)
            return false
        end
    return true
end)

tasks["event"] = wrapper(function(task_instance,event_name, finish_func)
    local event_handle 
    event_handle = function(...)
        if finish_func then
            if not finish_func(task_instance, ...) then
                return
            end
        end
        lua_unbinding(event_name, event_handle)
        task_instance:finish()
    end
    lua_binding(event_name, event_handle)
    return false
end)

---延迟time秒执行后续task
tasks["delay"] = wrapper(function(task_instance,time)
    local event_handle 
    event_handle = function()
        task_instance:finish()
    end
    T.Timer.Add(time, 1, event_handle, nil)
    return false
end)

tasks["get_replay_battle_data"] = wrapper(function(task_instance, battle_id, replay_id)
    local battle_data = models.rpg_battle_model.get_battle_data(battle_id)
    if not battle_data or  battle_id == 0 then
        battle_data = models.rpg_battle_model.get_battle_data(replay_id)
    end
    if not battle_data and g_custom_data then
        local battle_id = 1
        battle_data = table.clone(g_custom_data or ui_rpg_battle_test.battle_data, true)
        local battle_ins = T.battle_instance_calc(battle_id, battle_data)
        battle_ins._auto_skill = true
        battle_ins:start()
        battle_data = battle_ins:get_result_data(true)
        -- models.rpg_battle_model.set_battle_data(battle_id,battle_data)
    end

    if battle_data then
        task_instance:set_result("battle_data", battle_data)
        -- task_instance:finish()
        return true
    end
    Rpc:pullRpgRecord(replay_id, function (data)
        local len = #data.log
        local compressedLength, ret2 = CS.CommonUtils.Lz4DecompressWithLen(data.log, len)
        local buf = string.sub(ret2, 1, compressedLength)
        local battle_data = cmsgpack.unpack(buf)

        models.rpg_battle_model.set_battle_record_data(replay_id, battle_data)
        models.rpg_battle_model.set_battle_data(battle_id, battle_data)
            task_instance:set_result("battle_data", battle_data)
            task_instance:finish()
    end, function()
        task_instance:cancel()
    end)

    return false
end)

tasks["rpg_formation"] = wrapper(function(task_instance, rpg_formation_param, battle_level_id)
    if not rpg_formation_param then
        return true
    end

    models.rpg_battle_model.pre_troop_idx = 1
    if not battle_level_id then
        battle_level_id = RPG_DEFAULT_LEVEL_ID
    end

    if rpg_formation_param.skip_form then
        local compat_group_info = models.troop_model.get_compat_group_info()[rpg_formation_param.pre_troop_type]
        local formation = compat_group_info[models.rpg_battle_model.pre_troop_idx]
        local formation_param = {
                heros = formation.heros,
                pet_id = formation.pet_id,
                monsters = {},
            }
        task_instance:set_result("formation_param", formation_param)
        return true
    end

    rpg_formation_param.fomation_call_back = function(formation_param)
        task_instance:set_result("formation_param", formation_param)
        return true
    end
    rpg_formation_param.close_call_back = function(is_back)
        if is_back then
            task_instance:cancel()
        -- -----------默认认为布阵都要加载场景
        -- T.rpg_task():unload_battle_scene():excute()
            return
        end
        task_instance:finish()
    end
    rpg_formation_param.battle_level_id = task_instance:get_result("battle_level_id") or battle_level_id
    VMState:append_item_to("ui_rpg_battle","ui_rpg_battle_formation", rpg_formation_param)
    -- VMState:push_item("ui_rpg_battle_formation", rpg_formation_param)

    return false
end)


tasks["load_battle_scene"] = wrapper(function(task_instance, battle_level_id, not_unload_at_finish)
    local battle_data = task_instance:get_result("battle_data")
    local level_id = battle_data and battle_data.level_id or battle_level_id or RPG_DEFAULT_LEVEL_ID
    task_instance:set_result("battle_level_id", level_id)
    -- local level_prop = resmng.prop_rpg_battle_levelById(level_id)
    -- local map_id = level_prop.Map
    -- local scene = T.rpg_battle_scene(map_id)
    models.rpg_battle_model.pre_scene_load(level_id)
    if models.rpg_battle_model.is_scene_battle then
        VMState:push_item("ui_loading", { load_bg = "dungeon_loading_bg" });    -- 打开Loading
        g_ui_manager:call_func("rpg_battle_loading", "load_asset", {
            level_id,
            cb = function()
                VMState:popup_item("ui_loading")
                models.rpg_battle_model.pre_scene_load(level_id)
                models.rpg_battle_model.on_battle_loaded()
                if not not_unload_at_finish then
                    local task_class = tasks["unload_battle_scene"]
                    local task = task_class()
                    task._task_name = "unload_battle_scene"
                    task_instance:task_list():add_finish_task(task)
                    -- task_instance:finish_task("unload_battle_scene")
                end
                -- Logger.Log("load_battle_scene finish",CS.UnityEngine.Time.frameCount)
                task_instance:finish()
            end
        })    -- 执行场景加载
        -- T.rpg_task():event("rpg_battle_loading_finish", function()
        --     g_ui_manager:call_func("rpg_battle_loading", "close")
        --     task_instance:finish()
        -- end)
        return false
    else
        resmng.war = true   -- 标记在独立副本中
        post_event(DIS_TYPE.BATTLE_DISSOLVE, self._ins.scene._map_prop.Scene)
        models.rpg_battle_model.on_battle_loaded()

        local task_class = tasks["unload_battle_scene"]
        local task = task_class()
        task._task_name = "unload_battle_scene"
        task_instance:task_list():add_finish_task(task)
    end
    return true
end)

tasks["unload_battle_scene"] = wrapper(function(task_instance)
    -- models.rpg_battle_model.quit_battle()
    local rpg_battle_model = models.rpg_battle_model
    if rpg_battle_model.cur_battle_ins then
        rpg_battle_model.cur_battle_ins:stop()
        rpg_battle_model.cur_battle_ins = nil
    end

    rpg_battle_model.on_exit_scene()
    VMState:popup_item("ui_rpg_battle_formation")
    VMState:back();


    -- VMState:back();
    return true
end)

tasks["finish_task"] = wrapper(function(task_instance, task_name, ...)
    local task_class = tasks[task_name]
    local task = task_class(...)
    task_instance:task_list():add_finish_task(task)
    return true;
end)

tasks["open_rpg_battle_result"] = wrapper(function(task_instance, ui_rpg_battle_result_arg)
    VMState:push_item("ui_rpg_battle_result", ui_rpg_battle_result_arg) 
    ui_rpg_battle_result_arg._callback2 = function()
        task_instance:finish()
    end
    return false
end)

require("world_map.world_map_task_define")


rpg_task.test_task = function()
    local loop_count = 2

    

    -- T.rpg_task("begin")
    -- :print("step_1")
    -- :finish_task("print", "step_1 cancel")
    -- :delay(2)
    -- :print("step_2")
    -- :finish_task("print", "step_2 cancel")
    -- :call(function(task_instance)
    --     if loop_count > 0 then
    --         loop_count = loop_count - 1
    --         task_instance:restart()
    --     end
    -- end)
    -- -- :call(function(ins) ins:cancel() end)
    -- -- :call(function(ins) insa:cancel() end)
    -- :delay(2)
    -- :print("step_3")
    
    -- -- :delay(1)
    -- -- :print("step_1 cancel")
    -- :excute()

    local ret_good = T.rpg_task("begin")
    :print("step_1")
    :call(function(task_instance)
        task_instance:print("step_tmp")
    end)
    :print("step_2")
    :excute()
end