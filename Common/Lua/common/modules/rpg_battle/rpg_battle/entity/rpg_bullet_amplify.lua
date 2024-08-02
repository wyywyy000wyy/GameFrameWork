local rpg_bullet_amplify = class2("rpg_bullet_amplify", T.rpg_bullet, function(self, eff_env ,target_orient, bullet_param)
    T.rpg_bullet._ctor(self, eff_env, target_orient, bullet_param)
    self._orient = target_orient
    self._st = self:get_time()
    self._hit_map = {}
    self._hit_list = {}
    -- self.range = self._param[1]
    self.range_cfg = self._param[1]
    -- self.time = self._param[2]
    self._et = self._st + self._param[2]
    self.scale = self._param[3]
    local range_type = self.range_cfg[1]
    self.Range = {
        [1] = range_type
    }

    self._battle_mod = eff_env.ins._battle_mod

    self.afun = self.amplify_func[range_type]
end)

T.rpg_bullet.type_map[RPG_BULLET_TYPE.AMPLIFY] = rpg_bullet_amplify

rpg_bullet_amplify.amplify_func = {
    [RPG_RANGE_TYPE.CIRCLE] = function(param, source, scale)
        param[2] = source[2] * scale
    end,
    [RPG_RANGE_TYPE.RECT] = function(param, source, scale)
        param[2] = source[2] * scale
        param[3] = source[3] * scale
    end,
    [RPG_RANGE_TYPE.SECTOR] = function(param, source, scale)
        param[3] = source[3] * scale
    end,
}

function rpg_bullet_amplify:actor_pos()
    return self._orient
end

function rpg_bullet_amplify:update()
    local ctime = self:get_time()

    local et = self._et
    local a = rpg_invlerp(self._st, et, ctime)
    local scale = rpg_lerp(self.scale, 1, a)
    self.afun(self.Range, self.range_cfg, scale)

    local hit_list = self._hit_list
    local hit_map = self._hit_map
    local curIdx = #hit_list
    

    self._battle_mod:search_targets(self, self._eff_env, self._orient, hit_list, function(ety)
        return not hit_map[ety._eid]
    end)
    local hit_eff = self._hit_effect

    if curIdx < #hit_list then
        for i = curIdx + 1, #hit_list do
            local ety = hit_list[i]
            hit_map[ety._eid] = true
            self:do_effect(hit_eff, ety)
        end
    end

    if ctime >= self._et then
        return true
    end
end
