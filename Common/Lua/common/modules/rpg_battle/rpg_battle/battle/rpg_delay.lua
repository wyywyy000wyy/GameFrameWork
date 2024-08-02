local rpg_delay = class2("rpg_delay",T.rpg_pool_obj,function(self, battle_ins, btime, func)
    T.rpg_pool_obj._ctor(self, battle_ins)
    self._btime = btime
    self._func = func
end)

function rpg_delay:update()
    local btime = self._ins:get_btime()
    if btime >= self._btime then
        self._func()
        return true
    end
end