E.Plane = CS.UnityEngine.Plane
local rpg_drag_action = class2("rpg_drag_action", function(self, touch_id, camera, plane_height, excludeObject, maxDistance, layerMask)
    self._touch_id = touch_id 
    self._camera = camera
    self._excludeObject = excludeObject
    self._maxDistance = maxDistance or 1000
    self._layerMask = layerMask or -1
    self._plane = E.Plane(E.Vector3.up, E.Vector3(0,plane_height,0))
    self._hoverObject = nil
end)

function rpg_drag_action:drag_start()
    self.Update = function()
        self:dragging()
    end
    self.CS = CS.Hugula.Framework.LuaBehaviour.Create(self, "rpg_drag_action")
    self:on_drag_start()
end
E.TouchPhase = CS.UnityEngine.TouchPhase

function rpg_drag_action:get_touch()
    local touch_count = E.Input.touchCount
    local touch_id = self._touch_id
    if touch_count > 0 then
        for i = 0, touch_count - 1 do
            local touch = E.Input.GetTouch(i)
            if touch.fingerId == touch_id then
                return touch
            end
        end
    end
    if E.Input.GetMouseButtonUp(0) then
        local touch = {
            phase = E.TouchPhase.Ended,
            position = E.Input.mousePosition,
        }
        return touch
    elseif E.Input.GetMouseButton(0) then
        local touch = {
            phase = E.TouchPhase.Moved,
            position = E.Input.mousePosition,
        }
        return touch
    end
end

function rpg_drag_action.IsPointOverUIObject(screen3)
    local screen = CS.UnityEngine.Vector2(screen3.x, screen3.y)

    local EventSystem = CS.UnityEngine.EventSystems.EventSystem 
        local isOver = false;
        local pointTest = CS.UnityEngine.EventSystems.PointerEventData(EventSystem.current);
        pointTest.position = screen;
        -- overList.Clear();
        local overList = CS.System.Collections.Generic.List(CS.UnityEngine.EventSystems.RaycastResult)()
        if (EventSystem.current) then
            EventSystem.current:RaycastAll(pointTest, overList);
            if (overList.Count > 0) then
                return true;
            end
        end
        return isOver;
end
function rpg_drag_action:on_dragging(worldPosition)
end

function rpg_drag_action:screen_2_world_plane(screenPosition)
    local ray = self._camera:ScreenPointToRay(screenPosition)
    local plane = self._plane
    local is_hit, enter = plane:Raycast(ray)
    if is_hit then
        return ray:GetPoint(enter)
    else
        return E.Vector3.zero
    end
end

function rpg_drag_action:dragging()
    local touch = self:get_touch()
    if not touch then
        self:drag_end()
        return
    end
    local is_touch_end = touch.phase == E.TouchPhase.Ended or touch.phase == E.TouchPhase.Canceled
    if is_touch_end then
        self:drag_end()
        return
    end
    -- local is_over_ui = rpg_drag_action.IsPointOverUIObject(touch.position)
    local touchPos = E.Vector3(touch.position.x, touch.position.y, 0)
    local worldPosition = self:screen_2_world_plane(touchPos)
    self:on_dragging(worldPosition)
    -- if is_over_ui then
    --     return
    -- end

    local currHoverObj = CS.DragHelper.RayCast(E.Input.mousePosition, 
    self._camera,self._excludeObject,self._maxDistance,self._layerMask)

    if self._hoverObject == currHoverObj then
        if currHoverObj then
            self:on_hovering(currHoverObj)
        end
        return
    end
    if self._hoverObject then
        local hoverObject = self._hoverObject
        self._hoverObject = nil
        self:on_hover_end(hoverObject)
    end
    if currHoverObj then
        self._hoverObject = currHoverObj
        self:on_hover_start(currHoverObj)
    end
end

function rpg_drag_action:on_hover_start(dragObject)
end

function rpg_drag_action:on_hovering(dragObject)
end

function rpg_drag_action:on_hover_end(dragObject)
end


function rpg_drag_action:drag_end()
    local dragTarget = nil
    if self._hoverObject then
        local hoverObject = self._hoverObject
        dragTarget = hoverObject
        self._hoverObject = nil
        self:on_hover_end(hoverObject)
    end
    CS.Hugula.Framework.LuaBehaviour.Delete(self.CS)
    self.CS = nil
    self.Update = nil
    self:on_drag_end(dragTarget)
end

function rpg_drag_action:on_drag_start()
end

function rpg_drag_action:on_drag_end(dragTarget)
end