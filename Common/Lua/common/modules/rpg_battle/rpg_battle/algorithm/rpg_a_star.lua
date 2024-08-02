local table_insert = table.insert
local table_sort = table.sort
local table_remove = table.remove

local rpg_a_star = class2("rpg_a_star", function(self, grid, neighbors_offset, is_empty_func, size_2) 
    self.neighbors_offset = neighbors_offset
    self.grid = grid
    self.cells = grid.cells
    self.is_empty = is_empty_func
    self.size_2 = size_2
end)

function rpg_a_star:get_neighbors(axial_x, axial_y, exclude_pos)
    local neighbors = {}
    local grid = self.grid
    for _, offset in ipairs(self.neighbors_offset) do
        local neighbor_x = axial_x + offset[1]
        local neighbor_y = axial_y + offset[2]
        if exclude_pos and exclude_pos[neighbor_x] and exclude_pos[neighbor_x][neighbor_y] then
            goto CONTINUE
        end
        --TODO SIZE = 2
        if not self.is_empty(grid, neighbor_x, neighbor_y, self.exclude_eid) then
            goto CONTINUE
        end
        table_insert(neighbors, {axial_x = neighbor_x, axial_y = neighbor_y})
        ::CONTINUE::
    end

    ---------------------------
    if #neighbors == 0 and self.size_2 and not self.is_empty(grid, axial_x, axial_y, self.exclude_eid)  then
        for _, offset in ipairs(self.neighbors_offset) do
            local neighbor_x = axial_x + offset[1]
            local neighbor_y = axial_y + offset[2]
            if exclude_pos and exclude_pos[neighbor_x] and exclude_pos[neighbor_x][neighbor_y] then
                goto CONTINUE
            end
            --TODO SIZE = 2
            if not grid:is_empty(neighbor_x, neighbor_y, self.exclude_eid) then
                goto CONTINUE
            end
            table_insert(neighbors, {axial_x = neighbor_x, axial_y = neighbor_y})
            ::CONTINUE::
        end
    end
    return neighbors
end

local function get_distance(axial_x1, axial_z1, axial_x2, axial_z2)
    local x1, y1 = rpg_g2b(axial_x1, axial_z1)
    local x2, y2 = rpg_g2b(axial_x2, axial_z2)
    return rpg_dis(x1, y1, x2, y2)
end

local function get_heuristic(axial_x1, axial_z1, axial_x2, axial_z2)
    return get_distance(axial_x1, axial_z1, axial_x2, axial_z2)
end


function rpg_a_star:find_path(sx, sy, ex, ey, min_dis, exclude_pos, exclude_eid)
    self._find_path_count = self._find_path_count or 0
    self._find_path_count = self._find_path_count + 1
    local min_dis = min_dis or 0
    self.exclude_eid =exclude_eid

    local is_reach_func = nil 
    
    if min_dis > 0 then
        is_reach_func = function (cx, cy)
            if sx == cx and sy == cy then
                return false
            end
            local dis = get_distance(cx, cy, ex, ey)
            return dis <= min_dis
        end
    else
        is_reach_func = function (cx, cy)
            if sx == cx and sy == cy then
                return false
            end
            return  cx == ex and cy == ey
        end
    end

    
    local path = {}

    local point_map = {}
    local open_list = {}

    local get_or_create_point = function(x, y)
        local point = point_map[x]
        if not point then
            point = {}
            point_map[x] = point
        end
        local p = point[y]
        if not p then
            
            p = {x = x, y = y, f = 0, g = 0, h = 0, parent = nil, visited = false}
            if self._find_path_count == 1 then
                self._tmp_list = self._tmp_list or {}
                table_insert(self._tmp_list, {x = x, y = y})
            end
            point[y] = p
        end
        return p
    end

    local insert_sorted_open_list = function(point)
        table_insert(open_list, point)
    end

    local remove_from_open_list = function(point)
        for i, p in ipairs(open_list) do
            if p == point then
                table_remove(open_list, i)
                break
            end
        end
    end

    local pop_open_list = function()
        table_sort(open_list, function(a,b)
            if a.f ~= b.f then
                return a.f < b.f
            end
            return a.h < b.h
        end)
        local point = open_list[1]
        table_remove(open_list, 1)
        return point
    end

    local start_point = get_or_create_point(sx, sy)
    insert_sorted_open_list(start_point)

    local ep = nil
    local nearest_point = nil
    local nearest_min_dis = 0
    local first_point = true
    while #open_list > 0 do
        local p = pop_open_list()
        p.visited = true

        local tmp_dis = get_distance(p.x, p.y, ex, ey)
        if not first_point and (not nearest_point or tmp_dis < nearest_min_dis) then
            nearest_point = p
            nearest_min_dis = tmp_dis
        end
        first_point = false
        if is_reach_func(p.x, p.y) then
            ep = p
            goto END
        end

        local neighbors = self:get_neighbors(p.x, p.y, exclude_pos)
        for _, neighbor in ipairs(neighbors) do
            local neighbor_point = get_or_create_point(neighbor.axial_x, neighbor.axial_y)
            if not neighbor_point.visited then
                local g = p.g + RPG_F2I(hexWidth)
                local h = get_heuristic(neighbor_point.x, neighbor_point.y, ex, ey)
                local f = g + h
                if neighbor_point.f == 0 or f < neighbor_point.f then
                    local is_new = neighbor_point.f == 0
                    neighbor_point.f = f
                    neighbor_point.g = g 
                    neighbor_point.h = h
                    neighbor_point.parent = p
                    if not is_new then
                        remove_from_open_list(neighbor_point)
                    end
                    insert_sorted_open_list(neighbor_point)
                end
            end
        end
    end

    ::END::

    if self._find_path_count == 1 then
        self._tmp_list = self._tmp_list or {}
        table_sort(self._tmp_list, function (p1, p2)
            if p1.y ~= p2.y then
                return p1.y < p2.y
            end
            if p1.x ~= p2.x then
                return p1.x < p2.x
            end
            return false
        end)
    end

    if ep then
        local p = ep
        while p do
            table_insert(path, 1, {p.x, p.y})
            p = p.parent
        end
        return path
    end
end