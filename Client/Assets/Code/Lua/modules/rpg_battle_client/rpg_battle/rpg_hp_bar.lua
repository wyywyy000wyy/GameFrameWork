local rpg_hp_bar = class2("rpg_hp_bar", function(self, args)
    self._hp = args.hp
    self._hp_count = args.hp_count or 1
    self._max_hp = args.max_hp -- / self._hp_count
    self._max_hp2 = args.max_hp / self._hp_count
    self._shield = args.shield or 0
    self._hp_cb = args.hp_cb
    self._shield_cb = args.shield_cb
    self._hp_delay_cb = args.hp_delay_cb
    self._delay_hp = args.hp_delay_cb and args.hp or nil
    if self._hp_count > 1 then
        self._hp_percent_func = self.get_hp_percent_multi
    else
        self._hp_percent_func = self.get_hp_percent
    end
    self:update_bar()
end)

local fillOriginLeft = 3
local fillOriginRight = 1


function rpg_hp_bar:get_hp_percent_multi()
    local c, multi_hp_percent = math.modf(self._hp / self._max_hp2)
    return multi_hp_percent > 0 and multi_hp_percent or c > 0 and 1 or 0
end

function rpg_hp_bar:get_hp_percent()
    return self._hp / self._max_hp
end

function rpg_hp_bar:set_hp(hp, max_hp)
    self._hp = hp
    self._max_hp = max_hp or self._max_hp
    self:update_bar()
end

function rpg_hp_bar:update_bar()

    local hp_percent = self._hp_percent_func(self)
    local shield_percent =  self._shield / self._max_hp2
    local percent = hp_percent + shield_percent
    if percent >= 2 then
        hp_percent = 0
        shield_percent = 1
        self._hp_cb(hp_percent)
        self._shield_cb(shield_percent, fillOriginRight)
    elseif percent >= 1 then
        -- local _ , t = math.modf(percent - hp_percent)
        -- shield_percent = t
        hp_percent = 1 - shield_percent
        self._hp_cb(hp_percent)
        self._shield_cb(shield_percent, fillOriginRight)
    elseif shield_percent >0 then
        self._hp_cb(hp_percent)
        self._shield_cb(percent, fillOriginLeft)
    else
        self._hp_cb(hp_percent)
        self._shield_cb(0, fillOriginLeft)
    end
end

function rpg_hp_bar:set_shield(shield)
    self._shield = shield or 0
    self:update_bar()
end 