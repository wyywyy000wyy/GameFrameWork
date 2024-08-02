local rpg_pool_obj = class2("rpg_pool_obj",T.rpg_object, function(self, battle_ins)
    T.rpg_object._ctor(self, battle_ins)
end)

function rpg_pool_obj.new()
    
end

function rpg_pool_obj:reset()
end

function rpg_pool_obj:clone()
end

function rpg_pool_obj:dispose()

end
