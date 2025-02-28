--- Created by weizheng
--- DateTime: 2023/1/3 17:31
--- 战斗单位在客户端的表现单位
---     .战斗模块的每一个hero对象都有一个avatar

local DynamicObjLayer = CS.UnityEngine.LayerMask.NameToLayer("DynamicObj")

rpg_require("rpg_define_view")

-- local rpg_battle_model = require("models.rpg_battle_model")
local mgr_effect = rpg_require("mgr_effect")
local PoolManager = CS.CDL2.Utility.PoolManager
local Animator_type = typeof(CS.UnityEngine.Animator)
local Vector3 = CS.UnityEngine.Vector3
local LuaHelper = CS.Hugula.Utils.LuaHelper
local VEC_OUT = Vector3(-1000, -1000, -1000)
local lua_tween = lua_tween
local Ease = CS.DG.Tweening.Ease
local Sequence = CS.DG.Tweening.DOTween.Sequence
local AngerSkillBrightened_type = typeof(CS.AngerSkillBrightened)

---@class rpg_entity_avatar
local rpg_entity_avatar = class2("rpg_entity_avatar", function(self, eid, camp, lv, born_pos, born_dir)
    self._id = eid    -- 唯一Id
    self._eid = eid    -- 等级
    self._lv = lv    -- 等级
    self._born_pos = born_pos    -- 出生点位置
    self._born_dir = born_dir   -- 出生点方向
    self._camp = camp -- 阵营 0 己方 1 敌方
    self._height = self:get_model_height()    -- 模型高度
    -- 当前进行中行为的状态数据
    --      state == 1 移动
    --          speed 移动速度
    --          move_target 移动的目标位置
    self._data = { }
    
    self._entity_proxy = nil -- 对应的rpg_entity_proxy

    self._path = nil    -- 模型路径
    self._obj = nil -- 实体对象Transform
    self._trans = nil -- Transform组件
    self._body_obj = nil -- 模型 Body位置的Transform
    self._anim = nil -- Animator组件
    self._time_scale = 1 -- 该角色执行的time_scale
    self._effect_list = {} -- 该角色关联的特效，(技能特效、普攻特效等可以随着实体暂停一起暂停的特效)
    self._state_effects = {} -- 状态特效    key prop_rpg_battle_group中的Id value 播放的特效

    -- 属性信息
    self._hp = 0 -- 角色血量
    self._max_hp = 0 -- 最大血量

    self._anger = 0 -- 角色魔法值/怒气值
    self._max_anger = 0 -- 最大魔法值/怒气值    

    -- event 固定第一个字段为 时间 第二个字段为类型 后续字段为其他参数
    -- 技能表现播放时间轴
    self.skill_timeline = {}
    self:reset_display_timeline()
    self._time = 0
    self.destroyed = false -- 是否已经销毁
    self.ignore_camera_mask = false -- 是否忽略相机遮罩
end)

function rpg_entity_avatar:get_model_height()
    return 3
end

-- 每个状态对应的动画
rpg_entity_avatar.state_anim_name = {
    idle = "stand01",
    move = "run01",
    dead = "dead01",
    win = "win01",
    --attack = "attack 0",
    --skill = "attack_2",
}
local state_anim_name = rpg_entity_avatar.state_anim_name

rpg_entity_avatar.state_2_anim = {
    [RPG_ENTITY_STATE.IDLE] = state_anim_name.idle,
    [RPG_ENTITY_STATE.MOVE] = state_anim_name.move,
    [RPG_ENTITY_STATE.DEAD] = state_anim_name.dead,
    [RPG_ENTITY_STATE.WIN] = state_anim_name.win,
}

function rpg_entity_avatar:get_model_path()
    return nil
end

function rpg_entity_avatar:get_model_scale()
    return 1
end

function rpg_entity_avatar:get_team_pos()
    return nil
end

function rpg_entity_avatar:on_model_loaded(obj)

end

function rpg_entity_avatar:revert_mat_shader()
    if LuaHelper.IsNull(self._obj) then
        return
    end
    if self._origin_shader then
        local mr = self._obj:GetComponentInChildren(typeof(CS.UnityEngine.Renderer))
        if not mr then
            return
        end
        -- local mat = mr.material
        -- mat.shader = self._origin_shader
        local mtc = mr.materials.Length
        for i = 0, mtc -1 do
            local mt = mr.materials[i]
            mt.shader= self._origin_shader
        end
    end
    self._replace_mat_shader = nil
end
local ECSManager = CS.CDL2.ECSSystem.ECSManager

function rpg_entity_avatar:set_mat_alpha(alpha)
    self._replace_alpha = alpha
    if LuaHelper.IsNull(self._obj) then
        return
    end
    if ECSManager.instance.roleTransparentMat.shader ~= self._replace_mat_shader then
        self:replace_mat_shader(ECSManager.instance.roleTransparentMat.shader)
    end
    local mr = self._obj:GetComponentInChildren(typeof(CS.UnityEngine.Renderer))
    -- local OverlayModelLayer = CS.UnityEngine.LayerMask.NameToLayer("OverlayModel") 
    -- mr.gameObject.layer = OverlayModelLayer

    local mtc = mr.materials.Length
    for i = 0, mtc -1 do
        local mt = mr.materials[i]
        mt:SetFloat("gAlpha", alpha)
    end
end

function rpg_entity_avatar:replace_mat_shader(shader)
    self._replace_mat_shader = shader
    if LuaHelper.IsNull(self._obj) then
        return
    end
    local mr = self._obj:GetComponentInChildren(typeof(CS.UnityEngine.Renderer))
    if not mr then
        return
    end
    self._mr = mr
    local mat = mr.material
    self._origin_shader = self._origin_shader or mat.shader

    local mtc = mr.materials.Length
    for i = 0, mtc -1 do
        local mt = mr.materials[i]
        mt.shader= shader
    end
end

-- 加载英雄模型资源 和血条
function rpg_entity_avatar:load_res(callback, load_head, load_hero_info, is_support)
    self._path = self:get_model_path()
    self._is_support = is_support
    -- 读取配置表加载英雄模型
    g_load_asset(
            self._path,
            function(path, obj)
                if self.destroyed then
                    if not LuaHelper.IsNull(self._obj) then
                        self._obj.transform.position = VEC_OUT
                    end
                    
                    g_release_asset(self._path, obj)
                    return
                end
                
                obj.gameObject.name = "RPG_ETY_" .. self._id
                
                local trans = obj.transform
                trans.position = self._born_pos
                trans.localScale = Vector3.one * self:get_model_scale()
                trans.forward = self._born_dir
                trans:SetParent(nil)

                self._obj = obj
                self._trans = trans
                -- 找骨骼节点需要做max版本兼容 部分版本是Bip001 部分版本是Bip01
                self._body_obj = trans:Find("root/Bip001/Bip001 Pelvis/Bip001 Spine") or trans:Find("root/Bip01/Bip01 Pelvis/Bip01 Spine")
                self._anim = obj:GetComponent(Animator_type)
                
                if load_head == true then
                    self:create_ui_head() 
                end

                if load_hero_info == true then
                    self:create_ui_hero_info()
                end
                
                self:on_model_loaded(obj)
                if callback ~= nil then
                    callback()
                end

                if self._replace_alpha then
                    self:set_mat_alpha(self._replace_alpha)
                end
            end)
end

-- 更新血量信息
function rpg_entity_avatar:set_attr(hp, max_hp, anger, max_anger, is_init, static, shield)
    self._hp = hp and hp or self._hp
    self._max_hp = max_hp and max_hp or self._max_hp
    self._init_max_hp = self._init_max_hp or self._max_hp
    self._anger = anger and anger or self._anger
    self._max_anger = max_anger and max_anger or self._max_anger
    self._shield = shield or self._shield or 0
    -- self._shield = self._max_hp * 0.08
    self:update_ui_head(is_init, static)
end


function rpg_entity_avatar:create_ui_head()
    g_ui_manager:call_func("ui_rpg_head", "create_head", self._id, self._camp, self._trans, self._height)  -- 模型加载完成，实例化一个头像    
end

function rpg_entity_avatar:create_ui_hero_info()
    g_ui_manager:call_func("ui_rpg_head", "create_hero_info", self._id, self._hero_id, self._lv, self._is_support, self._trans)  -- 模型加载完成，实例化英雄种族和等级显示                  
end

function rpg_entity_avatar:update_ui_head(is_init, static)
    -- 调用 战斗界面更新血量
    g_ui_manager:call_func("ui_rpg_battle_main", "update_head", self._id, self._hp, self._max_hp, self._anger, self._max_anger, self._shield)
    -- 模型加载完成，实例化一个头像
    g_ui_manager:call_func("ui_rpg_head", "update_head", self._id, self._hp, self._max_hp, self._anger, self._max_anger, is_init, static, self._shield)
end

-- 同步属性值
function rpg_entity_avatar:async_props(props)
    local rpg_hp = props.RPG_Hp and props.RPG_Hp / 1000 or nil
    local rpg_hp_max = props.RPG_HpMax and props.RPG_HpMax / 1000 or nil
    local rpg_anger = props.RPG_Anger and props.RPG_Anger / 1000 or nil
    local rpg_anger_max = props.RPG_AngerMax and props.RPG_AngerMax / 1000 or nil
    local rpg_shield = props.RPG_Shield and props.RPG_Shield / 1000 or nil
    if rpg_hp ~= nil or rpg_hp_max ~= nil or rpg_anger ~= nil or rpg_anger_max ~= nil or rpg_shield ~= nil then
        self:set_attr(rpg_hp, rpg_hp_max, rpg_anger, rpg_anger_max, nil,nil, rpg_shield)
    end
end

-- 设置移动目标点
function rpg_entity_avatar:set_move_target(speed, target_point, cur_point, agent)
    if cur_point and self._trans then
        self._trans.position = Vector3(cur_point.x, self._trans.position.y, cur_point.z) 
    end
    if speed == 0 then  -- 移动结束时候，逻辑会同步一次位置，这个时候速度会设置成0
        -- self:set_state(RPG_ENTITY_STATE.IDLE)
        if self._trans  then
        self._trans.position = Vector3(target_point.x, self._trans.position.y, target_point.z) 
        end
        -- self:play_anim(state_anim_name.idle)  -- 默认动画
    else
        self:set_state(RPG_ENTITY_STATE.MOVE)
        -- self:play_anim(state_anim_name.move)  -- 播放移动动画
        self._ai_agent = agent
        self._data.speed = speed
        self._data.move_target = target_point
    end
end

-- 强制位移
function rpg_entity_avatar:force_move(target_point, dur)    
    self._force_move_sq = Sequence()        
    local sq = self._force_move_sq
    sq:Append(self._trans:DOMove(target_point, dur))
    sq:AppendCallback(function()
    end)
end

-- 修改位置
function rpg_entity_avatar:update_pos(x, y)
    self._trans.position = Vector3(x, self._trans.position.y, y)
end

function rpg_entity_avatar:update_forward(x, y)
   self._trans.forward =  Vector3(x, self._trans.forward.y, y).normalized
end

-- 该角色执行的time_scale
function rpg_entity_avatar:set_time_scale(time_scale)
    if self._time_scale == time_scale then
        return
    end
    
    self._time_scale = time_scale
    self._anim.speed = time_scale

    for _, effect in ipairs(self._effect_list) do
        effect:set_time_scale(time_scale)
    end

    for _, effect in ipairs(self._state_effects) do
        effect:set_time_scale(time_scale)
    end

    if self._force_move_sq ~= nil then
        self._force_move_sq.timeScale = time_scale
    end    
end

-- 设置角色忽略相机遮罩
function rpg_entity_avatar:set_ignore_camera_mask(ignore)
    if 1 then
        return
    end

    if self.ignore_camera_mask == ignore then
        return
    end

    self.ignore_camera_mask = ignore
    local bright = self._obj:GetComponent(AngerSkillBrightened_type)
    if not LuaHelper.IsNull(bright) then
        bright.enabled = false
    end

    if ignore then
        bright = self._obj:AddComponent(AngerSkillBrightened_type)
    end
end

-- 角色收到伤害
function rpg_entity_avatar:hurt(damage)
    local hp = self._hp + damage
    hp = hp > 0 and hp or 0

    --self:set_attr(hp, nil, nil, nil)
end

-- 释放技能
--- @param skill_id number 技能id
--- @param rapid number 技能释放速度 1为标准速度
--- @param pause_skill boolean 是否暂停其他技能
function rpg_entity_avatar:cast_skill(skill_id, rapid, pause_skill)
    self:set_state(RPG_ENTITY_STATE.SKILL)
    -- 播放技能特效
    local prop_skill = resmng.prop_rpg_battle_skill[skill_id];
    local pause_time = (prop_skill.SkillPause or 0)

    local sound_event = ""
    -- "重要说明：
    -- PVE我方英雄使用怒气技能时正常调用事件名，敌方英雄使用怒气技能需要增加 “_Enemy” 尾缀，如“RPG_Skill_caroline_Enemy”"
    -- 原本是一个可暂停其他技能的配置项，但是强制指定了不执行暂停
    if prop_skill.SkillSound ~= nil then
        if pause_time > 0 and pause_skill == false then
            sound_event = prop_skill.SkillSound .. "_Enemy" -- 播放技能音效
        else
            sound_event = prop_skill.SkillSound -- 播放技能音效
        end
    end

    if pause_skill == false then
        pause_time = 0
    end

    self:init_display_timeline(skill_id, prop_skill.SkillDisplay, prop_skill.Duration, pause_time, rapid, sound_event)
end

-- 技能结束
--- @param skill_id number 技能id
function rpg_entity_avatar:end_skill(skill_id)
    local prop_skill = resmng.prop_rpg_battle_skill[skill_id];
    if prop_skill ~= nil then
        if self.skill_timeline.skill_id == 0 or skill_id == self.skill_timeline.skill_id then
            -- PM.module_audio:stop_sound(prop_skill.SkillSound) -- 停掉正在播放的技能音效
            self:reset_display_timeline()
        end
    end
end

function rpg_entity_avatar:relive()
    -- self:set_state(RPG_ENTITY_STATE.IDLE, true)
    self:play_effect_on_body("ef_arthurking_rpg_spec2_spell")
    self._relive_time = self._time + RPG_I2F(RPG_RELIVE_DELAY)
end

function rpg_entity_avatar:relive_post()
    if self._relive_time < self._time then
        self._relive_time = nil
        self:set_state(RPG_ENTITY_STATE.IDLE, true)
    end
end

-- 死亡
function rpg_entity_avatar:dead()
    self:clear_effect()
    ------【RPG战斗】单位死亡时动作和受击特效会卡帧，无法正常播放死亡动画 http://10.23.0.3:8081/browse/SLGL2-23139
    self._anim.speed = 1;
    self:set_state(RPG_ENTITY_STATE.DEAD)
    -- self:play_anim(state_anim_name.dead)  -- 播放技能动画

    -- 播放死亡动画
    self.dead_delay_cor = coroutine.start(
            function()
                post_event(DIS_TYPE.SIMULATION_BATTLE_DROP, self._obj.transform.position)
                coroutine.wait_sec(3.5) -- 技能播放时长，需要取配置

                if self._data.state ~= RPG_ENTITY_STATE.DEAD or not self._obj then
                    return
                end
               
                self:destroy()
            end)
end

-- 重置时间轴
function rpg_entity_avatar:reset_display_timeline()
    self.skill_timeline.playing = false
    self.skill_timeline.skill_id = 0
    self.skill_timeline.pass_time = 0
    self.skill_timeline.duration = 0
    self.skill_timeline.pause_time = 0
    self.skill_timeline.events = nil
    self.skill_timeline.rapid = 1
    self.skill_timeline.sound_event = ""

    -- 根据技能急速播放速度设置动画播放速度
    if self._anim ~= nil then
        self._anim.speed = self.skill_timeline.rapid;
    end
end

-- 重新初始化Timeline
--- @param skill_id number 技能id
--- @param time_line_data table 时间轴数据
--- @param duration number 技能持续时间
--- @param rapid number 技能释放速度 1为标准速度
function rpg_entity_avatar:init_display_timeline(skill_id, time_line_data, duration, pause_time, rapid, sound_event)
    self.skill_timeline.playing = true
    self.skill_timeline.skill_id = skill_id
    self.skill_timeline.pass_time = 0
    self.skill_timeline.duration = RPG_I2F(duration or 0)
    self.skill_timeline.pause_time = RPG_I2F(pause_time or 0)
    self.skill_timeline.events = time_line_data
    self.skill_timeline.rapid = rapid or 1
    self.skill_timeline.sound_event = sound_event or ""
end

-- 检查是否正在释放冻结技能
function rpg_entity_avatar:is_pause_skill()
    return self.skill_timeline.pause_time > 0
end

-- 检查是否技能已经过了冻结时间
function rpg_entity_avatar:is_pause_time_over()
    return self.skill_timeline.pass_time >= self.skill_timeline.pause_time
end



rpg_entity_avatar.state_process_map = {
    [RPG_ENTITY_STATE.IDLE] = function(self, new_state)

    end,
}

function rpg_entity_avatar:set_state(state, force)
    if self._data.state == state then
        return
    end

    local cur_is_idle = self._data.state == RPG_ENTITY_STATE.IDLE --or self._data.state == RPG_ENTITY_STATE.MOVE
    local next_is_idle = state == RPG_ENTITY_STATE.IDLE --or state == RPG_ENTITY_STATE.MOVE
    if state == RPG_ENTITY_STATE.WIN then
        if not cur_is_idle then
            self._data.next_state = state
            return
        end
    elseif next_is_idle then
        if self._data.next_state ~= nil then
            state = self._data.next_state
            self._data.next_state = nil
        end
    else
        self._data.next_state = nil
    end

    self._data.state = state
    local anim = rpg_entity_avatar.state_2_anim[state]
    if anim then
        self:play_anim(anim, force)
    end
end

function rpg_entity_avatar:play_anim(anim, force)
    if self._cur_anim ~= anim and (self._cur_anim == state_anim_name.dead and not force) then
        return
    end
    if self._cur_anim2 == anim then
        return
    end
    if self._ismoving then
        anim = state_anim_name.move
    end
    self._cur_anim = anim
    if self._anim then
        self._cur_anim2 = anim
    self._anim:Play(anim)
    end
end

-- 演播技能时间轴
function rpg_entity_avatar:skill_time_line_update(ms_dt)
    if self._time_scale == 0 then
        return
    end
    
    if self.skill_timeline.playing then
        if self.skill_timeline.pass_time == 0 then
            -- PM.module_audio:play_sound(self.skill_timeline.sound_event) -- 播放技能音效
            PM.module_audio:play_sound(self.skill_timeline.sound_event)
        end
        
        local curTime = self.skill_timeline.pass_time + ms_dt * self.skill_timeline.rapid -- 累计时间
        
        if self.skill_timeline.events then
            for _, event in ipairs(self.skill_timeline.events) do
                local event_time = RPG_I2F(event[1])

                if self.skill_timeline.pass_time == 0 and event_time == 0 or
                        (self.skill_timeline.pass_time < event_time and event_time <= curTime) then
                    -- 动画节点从展示时间结束后开始播放
                    if event[2] == 'anim' then
                        -- 根据技能急速播放速度设置动画播放速度
                        self._anim.speed = self.skill_timeline.rapid;
                        
                        -- 播放技能动画
                        self:play_anim(event[3])
                    end

                    if event[2] == 'effect' then
                        -- 播放特效
                        local eff = mgr_effect.create_effect(event[3]):auto_destroy_follow(self._trans, self._height)
                        table.insert(self._effect_list, eff)
                    end

                    if event[2] == 'sound' then
                        -- 播放音效
                        PM.module_audio:play_sound(event[3])
                    end
                end
            end
        end
        
        self.skill_timeline.pass_time = curTime
        
        -- 技能时间轴结束
        if self.skill_timeline.pass_time >= self.skill_timeline.duration then
            self:reset_display_timeline()
            self:set_state(RPG_ENTITY_STATE.IDLE)
        end        
    end
end

function rpg_entity_avatar:update_dir__(moveDir)
    -- local cur_dir = self._trans.forward.normalized
    -- local nmove_dir = moveDir.normalized

    -- local angle = Vector3.Angle(cur_dir, nmove_dir)
    -- if math.abs(angle) > 0 then
    --     Logger.LogerWYY2("event___update_dir__", angle, moveDir)
    -- end
    -- if self._eid == 1002 then
    --     Logger.LogerWYY2("event___update_dir__", moveDir)
    -- end
    self._trans.forward = moveDir
end

function rpg_entity_avatar:update(ms_dt)
    if self._time_scale == 0 then
        return
    end
    
    ms_dt = self._time_scale * ms_dt
    self._time = self._time + ms_dt
    if self._relive_time then
        self:relive_post()
    end

    if self._data.state == RPG_ENTITY_STATE.SKILL then
        self:skill_time_line_update(ms_dt)
    end

    if self._data.state == RPG_ENTITY_STATE.MOVE then
        -- 移动
        local target_pos = self._data.move_target
        local tran_pos = self._trans and self._trans.position
        if self._ai_agent then
            if not self._trans then
                goto UPDATE_
            end
            local agent = self._ai_agent
            local x, y = agent.pos.x, agent.pos.z
            local target_pos = self._ins.scene:b2w_point(E.Vector3(x, 0, y)) 
            self:play_anim(state_anim_name.move, true)  -- 播放移动动画

            local dir =  agent.velocity--target_pos - self._trans.position -- self._ai_agent.velocity
            if math.abs(dir.x) > 0.0001 or math.abs(dir.z) then
                local dir2 =  self._ins.scene:b2w_rot(E.Vector3(dir.x,0,dir.z))
                self:update_dir__(E.Vector3(dir2.x,0,dir2.z))
            end
            self._trans.position = target_pos
            goto UPDATE_
        end
        if not target_pos or not tran_pos then
            goto UPDATE_
        end

        local moveDir = target_pos - tran_pos
        local distance = E.Vector3.Distance(target_pos, tran_pos)
        local displacement = self._data.speed * ms_dt
        if distance > displacement then
            moveDir = moveDir / distance
            local move_displacement = moveDir * displacement
            self._trans.position = tran_pos + move_displacement
            self._trans.forward = moveDir
            self:play_anim(state_anim_name.move)  -- 播放移动动画
        else
            self._trans.position = target_pos
            self:set_state(RPG_ENTITY_STATE.IDLE)
        end
    end

    ::UPDATE_::

    if self._ai_agent and self._trans then
        local agent = self._ai_agent
        local x, y = agent.pos.x, agent.pos.z
        local target_pos2 = self._ins.scene:b2w_point(E.Vector3(x, 0, y)) 
        self._trans.position = target_pos2
    end

    -- 清理无效特效
    --for i = 1, #self._effect_list do
    --    if self._effect_list[i] and self._effect_list[i].destroyed then
    --        self._effect_list[i] = nil
    --    end
    --end

    -- 驱动关联的粒子特效播放
    for k, effect in pairs(self._effect_list) do
        effect:update(ms_dt)
    end

    -- 状态特效Update
    for k, effect in pairs(self._state_effects) do
        effect:update(ms_dt)
    end
end

function rpg_entity_avatar:set_pos(pos)
    if not LuaHelper.IsNull(self._obj) then
        self._obj.transform.position = pos
    end
end

function rpg_entity_avatar:destroy()
    self.destroyed = true
    self:clear_effect()

    if not LuaHelper.IsNull(self._obj) then
        --http://10.23.0.3:8081/browse/SLGL2-22580 释放必杀时，退出战斗会造成显示错误
        self._anim:Play(self._cur_anim, -1, 1)
        self._anim:Update(1)
        self._obj.transform.position = VEC_OUT
        g_release_asset(self._path, self._obj)
        self._obj = nil
        self._trans = nil

        if self._replace_mat_shader then
            self._replace_mat_shader = nil
            self:replace_mat_shader(self._origin_shader)
        end

        -- 模型加载完成，实例化一个头像
        g_ui_manager:call_func("ui_rpg_head", "remove_head", self._id)
    end

    lua_tween.remove(self)
    -- 初始化变量，如果用回收池管理可以放回回收池

    if self.move_delay_cor ~= nil then
        coroutine.stop(self.move_delay_cor)
        self.move_delay_cor = nil
    end
    
    if self.dead_delay_cor ~= nil then
        coroutine.stop(self.dead_delay_cor)
        self.dead_delay_cor = nil
    end
end

-- 清理特效
function rpg_entity_avatar:clear_effect()
    self:set_ignore_camera_mask(false)
    self:stop_anger_effect()
    -- 清理状态特效
    for _, state_effect in pairs(self._state_effects) do
        state_effect:destroy()
    end
    table.clear(self._state_effects)

    -- 清理状态特效
    for _, effect in pairs(self._effect_list) do
        effect:destroy()
    end
    table.clear(self._effect_list)
end

--------- 特效播放 Begin ---------------
function rpg_entity_avatar:play_anger_effect()
    local eff = self:play_effect_on_body("ef_zd_nqbf") -- 怒气技能特效
    eff:set_auto_destroy(false)
    self._anger_eff = eff
end

function rpg_entity_avatar:stop_anger_effect()
    if self._anger_eff and self._anger_eff.obj then
        -----poolmanager 不会将特效deactiv
        self._anger_eff.obj:SetActive(false)
        self._anger_eff:destroy()
        self._anger_eff = nil
    end
end

-- 在身上播放一个特效
function rpg_entity_avatar:play_effect_on_body(effect, dir)
    if not effect then
        return
    end

    -- 播放特效
    local eff = mgr_effect.create_effect(effect):play_hit_effect(self._trans, self._height, self._body_obj, dir)
    -- table.insert(self._effect_list, eff)
    return eff
end

-- 在目标位置播放一个特效
function rpg_entity_avatar:play_effect(effect, target_pos)
    if not effect then
        return
    end

    -- 播放特效
    local eff = mgr_effect.create_effect(effect):play(target_pos, self._trans.forward)
    table.insert(self._effect_list, eff)
end

function rpg_entity_avatar:set_entity_proxy(entity_proxy)
    self._entity_proxy = entity_proxy
end

-- 在身上播放Buff特效
function rpg_entity_avatar:play_buff_effect(effect, group_id)
    if not effect then
        return
    end

    -- 播放特效
    local eff = mgr_effect.create_effect(effect):follow(self._trans, self._height)
    eff.gid = group_id
    eff.ref_number = 1 

    table.insert(self._effect_list, eff)
end

-- 播放连线型的特效
-- start_obj 起始对象Gameobject,buff的发起者
-- end_obj 结束对象Gameobject,buff的接收者
function rpg_entity_avatar:play_line_effect(effect, group_id, start_obj, end_obj, start_offset_Y, end_offset_y)
    if not effect then
        return
    end

    -- 播放特效
    local eff = mgr_effect.create_effect(effect):line(start_obj, end_obj, start_offset_Y, end_offset_y)
    eff.gid = group_id
    eff.ref_number = 1

    table.insert(self._effect_list, eff)    
end

-- 移除身上的Buff特效
function rpg_entity_avatar:remove_buff_effect(group_id)
    for index, effect in pairs(self._effect_list) do
        if effect.gid == group_id then
            if effect.ref_number == 1 then
                effect:destroy()
                self._effect_list[index] = nil
            elseif effect.ref_number then
                effect.ref_number = effect.ref_number - 1
            end
        end
    end
end

-- 检查身上是否已经挂载了状态特效
function rpg_entity_avatar:get_buff_effect(group_id)
    for _, effect in pairs(self._effect_list) do
        if effect.gid == group_id then
            return effect            
        end
    end
    
    return nil
end

------------ 特效播放 End---------------

--------- 客户端模拟 Begin ---------------
-- 播放一段入场动画
function rpg_entity_avatar:play_entry_anim(during)
    local local_team_pos = self:get_team_pos() -- 布阵位置
    local team_pos = self._ins.scene:b2w_point(E.Vector3(local_team_pos[1], 0, local_team_pos[2]))   -- 布阵世界坐标系位置

    if not self._trans then
        return
    end
    
    -- 记录当前位置
    local born_pos = self._trans.position
    -- 移动偏移量
    local move_offset = born_pos - team_pos

    -- 朝向移动方向
    local distance = E.Vector3.Distance(born_pos, team_pos)
    self._trans.forward = move_offset / distance

    -- 播放移动动画
    self:set_state(RPG_ENTITY_STATE.MOVE)

    -- 开场移动
    lua_tween.add(self, during,
            function(prg)
                self._trans.position = Vector3(born_pos.x - (move_offset.x * (1 - prg)), born_pos.y, born_pos.z - (move_offset.z * (1 - prg)))
            end,
            { ease = Ease.linearTween, complete_func = function()
                self:set_state(RPG_ENTITY_STATE.IDLE)
            end })
end

-- 远征模拟战斗，攻击方播放入场动画
function rpg_entity_avatar:play_entry_anim_simulation_battle(during)
    -- 攻击方原地播放动画
    if self._camp == 0 then
        self._trans.forward = self._born_dir
        --self:play_anim(state_anim_name.move)
        --
        --self.move_delay_cor = coroutine.start(
        --        function()
        --            coroutine.wait_sec(during)
                    self:play_anim(state_anim_name.idle)
        --        end
        --)
        return
    else
        -- 防守方从屏幕外移动到战斗位置
        self._trans.forward = self._born_dir
        
        -- 记录当前位置
        local born_pos = self._born_pos    -- 布阵位置

        -- 根据自己的朝向计算一个移动偏移量
        local move_offset = self._trans.forward * 15

        -- 播放移动动画
        self:play_anim(state_anim_name.move)

        -- 开场移动
        lua_tween.add(self, during,
                function(prg)
                    self._trans.position = Vector3(born_pos.x - (move_offset.x * (1 - prg)), born_pos.y, born_pos.z - (move_offset.z * (1 - prg)))
                end,
                { ease = Ease.linearTween, complete_func = function()
                    self:play_anim(state_anim_name.idle)
                end })
    end
end 

-- 回到自己出生点位置
function rpg_entity_avatar:return_to_born_pos(during)
    local local_born_pos = self._ins.scene._map_prop.BornPos[self._pos_index]    -- 战斗位置
    local born_pos = self._ins.scene:b2w_point(E.Vector3(local_born_pos[1], 0, local_born_pos[2]))   -- 战斗世界坐标系位置

    -- 记录当前位置
    local cur_pos = self._trans.position
    
    -- 移动偏移量
    local move_offset = born_pos - cur_pos

    -- 朝向移动方向
    --local distance = E.Vector3.Distance(cur_pos, born_pos)
    self._trans.forward = self._born_dir

    -- 播放移动动画
    self:play_anim(state_anim_name.move)

    self._ismoving = true
    --Logger.LogerWYY2("回到出生点位置__1")
    -- 开场移动
    lua_tween.add(self, during,
            function(prg)
                self._trans.position = Vector3(born_pos.x - (move_offset.x * (1 - prg)), born_pos.y, born_pos.z - (move_offset.z * (1 - prg)))
            end,
            { ease = Ease.linearTween,complete_func = function()
                self._ismoving = false
                --Logger.LogerWYY2("回到出生点位置__2")
            end })
end

--------- 客户端模拟 End---------------

--------- 子弹特效播放逻辑处理 Begin ---------


function rpg_entity_avatar:set_battle_instance(ins)
    self._ins = ins
    self._skill_cds = {}
end

function rpg_entity_avatar:set_skill_cd(skill_id, cd)
    self._skill_cds[skill_id] = cd + self._ins:get_btime()
end

function rpg_entity_avatar:get_skill_cd(skill_id)
    local cd = self._skill_cds[skill_id] or 0
    return (cd) - self._ins:get_btime()
end

rpg_entity_avatar.send_bullet_handle = {}

-- 发射子弹
function rpg_entity_avatar:send_bullet(event)
    local prop_bullet = resmng.prop_rpg_battle_effectById(event.pid);
    local sub_type = prop_bullet.EffectParam[1]
    if not rpg_entity_avatar.send_bullet_handle[sub_type] then
        Logger.LogError("未处理的子弹类型" .. sub_type)
        return
    end

    rpg_entity_avatar.send_bullet_handle[sub_type](self, prop_bullet, event);
end

-- 删除子弹
function rpg_entity_avatar:remove_bullet(oid)
    for index, effect in pairs(self._effect_list) do
        if effect.oid == oid then
            effect:destroy()
            self._effect_list[index] = nil
            break
        end
    end
end

-- 指向性子弹 1
rpg_entity_avatar.send_bullet_handle[RPG_BULLET_TYPE.TARGET] = function(self, prop_bullet, event)
    local effect_asset = prop_bullet.VFXEffect
    if not effect_asset then
        return
    end

    local offset_y = self._height / 2
    
    local speed = RPG_I2F(prop_bullet.EffectParam[2][1])  or 0
     
    local target_pos = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(event.tpos_x), offset_y, RPG_I2F(event.tpos_y)))
    
    local eff

    ---------------------子弹速度为0 的子弹不跟着BULLET_END 一起销毁---------------------
    if speed == 0 then
        -- local dur = RPG_I2F(event.time)
        eff = mgr_effect.create_effect(effect_asset):play(target_pos + E.Vector3(0,- offset_y, 0),nil,self._height)
    else
        local start_pos = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(event.spos_x), offset_y, RPG_I2F(event.spos_y)))
        eff = mgr_effect.create_effect(effect_asset):fly(start_pos, target_pos, speed, 0)
        table.insert(self._effect_list, eff)
    end

    eff.oid = event.oid

end 

-- 直线子弹 2
rpg_entity_avatar.send_bullet_handle[RPG_BULLET_TYPE.LINE] = rpg_entity_avatar.send_bullet_handle[RPG_BULLET_TYPE.TARGET]

-- 抛物线子弹 3
rpg_entity_avatar.send_bullet_handle[RPG_BULLET_TYPE.PARABOLA] = function(self, prop_bullet, event)
    local effect_asset = prop_bullet.VFXEffect
    if not effect_asset then
        return
    end
    
    local offset_y = self._height / 2
    
    local speed = RPG_I2F(prop_bullet.EffectParam[2][1])
    local height = RPG_I2F(prop_bullet.EffectParam[2][2])
    local start_pos = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(event.spos_x), offset_y, RPG_I2F(event.spos_y)))
    local target_pos = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(event.tpos_x), offset_y, RPG_I2F(event.tpos_y)))

    local eff = mgr_effect.create_effect(effect_asset):fly(start_pos, target_pos, speed, height)
    eff.oid = event.oid
    table.insert(self._effect_list, eff)
end

-- 链式子弹 4
rpg_entity_avatar.send_bullet_handle[RPG_BULLET_TYPE.CHAIN] = function(self, prop_bullet, event)
    local effect_asset = prop_bullet.VFXEffect
    if not effect_asset then
        return
    end

    local offset_y = self._height / 2
    
    local speed = RPG_I2F(prop_bullet.EffectParam[2][1])    
    local start_pos = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(event.spos_x), offset_y, RPG_I2F(event.spos_y)))
    local target_pos = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(event.tpos_x), offset_y, RPG_I2F(event.tpos_y)))
        
    local bullet_effect = nil
    for _, effect in pairs(self._effect_list) do
        if effect.oid == event.oid then
            bullet_effect = effect
            break
        end
    end

    if not bullet_effect then
        local eff = mgr_effect.create_effect(effect_asset):set_auto_destroy(false):fly(start_pos, target_pos, speed, 0)
        eff.oid = event.oid
        table.insert(self._effect_list, eff)
    else
        bullet_effect:fly(start_pos, target_pos, speed, 0)
    end
end

--------- 子弹特效播放逻辑处理 End ---------