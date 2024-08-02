
local math = math
local ceil = math.ceil
local abs = math.abs
local sqrt = math.sqrt
local floor = math.floor
local min = math.min
local max = math.max
local cos = math.cos

function RPG_F2I(value)
    local intvalue = floor(value * 1000)
    return intvalue
end

RPG_PI = 3.1415926535

RPG_D2R = 0.017453292519--(RPG_PI * 2) / 360
local RPG_D2R = RPG_D2R

local RPG_F2I = RPG_F2I

function RPG_I2F(value)
    if not value then
        return 0
    end
    
    return value / 1000
end


function rpg_sign(x)
    if x < 0 then
        return -1
    elseif x > 0 then
        return 1
    else
        return 0
    end
end

function rpg_repeat(value, wrapSize)
    return value - (math.floor(value / wrapSize) * wrapSize)
end

function rpg_clamp(a,b,v)
    v = max(a, v)
    return min(b, v)
end

function rpg_dis(x1,y1,x2,y2)
    local dx = x2- x1
    local dy = y2 - y1
    return floor(sqrt(dx*dx + dy*dy)) 
end

function rpg_dir(x1,y1,x2,y2)
    local dir_x = x2 - x1
    local dir_y = y2 - y1

    local d = sqrt(dir_x * dir_x + dir_y * dir_y)
    if abs(d) <= 0.000001 then
        return 1, 0
    end
    d = 1 / d
    return (dir_x * d),(dir_y * d) --floor(RPG_F2I(dir_x * d)), floor(RPG_F2I(dir_y * d))
end

function rpg_left_dir(dir_x, dir_y)
    return dir_y, -dir_x
end

function rpg_right_dir(dir_x, dir_y)
    return -dir_y, dir_x
end

function rpg_normalize(nx, ny)
    local d = sqrt(nx * nx + ny * ny)
    if abs(d) <= 0.000001 then
        return 1, 0
    end
    d = 1 / d
    return (nx * d),(ny * d) --floor(RPG_F2I(dir_x * d)), floor(RPG_F2I(dir_y * d))
end

function rpg_pos(pos)
    return {pos[1], pos[2]}
end

function rpg_pos2(x, y)
    return {x, y}
end

----TODO
function rpg_dir_e(x1,y1,x2,y2)
    if y1 == 0 then
        if y2 == 0 then
            return true
        end
        return false
    end
    local f1 = x1/y1
    local f2 = x2/y2
    local f = abs(f1 - f2)
    return f < 0.000001
end

function rpg_pe(pos, pos2)
    local dx = pos2[1] - pos[1]
    local dy = pos2[2] - pos[2]
    return (pos[1] == pos2[1]) and (pos[2] == pos2[2])
end

function rpg_invlerp(a, b, p)
    local v = (p - a)/(b - a)
    v = max(0, v)
    v = min(1, v)
    return v
end

function rpg_lerp(a, b, p)
    return a + (b-a) * p
end

function rpg_lerp_pos(px,py, px2, py2, p)
    local x = px + p * (px2 - px)
    local y = py + p * (py2 - py)
    return x, y
end

function rpg_lerp_p2(pos, pos2, p)
    local x = pos[1] + p * (pos2[1] - pos[1])
    local y = pos[2] + p * (pos2[2] - pos[2])
    return x, y
end

function rpg_dis2(x1,y1,x2,y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return floor(sqrt(dx*dx + dy*dy)) 
end

function rpg_in_circle(x, y, cx, cy, radius)
    local dx = (cx - x)
    local dy = (cy - y)
    return dx * dx + dy * dy <= radius * radius
end

function rpg_in_rect(x, y, start_x, start_y, forward_x, forward_y, width, length)
    local halfWidth = width / 2
    local localX = (x - start_x) * forward_x + (y - start_y) * forward_y
    if localX < 0 then
        return false
    end
    local localY = (x - start_x) * forward_y - (y - start_y) * forward_x
    return localX <= length and abs(localY) <= halfWidth
end

function angle_to_cos(angle)
    return cos(angle * 0.017453292519)
end

local d2g = 0.017453292519
local half_d2g = d2g * 0.5

function rpg_in_sector(x, y, cx, cy, normalized_dir_x, normalized_dir_y, radius, angle)
    local r2 = radius * radius
    local dx = x - cx
    local dy = y - cy
    local d2 = dx*dx + dy*dy
    if d2 > r2 then
        return false
    end

    local d = sqrt(d2)
    -- -----dx dy没有归一化 点乘结果为 cos(角度) * 距离d
    local dot_with_d = dx * normalized_dir_x + dy * normalized_dir_y
    local cos_half_angle_width_d = cos(angle * half_d2g) * d
    return dot_with_d >= cos_half_angle_width_d
end


rpg_raw_set = function (cells, axial_x, axial_y, value)
    cells[axial_x] = cells[axial_x] or {}
    cells[axial_x][axial_y] = value
end

rpg_raw_get = function (cells, axial_x, axial_y)
    return cells[axial_x] and cells[axial_x][axial_y]
end

rpg_raw_add = function (cells, axial_x, axial_y, value)
    local old_value = cells[axial_x] and cells[axial_x][axial_y] or 0
    cells[axial_x] = cells[axial_x] or {}
    cells[axial_x][axial_y] = old_value + value
end

-- function rpg_in_sector(x, y, cx, cy, normalized_dx, normalized_dy, radius, angle)
--     return rpg_in_circle(x, y, cx, cy, radius)
-- end