T.rpg_bullet.type_map[RPG_BULLET_TYPE.MULTI_LINE] = function(eff_env, target_orient, param)
    local count, angle = param[5][1] , param[5][2]

    local d_angle = angle / count
    local half_angle = -angle / 2

    local dir_x, dir_y = rpg_normalize(target_orient._dir_x, target_orient._dir_y)
    local caster = eff_env.ety
    local sx = target_orient._sx or caster._x
    local sy = target_orient._sy or caster._y

    for i = 1, count do
        local a = half_angle + d_angle * i
        local cos_a = angle_to_cos(a)
        local sin_a = angle_to_sin(a)

        local nx = dir_x * cos_a - dir_y * sin_a
        local ny = dir_x * sin_a + dir_y * cos_a

        local new_orient = {
            _sx = sx,
            _sy = sy,
            _x = sx + nx * 100000,
            _y = sy + ny * 100000,
            _dir_x = nx,
            _dir_y = ny
        }

        local b = T.rpg_bullet_line(eff_env, new_orient, param)
    end
end
