
-- local rpg_battle_model = require("models.rpg_battle_model")

local callback_combiner = rpg_require("callback_combiner")
local table_insert = table.insert
local table_remove = table.remove
local pairs = pairs
local mgr_effect = rpg_require("mgr_effect")

RPG_PLAY_MODE = {
    expedition_simulation = 1, -- 关卡主界面模拟战斗
    expedition = 2, -- 关卡战斗
}

-- 场景中所有的实体对象 
-- key 实体对象id value 
-- value 实体对象客户端表现对象
---@type table<number, rpg_hero_avatar>

local battle_player_mod = class2("battle_player_mod", T.mod_base, function(self, battle_instance, play_mode)
    T.mod_base._ctor(self, battle_instance)

    self.is_play_entry_anim = false -- 是否播放入场动画
    self.is_release_rage_skill = false -- 是否释放大招技能
    self.ety_avatar = {}
    self.ety_dead_avatar = {}
    self.play_mode = play_mode -- 战斗播放模式 RPG_PLAY_MODE
    self.rcur_time = 0 -- 战斗时间，从实例化开始，每帧递增
    self.cur_time = 0 -- 战斗时间，从实例化开始，每帧递增
    self.play_time_line = {} -- 客户端战斗演播时间轴 key时间 value演播事件列表, key的值一定是一个递增的数字    
    self.ety_height = {}
    self.event_list = {} -- 事件列表
    self.event_index = 1 -- 事件索引
    local player_data = battle_instance._init_data._player_data
    if player_data and player_data.pre_troop_type == resmng.PRE_EDIT_TROOP_TYPE.RPG_ARENA_ATK_TYPE then
        g_wait_show_pvp_vs = true
    else
        g_wait_show_pvp_vs = false
    end

    if play_mode ~= RPG_PLAY_MODE.expedition_simulation then
        -- g_ui_manager:push_item("ui_rpg_battle_main", player_data)
        g_ui_manager:push_window("ui_rpg_battle_main", player_data)
    end
end)

local use_time_line = true -- 是否使用时间轴播放战斗 用于调试

-- 事件注册
function battle_player_mod:register_listener()
    self._on_battle_data_init_event = function(param)
        --Logger.LogFormat("[RPG] 演播消息 Id:%s 时间:%s 真实时间:%s 内容：%s", get_rpg_event_type_name(param.id), param.event_time, param.rtime, serpent.block(param))
        self:on_battle_data_init_event(param)
    end

    self._on_receive_event = function(event)
        if self._ins._skip then
            return
        end

        if use_time_line then
            self:add_time_line_key_data(event.rtime, event)
        else
            local event_handle = battle_player_mod.event_handle[event.id]
            if event_handle then
                event_handle(self, event)
            end
        end

        if not battle_player_mod.event_handle[event.id] then
            --Logger.LogError("[RPG] 未接管的演播消息",RPG_EVENT_TYPE_STR[event.id] or "", "on_event_" .. (event.eid or "") .. " " .. RPG_EVENT_TYPE2[event.id], event)    
        end
        
        --Logger.LogerWYY2("[RPG] 演播消息",RPG_EVENT_TYPE_STR[event.id] or "", "on_event_" .. (event.eid or "") .. " " .. RPG_EVENT_TYPE2[event.id], event)
    end

    for _, event_type in pairs(RPG_EVENT_TYPE) do
        local event_handle = self._on_receive_event

        -- 初始化消息单独处理
        if event_type == RPG_EVENT_TYPE.BATTLE_DATA_INIT then
            event_handle = self._on_battle_data_init_event
        end

        self._ins:add_event_listener(event_type, event_handle)
    end  
end

-- 取消事件注册
function battle_player_mod:remove_listener()

    for _, event_type in pairs(RPG_EVENT_TYPE) do
        local event_handle = self._on_receive_event

        -- 初始化消息单独处理
        if event_type == RPG_EVENT_TYPE.BATTLE_DATA_INIT then
            event_handle = self._on_battle_data_init_event
        end

        self._ins:remove_event_listener(event_type, event_handle)
    end
end

-- 根据self.battle_instance中的数据初始化战场
function battle_player_mod:init()

end

-- 每帧检查
function battle_player_mod:init_finish()
    return self._init_completed --and not g_wait_show_pvp_vs
end

local entry_during = 0.8
local entry_anim_cor = nil

-- 战斗初始化事件
function battle_player_mod:on_battle_data_init_event(param)
    -- .战斗数据记录
    local res_combiner = callback_combiner.gen_combiner()    
    res_combiner.on_completed = function()
        -- 表现模块初始化必须要等战斗模块初始化完成，并发出初始化事件之后才能算模块初始化完成
        -- self._init_completed = true
        self.is_play_entry_anim = true
        
        if self.play_mode == RPG_PLAY_MODE.expedition_simulation then
            -- 关卡模拟入场方式
            for _, avatar in pairs(self.ety_avatar) do
                avatar:play_entry_anim_simulation_battle(entry_during)
            end
        else
            -- 执行开场动画播放
            for _, avatar in pairs(self.ety_avatar) do
                avatar:play_entry_anim(entry_during)
            end
        end
        -- 3 秒之后开始战斗
        entry_anim_cor = coroutine.start(
                function()
                    coroutine.wait_sec(entry_during)
                    self._init_completed = true
                    self.is_play_entry_anim = false
                end)
    end
    battle_player_mod.pet_avatar = {}
    -- .ety加载
    for i, team in pairs(param.team_list) do
        local tid = i
        for _, hero in pairs(team.heros) do

            local pos = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(hero._x), 0, RPG_I2F(hero._y)))
            local dir = self._ins.scene:b2w_euler(E.Vector3(hero._dir_x, 0, hero._dir_y))   -- 出生点方向

            local hero_avatar
            if hero.is_boss then
                hero_avatar = T.rpg_boss_avatar(hero._eid, hero._hero_id, hero._lv, hero._fpos, pos, dir,hero)
            else
                hero_avatar = T.rpg_hero_avatar(hero._eid, hero._hero_id, hero._lv, hero._fpos, pos, dir)
            end
            hero_avatar:set_battle_instance(self._ins)
            local load_head = true
            if self.play_mode == RPG_PLAY_MODE.expedition_simulation and hero._fpos < 6 then
                load_head = false
            end
            
            local res_load_completed = res_combiner:gen_callBack()
            hero_avatar:load_res(function()
                res_load_completed(res_load_completed)
                hero_avatar:set_attr(RPG_I2F(hero.RPG_Hp), RPG_I2F(hero.RPG_HpMax), RPG_I2F(hero.RPG_Anger), RPG_I2F(hero.RPG_AngerMax), true)

                -- 如果当前战斗附加了debug模块，则将实例化的avatar注册到debug模块中，方便调试
                if self._ins._debug_view_mod ~= nil then
                    self._ins._debug_view_mod:register_debug_target(hero_avatar._obj, hero_avatar._id, tid == 1)
                end                
            end , load_head,false)
            
            self.ety_avatar[hero._eid] = hero_avatar
        end
        battle_player_mod.pet_avatar[i] = nil
        if team.pet then
            local pet = team.pet
            local pos = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(pet._x), 0, RPG_I2F(pet._y)))
            local dir = self._ins.scene:b2w_euler(E.Vector3(pet._dir_x, 0, pet._dir_y))   -- 出生点方向
            local camp = i-1
            local pet_avatar = T.rpg_pet_avatar(pet._eid, camp, pet._pet_id, pet._lv, pos, dir)
            pet_avatar:set_battle_instance(self._ins)
            battle_player_mod.pet_avatar[i] = pet_avatar
            local res_load_completed = res_combiner:gen_callBack()
            pet_avatar:load_res(function()
                res_load_completed(res_load_completed)
            end)
            self.ety_avatar[pet._eid] = pet_avatar
        end
    end

    if self.play_mode == RPG_PLAY_MODE.expedition then
        g_ui_manager:call_func("ui_rpg_battle_main", "gen_hero_list", param.team_list[1])
        g_ui_manager:call_func("ui_rpg_battle_main", "show_race_buff", param.team_list)
        g_ui_manager:call_func("ui_rpg_battle_main", "gen_pet", battle_player_mod.pet_avatar[1])
    end
end

function battle_player_mod:start()
    -- .关闭Loading界面
    -- .播放战场音效
    -- .播放开场动画
end

-- 添加演播时间轴数据
function battle_player_mod:add_time_line_key_data(time, data)
    if not time then
        Logger.LogError("add_time_line_key_data time is nil ")
        return
    end

    table_insert(self.play_time_line, data)
end

function battle_player_mod:return_to_born_pos(entry_during)
    self.is_play_entry_anim = true
    
    for _, avatar in pairs(self.ety_avatar) do
        avatar:return_to_born_pos(entry_during)
    end
end

function battle_player_mod:play_entry_anim_simulation_battle(entry_during)
    for _, avatar in pairs(self.ety_avatar) do
        avatar:play_entry_anim_simulation_battle(entry_during)
    end
end

function battle_player_mod:get_avatar_by_id(id)
    return self.ety_avatar[id]
end

-- function battle_player_mod:pause()
-- end

-- function battle_player_mod:resume()
-- end
-- local Profiler = CS.UnityEngine.Profiling.Profiler

--有 update 会自己调用
function battle_player_mod:update(ms_dt)
    if self._ins._skip then
        return
    end

    for _, avatar in pairs(self.ety_avatar) do
        avatar:update(RPG_I2F(ms_dt))
    end

    if self.is_release_rage_skill then
        self:skill_pause_end_check()
    end

    self.cur_time = self.cur_time + ms_dt  -- 每帧更新当前演播时间

    local play_time_line = self.play_time_line
    for i = 1, #play_time_line do
        local event = play_time_line[i]
        if event and event.rtime <= self.cur_time then
            table_remove(play_time_line, i) --移除

            local event_handle = battle_player_mod.event_handle[event.id]
            if event_handle then
                -- Profiler.BeginSample("update____" .. RPG_EVENT_TYPE2[event.id])
                event_handle(self, event)
                -- Profiler.EndSample()
            end
        else
            break
        end
    end
end

function battle_player_mod:stop()
    if self._edoor then
        self._edoor:destroy()
        self._edoor = nil
    end
    if self._fade_in then
        self._fade_in = false
        -- camera_utils.mask_fade_out(0.1)  -- 相机遮罩淡出
    end
    for eid, avatar in pairs(self.ety_avatar) do
        avatar:set_ignore_camera_mask(false)
        avatar:destroy()
        self.ety_avatar[eid] = nil
    end

    battle_player_mod.pet_avatar = nil
    
    for eid, avatar in pairs(self.ety_dead_avatar) do
        avatar:destroy()
        self.ety_dead_avatar[eid] = nil
    end

    if nil ~= entry_anim_cor then
        coroutine.stop(entry_anim_cor)
    end

    g_ui_manager:call_func("ui_rpg_battle_txt", "clear_txt")
end

-- 清空环境
function battle_player_mod:clear_env()
    camera_utils.reset_mask()

    -- 清空avatar上面的特效
    for _, avatar in pairs(self.ety_avatar) do
        avatar:clear_effect()
    end
    
    for _, avatar in pairs(self.ety_dead_avatar) do
        avatar:clear_effect()
    end
end

-- 怒气技能播放开始
function battle_player_mod:skill_pause_start(caster_eid, target_eid)
    -- 技能释放期间，其他非怒气技能角色暂停动画
    for _, ins in pairs(self.ety_avatar) do
        if not ins:is_pause_skill() then
            ins:set_time_scale(0)
        end
    end

    if self._ins._battle_player_mod.is_release_rage_skill == false then
        -- camera_utils.mask_fade_in(0.1)  -- 相机遮罩淡入
        self._fade_in = true
    end
    
    local avatar = self.ety_avatar[caster_eid]
    if avatar ~= nil then
        avatar:set_time_scale(1)
        avatar:set_ignore_camera_mask(true) -- 释放技能者，添加遮罩忽略
        avatar:play_anger_effect()
        post_event(DIS_TYPE.RPG_BATTLE_ANGER_MASK_SHOW, avatar._obj.transform.position)
    end

    local target_avatar = self.ety_avatar[target_eid]
    if target_avatar ~= nil then
        target_avatar:set_ignore_camera_mask(true) -- 技能目标，添加遮罩忽略     
    end

    -- 调用 战斗界面释放技能表现
    -- if not g_close_anger_ui_eff then
        g_ui_manager:call_func("ui_rpg_battle_main", "hero_cast_anger_skill", caster_eid)
    -- end
    self._ins._battle_player_mod.is_release_rage_skill = true
    PM.module_audio:post_event("Pause_RPG_Skills")
end

-- 怒气技能播放结束
function battle_player_mod:skill_pause_end_check()
    local skill_pause_end = true
    -- 检查是否所有角色都释放完毕
    for _, ins in pairs(self.ety_avatar) do
        if ins:is_pause_skill() then
            if not ins:is_pause_time_over() then
                skill_pause_end = false
                break
            else
                ins:stop_anger_effect()
            end
        end
    end

    if not skill_pause_end then
        return
    end

    post_event(DIS_TYPE.RPG_BATTLE_ANGER_MASK_HIDE)

    
    -- 大招释放完成恢复
    for _, ins in pairs(self.ety_avatar) do
        ins:set_time_scale(1)
    end

    self._fade_in = false
    -- camera_utils.mask_fade_out(0.1)  -- 相机遮罩淡出
    coroutine.start(
            function()
                coroutine.wait_sec(0.1)
                for _, ins in pairs(self.ety_avatar) do
                    ins:set_ignore_camera_mask(false)
                end
            end)

    self._ins._battle_player_mod.is_release_rage_skill = false
    PM.module_audio:post_event("Resume_RPG_Skills")
end

battle_player_mod.event_handle = {} -- 事件处理

-- 战场事件
battle_player_mod.event_handle[RPG_EVENT_TYPE.BATTLE_START] = function(self, event)
    -- 显示战斗开始特效    
    --Logger.Log(" RPG_EVENT_TYPE.BATTLE_START")
end

-- 战斗结束
battle_player_mod.event_handle[RPG_EVENT_TYPE.BATTLE_END] = function(self, event)
    -- 胜利方播放胜利动画
    local win_team_id = event.win
    local win_camp = win_team_id - 1

    -- local state = RPG_ENTITY_STATE.WIN
    if self.play_mode == RPG_PLAY_MODE.expedition_simulation then
        -- state = RPG_ENTITY_STATE.IDLE
        return
    end
    for _ , avatar in pairs(self.ety_avatar) do
        if avatar._camp == win_camp then
            avatar:set_state(RPG_ENTITY_STATE.WIN)
        end
    end
end

battle_player_mod.born_handle = battle_player_mod.born_handle or {}
battle_player_mod.born_handle[RPG_ETY_TYPE.MDOOR] = function(self, event)
    if self._edoor then
        return
    end
    local pos = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(event.x), 0, RPG_I2F(event.y)))
    local dir = self._ins.scene:b2w_euler(E.Vector3(event.dir_x, 0, event.dir_y))   -- 出生点方向
    local eff = mgr_effect.create_effect("ef_rpg_sc_ksm"):set_auto_destroy(false):scale(E.Vector3(RPG_I2F(event.width),1,1)):play(pos, dir)
    self._edoor = eff
end
battle_player_mod.event_handle[RPG_EVENT_TYPE.CUSTOM] = function(self, event)
    if event.door then
        if not self._edoor then
            return
        end
        if event.type == 1 then
            self._edoor:scale(E.Vector3(RPG_I2F(event.width),1,1)) 
        end
    end
end
-- 英雄出生/新的召唤物
battle_player_mod.event_handle[RPG_EVENT_TYPE.BORN] = function(self, event)
    local born_handle = battle_player_mod.born_handle[event.ety_type]
    if born_handle then
        born_handle(self, event)
        return
    end
    -- 加载资源，生成实例化场景对象    
    local pre_avatar = self.ety_dead_avatar[event.eid]
    if pre_avatar then   ----------复活
        self.ety_avatar[event.eid] = pre_avatar
        pre_avatar:async_props(event.attr)
        pre_avatar:relive()
        self.ety_dead_avatar[event.eid] = nil
    end
    if self.ety_avatar[event.eid] then
        return
    end
    local pos = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(event.x), 0, RPG_I2F(event.y)))
    local dir = self._ins.scene:b2w_euler(E.Vector3(event.dir_x, 0, event.dir_y))   -- 出生点方向
    local hero_avatar = T.rpg_hero_avatar(event.eid, event.hero_id, event.lv, event.fpos, pos, dir)
    hero_avatar:set_battle_instance(self._ins)
    hero_avatar:load_res(function()
        hero_avatar:set_attr(RPG_I2F(event.attr.RPG_Hp), RPG_I2F(event.attr.RPG_HpMax), RPG_I2F(event.attr.RPG_Anger), RPG_I2F(event.attr.RPG_AngerMax), true)
        -- 如果当前战斗附加了debug模块，则将实例化的avatar注册到debug模块中，方便调试
        if self._ins._debug_view_mod ~= nil then
            self._ins._debug_view_mod:register_debug_target(hero_avatar._obj, hero_avatar._id, event.tid == 1)
        end
    end, true)
    self.ety_avatar[event.eid] = hero_avatar
    self.ety_height[event.eid] = hero_avatar._height
end
battle_player_mod.event_handle[RPG_EVENT_TYPE.TD_SELECT_EVENT_START] = function(self, event)
    g_ui_manager:call_func("ui_rpg_battle_main", "select_buff", event.effs)
end

-- 技能开始
battle_player_mod.event_handle[RPG_EVENT_TYPE.SKILL_START] = function(self, event)
    local avatar = self.ety_avatar[event.eid]
    if avatar == nil then
        return
    end

    avatar:set_skill_cd(event.skill_id, event.cd)

    -- 技能释放时候，英雄需要转向
    if event.dir_x ~= nil and event.dir_y ~= nil then
        local forward = self._ins.scene:b2w_euler(E.Vector3(event.dir_x, 0, event.dir_y))
        avatar:update_forward(forward.x, forward.z)
    end

    local prop_skill = resmng.prop_rpg_battle_skill[event.skill_id]
    if prop_skill and prop_skill.SkillPause ~= nil and prop_skill.SkillPause > 0 then
        --if self.play_mode == RPG_PLAY_MODE.expedition_simulation then
        --    avatar:cast_anger_skill(event.skill_id, true)
        --elseif self.play_mode == RPG_PLAY_MODE.expedition then
            -- 关卡战斗，攻击方放技能怒气技能，黑屏播放
            if avatar._camp == 0 then
                avatar:cast_skill(event.skill_id, event.speed, true)
                battle_player_mod.skill_pause_start(self, event.eid, event.target)
            else
                avatar:cast_skill(event.skill_id, event.speed, false)
            end
        --end
    else
        avatar:cast_skill(event.skill_id, event.speed, false)
    end
end

-- 技能结束
battle_player_mod.event_handle[RPG_EVENT_TYPE.SKILL_END] = function(self, event)
    -- 技能释放完毕时候，同步一次方向
    local avatar = self.ety_avatar[event.eid]
    if avatar ~= nil then
        if event.dir_x ~= nil and event.dir_y ~= nil then
            local forward = self._ins.scene:b2w_euler(E.Vector3(event.dir_x, 0, event.dir_y))
            avatar:update_forward(forward.x, forward.z)
        end

        avatar:end_skill(event.skill_id)
    end
end

-- 伤害消息
battle_player_mod.event_handle[RPG_EVENT_TYPE.DAMAGE] = function(self, event)
    --Logger.LogFormat("[RPG] 演播消息 Id:%s damage %s", event.target, event.damage)

    local avatar = self.ety_avatar[event.target]
    if avatar == nil then
        return
    end

    local damage = event.shield_damage or event.damage
    ------- 伤害扣血 -------
    avatar:hurt(damage)

    if avatar._trans == nil then
        return
    end

    ------- 战斗伤害飘字 -------
    local battle_text_type = RPG_BATTLE_TEXT_TYPE.HP_NORMAL
    local text = tostring(math.ceil(RPG_I2F(damage)))
    
    if damage > 0 then
        text = "+" .. text
    end
    
    if bit.contain(event.dmg_bit, RPG_DAMAGE_TYPE.DAMAGE) then
        battle_text_type = RPG_BATTLE_TEXT_TYPE.HP_NORMAL-- 伤害    
    end    
    if bit.contain(event.dmg_bit, RPG_DAMAGE_TYPE.CRIT) then
        battle_text_type = RPG_BATTLE_TEXT_TYPE.HP_CRIT-- 暴击
    elseif bit.contain(event.dmg_bit, RPG_DAMAGE_TYPE.BLOCK) then
        battle_text_type = RPG_BATTLE_TEXT_TYPE.HP_BLOCK-- 格挡        
    elseif bit.contain(event.dmg_bit, RPG_DAMAGE_TYPE.HEAL) then
        battle_text_type = RPG_BATTLE_TEXT_TYPE.HP_RECOVER-- 治疗
    elseif bit.contain(event.dmg_bit, RPG_DAMAGE_TYPE.MISS) then
    end
 
    local show_txt = true
    if battle_text_type == RPG_BATTLE_TEXT_TYPE.HP_RECOVER and self.play_mode == RPG_PLAY_MODE.expedition_simulation then
        show_txt = false
    end

    if show_txt then
        g_ui_manager:call_func("ui_rpg_battle_txt", "rpg_show_txt", battle_text_type, avatar._trans.position.x, avatar._trans.position.y + avatar._height / 2, avatar._trans.position.z, text)
    end
    if event.steal then
        local caster_avatar = self.ety_avatar[event.eid]
        if caster_avatar then
            local steal_txt = "+" .. math.ceil(RPG_I2F(event.steal))
            g_ui_manager:call_func("ui_rpg_battle_txt", "rpg_show_txt", RPG_BATTLE_TEXT_TYPE.HP_RECOVER, caster_avatar._trans.position.x, caster_avatar._trans.position.y + caster_avatar._height / 2, caster_avatar._trans.position.z, steal_txt)
        end
    end

    --http://10.23.0.3:8081/browse/SLGL2-22690 【RPG战斗】分摊型技能，调整分摊比例未生效，同时需移除分担时的受击特效
    if bit.contain(event.dmg_bit, RPG_DAMAGE_TYPE.SHARE) then
        return
    end

    local eff_cfg = resmng.prop_rpg_battle_effect[event.eff_id]
    if eff_cfg ~= nil then
        ------- 受击特效 -------
        if eff_cfg.VFXHit ~= nil then
            local attack_avatar = self.ety_avatar[event.eid]
            local attack_dir = attack_avatar and attack_avatar._trans and attack_avatar._trans.forward
            avatar:play_effect_on_body(eff_cfg.VFXHit, attack_dir and -attack_dir)
        end

        ------- 受击音效 -------        
        if eff_cfg.SoundHit ~= nil then
            PM.module_audio:play_sound(eff_cfg.SoundHit)
        end
    end
end

-- 怒气回复
battle_player_mod.event_handle[RPG_EVENT_TYPE.SKILL_ANGER] = function(self, event)
    local avatar = self.ety_avatar[event.eid]
    if not avatar then
        return
    end

    -- 怒气飘字
    g_ui_manager:call_func("ui_rpg_battle_txt", "rpg_show_txt", RPG_BATTLE_TEXT_TYPE.ANGER_ADD, avatar._trans.position.x, avatar._trans.position.y + avatar._height / 2, avatar._trans.position.z, "+" .. math.ceil(RPG_I2F(event.anger)))
end

-- Buff
battle_player_mod.event_handle[RPG_EVENT_TYPE.BUFF] = function(self, event)
    -- 显示buff特效
    local avatar = self.ety_avatar[event.owner]
    if not avatar then
        return
    end

    -- 判断是否是强制位移的Buff
    if event.force_move == true then
        -- 如果是强制位移，则修改状态，执行强制位移，播放动画
        local target_point = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(event.ex), 0, RPG_I2F(event.ey)))
        avatar:force_move(target_point, RPG_I2F(event.et - event.event_time))
    end

    -- 逻辑buff，不做其他表现处理
    -- if event.buff < RPG_ETY_INNER_BUFF.MAX_ID then
    --     return
    -- end

    local buff_cfg = resmng.prop_rpg_battle_buff[event.buff]
    local group_cfg = resmng.prop_rpg_battle_group[buff_cfg.Group]

    if not group_cfg then
        return
    end

    local buff_effect = avatar:get_buff_effect(buff_cfg.Group)

    -- 身上已经有状态，则不需要播放特效
    if buff_effect ~= nil and buff_effect.ref_number then
        buff_effect.ref_number = buff_effect.ref_number + 1 -- 已经存在则累计引用次数
    else
        local effectRes = group_cfg.VFXGroup

        -- buff配置表单独配了，那么显示优先级更高
        if buff_cfg.VFXBuff ~= nil then
            effectRes = buff_cfg.VFXBuff
        end

        if effectRes ~= nil then
            if event.share_damage == true then
                local start_avatar = self.ety_avatar[event.caster]

                if start_avatar == nil then
                    start_avatar = avatar
                end

                local start_offset_Y = start_avatar._height / 2
                local end_offset_y = avatar._height / 2

                if type(effectRes) == "table" then
                    avatar:play_line_effect(effectRes[1], buff_cfg.Group, start_avatar._obj, avatar._obj, start_offset_Y, end_offset_y)
                    avatar:play_buff_effect(effectRes[2], buff_cfg.Group)
                else
                    avatar:play_line_effect(effectRes, buff_cfg.Group, start_avatar._obj, avatar._obj, start_offset_Y, end_offset_y)
                end
            else
                avatar:play_buff_effect(effectRes, buff_cfg.Group)
            end
        end

        local state_type = RPG_BATTLE_TEXT_TYPE.TEXT_STATE_1
        if group_cfg.Type == 0 or group_cfg.Type == 1 then
            state_type = RPG_BATTLE_TEXT_TYPE.TEXT_STATE_2
        end
        
        -- 状态飘字
        if group_cfg.Text then
            g_ui_manager:call_func("ui_rpg_battle_txt", "rpg_show_txt", state_type, avatar._trans.position.x, avatar._trans.position.y + avatar._height, avatar._trans.position.z, group_cfg.Text)
        end
    end
end

battle_player_mod.event_handle[RPG_EVENT_TYPE.BUFF_END] = function(self, event)
    local avatar = self.ety_avatar[event.owner]
    if not avatar then
        return
    end

    -- 逻辑buff，不做其他表现处理
    -- if event.buff < RPG_ETY_INNER_BUFF.MAX_ID then
    --     return
    -- end

    local buff_cfg = resmng.prop_rpg_battle_buff[event.buff]

    -- 根据gid移除特效
    avatar:remove_buff_effect(buff_cfg.Group)
end

-- 技能特效播放
--      1.在目标位置释放aoe技能会触发这个消息
battle_player_mod.event_handle[RPG_EVENT_TYPE.EFFECT] = function(self, event)
    local avatar = self.ety_avatar[event.eid]
    if avatar == nil then
        return
    end

    local eff_cfg = resmng.prop_rpg_battle_effect[event.eff_id]
    if eff_cfg.VFXEffect ~= nil then
        local target_point = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(event.x), 0, RPG_I2F(event.y)))
        avatar:play_effect(eff_cfg.VFXEffect, target_point)
    end
end

--battle_player_mod.event_handle[RPG_EVENT_TYPE.INTERRUPT] = function(self, event)
--
--end

battle_player_mod.event_handle[RPG_EVENT_TYPE.MOVE] = function(self, event)
    -- 调用实体管理器做移动处理    
    --Logger.Log(" RPG_EVENT_TYPE.MOVE", event.rtime)
    local avatar = self.ety_avatar[event.eid]
    if avatar then
        local cur_point = nil
        if event.sx and event.sy then
            cur_point = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(event.sx), 0, RPG_I2F(event.sy)))
        end
        local target_point = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(event.tx), 0, RPG_I2F(event.ty)))
        -- if event.eid == 1007 then
        --     Logger.LogerWYY2("event___move", target_point, event.sp)
        -- end
        avatar:set_move_target(event.sp, target_point, cur_point, event.agent)
    end
end

battle_player_mod.event_handle[RPG_EVENT_TYPE.DEAD] = function(self, event)
    --Logger.LogFormat("[RPG] 演播消息 Id:%s 死亡", event.eid)

    local avatar = self.ety_avatar[event.eid]
    if not avatar then
        return
    end

    -- 死亡时候，同步血量
    avatar:async_props({ RPG_Hp = 0 })

    -- 调用实体管理器播放死亡动画，删除实体
    avatar:dead(event.eid)
    self.ety_avatar[event.eid] = nil
    self.ety_dead_avatar[event.eid] = avatar
end

-- 子弹
battle_player_mod.event_handle[RPG_EVENT_TYPE.BULLET] = function(self, event)
    local avatar = self.ety_avatar[event.eid]
    if not avatar then
        return
    end

    avatar:send_bullet(event)
end
battle_player_mod.event_handle[RPG_EVENT_TYPE.BULLET_END] = function(self, event)
    local avatar = self.ety_avatar[event.eid]
    if not avatar then
        return
    end
    avatar:remove_bullet(event.oid)
    local eff_cfg = resmng.prop_rpg_battle_effect[event.eff]
    if eff_cfg and eff_cfg.VFXHit then
        local height = 0
        if event.target then
            height = self.ety_height[event.target] or 0
        end
        local target_point = self._ins.scene:b2w_point(E.Vector3(RPG_I2F(event.x), 0, RPG_I2F(event.y)))
        -- mgr_effect.play_hit_effect(eff_cfg.VFXHit, target_point)
        mgr_effect.create_effect(eff_cfg.VFXHit):play(target_point,nil,height)
    end
end

-- battle_player_mod.event_handle[RPG_EVENT_TYPE.PROP_CHANGE] = function(self, event)
--     local avatar = self.ety_avatar[event.eid]
--     if not avatar then
--         return
--     end

--     if event.prop == "RPG_DIR_X" or event.prop == "RPG_DIR_Y" then
--         local forward = self._ins.scene:b2w_euler(E.Vector3(event.props.RPG_DIR_X, 0, event.props.RPG_DIR_Y))
--         avatar:update_forward(forward.x, forward.z)
--         return
--     end 
-- end

function battle_player_mod:update_dir(event)
    local avatar = self.ety_avatar[event.eid]
    avatar._dir = event.props.RPG_DIR
    local radian = avatar._dir --* math.pi  / 180
    local radian2 = RPG_I2F(radian)
    local dir_x = math.cos(radian2)
    local dir_y = math.sin(radian2) 
    local forward = self._ins.scene:b2w_euler(E.Vector3(dir_x, 0, dir_y))
    avatar:update_forward(forward.x, forward.z)
end

-- 数值属性同步
battle_player_mod.event_handle[RPG_EVENT_TYPE.PROPS_CHANGED] = function(self, event)
    local avatar = self.ety_avatar[event.eid]
    if not avatar then
        return
    end


    if event.props.RPG_DIR then
        -- battle_player_mod.update_dir(self, event)
    end

    avatar:async_props(event.props)
end