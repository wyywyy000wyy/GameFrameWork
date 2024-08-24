local rpg_drag_action_formation_hero = class2("rpg_drag_action_formation_hero", T.rpg_drag_action, function(self, drag_end_func, touch_id, rpg_entity_avatar, plane_height)
    local camera = nil
    -- if models.rpg_battle_model.is_scene_battle then
    --     camera = CS.RoomManager.Instance.sceneCamera;
    -- else
        local unity = CS.UnityEngine;
		camera = unity.Camera.main;
    -- end
    local layerMask = CS.UnityEngine.LayerMask.GetMask("Army")
    T.rpg_drag_action._ctor(self, touch_id, camera, plane_height,nil,nil,layerMask)

    self._drag_end_func = drag_end_func
    self._avatar = rpg_entity_avatar
    -- self._avatar:load_res(function()

    -- end)
    -- self._avatar:set_mat_alpha(1)
end)

function rpg_drag_action_formation_hero:on_drag_end(dragSlot)
    -- self._avatar:revert_mat_shader()
    local slotId = dragSlot and dragSlot.id
    Logger.LogerWYY2("rpg_drag_action_formation_hero:on_drag_end",slotId)
    self._drag_end_func(slotId)
end

function rpg_drag_action_formation_hero:on_dragging(worldPosition)
    if self._avatar then
        -- Logger.LogerWYY2("rpg_drag_action_formation_hero:on_dragging",worldPosition)
        self._avatar:set_pos(worldPosition)
    end
end

function rpg_drag_action_formation_hero:on_hover_start(dragSlot)
    local slotId = dragSlot.id
    Logger.LogerWYY2("rpg_drag_action_formation_hero:on_hover_start",slotId)

    g_ui_manager:call_func("ui_rpg_battle_formation", "on_hover_slot_start", slotId);
end

function rpg_drag_action_formation_hero:on_hover_end(dragSlot)
    local slotId = dragSlot.id
    Logger.LogerWYY2("rpg_drag_action_formation_hero:on_hover_end",slotId)
    g_ui_manager:call_func("ui_rpg_battle_formation", "on_hover_slot_end", slotId);
end