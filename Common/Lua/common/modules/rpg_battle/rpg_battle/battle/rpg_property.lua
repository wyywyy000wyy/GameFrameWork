-- rpg_property = rpg_property or {}
local rpg_property = class2("rpg_property", T.rpg_object, function(self, battle_instance, entity, attr)
    T.rpg_object._ctor(self, battle_instance)
    self._ety = entity
    self._b = {}
    self._p = {}
    self:init(attr)
end)

-- rpg_property.func = {
--     RPG_Hp = function()
--     end
-- }

--设计目的
--回血，回怒气等属性，常规的实现需要每帧重新计算数值 ==》累加数值 hp = math.min(（hp_speed * dt）, hp_max)
--会导致每帧很多重复的计算
--现在实现是 不每帧


-- function rpg_property.calc_Hp(props)
--     -- local cur_hp = props.Hp_c
--     local speed = props.Hp_sp
--     local end_time = props.Hp_et
--     local max_hp = props.Hp_m
--     local btime = props._ins:get_btime()
--     local t = math.max(0, end_time - btime)
--     local cur_hp = max_hp - t * speed
--     rawset(props, "RPG_Hp", cur_hp)
-- end

-- local calcmap = {
--     RPG_Hp = rpg_property.calc_Hp
-- }

-- local mt = {
--     __index = function(t, k)
--         local r = calcmap[k](t)
--         return t._b[k]
--     end
-- }

function rpg_property:init(attr)
    for n, v in pairs(attr) do
        self._b[n] = v
    end 
    for n, v in pairs(self._b) do
        self._p[n] = v
    end 
end

