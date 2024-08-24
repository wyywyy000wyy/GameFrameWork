-----------实现hexagonal_grid vertical axial 类的相关方法

local SQRT_3 = math.sqrt(3)
local mod = math.fmod
local floor = math.floor
local abs = math.abs
local table_insert = table.insert
local table_sort = table.sort
local table_remove = table.remove
hexWidth = 2 --hexSize * SQRT_3 / 2
hex_3 = 3 / hexWidth
hexSize = hexWidth / SQRT_3
hexSize3_2 = hexSize * 3 / 2
insHexSize3_2 = 1 / hexSize3_2
insHexWidth = 1 / hexWidth
halfHexWidth = hexWidth / 2
local ipairs = ipairs
rpg_testPos = {
    {{0.51,0},          {0,0}},
    {{0.97,0},          {2,0}},
    {{1.244,0.673},     {2,0}},
    {{1.523,0.955},     {1,1}},
    {{0.828,1.388},     {1,1}},
    {{-0.517,1.794},    {-1,1}},
    {{-1.789,-1.289},   {-3,-1}},
    {{-2.852,-4.219},   {-3,-3}},
    {{6.72,-6.144},     {8,-4}},
}

local neighbors_offset = {
    {-2, 0}, {-1, -1}, {1, -1},
    {2, 0}, {1, 1}, {-1, 1}
}

local neighbors_offset2 = {
    {-4,0},{-3,-1},--左上
    {-2,-2},{0,-2},{2,-2}, ----上
    {3,-1},{4,0},--右上
    {3,1},--右下
    {2,2},{0,2},{-2,2},--下
    {-3,1}--左下
}

---“double-width” horizontal layout
local hexagonal_grid = class_rpg("hexagonal_grid", function(self, map_width, map_length)
    self.cells = {}
    self.cells2 = {}
    self.map = {}
    self.a_star = T.rpg_a_star(self, neighbors_offset, self.is_empty)
    self.a_star2 = T.rpg_a_star(self, neighbors_offset, self.is_empty2, true)
    local half_maxCol = rpg_hex_half_length(map_length)
    local half_maxRow = rpg_hex_half_width(map_width)
    
    self.halfMaxCol = half_maxCol * 2 --math.ceil(maxCol / 2)
    self.halfMaxRow =  half_maxRow --math.ceil(maxRow / 2)

    self:init_delegate()

end)


function rpg_g2b(q, r)
    local x, y
    x = hexWidth * (q + (mod(r, 2) * 0.5))
    y = hexSize3_2 * r;
    x, y = RPG_F2I(x), RPG_F2I(y)
    return x, y
end

function rpg_g2b(q, r)
    local x = hexSize / 2 * SQRT_3 * q;
    local y = hexSize3_2 * r;
    x, y = RPG_F2I(x), RPG_F2I(y)
    return x, y
end

function rpg_hex_grid_dir(q1, r1, q2, r2)
    local dir_x = q1 > q2 and -1 or 1
    local dir_y
    if r1 > r2 then
        dir_y = -1
    elseif r1 < r2 then
        dir_y = 1
    else
        dir_y = 0
        dir_x = dir_x * 2
    end
    return dir_x, dir_y
end

function rpg_hex_length(dis)
    local battle_len = RPG_I2F(dis)
    return math.ceil(battle_len / hexWidth)
end

function rpg_hex_half_length(dis)
    local battle_len = RPG_I2F(dis) / 2
    local mul = (battle_len / hexWidth)
    return math.ceil(mul)
end

function rpg_hex_half_width(dis)
    local battle_len = RPG_I2F(dis) / 2 
    local mul = battle_len / hexSize3_2 
    return math.ceil(mul)
end

function rpg_b2g(x, y)
    x, y = RPG_I2F(x), RPG_I2F(y)
    local q = x * 2 / (hexSize * math.sqrt(3))
    local r = y * 2 / (hexSize * 3.0)

    local grid_x = math.floor(q + 0.5)
    local grid_y = math.floor(r + 0.5)

    if ((mod(grid_x, 2) ~= 0) ~= (mod(grid_y , 2) ~= 0)) then
        local fx = rpg_repeat(q + 1, 2) -1
        if fx == 0 then
            fx = 1
        end
        local fy = rpg_repeat(r + 1, 2) -1
        local ttfx = fx
        if (fx < 0) then
            ttfx = -2 - fx
        else
            ttfx = 2 - fx
        end
        if (abs(fy) * 3 <= abs(ttfx)) then
            local mod_y = mod(grid_y , 2)
            if (mod_y ~= 0) then
                grid_y = grid_y -rpg_sign(fy)
            else
                grid_x = grid_x -rpg_sign(fx)
            end
        else
            if (mod(grid_y , 2) == 0) then
                grid_y = grid_y +rpg_sign(fy)
            else
                grid_x = grid_x +rpg_sign(fx)
            end
        end
    end

    return grid_x, grid_y
end

local for_each = function (axial_x, axial_y, func, d)
    func(axial_x, axial_y, d)
    for _, offset in ipairs(neighbors_offset) do
        local neighbor_x = axial_x + offset[1]
        local neighbor_y = axial_y + offset[2]
        func(neighbor_x, neighbor_y, d)
    end
end

local for_each2 = function (axial_x, axial_y, func, d)
    func(axial_x, axial_y, d)
    for _, offset in ipairs(neighbors_offset) do
        local neighbor_x = axial_x + offset[1]
        local neighbor_y = axial_y + offset[2]
        func(neighbor_x, neighbor_y, d)
    end
    for _, offset in ipairs(neighbors_offset2) do
        local neighbor_x = axial_x + offset[1]
        local neighbor_y = axial_y + offset[2]
        func(neighbor_x, neighbor_y, d)
    end
end

local for_each_neighbor = function (axial_x, axial_y, func, d)
    for _, offset in ipairs(neighbors_offset) do
        local neighbor_x = axial_x + offset[1]
        local neighbor_y = axial_y + offset[2]
        func(neighbor_x, neighbor_y, d)
    end
end

local for_each_neighbor2 = function (axial_x, axial_y, func, d)
    for _, offset in ipairs(neighbors_offset2) do
        local neighbor_x = axial_x + offset[1]
        local neighbor_y = axial_y + offset[2]
        func(neighbor_x, neighbor_y, d)
    end
end

local raw_set = rpg_raw_set
local raw_get = rpg_raw_get
local raw_add = rpg_raw_add


function hexagonal_grid:init_delegate()
    ----------foreach_raw_clear
    self._rs = function(axial_x, axial_y, value)
        raw_set(self.cells, axial_x, axial_y, value)
    end
    self._rs2 = function(axial_x, axial_y, value)
        raw_set(self.cells2, axial_x, axial_y, value)
    end
    self._ra = function(axial_x, axial_y, value)
        raw_add(self.cells, axial_x, axial_y, value)
    end
    self._ra2 = function(axial_x, axial_y, value)
        raw_add(self.cells2, axial_x, axial_y, value)
    end
end

function hexagonal_grid.debug:init_delegate()
    local DrawHexagonalGridGo = E and E.GameObject and E.GameObject.Find("DrawHexagonalGrid")
    if not DrawHexagonalGridGo then
        return
    end
    local scene = self._ins.scene
    local DrawHexagonalGrid = DrawHexagonalGridGo:GetComponent("DrawHexagonalGrid")
    if scene then
        local pos = scene:b2w_point(E.Vector3(0, 0, 0))
        DrawHexagonalGridGo.transform.rotation = scene._quaternion
        pos.y = pos.y + 0.1
        DrawHexagonalGridGo.transform.position = pos
    end
    DrawHexagonalGrid.hexSize = hexSize
    DrawHexagonalGrid.width = (self.halfMaxCol/2) 
    DrawHexagonalGrid.height = (self.halfMaxRow)
    DrawHexagonalGrid:GenerateMesh()
    hexagonal_grid.DrawHexagonalGrid = DrawHexagonalGrid
end

function test_rpg_func()
    for _, v in ipairs(rpg_testPos) do
        local x, y = rpg_b2g(v[1][1], v[1][2])
        local tx, ty = v[2][1], v[2][2]
        if x ~= tx or y ~= ty then
            --Logger.LogerWYY2("test_rpg_func", v[1][1], v[1][2], x, y, tx, ty)
            x , y = rpg_b2g(v[1][1], v[1][2])
        end
    end
end  
test_rpg_func() 

function hexagonal_grid:get_empty_neighbor(x, y, size)
    local axial_x, axial_y = rpg_b2g(x, y)
    local offset_list = size == 2 and neighbors_offset2 or neighbors_offset
    for _, offset in ipairs(offset_list) do
        local neighbor_x = axial_x + offset[1]
        local neighbor_y = axial_y + offset[2]
        if self:is_empty(neighbor_x, neighbor_y) then
            return neighbor_x, neighbor_y
        end
    end
end

function hexagonal_grid:set(axial_x, axial_y, eid)
    if self:is_in(axial_x, axial_y, eid) then
        return
    end
    local pre_info = self.map[eid]
    self:clear(eid)
    self._rs(axial_x, axial_y, eid)

    local cells2 = self.cells2
    if cells2 then
        for_each(axial_x, axial_y, self._ra2, 1)
    end

    pre_info = pre_info or {}
    pre_info[1] = axial_x
    pre_info[2] = axial_y
    pre_info[3] = 1
    self.map[eid] = pre_info
end

function hexagonal_grid.debug._rs(axial_x, axial_y, value)
    -- Logger.LogerWYY2("hexagonal_grid.debug._rs", axial_x, axial_y, value)
    if not hexagonal_grid.DrawHexagonalGrid then
        return
    end
    if not value or value<= 0 then
        hexagonal_grid.DrawHexagonalGrid:SetGridColor(axial_x, axial_y, E.Color.green)
    else
        hexagonal_grid.DrawHexagonalGrid:SetGridColor(axial_x, axial_y, E.Color.red)
    end
end

function hexagonal_grid.debug._ra2(axial_x, axial_y, value)
    -- Logger.LogerWYY2("hexagonal_grid.debug._ra2", axial_x, axial_y, value)
end

function hexagonal_grid.debug:clear_pre(eid)
    -- if not hexagonal_grid.DrawHexagonalGrid then
    --     return
    -- end
    -- local pre = self.map[eid]
    -- if pre then
    --     local axial_x, axial_y = unpack(pre)
    --     hexagonal_grid.DrawHexagonalGrid:SetGridColor(axial_x, axial_y, E.Color.green)
    -- end
end

function hexagonal_grid:set2(axial_x, axial_y, eid)
    local pre_info = self.map[eid]
    self:clear(eid)

    for_each(axial_x, axial_y, self._rs, eid)
    local cells2 = self.cells2
    if cells2 then
        for_each2(axial_x, axial_y, self._ra2, 1)
    end

    pre_info = pre_info or {}
    pre_info[1] = axial_x
    pre_info[2] = axial_y
    pre_info[3] = 2
    self.map[eid] = pre_info
end

function hexagonal_grid:clear(eid)
    local pre = self.map[eid]
    if pre then
        self.map[eid] = nil
        local pre_axial_x, pre_axial_y, size = pre[1], pre[2], pre[3]
        if raw_get(self.cells, pre_axial_x, pre_axial_y) == eid then
            self._rs(pre_axial_x, pre_axial_y)
            if size == 2 then
                for_each_neighbor(pre_axial_x, pre_axial_y, self._rs)
            end

            local cells2 = self.cells2
            if cells2 then
                if size == 2 then
                    for_each2(pre_axial_x, pre_axial_y, self._ra2, -1)
                else
                    for_each(pre_axial_x, pre_axial_y, self._ra2, -1)
                end
            end
        end
    end
end

-- function hexagonal_grid:is_out(axial_x, axial_y)
--     return abs(axial_x) > self.halfMaxCol or abs(axial_y) > self.halfMaxRow
-- end

-- function hexagonal_grid:is_out2(axial_x, axial_y)
--     return abs(axial_x) + 1 > self.halfMaxCol or abs(axial_y) + 1 > self.halfMaxRow
-- end

function hexagonal_grid:in_grid(axial_x, axial_y)
    return abs(axial_x) <= self.halfMaxCol and abs(axial_y) <= self.halfMaxRow
end

function hexagonal_grid:in_grid2(axial_x, axial_y)
    return abs(axial_x) + 1 <= self.halfMaxCol and abs(axial_y) + 1 <= self.halfMaxRow
end

function hexagonal_grid:is_empty(axial_x, axial_y, eid)
    if abs(axial_x) > self.halfMaxCol or abs(axial_y) > self.halfMaxRow then
        return false
    end

    local peid = raw_get(self.cells, axial_x, axial_y)
    return not peid or peid == eid
end

function hexagonal_grid:is_empty2(axial_x, axial_y, eid)
    if abs(axial_x) + 1 > self.halfMaxCol or abs(axial_y) + 1 > self.halfMaxRow then
        return false
    end

    local peid = raw_get(self.cells, axial_x, axial_y)
    local empty_count = 0
    if peid and peid == eid then
        empty_count = 1
    end

    local value = raw_get(self.cells2, axial_x, axial_y)
    return not value or value == empty_count
end


function hexagonal_grid:is_in(axial_x, axial_y, eid)
    -- local axial_x, axial_y = rpg_b2g(x, y)
    local ety_info = self.map[eid]
    if ety_info and ety_info[1] == axial_x and ety_info[2] == axial_y then
        return true
    end
    return false
end

-----------A*寻路
function hexagonal_grid:find_path(sx, sy, ex, ey, min_dis, exclude_pos)
    return self.a_star:find_path(sx, sy, ex, ey, min_dis, exclude_pos)
end

function hexagonal_grid:find_path2(sx, sy, ex, ey, min_dis, exclude_pos)
    return self.a_star2:find_path(sx, sy, ex, ey, min_dis, exclude_pos)
end

return hexagonal_grid


