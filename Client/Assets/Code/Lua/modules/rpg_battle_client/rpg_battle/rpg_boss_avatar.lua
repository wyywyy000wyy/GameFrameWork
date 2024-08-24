local PoolManager = CS.CDL2.Utility.PoolManager
local rpg_boss_avatar = class2("rpg_boss_avatar", T.rpg_hero_avatar, function(self, eid, hero_pid, lv, pos_index, born_pos, born_dir, hero_data, BossScale)
    self._BossScale = hero_data and hero_data.scale or BossScale or 1
    T.rpg_hero_avatar._ctor(self, eid, hero_pid, lv, pos_index, born_pos, born_dir, hero_data)
end)

local boss_eff_path = "ef_xuzhang_huan_r"

function rpg_boss_avatar:update_ui_head()
    if not self._create_head then
        g_ui_manager:call_func("ui_rpg_battle_main", "set_boss_avatar", self) 
    else
        g_ui_manager:call_func("ui_rpg_battle_main", "refresh_boss_hp") 
    end
end

function rpg_boss_avatar:get_hp_count()
    return self._hero_data and self._hero_data.hp_count or 1
end

function rpg_boss_avatar:get_model_scale()
    return self._BossScale * self._hero_prop.RpgModelScale
end

function rpg_boss_avatar:on_model_loaded(obj)
    -- g_load_asset(boss_eff_path,
    -- function(arg, path, eff)
    --     if self.destroyed then
    --         g_release_asset(boss_eff_path, eff)
    --         return
    --     end
    --     if eff then
    --         eff.transform:SetParent(obj.transform, false)
    --         eff.transform.localPosition = E.Vector3.zero
    --         eff.transform.localRotation = E.Quaternion.identity
    --         eff.transform.localScale = E.Vector3.one
    --         eff:SetActive(true)
    --         self._boss_eff = eff
    --     end
    -- end
    -- )
end

function rpg_boss_avatar:destroy()
    g_ui_manager:call_func("ui_rpg_battle_main", "set_boss_avatar") 
    -- if self._boss_eff then
    --     g_release_asset(boss_eff_path, self._boss_eff)
    --     self._boss_eff = nil
    -- end
    T.rpg_hero_avatar.destroy(self)
end