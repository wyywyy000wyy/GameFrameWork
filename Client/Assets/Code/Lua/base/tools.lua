function string.split(str, delimiter)
    if str == nil or str == "" or delimiter == nil then
        return nil
    end

    local results = {}
    for match in (str ..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(results, match)
    end
    return results
end

function string.splitDot(str)
    if str == nil or str == ""then
        return nil
    end

    local results = {}
    for match in (str ..'.'):gmatch("(.-)"..'%.') do
        table.insert(results, match)
    end
    return results
end

function string.splitDot2(str)
    if str == nil or str == "" then
        return nil
    end

    local results = {}

    local s = 1
    local l = 0

    for i = 1, string.len(str) do
        if str[i] ~= '.' then
            -- s = i
            l = l + 1
        else
            local tstr = string.sub(str, s, s + l) or ""
            table.insert(results, tstr)
            s = i + 1
            l = 0
        end
    end

    if l > 0 then
        local tstr = string.sub(str, s, s + l) or ""
        table.insert(results, tstr)
    end

    return results
end

function string.join(arr, delimiter)
    local s=""
    local len=#arr
    for i,v in ipairs(arr) do
        s=s..v
        if i<len then s=s..delimiter end
    end
    return s
end

function string.endwith(str, substr)
    if not str or not substr then return false end
    return string.sub(str, -string.len(substr)) == substr
end

function string.utf8_len(s)
    local _, count = string.gsub(s, "[^\128-\193]", "")
    return count
end

---按照给定的长度对传入的字符串做字节长度检测，返回布尔值：可用与否
function is_inputlen_avaliable(a_str,a_cfg_len)
    if not a_str then return false end
    if not a_cfg_len then return true end
    return #a_str >= a_cfg_len[1] and #a_str <= a_cfg_len[2]
end

function string.contains_sign(str,...)
    local signs = {...}
    for k,v in pairs(signs or {}) do
        if string.match(str,v) then
            return true
        end
    end
    return false
end

function math.round(f)
    local i,f = math.modf(f)
    if f >= 0.5 then -- >=0.5加1
        return i+1
    elseif  f < -0.5 and f < 0 then --负数 < 0.5 减1
        return i-1
    else
        return i
    end
end

function is_gbchar( _char )
    if _char >= 0x81 then
        return true
    else
        return false
    end
end

function gen_chinese_str(_str,len)
    if _str == " " then
        return _str
    end
    local length = string.len(_str)
    local i = 1
    local ret_arr = {}

    while i <= length do
        local char = string.sub(_str,i,i)
        if is_gbchar(string.byte(char)) then
            table.insert(ret_arr, string.sub(_str,i,i+2))
            i = i + 3
        else
            table.insert(ret_arr, string.sub(_str,i,i))
            i = i + 1
        end
    end
    local ret = ""
    local c = 0
    for _, w in ipairs(ret_arr) do
        c = c + 1
        ret = ret .. w
        if c >= len then
            break
        end
    end
    return ret
end

function string.starts_with(str,start_str)
    if str == start_str then return true end
    if not str or not start_str then return false end
    return start_str == string.sub(str,1,string.len(start_str))
end

function string.ends_with(str,end_str)
    if str == end_str then return true end
    if not str or not end_str then return false end
    return end_str == string.sub(str,-string.len(end_str))
end

function string.format_ex(str,tab_arg)
    if not str then return "" end
    if not tab_arg then return str end
    local match_count = 0
    for i = 1,#tab_arg do
        local pattern = string.format("{%d}",i)
        str,match_count = string.gsub(str,pattern,tostring(tab_arg[i]))
        if match_count > 1 then
            print("<color=yellow>target string has more than one pattern: "..pattern.."</color>\nstring is: "..str)
        end
    end
    return str
end

local function format_ts(s,fun)
    while true do
        local i,e=string.find(s,"{%d,%d}")
        if i==nil then
            break
        end

        local p=string.sub(s,i,e)
        local p2=string.split(string.sub(p,2,-2),",")

        s=string.gsub(s,p,fun(p2[1],p2[2]),1)
    end
    return s
end

local function replace_ts(s,i,e,r)
    local t=string.sub(s,1,i-1)
    if r==nil then return t.."[R]"..string.sub(s,e+1) end
    t=t..r..string.sub(s,e+1)
    return t
end

function string.format_ts(s,...)
    if s==nil then
        return s
    end

    local i,e=string.find(s,"%%%d%$%w")
    local arg={...}

    if i==nil then
        return string.format(s,...)
    end

    local replace_table=arg[1]
    if replace_table==nil then
        return "[R]"..s
    end

    for ijk=1,20 do
        local p=string.sub(s,i,e)
        local mtype=string.sub(p,4,4)
        local index=tonumber(string.sub(p,2,2))
        if mtype=="s" or mtype=="d" then   ---格式化字符串和数字
             if type(replace_table[index])=="table" then
                local ms=""
                for i,v in ipairs(replace_table[index]) do
                    ms=ms..v
                    if i ~= #replace_table[index] then
                        ms=ms..","
                    end
                end
                s=replace_ts(s,i,e,ms)
            else
                s=replace_ts(s,i,e,replace_table[index])
            end
        elseif mtype=="z" then ---格式化多语言字段
            if type(replace_table[index])=="table" then
                local ms=""
                for i,v in ipairs(replace_table[index]) do
                    ms=ms..resmng.get_lan(v)
                    if i ~= #replace_table[index] then
                        ms=ms..","
                    end
                end
                s=replace_ts(s,i,e,ms)
            else
                s=replace_ts(s,i,e,resmng.get_lan(replace_table[index]))
            end
        elseif mtype == "y" then  ---格式化国旗
            local lancfg = resmng.get_conf("prop_language_cfg",replace_table[index])
            if lancfg then
                s = replace_ts(s,i,e,"≙"..lancfg.Icon.."≙")
            end
        elseif mtype == "h" then  ---格式化时区偏移
            local replace_s = timekit.get_utc_timestr_1(tonumber(replace_table[index]) + timekit.get_timezone())
            s = replace_ts(s,i,e, replace_s)
        else
            break
        end

        i,e=string.find(s,"%%%d%$%w")
        if i==nil then
            break
        end
    end
    return s
end

function math.clamp(max,min,value)
    if min > max then max,min = min,max end
    if value > max then value = max end
    if value < min then value = min end
    return value
end

-- 返回最接近该数的整数
function math.round(num)
    if "integer" == math.type(num) then return num end
    if num >= 0 then
        return math.floor(num + 0.5)
    else
        return math.ceil(num - 0.5)
    end
end

-- 保留小数点后N位
function math.round_decimal(src_num,decimal)
    local _ret = src_num
    local _dig_pow = math.pow(10,decimal)
    _ret = math.round(src_num*_dig_pow)/_dig_pow
    return _ret
end

function basename(path)
    if type(path) ~= "string" then
        INFO("basename: %s not a string")
        return nil
    end

    return ((path):gsub(".*[\\/]", ""))
end

-- [反转]
function table.reverse(t)
    local ret = {}
    for k, v in pairs(t) do
        ret[v] = k
    end
    return ret
end

--清理table数据
function table.clear(tb)
    if type(tb) ~= "table" then return end

    for k, v in pairs(tb) do
        tb[k] = nil
    end
end

function table.index_of(tb, o, field)
    for k, v in ipairs(tb) do
        if field ~= nil and type(v) == "table" and v[field] == o then
            return k
        elseif v == o then
            return k
        end
    end

    return -1
end

---@param tb any[]
---@param cmp fun(ob):boolean
---@return number|nil
function table.indexof_cmp(tb, cmp)
    if not cmp then
        return nil
    end
    for i = 1, #tb do
        if cmp(tb[i]) then
            return i
        end
    end
    return nil
end

-- 对目标table的value求和
function table.get_value_sum(tab)
    local sum = 0
    for k, v in pairs(tab) do
        if "number" == type(v) then
            sum = sum + v
        end
    end
    return sum
end

-- 多层向下查找
function table.loop_find(tab,...)
    if type(tab) == "table" then
        local _value = tab
        for i,v in ipairs({...}) do
            _value = _value[v]
            if not _value then
                break
            end
        end
        return _value
    end
end

function table.max(key, ...)
    local tab_temp = {...}
    if #tab_temp <= 0 then return end
    local max = tab_temp[1]
    for i = 1,#tab_temp do
        local tab = tab_temp[i]
        if tab[key] then
            if not max[key] or max[key] < tab[key] then
                max = tab
            end
        end
    end
    return max
end

function table.min(key, ...)
   local tab_temp = {...}
    if #tab_temp <= 0 then return end
    local min = tab_temp[1]
    for i = 1,#tab_temp do
        local tab = tab_temp[i]
        if tab[key] then
            if not min[key] or min[key] > tab[key] then
                min = tab
            end
        end
    end
    return min
end

function table.find_in_table(tab,findfunc)
    local tab_res = {}
    if not tab or not next(tab) then return tab_res end
    for k,v in pairs(tab) do
        if findfunc(v) then
            table.insert(tab_res,v)
        end
    end
    return tab_res
end

-- 只比较数组类型的table元素
function table.icompare(t1, t2)
    if #t1 ~= #t2 then
        return
    end
    for k, v in ipairs(t1) do
        if t2[k] ~= v then
            if type(v) ~= "table" or type(t2[k]) ~= "table" then
                return
            end
            if not table.icompare(v, t2[k]) then
                return
            end
        end
    end
    return true
end

function table.hash_len(tab)
    local num = 0
    for _, v in pairs(tab) do
        num = num + 1
    end
    return num
end

function is_table_empty(t)
    assert(type(t) == "table", "unexpected type".. type(t))
    return next(t) == nil
end

function handler(obj, method)
    assert(obj)
    assert(method)
    return function(...)
        method(obj, ...)
    end
end

function tojson(tbl, indent)
    assert(tbl ~= nil)
    if not indent then indent = 0 end
    if indent > 5 then return "" end
    local tab=string.rep("  ",indent)
    local havetable=false
    local str="{"
    local sp=""
    if type(tbl) == "table" then
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                havetable=true
                if(indent==0) then
                    str=str..sp.."\r\n  "..tostring(k)..":"..tojson(v,indent+1)
                else
                    str=str..sp.."\r\n"..tab..tostring(k)..":"..tojson(v,indent+1)
                end
            else
                str=str..sp..tostring(k)..":"..tostring(v)
            end
            sp=";"
        end
    else
        str = "[not a table]" .. type(tbl)
    end

    if(havetable) then      str=str.."\r\n"..tab.."}"   else        str=str.."}"    end

    return str
end

function table2json(t)
        local function serialize(tbl)
                local tmp = {}
                for k, v in pairs(tbl) do
                        local k_type = type(k)
                        local v_type = type(v)
                        local key = (k_type == "string" and "\"" .. k .. "\":")
                            or (k_type == "number" and "")
                        local value = (v_type == "table" and serialize(v))
                            or (v_type == "boolean" and tostring(v))
                            or (v_type == "string" and "\"" .. v .. "\"")
                            or (v_type == "number" and v)
                        tmp[#tmp + 1] = key and value and tostring(key) .. tostring(value) or nil
                end
                if table.maxn(tbl) == 0 then
                        return "{" .. table.concat(tmp, ",") .. "}"
                else
                        return "[" .. table.concat(tmp, ",") .. "]"
                end
        end
        assert(type(t) == "table")
        return serialize(t)
end

--------------------------------------------------------------------------------
-- Function : 检查元素是否在 table 中
-- Argument : tab value
-- Return   : succ - k / fail - false
-- Others   : NULL
--------------------------------------------------------------------------------
function is_in_table(tab, value)
    if type(tab) ~= "table" then
        ERROR("Argument error: tab isn't a table, type(tab) = %s", type(tab))
        return false
    end

    for k, v in pairs (tab) do
        if v == value then
            return k
        end
    end

    return false
end


--------------------------------------------------------------------------------
-- Function : 获取 table 元素个数
-- Argument : table
-- Return   : number
-- Others   : NULL
--------------------------------------------------------------------------------
function get_table_valid_count(tab)
    if not tab then
        return 0
    end

    local count = 0
    for k, v in pairs(tab) do
        if v then count = count + 1 end
    end

    return count
end


--------------------------------------------------------------------------------
-- Function : 时间戳转字符串
-- Argument : timestamp
-- Return   : NULL
-- Others   : timestamp 为空则取当前时间
--------------------------------------------------------------------------------
function timestamp_to_str(timestamp)
    return os.date("%Y-%m-%d %X", timestamp or timekit.get_server_time())
end

function tab_to_timestamp(tab)
    local temp = {year = 2017, month = 1, day = 1, hour = 0, min = 0, sec = 0}
    local idx =
    {
        year = 1,
        month = 2,
        day = 3,
        hour = 4,
        min = 5,
        sec = 6
    }
    for k, v in pairs(temp) do
        if tab[idx[k]] then
            temp[k] = tab[idx[k]]
        end
    end
    return os.time(temp)
end

--计算在一条直线上的点 cx,cy是否在在线段内部
function calc_is_point_in_segment(cx,cy,sx,sy,dx,dy)
    return math.abs(dx-sx)==math.abs(cx-sx)+math.abs(dx-cx) and math.abs(dy-sy)==math.abs(cy-sy)+math.abs(dy-cy)
end

--[[
    @desc: 点是否在矩形内部
    author:Zhao
    time:2018-05-07 16:31:52
    return bool
]]
function is_in_rect(rect, point)
    if point[1] >= rect.x1 and point[1] <= rect.x2 then
        if point[2] >= rect.y1 and point[2] <= rect.y2 then
            return true
        end
    end
    return false
end

--线段与矩形相交
function calc_crosspoint(sx, sy, dx, dy, rect)
    local crosspoint = {}

    local point_start = {sx, sy}
    local point_end = {dx, dy}
    if is_in_rect(rect,point_start) and is_in_rect(rect,point_end) then  ---起点和终点在rect的内部
        table.insert( crosspoint, point_start )
        table.insert( crosspoint, point_end )
    end
    if #crosspoint > 0 then return crosspoint,true end

    if sx == dx then
        if  sx >= rect.x1 and sx <= rect.x2 then
            local miny = math.min(sy, dy)
            local maxy = math.max(sy, dy)

            if miny < rect.y1 and maxy > rect.y1 then table.insert(crosspoint,{sx, rect.y1}) end
            if miny < rect.y2 and maxy > rect.y2 then table.insert(crosspoint,{sx, rect.y2}) end

            if #crosspoint > 0 then return crosspoint end
        end
        return nil
    elseif sy == dy then
        if sy >= rect.y1 and sy <= rect.y2 then
            if sx > dx then sx,dx = dx,sx end
            if sx < rect.x1 and dx > rect.x1 then table.insert(crosspoint,{rect.x1,sy}) end
            if dx < rect.x2 and dx > rect.x2 then table.insert(crosspoint,{rect.x2,sy}) end
            if #crosspoint > 0 then return crosspoint end
        end
        return nil
    end

    --y = kx + b
    local k = (sy - dy) / (sx - dx)
    local b = sy - k * sx
    local function get_linear_y(x) return k * x + b end
    local function get_linear_x(y) return (y - b) / k end

    local y1 = get_linear_y(rect.x1)
    if y1 > rect.y1 and y1 < rect.y2 then
        if calc_is_point_in_segment(rect.x1, y1,sx,sy,dx,dy) then
            table.insert(crosspoint, {rect.x1, y1})
        end
    end

    local x1 = get_linear_x(rect.y1)
    if x1 > rect.x1 and x1 < rect.x2 then
        if calc_is_point_in_segment(x1, rect.y1,sx,sy,dx,dy) then
            table.insert(crosspoint, {x1, rect.y1})
        end
    end

    local y2 = get_linear_y(rect.x2)
    if y2 > rect.y1 and y2 < rect.y2 then
        if calc_is_point_in_segment(rect.x2, y2,sx,sy,dx,dy) then
            table.insert(crosspoint, {rect.x2, y2})
        end
    end

    local x2 = get_linear_x(rect.y2)
    if x2 > rect.x1 and x2 < rect.x2 then
        if calc_is_point_in_segment(x2, rect.y2,sx,sy,dx,dy) then
            table.insert(crosspoint, {x2, rect.y2})
        end
    end

    if #crosspoint > 0 then return crosspoint end
end

-- 计算年月日组合
function get_format_day(timestamp)
    local time = timestamp + TIME_ZONE
    local t = os.date("*t", time)
    return string.format("%s/%s/%s", t.year, t.month, t.day)
end


--计算两个时间戳间隔的天数
function get_diff_days(timestamp1, timestamp2)
    local days1 = math.floor((timestamp1 + TIME_ZONE) / 86400)
    local days2 = math.floor((timestamp2 + TIME_ZONE) / 86400)
    return math.abs(days1 - days2)
end

--计算1970年1月1日到当前的天数
function get_days(timestamp)
    return math.floor((timestamp + TIME_ZONE) / 86400)
end

--计算这个时间戳是当天的第几个小时
function get_cur_hour(timestamp)
    local s = timestamp % 86400
    return math.floor(s / 3600)
end

function get_next_day_stamp(timestamp, offset)
    offset = offset or 1
    local dest_days = get_days(timestamp) + offset
    return (dest_days * 86400)
end

function get_next_round_stamp(timestamp, round_time, offset)
    offset = offset or 1
    local count = math.floor(timestamp / round_time) + offset
    return count * round_time
end

function get_wdays(timestamp)
    return math.floor((timestamp + SECONDS_ONE_DAY * 4) / SECONDS_ONE_DAY) % 7
end

function t_random(t)--序列化随机
    local n =0
    for _,v in pairs (t) do
        n = n+v
    end
    local p = math.random(n)
    n=0
    for k,v in pairs (t) do
        n = n+v
        if p <= n then
            return k
        end
    end
end

-- 第二天零点
function get_next_time()
    local now = os.date("!*t", timekit.get_server_time())
    local temp = { year=now.year, month=now.month, day=now.day + 1, hour=0, min=0,sec=0 }
    return os.time(temp) + timekit.get_timezone() --服务器时区为utc-0
end

function get_timekit_next_time()
    local server_time = timekit.get_server_time()
    local time = os.date("!*t", server_time)
    local next_day_time = os.time({year = time.year, month = time.month, day = time.day + 1, hour = 0}) + timekit.get_timezone()
    return next_day_time
end

function can_date(time, cur)--是否跨天
    if (not time) or (time == 0)  then return true end

    cur = cur or timekit.get_server_time()

    return (get_diff_days(time, cur) > 0)

    --local zone = tm_zone()

    --if os.date("%d", cur+zone )~=os.date("%d",time+zone ) then
    --    return true
    --end
    --return false
end

function can_month(time,cur)--是否跨月

    if (not time) or (time == 0)  then return true end
    cur = cur or timekit.get_server_time()
    if (not cur) or (cur == 0) then return true end
    return (get_diff_days(time, cur) > 30)
end

function can_weekly(time, cur) --是否跨周
    if (not time) or (time == 0)  then return true end
    cur = cur or timekit.get_server_time()
    if (not cur) or (cur == 0) then return true end
    if get_diff_days(time, cur) > 7 then
        return true
    end

    local now = os.date("*t", cur)
    local tm = os.date("*t", time)
    if tm.day < now.day then
        return true
    end
end


function calc_pow(lv, builds, arms, equips, techs, genius, heros)
    local pow = 0

    local conf = resmng.get_conf("prop_level", lv)
    if conf then
        pow = pow + conf.Pow
    end

    for _, v in pairs(builds or {}) do
        local conf = resmng.get_conf("prop_build", v.propid)
        if conf then
            if conf.Pow then
                pow = pow + (conf.Pow or 0)
            else
                print("build no pow, id = ", conf.ID)
            end
        end
    end

    -- for id, num in pairs(arms or {}) do
    --     local conf = resmng.get_conf("prop_arm", id)
    --     if conf then
    --         pow = pow + conf.Pow * num
    --     end
    -- end

    for _, v in pairs(equips or {}) do
        if v.pos > 0 then
            local conf = resmng.get_conf("prop_equip", v.propid)
            if conf then
                pow = pow + (conf.Pow or 0)
            end
        end
    end

    for _, v in pairs(techs or {}) do
        local conf = resmng.get_conf("prop_tech", v)
        if conf then
            pow = pow + (conf.Pow or 0)
        end
    end

    for _, v in pairs(genius or {}) do
        local conf = resmng.get_conf("prop_genius", v)
        if conf then
            pow = pow + (conf.Pow or 0)

        end
    end

    for _,v in pairs(heros or {}) do
        if v.status == HERO_STATUS_TYPE.FREE or v.status == HERO_STATUS_TYPE.BUILDING or
           v.status == HERO_STATUS_TYPE.MOVING or v.status == HERO_STATUS_TYPE.BEING_CURED then
           pow = pow + (v.fight_power or 0)
        end
    end

    return math.ceil(pow)
end

function calc_res(res_id,res_num) --计算资源单位量
    local prop = resmng.get_conf("prop_resource", res_id)
    if not prop then return res_num end
    return res_num * prop.Mul
end

function calc_acc_gold(total)
    local orig = total
    if total <= 0 then return 0 end
    local cost = 0
    for k, v in ipairs(CLEAR_CD_COST) do
        if total >= v[1] then
            cost = cost + v[2]
            total = total - v[1]
        else
            cost = cost + total * v[2] / v[1]
            total = 0
            break
        end
    end
    if total > 0 then
        local v = CLEAR_CD_COST[ #CLEAR_CD_COST ]
        cost = cost + total * v[2] / v[1]
    end
    -- print("time_to_gold", orig, cost)
    return math.ceil( cost )
end

function calc_buyres_gold(res_num, res_id)
    if res_id == resmng.DEF_RES_SILVER then
        return math.ceil(res_num/BUY_SILVER_COST)
    end
    local orig = res_num
    local total = RES_RATE[ res_id ]  * res_num
    if total < 1 then return 0 end
    local cost = 0
    for k, v in ipairs(BUY_RES_COST) do
        if total >= v[1] then
            cost = cost + v[2]
            total = total - v[1]
        else
            cost = cost + math.ceil(total * v[2] / v[1])
            total = 0
            break
        end
    end
    if total > 0 then
        local v = BUY_RES_COST[ #BUY_RES_COST ]
        cost = cost + math.ceil(total * v[2] / v[1])
    end
    -- print("res_to_gold", res_id, orig, cost)
    return cost
end

function get_taxrate(propid,effect)--获取税率
    local c = resmng.get_conf("prop_build",propid)
    if c.Mode ~= BUILD_FUNCTION_MODE.MARKET then
        return 45
    end
    return (c.Effect.CountTax + (effect or 0))
end

function get_castle_count(member_count)
    local count = 0
    if member_count < UNION_CASTALCOUNT_LIMIT[1] then
        return count
    end
    count = 1 + math.floor((member_count - UNION_CASTALCOUNT_LIMIT[1]) / UNION_CASTALCOUNT_LIMIT[2])
    return count
end

function get_can_occupycity_count(member_count)
    local cfg_consume = resmng.get_conf("prop_tw_union_consume",1)
    if member_count < cfg_consume.Condition[1] then
        return 0
    end
    return 1 + math.floor((member_count - cfg_consume.Condition[1]) / cfg_consume.Condition[2])
end

function table_count(tab)
    local n = 0
    for k, v in pairs(tab or {}) do
        n = n + 1
    end
    return n
end

function recalc_sinew( val, tm, now, mul )
    if val > 100 then return val end
    local elaps = now - tm
    local inc = elaps * mul / 300
    local total = val + inc
    if total > 100 then total = 100 end
    if total < 0 then total = 0 end
    return total
end

--------------------------------------------------------------------
--解析奖励
--------------------------------------------------------------------
-- function analysis_award(tab, culture, close_open)
--     local list = {}
--     local box = {}

--     for k, v in pairs(tab) do
--         local unit = {}
--         unit.type, unit.id, unit.num = unpack(v)
--         local prop_tmp = nil
--         if unit.type == "item" then
--             local array = ana_item(unit, culture, close_open)
--             if array ~= nil then
--                 for i = 1, #array, 1 do
--                     table.insert(list, array[i])
--                 end
--             end

--             --第一层物品信息
--             local prop_tab = resmng.prop_itemById(unit.id)
--             if prop_tab ~= nil and prop_tab.Open == 1 then
--                 local temp = {}
--                 temp.id = unit.id
--                 temp.icon = prop_tab.Icon
--                 temp.grade = prop_tab.Color or 1
--                 temp.name = prop_tab.Name
--                 table.insert(box, temp)
--             end
--             if nil == prop_tab then
--                 utils.printwarning("got nil item config of id:",unit.id)
--             end
--         elseif unit.type == "res" or unit.type == "respicked" then
--             ana_res(unit)
--             table.insert(list, unit)

--         elseif unit.type == "hero" then
--             ana_hero(unit)
--             table.insert(list, unit)

--         elseif unit.type == "soldier" then
--             ana_solider(unit, culture)
--             table.insert(list, unit)

--         elseif unit.type == "equip" then
--             ana_equip(unit)
--             table.insert(list, unit)
--         end
--     end
--     return list, box
-- end

-- function ana_item(unit, culture, close_open)
--     local prop_tab = resmng.prop_itemById(unit.id)
--     if prop_tab == nil then
--         return nil
--     end
--     local src_num = unit.num
--     local list = {}
--     if prop_tab.Open == 0 or close_open == true or prop_tab.Action == "LevelAward" then
--         unit.icon = prop_tab.Icon
--         unit.grade = prop_tab.Color or 1
--         unit.name = prop_tab.Name
--         table.insert(list, unit)
--     else
--         for _, info in pairs(prop_tab.Param) do
--             for k, v in pairs(info[2]) do
--                 local tmp = {}
--                 tmp.type, tmp.id, tmp.num = unpack(v)
--                 if tmp.type == "item" then
--                     local prop_tmp = resmng.prop_itemById(tmp.id)
--                     if prop_tmp ~= nil then
--                         tmp.icon = prop_tmp.Icon
--                         tmp.grade = prop_tmp.Color or 1
--                         tmp.name = prop_tmp.Name
--                     end
--                 elseif tmp.type == "res" or tmp.type == "respicked" then
--                     ana_res(tmp)
--                 elseif tmp.type == "hero" then
--                     ana_hero(tmp)
--                 elseif tmp.type == "soldier" then
--                     ana_solider(tmp, culture)
--                 elseif tmp.type == "equip" then
--                     ana_equip(tmp)
--                 end
--                 tmp.num = tmp.num * src_num
--                 table.insert(list, tmp)
--             end
--         end
--     end
--     return list
-- end

-- function ana_res(unit)
--     local prop_tab = resmng.prop_resourceById(unit.id)
--     if prop_tab == nil then
--         return
--     end
--     unit.icon = prop_tab.IconBig
--     unit.grade = prop_tab.Color or 1
--     unit.name = prop_tab.Name
-- end

-- function ana_hero(unit)
--     local prop_tab = resmng.prop_hero_basicById(unit.id)
--     if prop_tab == nil then
--         return
--     end
--     unit.icon = prop_tab.Icon
--     unit.grade = prop_tab.Quality or 1
--     unit.name = prop_tab.Name
-- end

-- function ana_solider(unit, culture)
--     local real_id = culture * 1000000 + unit.id
--     local prop_arm = resmng.prop_armById(real_id)
--     if prop_arm == nil then
--         return
--     end
--     unit.id = real_id
--     unit.icon = prop_arm.Icon
--     unit.grade = 1
--     unit.name = prop_arm.Name
-- end

--获取skill技能描述
function get_skill_detail(id , usearg)

    local cfg = resmng.prop_skillById(id)
    if cfg == nil then
        Logger.LogerWYY2("hero_util.get_skill_detail 没有取到prop_skill数据 id: " .. id)
        return ""
    end
    --保证展开的参数一定是对的
    local tab = {}
    if usearg == nil then
        tab ={}
        tab.lv = cfg.Lv
        tab.coeff = 1
    elseif type(usearg) == "number" then
        tab.lv = cfg.Lv
        tab.coeff = usearg
    elseif type(usearg) == "table" then
        tab.lv = usearg.lv or cfg.Lv
        tab.coeff = usearg.coeff or 1
    else
        tab.lv = cfg.Lv
        tab.coeff = 1
    end
    local  NumChange = {}
    if cfg.NumChange ~= nil then
        NumChange = cfg.NumChange
    end
    if cfg.DetailARG then
        local args = {}
        for i , v in pairs(cfg.DetailARG) do
            local value = do_skill_extend(v , tab,NumChange[i])
            table.insert(args,value)
        end
        return hero_util.propLanguageById(cfg.Detail, args)
    else
        return resmng.get_lan(cfg.Detail)
    end
end

--获取skill技能描述
function get_common_skill_detail( Detail , DetailARG , usearg,NumChange)
    --保证展开的参数一定是对的
    local tab = {}
    if usearg == nil then
        tab ={}
        tab.lv = 1
        tab.coeff = 1
    else
        tab = usearg
    end
    if NumChange == nil then
        NumChange = {}
    end
    if DetailARG then
        local args = {}
        for i , v in pairs(DetailARG) do
            local value = do_skill_extend(v , tab , NumChange[i])
            table.insert(args,value)
        end
        return hero_util.propLanguageById(Detail, args)
    else
        return resmng.get_lan(Detail)
    end
end
-- [ 计算展开值 ]
function do_skill_extend(idx, args, NumChange)
    local value = idx
    if lua_types.is_string(idx) then
       -- local key = resmng[idx]
        local rule = conf_util.get_or_create_extend_rule(idx)
        if not rule then
            Logger.LogError("conf_util.get_or_create_extend_rule is nil :" .. idx)
            return idx
        else
            value = rule(args.coeff , args.lv) --resmng.prop_skill_extend[key]
        end
    end

    if NumChange and NumChange == 1 then
        local ve = math.floor(value) * 0.01
        local dcl = get_decimal_part(ve)
        if dcl > 0 then
            local sv = tostring(ve) .."%"
            return sv
        else
            local sv = tostring(math.floor(ve)) .."%"
            return sv
        end
    else
        local dcl = get_decimal_part(value)
        if dcl <= 0 then
            value = math.floor(value)
        end
    end
    return value
end

function get_decimal_part(num)
    local integer_part = math.floor(num)
    local decimal_part = num - integer_part
    return decimal_part
end



--@return nubmer
function do_skill_extend_number(idx, args)
    if lua_types.is_string(idx) then
        local key = resmng[idx]
        local cfg = conf_util.get_or_create_extend_rule(key) --resmng.prop_skill_extend[key]
        if not cfg or not cfg._Rule then
            ERROR("[%s] do_extend: invalid extend rule. ID=%s", _NAME, idx)
        else
            local value = cfg._Rule(args)
            if cfg.NumAbsolute == 1 then
                value = math.abs(value)
            end
            if cfg.NumChange == 1 then
                local sv = value * 0.01
                return sv
            end
            return value
        end
    end
    return idx
end

function ana_equip(unit)
    local prop_tab = resmng.prop_equipById(unit.id)
    if prop_tab == nil then
        return
    end
    unit.icon = prop_tab.Icon
    unit.grade = prop_tab.Class or 1
    unit.name = prop_tab.Name
end

function is_in_black_land( x, y )
    --return  x >= 512 and x < 512 + 256 and y >= 512 and y < 512 + 256
    return  x >= 608 and x < 608 + 64 and y >= 608 and y < 608 + 64  -- 640 - 16 * 2
end

function is_hit_black_land( x, y, size )
    return is_intersec( x, y, size, 608, 608, 64 )
end

function is_intersec( x1, y1, w1, x2, y2, w2 )
    local minx = math.min( x1, x2 )
    local maxx = math.max( x1 + w1, x2 + w2 )
    local miny = math.min( y1, y2 )
    local maxy = math.max( y1 + w1, y2 + w2 )

    return math.max( maxx - minx, maxy - miny ) < w1 + w2
end

function is_union_construct(propid)
    local cfg = resmng.get_conf("prop_world_unit",propid)
    if cfg then
        return cfg.Class == BUILD_CLASS.UNION
    end
    return false
end

function is_union_miracal(propid)
    local cfg = resmng.get_conf("prop_world_unit",propid)
    if cfg and is_union_construct(propid) then
        return cfg.Mode > 20
    end
    return false
end

function is_union_miracal_main(propid)
    local cfg = resmng.get_conf("prop_world_unit",propid)
    if cfg and is_union_construct(propid) then
        return cfg.Mode > 20 and cfg.Mode < 30
    end
    return false
end

function is_union_miracal_small( propid )
    local cfg = resmng.get_conf("prop_world_unit",propid)
    if cfg and is_union_construct(propid) then
        return cfg.Mode > 30 and cfg.Mode < 40
    end
    return false
end

---return define.lua near 1096 CULTURE_TYPE
function get_union_miracal_culture(propid)
    local cfg = resmng.get_conf("prop_world_unit",propid)
    if cfg and is_union_miracal(propid) then
        return cfg.Mode % 10
    end
    return CULTURE_TYPE.EAST   ---出现任何不满足的情况都默认返回东方文明
end

function is_union_superres(propid)
    local cfg = resmng.get_conf("prop_world_unit",propid)
    if cfg and is_union_construct(propid) then
        return cfg.Mode == resmng.CLASS_UNION_BUILD_FARM or
               cfg.Mode == resmng.CLASS_UNION_BUILD_LOGGINGCAMP or
               cfg.Mode == resmng.CLASS_UNION_BUILD_MINE or
               cfg.Mode == resmng.CLASS_UNION_BUILD_QUARRY
    end
    return false
end

function is_union_restore(propid)
    local cfg = resmng.get_conf("prop_world_unit",propid)
    if cfg and is_union_construct(propid) then
        return cfg.Mode == resmng.CLASS_UNION_BUILD_RESTORE
    end
    return false
end

function clr_bit( val, idx )
    val = math.floor( val )
    local n1 = 2 ^ idx
    local n0 = 2 ^ (idx - 1)

    local remain = val % n1
    if remain >= n0 then
        val = val - n0
    end
    return math.floor( val )
end

-- the first bit idx is 1, not 0
function set_bit( val, idx )
    val = math.floor( val or 0 )
    local n1 = 2 ^ idx
    local n0 = 2 ^ (idx - 1)

    local remain = val % n1
    if remain < n0 then
        val = val + n0
    end
    return math.floor(val)
end

-- the first bit idx is 1, not 0
function get_bit( val, idx )
    local n1 = 2 ^ idx
    local n0 = 2 ^ (idx - 1)

    local remain = val % n1
    if remain < n0 then return 0
    else return 1 end
end

-- 获取table的位
function get_tab_bit(tab, idx)
    local n = math.floor((idx-1) / 32) + 1
    local i = ((idx-1) % 32) + 1
    local val = tab[n] or 0
    return get_bit(val, i)
end

-- 设置table的位
function set_tab_bit(tab, idx, is_true)
    local n = math.floor((idx-1) / 32) + 1
    local i = ((idx-1) % 32) + 1
    tab[n] = tab[n] or 0
    if is_true then
        tab[n] = set_bit(tab[n], i)
    else
        tab[n] = clr_bit(tab[n], i)
    end
end



function get_first_zero( val )
    for i = 1, 32, 1 do
        if get_bit( val, i ) == 0 then return i end
    end
end

function format_time(time)
    local hour = math.floor(time/3600);
    local minute = math.fmod(math.floor(time/60), 60)
    local second = math.fmod(time, 60)

    local rtTime = ""
    if hour ~= 0 then
        rtTime = string.format("%s:%s", hour, minute)
    else
        rtTime = string.format("%s",  minute)
    end
    return rtTime
end

function can_enter_reszone_lv( lv_castle )
    --if lv_castle <  6 then return 1 end
    if lv_castle < 10 then return 2 end
    if lv_castle < 12 then return 3 end
    if lv_castle < 15 then return 4 end
    return 6
end

function enter_lvreszone_need(lv_pos)
    if lv_pos == 1 then return 0 end
    if lv_pos == 2 then return 0 end
    if lv_pos == 3 then return 10 end
    if lv_pos == 4 then return 12 end
    return 15
end

function can_enter( lv_castle, lv_pos )
    --if lv_castle <  6 then return lv_pos <= 1 end
    if lv_castle < 10 then return lv_pos <= 2 end
    if lv_castle < 12 then return lv_pos <= 3 end
    if lv_castle < 15 then return lv_pos <= 4 end
    return true
end

function check_union_cross(union)
    if not union then
        return false
    end
    local u = {}
    if type(union) == "number" then
        u = union_mng:get_union(union) or {}
    else
        u = union
    end
    if not u.map_id then
        return false
    end
    return true
end

function check_ply_cross(ply)
    local union = union_mng.get_union(ply.uid)
    if union then
        return check_union_cross(union)
    end
    return  ply.emap ~= gMapID and ply.emap ~= 0
    --return false
--    local p = {}
--    if type(ply) == "number" then
--        p = getPlayer(ply) or {}
--    else
--        p = ply
--    end
--    if not p.map_id then
--        return false
--    end
 --   return true
end

function is_center_server()
    return gCenterID == gMapID
end

--------------------------------------------------------------------
--------------------------------------------------------------------


--------------------------------------------------------------------------------
-- 常用调试函数，简写函数名
--p = dumpTab   -- 全局p 容易和很多局部 p 造成混淆不要使用

--判定串的第一个字符是否为数字字符
function is_valid_chinese_char( s )
    if( type(s) == "string" and string.len(s) == 2 )then
        local hi   = string.byte( string.sub( s, 1, 1 ) )
        local low  = string.byte( string.sub( s, 2 ) )
        if(( hi >= 0xb0 and hi <= 0xf7 ) and ( low >= 0xa1 and low <= 0xfe) )then
            return true
        elseif( hi == 0xa1 and ( low >= 0xa2 and low <= 0xfe ) )then
            return true
        elseif( hi == 0xa3 and ( low >= 0xa1 and low <= 0xfe ) )then
            return true
        elseif( hi == 0xa4 and ( low >= 0xa1 and low <= 0xf3 ) )then
            return true
        elseif( hi == 0xa5 and ( low >= 0xa1 and low <= 0xf6 ) )then
            return true
        elseif( hi == 0xa9 and ( low >= 0xa4 and low <= 0xef ) )then
            return true
            --GBK/5：扩充非汉字
        elseif( hi == 0xa8 and ( low >= 0x40 and low <= 0x95 ) )then
            return true
            --GBK/4: 扩充汉字
        elseif( ( hi >= 0xaa and hi <= 0xfd ) and ( low >= 0x40 and low <= 0x9f ) ) then
            return true
            --GBK/3: 扩充汉字
        elseif ( ( hi >= 0x81 and hi <= 0xa0 ) and ( low >= 0x40 and low <= 0xff ) ) then
            return true
        else
            return false
        end
    else
        return false
    end
end

--数字和字母字符
function is_alpha_num_char( s )
    if( type(s) == "string" and string.len(s) == 1 )then
        if( string.match( s, "%w") )then
            return true
        else
            return false
        end
    else
        return false
    end
end

--只包含数字和字母字符的字符串
function is_alpha_num_string( s )
    if( type(s) == "string" and string.len(s) > 0 )then
        if( string.match( s, "^[A-Za-z0-9]*$") )then
            return true
        else
            return false
        end
    else
        return false
    end
end


--标点符号字符
function is_punctuation_char( s )
    if( type(s) == "string" and string.len(s) == 1 )then
        if( string.match( s, "%p") )then
            return true
        else
            return false
        end
    else
        return false
    end
end

--判定串的第一个字符是否为数字字符
function is_digit2( ch )
    if( type(ch) == "string" )then
        if( ch >= '0' and ch <= '9' )then
            return true
        else
            return false
        end
    else
        return false
    end
end

--判定字符是否为程序保留关键字
program_keyword = { [','] = true, [';'] = true, ['/'] = true, ['\''] = true, ['\\'] = true, ['%'] = true, ['?'] = true, ['#'] = true, ['<'] = true, ['>'] = true }
function is_program_keyword( ch )
    if( program_keyword[ch] == true )then
        return true
    else
        return false
    end
end

--必须为汉字、数字、字母、标点符号字符串
function is_valid_name( s )
    if( type(s) == "string" )then
        local length = string.len(s)
        local i = 1

        while( i <= length ) do
            local first_char = string.sub( s, i, i )
            if( is_program_keyword( first_char ) == true )then
                return false
            elseif( is_alpha_num_char( first_char ) == false )then
                if( is_punctuation_char( first_char ) == true )then
                    return false
                end
            end
            i = i + 1
        end
    else
        return false
    end
    return true
end

---这个检测全列表屏蔽符号，检查是不是包含屏蔽符号，限制范围大
--中文标点符号暂未找到屏蔽方案
function check_signs_valid(str)
    if not str or #str < 1 then return true end
    for k,v in pairs(FORBID_SIGNS) do
        if string.find(str,k) then
            return false
        end
    end
    return true
    -- print(string.match(str,"[%p%s\a\b\n\t\r\v\f\'\"]"))
    -- return nil == string.find(str,"[%p%s\a\b\n\t\r\v\f\'\"]")
end

---这个只检测强屏蔽符号，去掉函数中的强屏蔽符号，限制范围小
function check_valid_input(s)
    local regular = { ['<'] = true, ['>'] = true,['\r']=true, ['\n']=true }

    local rst=""
    if( type(s) == "string" )then
        local length = string.len(s)
        local i = 1

        while i <= length do
            local first_char = string.sub( s, i, i )
            if not regular[first_char] then
                rst=rst..first_char
            end
            i = i + 1
        end
    end
    return rst
end

--洗牌算法，用于将一组数据等概率随机打乱。等概率算法。
function shuffle(t)
    if not t then return end
    local cnt = #t
    for i=1,cnt do
        local j = math.random(i,cnt)
        t[i],t[j] = t[j],t[i]
    end
end

function shuffle_by_range(t, start, end_idx)
    if not t then return end
    for i= start, end_idx, 1 do
        local j = math.random(i, end_idx)
        t[i],t[j] = t[j],t[i]
    end
end

--分红包算法
function split(m,n)
    --构造m-1个可用的分割标记位
    local mark = {}
    for i=1,m-1 do
        mark[i] = i
    end

    --打乱标所有记位
    shuffle(mark)
    --构建一个新的表，并从mark表中取前n-1个位置作为有效标记位
    local validMark = {}
    for i=1,n-1 do
        validMark[i] = mark[i]
    end

    --重新按从小到大排序有效标记
    table.sort(validMark,function (a,b)
        return a<b
    end)

    --设置有效标记表的头、尾分别为0和m
    validMark[0] = 0
    validMark[n] = m
    --构建输出数组
    local out = {}
    for i=1,n do
        out[i] = validMark[i] - validMark[i-1]
    end
    return out
end


function tm_zone() --时区差   --全部使用 utc 0点
    --local now = os.time()
    --return os.difftime(now, os.time(os.date("*t", now)))
    return 0
end

function get_npc_state()
    local now = os.date("*t", timekit.get_server_time())
    local startHour = resmng.prop_tw_stage[TW_STATE.DECLARE].Start.hour
    local endHour = resmng.prop_tw_stage[TW_STATE.DECLARE].End.hour
    local startMin = resmng.prop_tw_stage[TW_STATE.DECLARE].Start.min
    local endMin = resmng.prop_tw_stage[TW_STATE.DECLARE].End.min
    local startTime = 0
    local endTime = 0
    local state = 1
    local temp = { year=now.year, month=now.month, day=now.day, hour=0, min=0, sec=0 }
    if now.hour >= startHour and now.hour < endHour then
        state = TW_STATE.DECLARE
        temp.hour = startHour
        temp.min = startMin
        startTime = os.time(temp)
        temp.hour = endHour
        endTime = os.time(temp)
    elseif now.hour >= endHour then
        state = TW_STATE.PACE
        temp.hour = endHour
        temp.min = endMin
        startTime = os.time(temp)
        temp.hour = startHour
        endTime = os.time(temp) + 24 * 3600
    elseif now.hour < startHour then
        state = TW_STATE.PACE
        startTime = timekit.get_server_time()
        temp.hour = startHour
        temp.min = startMin
        endTime = os.time(temp)
    end
    return state, startTime, endTime
end

--屏蔽字
------------------------------------------------------------------------------
function string.replace(str, tofind, toreplace)
    tofind = string.gsub(tofind, "[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%1")
    toreplace = string.gsub(toreplace, "%%", "%%%1")
    return (string.gsub(str, tofind, toreplace))
end

------------------------
--客户端用
------------------------
function is_include_filter(str)
    str = string.lower( str )
    if resmng.prop_filterData then
        local filter_map = resmng.prop_filterData
        for _, v in pairs(filter_map) do
            if string.find(str, v[2]) then
                return true
            end
        end
        return false
    else
        local filter_map = resmng.prop_filter
        for _, v in pairs( filter_map ) do
            if string.find( str, v.Filter ) then
                return true
            end
        end
    end
end

--屏蔽字替换
function replace_filter(str)
    local filter_map = resmng.prop_filterData
    for _, v in pairs(filter_map) do
        str = string.replace(str, v[2], "*")
    end
    return str
end
------------------------
------------------------

------------------------
--服务器用
------------------------
function is_include_filter_server(str)
    local filter_map = resmng.prop_filter
    for _, v in pairs(filter_map) do
        if string.find(str, v.Filter) then
            return true
        end
    end
    return false
end
------------------------
------------------------
------------------------------------------------------------------------------
function check_name_avalible(str,c)
    if str == "" then
        return false, resmng.LORD_NAME_INPUT_EMPTY
    elseif not is_inputlen_avaliable(str,(c or {})[CHA_LIMIT.Lord_Name]) then
        return false, resmng.LORD_NAME_INPUT_TOOLONG
    elseif not check_signs_valid(str) then
        return false, resmng.LORD_NAME_CHARACTOR_FORBID
    elseif is_include_filter(str) then
        return false, resmng.PLAYER_NAME_TIPS
    end
    return true
end

function get_zero_tm(tm)
    local tm_t = os.date("*t", tm)
    local temp = { year=tm_t.year, month=tm_t.month, day=tm_t.day, hour=0, min=0, sec=0 }
    return os.time(temp)
end

function resmng_update(diff_file)
    local mod
    local prop = {}
    for line in io.lines(diff_file) do
        local new  = string.match(line,"([%w_]*).lua$" ) --获取模块名
        if new == "prop_language" then new = "propLanguage" end
        mod = new or mod

        if string.find(mod,"prop") then
            local a,b,c  = string.match(line,"^([+-])%s*(%b[])%s*=%s*(%b{})" )
            if a == "-" then
                b = string.sub(b, 2, -2)
                print(mod,a,b,c)
                table.insert(prop ,{mod,b,nil})
            elseif a == "+" then
                b = string.sub(b, 2, -2)
                c = loadstring("return "..c)()
                print(mod,a,b,c)
                table.insert(prop ,{mod,b,c})
            end
        elseif string.find(mod,"define") then
            local m = string.gsub(mod,"define","prop")
            local a,b,c  = string.match(line,"^([+-])([%w_]*) = (%d+)" )
            print(m,a,b,c)
            if a == "-" then
                local t,id = resmng[m] ,resmng[b]
              if t and id then t[id]= nil end
                resmng[b]= nil
            elseif a == "+" then
                resmng[b]=c
            end
        end

    end

    for _,v in ipairs(prop) do
        local t,id = resmng[v[1]], resmng[v[2]]
        if id and  t then t[id] = v[3] end
    end
end

local ref_mng = {}
ref_mng.__index = ref_mng

function createRef(...)
    local instance = setmetatable({}, ref_mng)
    instance:init(...)
    return instance
end

function ref_mng:init(max_ref, cur_ref)
    self.max_ref = max_ref
    self.cur_ref = cur_ref or 0
    self.min_ref = self.cur_ref
    self.freed_refs = {[0] = 0}
end

function ref_mng:ref()
    local r = self.freed_refs[0]
    if 0 ~= r then
        self.freed_refs[0] = self.freed_refs[r]
        self.freed_refs[r] = nil
    else
        if self.cur_ref >= self.max_ref then
            return
        end
        r = self.cur_ref + 1
        self.cur_ref = r
    end
    return r
end

function ref_mng:unref(r)
    if self.min_ref >= r or r > self.cur_ref or self.freed_refs[r] then
        return
    end
    self.freed_refs[r] = self.freed_refs[0]
    self.freed_refs[0] = r
end

function ref_mng:print()
    WARN("dumping ref_mng(%s) %d|%d", self, self.cur_ref, self.max_ref)
    for k, v in pairs(self.freed_refs) do
        WARN("\t%d -> %d", k, v)
    end
    WARN("dumping ref_mng(%s) is done", self)
end

function ref_mng_test()
    local ins = createRef(20, 5)
    local ins2 = createRef(5, 0)
    local function do_ref()
        WARN("ref %s", ins:ref())
    end
    local function do_unref(r)
        ins:unref(r)
        WARN("unref %d", r)
    end
    local function do_ref2()
        WARN("ref2 %s", ins2:ref())
    end
    local function do_unref2(r)
        ins2:unref(r)
        WARN("unref2 %d", r)
    end
    do_ref()
    do_ref()
    do_ref()
    do_ref()
    do_ref()
    do_ref2()
    do_ref2()
    do_ref()
    do_ref()
    do_ref()
    do_unref(12)
    do_unref(7)
    do_unref(7)
    do_unref(3)
    do_unref(5)
    do_unref(10)
    do_unref(11)
    do_unref2(1)
    do_ref2()
    do_ref2()
    do_ref2()
    ins:print()
    do_ref()
    do_ref()
    do_unref(9)
    ins:print()
    do_ref()
    do_ref()
    do_ref()
    do_unref(8)
    do_ref()
    ins:print()
    do_ref()
end

function spin_zones(spin_count)
    local spin_info =
    {
        {-1, -1, 1, 0},
        {1, -1, 0, 1},
        {1, 1, -1, 0},
        {-1, 1, 0, -1},
    }
    local function spin(layer)
        for k, v in ipairs(spin_info) do
            local start_x = layer * v[1]
            local start_y = layer * v[2]
            local count = layer * 2
            for i = 1, count do
                coroutine.yield(start_x + v[3] * i, start_y + v[4] * i)
            end
        end
    end

    local function _zones()
        coroutine.yield(0, 0)
        for i = 1, spin_count do
            spin(i)
        end
    end

    return coroutine.wrap(_zones)
end

function is_in_activity(act_id, ply)
    local act = nil
    if ply then
        if not check_ply_cross(ply) then
            act = ply:get_op_activity_data(act_id)
        end
    else
        act = operate_activity.OpActivityData[act_id]
        local prop_tab = resmng.get_conf("prop_operate_activity", act_id)
        if prop_tab.Type ==  OPERATE_ACTIVITY_TYPE.PERSON then
            return false
        end
    end

    if  act then
        if act.start_time < timekit.get_server_time() and act.end_time > timekit.get_server_time() then
            return true
        end
    end

    return false
end

function add_recover_log(record, log, limit)
    limit = limit or 20
    local now = record.idx or 1
    record[now] = log
    now = now + 1
    if now > limit then now = 1 end
    record.idx = now
end

--[[
-- 1.容易删除最先添加的
-- 2.按序添加，且固定容量
-- 3.随机删除
--]]
function add_refill_log(record, log)
    local info = record.info
    local limit = info.limit or 20
    local now   = info.tail
    local head  = info.head
    local count = info.count or 0

    local ptr = head
    local loop_times = 0

    while count >= limit do
        if record[ptr] then
            count = count - 1
            record[ptr] = nil
        end
        head = ptr
        loop_times = loop_times + 1
        if loop_times >= limit then
            break
        end
    end
    info.head = head

    if head > now then
        count = 0
        info.head = now
    end

    record[now] = log
    info.tail = now + 1
    info.count = count + 1
end

--[[
-- 1.按序添加，且固定容量
-- 2.到达限制返回false
-- return nil 失败 idx 成功
--]]
function add_limit_log(record, log)
    local limit = record.limit or 20
    local now   = record.tail or 1
    local count = record.count or 0

    if count >= limit then return end

    record[now] = log
    record.tail = now + 1
    record.count = count + 1
    return now
end

function wrap_father(meta)
    return package.seeall, function(tbl)
        tbl._base = meta
        setmetatable(tbl, {__index = meta})
    end
end

function get_cd_str(tm)
    return string.format("%d:%d:%d", math.floor(tm/3600), math.floor((tm%3600)/60), tm%60)
end

function make_str_id(id1, id2)
    return string.format("%d_%d", id1, id2)
end

function split_str_id(str)
    local id1, id2 = string.match(str, "(%d+)_(%d+)")
    return tonumber(id1), tonumber(id2)
end

function get_random_list(low, high)
    local list = {}
    for i = low, high do
        table.insert(list, {i, math.random(1,10000)})
    end
    table.sort(list, function(ta, tb)
        return ta[2] < tb[2]
    end)
    return list
end


