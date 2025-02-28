local rpg_multiply_door = class2("rpg_multiply_door",T.rpg_entity, function(self,eff_env, _, param)

    self._multi_map = {}
    self._param = param
    local range_param = param[3]
    self._range_param = range_param
    self._eff_env = eff_env
    self._ins = eff_env.ins
    self._multy = param[1]
    local prop_rpg_battle_level = resmng.prop_rpg_battle_level[eff_env.ins._init_data.level_id]
    local prop_rpg_battle_map = resmng.prop_rpg_battle_map[prop_rpg_battle_level.Map]
    self._x = prop_rpg_battle_map.DoorPos[1]
    self._y = prop_rpg_battle_map.DoorPos[2]

    if range_param[1] == RPG_RANGE_TYPE.RECT then
        local width = range_param[2]
        local length = range_param[3]
        local dir_x = 1000
        local dir_y = 0

        local sx = self._x -  width / 2

        self._rx = sx
        self._ry = self._y
        self._dir_x = dir_x
        self._dir_y = dir_y
        self._w = width
        self._bw = width
        self._mw = 1000
        self._l = length

        self:update_size()
    end

    eff_env.ins:post_event({
        id = RPG_EVENT_TYPE.BORN,
        ety_type = RPG_ETY_TYPE.MDOOR,
        x = self._x,
        y = self._y,
        dir_x = self._dir_x,
        dir_y = self._dir_y,
        width = self._w,
    })
end)


function rpg_multiply_door:update_size()

    self._p1 = {
        self._x - self._w / 2,
        self._y
    }
    self._p2 = {
        self._x + self._w / 2,
        self._y
    }
end

rpg_multiply_door.range_filter = rpg_multiply_door.range_filter or {
}
local range_filter = rpg_multiply_door.range_filter

range_filter[RPG_RANGE_TYPE.CIRCLE] = function(self, x, y, range_param)
    -- local circle_x = skill_orient._sx or skill_orient._x
    -- local circle_y = skill_orient._sy or skill_orient._y
    -- local radius = range_param[2] + ety._p.RPG_Radius
    -- return rpg_in_circle(ety._x, ety._y, circle_x, circle_y, radius)
end


local function orientation(p, q, r)
    local val = (q[2] - p[2]) * (r[1] - q[1]) - (q[1] - p[1]) * (r[2] - q[2])
    if val == 0 then
        return 0
    elseif val > 0 then
        return 1
    else
        return 2
    end
end

-- Helper function to check if point q lies on line segment pr
local function onSegment(p, q, r)
    if q[1] <= math.max(p[1], r[1]) and q[1] >= math.min(p[1], r[1]) and
       q[2] <= math.max(p[2], r[2]) and q[2] >= math.min(p[2], r[2]) then
        return true
    end
    return false
end

-- Function to check if two line segments p1q1 and p2q2 intersect
local function rpg_seg_intersect(p1, q1, p2, q2)
    -- Find the four orientations needed for the general and special cases
    local o1 = orientation(p1, q1, p2)
    local o2 = orientation(p1, q1, q2)
    local o3 = orientation(p2, q2, p1)
    local o4 = orientation(p2, q2, q1)

    -- General case
    if o1 ~= o2 and o3 ~= o4 then
        return true
    end

    -- Special cases
    -- p1, q1 and p2 are collinear and p2 lies on segment p1q1
    if o1 == 0 and onSegment(p1, p2, q1) then
        return true
    end

    -- p1, q1 and q2 are collinear and q2 lies on segment p1q1
    if o2 == 0 and onSegment(p1, q2, q1) then
        return true
    end

    -- p2, q2 and p1 are collinear and p1 lies on segment p2q2
    if o3 == 0 and onSegment(p2, p1, q2) then
        return true
    end

    -- p2, q2 and q1 are collinear and q1 lies on segment p2q2
    if o4 == 0 and onSegment(p2, q1, q2) then
        return true
    end

    -- Doesn't fall in any of the above cases
    return false
end


local q1 = {

}

local q2 = {}

range_filter[RPG_RANGE_TYPE.RECT] = function(self , bullet, range_param)
    q1[1] = bullet._x
    q1[2] = bullet._y
    q2[1] = bullet.pre_x or bullet._x
    q2[2] = bullet.pre_y  or bullet._y
    local ret = rpg_seg_intersect(self._p1, self._p2, q1, q2) --rpg_in_rect(x, y, self._rx, self._ry, self._dir_x, self._dir_y, self._w, self._l)
    return ret
end

function rpg_multiply_door:detect(bullet)
    if self._multi_map[bullet._oid] then
        return
    end

    local range_filter = range_filter[self._range_param[1]]
    if not range_filter(self, bullet, self._range_param) then
        return
    end

    local multy = self._multy
    local angle = self._param[2]
    local rand = self._ins._battle_mod._rand

    local dir_x, dir_y = rpg_normalize(bullet._orient._dir_x, bullet._orient._dir_y)

    -- local 
    for i = 1, multy do
        local a = rand:range2(-angle, angle)
        local cos_a = angle_to_cos(a)
        local sin_a = angle_to_sin(a)

        local nx = dir_x * cos_a - dir_y * sin_a
        local ny = dir_x * sin_a + dir_y * cos_a
        self:multiply(bullet, nx, ny)
    end

    bullet:destroy()
end

function rpg_multiply_door:multiply(bullet, dir_x, dir_y)
    local new_orient = {
        _sx = bullet._x,
        _sy = bullet._y,
        _x = bullet._x + dir_x * 100000,
        _y = bullet._y + dir_y * 100000,
        _dir_x = dir_x,
        _dir_y = dir_y
    }
    local b = T.rpg_bullet_line(bullet._eff_env.p_env, new_orient, bullet.__param)
    self._multi_map[b._oid] = true
end