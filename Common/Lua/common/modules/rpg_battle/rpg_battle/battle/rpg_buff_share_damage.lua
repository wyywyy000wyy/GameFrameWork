local table_insert = table.insert
local table_remove = table.remove
local floor = math.floor
local rpg_buff_share_damage = class2("rpg_buff_share_damage", T.rpg_buff, function(self,buff_id, battle_ins, owner, eff_env, time, parent_buff, share_type, factor) 
    T.rpg_buff._ctor(self, buff_id, battle_ins, owner, eff_env, time)
    self._factor = factor
    -- self._others = {}
    self._share_type = share_type
    self._parent = parent_buff
    self._is_main_buff = not parent_buff and true or false
    self._childs = self._is_main_buff and {} or nil
    if share_type == 1 then
        self.share_damage = self._share_dmg
    elseif share_type == 2 then
        self.share_damage = self._transfer_dmg
    else
        self.share_damage = self._guard_dmg
    end
    -- Logger.LogerWYY2("[BATTLE] rpg_buff_share_damage", self._id, "eid",self._ety._eid, "is_main", self._is_main_buff, "_share_type", self._share_type, self._ins:get_rtime())
end)

function rpg_buff_share_damage:add_child(buff)
    table_insert(self._childs, buff)
end

function rpg_buff_share_damage:remove_child(buff)
    local childs = self._childs
    if not childs then return end
    for i = #childs, 1, -1 do
        if childs[i] == buff then
            childs[i] = childs[#childs]
            table_remove(childs, #childs)
            buff:finish()
            return
        end
    end 
end

function rpg_buff_share_damage:on_enter()
    local main_buff = not self._parent 
    if self._share_type == RPG_SHARE_DAMAGE_TYPE.SHARE then
        self._ety:add_share_damage(self)
    elseif self._share_type == RPG_SHARE_DAMAGE_TYPE.TRANSFER then
        local _ = main_buff and self._ety:add_share_damage(self)
    elseif self._share_type == RPG_SHARE_DAMAGE_TYPE.GUARD then
        local _ = not main_buff and self._ety:add_share_damage(self)
    end
    rpg_buff_share_damage._base.on_enter(self)
end

function rpg_buff_share_damage:_share_dmg(dmg,dmg_composer)
    local is_main = self._is_main_buff
    local main_buff = is_main and self or self._parent
    local childs = main_buff._childs
    if #childs == 0 then
        if main_buff ~= self then
            dmg_composer:compose(main_buff._ety, dmg)
        end
        return is_main and dmg or 0
    end
    local main_dmg = floor(dmg * self._factor) 
    local child_dmg = floor((dmg - main_dmg)/ #childs)

    dmg_composer:compose(self._ety, main_dmg)
    for _, buf in ipairs(childs) do
        if buf ~= self then
            dmg_composer:compose(buf._ety, child_dmg)
        end
    end
    if main_buff ~= self then
        dmg_composer:compose(main_buff._ety, child_dmg)
    end
    return main_dmg
end

function rpg_buff_share_damage:_transfer_dmg(dmg,dmg_composer)
    local is_main = not self._parent
    if not is_main then
        return dmg
    end
    local main_buff = self
    local childs = main_buff._childs
    if #childs == 0 then
        return dmg or 0
    end
    local main_dmg = floor(dmg * self._factor) 
    local child_dmg = floor((dmg - main_dmg)/ #childs)
    for _, buf in ipairs(childs) do
        dmg_composer:compose(buf._ety, child_dmg)
    end
    return main_dmg
end

function rpg_buff_share_damage:_guard_dmg(dmg,dmg_composer)
    local is_main = not self._parent
    if is_main then
        return dmg
    end
    local main_buff = self._parent
    local main_dmg = floor(dmg * self._factor) 
    local child_dmg = dmg - main_dmg
    dmg_composer:compose(main_buff._ety, main_dmg)
    return child_dmg
end

function rpg_buff_share_damage:on_exit()
    if self._finish then
        return
    end
    if self._parent then
        self._parent:remove_child(self)
    end
    if self._childs then
        local childs = self._childs
        local idx = #childs
        for i = idx, 1, -1 do
            childs[i]:finish()
        end
        -- for _, child in ipairs(childs) do
        --     child:on_exit()
        -- end
        self._childs = nil
    end
    self._ety:remove_share_damage(self)
    -- Logger.LogerWYY2("[BATTLE] rpg_buff_share_damage exit", self._id, "eid",self._ety._eid, "is_main", self._is_main_buff, "_share_type", self._share_type, self._ins:get_rtime())
    self._parent = nil
    rpg_buff_share_damage._base.on_exit(self)
end


function rpg_buff_share_damage:post_buff_event()
    self._ins:post_event({
        id = RPG_EVENT_TYPE.BUFF,
        event_time = self:get_time(),
        oid = self._eff_env.p_env.actor._oid,
        caster = self._caster._eid,
        owner = self._ety._eid,
        buff = self._id,
        ia_anger = self.is_anger,
        -- grade = self._grade > 1 and self._grade or nil,
        -- dur = self._dur
        et = self._et,
        share_damage = true
    })
end