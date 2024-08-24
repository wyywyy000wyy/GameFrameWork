--- Created by weizheng
--- DateTime: 2023/3/9
--- 客户端用于表现的战斗场景
---     .逻辑模块战斗中心点位置始终是坐标轴中心点，这个脚本负责将逻辑坐标系转换成表现坐标系

local Vector3 = CS.UnityEngine.Vector3

---@class rpg_battle_scene
local rpg_battle_scene = class2("rpg_battle_scene", function(self, mapId)
    local cur_map_prop = resmng.prop_rpg_battle_map[mapId]; 
    self._map_prop = cur_map_prop
    self._dir = Vector3(0, cur_map_prop.MapRot, 0)   -- 出生点方向
    self._quaternion = E.Quaternion.Euler(self._dir)
    self._center = Vector3(cur_map_prop.MapCenter[1], cur_map_prop.Height, cur_map_prop.MapCenter[2]) -- 出生点位置
    
    -- 布阵相机参数
    local deploy_camera_center_x = cur_map_prop.DeployCameraCenter[1] + cur_map_prop.MapCenter[1]
    local deploy_camera_center_z = cur_map_prop.DeployCameraCenter[2] + cur_map_prop.MapCenter[2]
    self._deploy_camera_center = Vector3(deploy_camera_center_x, cur_map_prop.Height, deploy_camera_center_z) -- 布阵相机中心点位置

    local deploy_rot_x = cur_map_prop.DeployCameraParam[2][1]
    local deploy_rot_y = cur_map_prop.DeployCameraParam[2][2]
    self._deploy_camera_world_rot = self._dir + E.Vector3(deploy_rot_x, deploy_rot_y, 0)

    self._deploy_camera_distance = cur_map_prop.DeployCameraParam[1]

    -- 战斗相机参数
    local battle_camera_center_x = cur_map_prop.BattleCameraCenter[1] + cur_map_prop.MapCenter[1]
    local battle_camera_center_z = cur_map_prop.BattleCameraCenter[2] + cur_map_prop.MapCenter[2]
    self._battle_camera_center = Vector3(battle_camera_center_x, cur_map_prop.Height, battle_camera_center_z) -- 战斗相机中心点位置

    local battle_rot_x = cur_map_prop.BattleCameraParam[2][1]
    local battle_rot_y = cur_map_prop.BattleCameraParam[2][2]
    self._battle_camera_world_rot = self._dir + E.Vector3(battle_rot_x, battle_rot_y, 0)

    self._battle_camera_distance = cur_map_prop.BattleCameraParam[1]
end)

--坐标点 战斗坐标系转换到世界坐标系
function rpg_battle_scene:b2w_point(battle_position)
    return self._quaternion * battle_position + self._center
end

--旋转 战斗坐标系转换到世界坐标系
function rpg_battle_scene:b2w_rot(battle_rotation)
    return self._quaternion * battle_rotation
end

--角度 战斗坐标系转换到世界坐标系
function rpg_battle_scene:b2w_euler(battle_dir)
    return self._quaternion * battle_dir
end

-- 修改战斗中心点位置
function rpg_battle_scene:update_center(offset)
    self._center = self._center + offset -- 出生点位置
    self._deploy_camera_center = self._deploy_camera_center + offset
    self._battle_camera_center = self._battle_camera_center + offset
end