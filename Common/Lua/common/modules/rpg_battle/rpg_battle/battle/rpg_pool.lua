
local rpg_pool = class2("rpg_pool", function(self, type) 
    self._type = type
end)

rpg_pool_class = function(class_name, ...)
    local tclass = class2(class_name,T.rpg_pool_obj,...)
    local pool =  tclass._pool or T.rpg_pool(tclass)
    tclass._pool = pool
    tclass.new = function(battle_ins)
        local obj = tclass()
        obj._pool = pool
        obj._ins = battle_ins
        obj:reset()
        return obj
    end
    return tclass
end
