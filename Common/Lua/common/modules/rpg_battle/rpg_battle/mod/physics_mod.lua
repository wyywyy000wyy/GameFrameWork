local max = math.max
local min = math.min
local floor = math.floor
local sqrt = math.sqrt
local RPG_I2F = RPG_I2F
local RPG_F2I = RPG_F2I
local rpg_b2g = rpg_b2g
local rpg_dir = rpg_dir
local rpg_dis = rpg_dis

local physics_mod = class2("physics_mod", T.mod_base, function(self, battle_instance)
    T.mod_base._ctor(self, battle_instance)
    self._ins._physics_mod = self
    -- self._map_width = 20 * 1000
    -- self._map_length = 40 * 1000

    local level_id = battle_instance._init_data.level_id
    local level_data = resmng.prop_rpg_battle_level[level_id]
    local map_data = resmng.prop_rpg_battle_map[level_data.Map] 
    if battle_instance._init_data.map_id then
        map_data = resmng.prop_rpg_battle_map[battle_instance._init_data.map_id]
    end

    local mapSize = map_data.MapSize

    local width = (mapSize and mapSize[1] or 11) * 1000
    local length = (mapSize and mapSize[2] or 14) * 1000
    self._grid = T.hexagonal_grid(width, length)
    self._obj_pos = {}
end)

function physics_mod:init()
    self._init_completed = true
end

function physics_mod:register_listener()
    -- self._ins:add_event_listener2(RPG_EVENT_TYPE.BORN, self.on_ety_born) -- 战斗开始
end

function physics_mod:init_finish()
    return self._init_completed
end

function physics_mod:start()

end

function physics_mod:empty(x, y, oid, ssize)
    if ssize >= RPG_ENTITY_RADIUS2 then
        return self._grid:is_empty2(x, y, oid)
    end
    return self._grid:is_empty(x, y, oid)
end

function physics_mod:knockback(from_x, from_y, to_x, to_y, dis, ssize, cross)
    local from_g_x , from_g_y = rpg_b2g(from_x, from_y)
    -- local to_g_x , to_g_y = rpg_b2g(to_x, to_y)

    local is_empty_func = nil
    if cross then
        is_empty_func = ssize >= RPG_ENTITY_RADIUS2 and self._grid.in_grid2 or self._grid.in_grid
    else
        is_empty_func =  ssize >= RPG_ENTITY_RADIUS2 and self._grid.is_empty2 or self._grid.is_empty
    end

    ---------------------用from_x, to_x 精度要高一点，因为只有x < 0 or x > 0
    local dir_x, dir_y = rpg_dir(from_x, from_y, to_x, to_y)
    dir_x = RPG_F2I(dir_x)
    dir_y = RPG_F2I(dir_y)
    -- local length = rpg_dis(from_x, from_y, to_x, to_y)
    local step = floor(dis / RPG_F2I(halfHexWidth)) 
    local ret_x, ret_y = from_g_x, from_g_y
    local collider = false
    for i = 1, step do
        local tx, ty = from_x + dir_x * i, from_y + dir_y * i
        local x, y = rpg_b2g(tx, ty )
        if not is_empty_func(self._grid, x, y) then
            collider = true
            break
        end
        ret_x, ret_y = x, y
    end
    ret_x, ret_y = rpg_g2b(ret_x, ret_y)
    return ret_x, ret_y
end

function physics_mod:get_empty_pos(x, y)
    return self._grid:get_empty_neighbor(x, y)
end

function physics_mod:set(x, y, oid, ssize)
    if ssize >= RPG_ENTITY_RADIUS2 then
        self._grid:set2(x, y, oid)
    else
        self._grid:set(x, y, oid)
    end
end

function physics_mod:clear(eid)

    self._grid:clear(eid)

end

function physics_mod:stop()

end

