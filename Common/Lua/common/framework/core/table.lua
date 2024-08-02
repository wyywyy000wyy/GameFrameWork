


---查找table中的指定项的索引
---@overload fun(tb:table,item:any):int
---@param tb table
---@param item any
---@return int
function table.indexof(table, item)
    local idx
    for k, v in ipairs(table) do
        if v == item then
            idx = k
            break
        end
    end
    return idx
end

function table.multiply(t, x)
    local ret = {}
    for k, v in pairs(t) do
        ret[k] = math.floor(v*x)
    end
    return ret
end

---移除table中的指定项
---@overload fun(tb:table,item:any):int
---@param tb table
---@param item any
---@return int
function table.remove_item(tb, item)
    local idx = table.indexof(tb, item)
    if idx ~= nil then
        table.remove(tb, idx)
        return idx
    end
    return nil
end

function table.clear(tb)
    for k, v in pairs(tb) do
        tb[k] = nil
    end
end

function table.get_size(tab)
    if not tab then
        return 0
    end
    local i = 0
    for k, v in pairs(tab) do
        i = i + 1
    end
    return i
end

function table.has_value(tb)
    return type(tb) == "table" and next(tb) ~= nil
end

-- 比较第一层是否相同
function table.equals(tb1, tb2)
    if type(tb1) ~= "table" or type(tb2) ~= "table" then
        return false
    end
    for k, v in pairs(tb1) do
        if tb2[k] ~= v then
            return false
        end
    end
    for k, v in pairs(tb2) do
        if tb1[k] ~= v then
            return false
        end
    end
    return true
end

---列表分数排序
---@param src_tab table 数据列表
---@param score_callback fun(data, id) 排序函数
---@param descending boolean 是否降序，默认降序:分数高的排在前面
---@param collect_key any 用于获取某个字段的数据用于排序
---@param is_array boolean 是否数组，是数组可以不传
---@return table 数组
function table.score_sort(src_tab, score_callback, descending, collect_key, is_array)
    if descending == nil then
        descending = true
    end

    local sort_list = {}
    local score_map = {}

    local my_pairs = is_array and ipairs or pairs
    for id, data in my_pairs(src_tab) do
        local val = (collect_key and data[collect_key] or data)
        table.insert(sort_list, val)
        if score_callback then
            score_map[val] = score_callback(data, id)
        end
    end

    if score_callback then
        local cmp_fun = function(a, b)
            if descending then
                return score_map[a] > score_map[b]
            else
                return score_map[b] > score_map[a]
            end
        end
        table.sort(sort_list, cmp_fun)
    end
    return sort_list
end
---列表过滤
---@param src_tab table 数据列表
---@param filter_callback fun(data, id) 过滤函数
---@param is_array boolean 是否数组，是数组可以不传
---@return table 数组
function table.filter(src_tab, filter_callback, is_array)
    local filter_list = {}

    local my_pairs = is_array and ipairs or pairs
    for id, data in my_pairs(src_tab) do
        if (not filter_callback) or filter_callback(data, id) then
            table.insert(filter_list, data)
        end
    end

    return filter_list
end
---组合两个列表
function table.combine(tab1, tab2, is_array)
    local ret = {}
    local my_pairs = is_array and ipairs or pairs
    for i, v in my_pairs(tab1) do
        table.insert(ret, v)
    end

    for i, v in my_pairs(tab2) do
        table.insert(ret, v)
    end

    return ret
end

function table.addM(t1, ...)
    local ret = t1
    for _, t in pairs({...}) do
        for k, v in pairs(t) do
            ret[k] = (ret[k] or 0) + v
        end
    end
    return ret
end

is_table = function(val)
    return type(val) == "table"
end

function table.index(t, val)
    for k, v in pairs(t) do
        if val == v then
            return k
        end
    end
end

function table.not_empty(val)
    return is_table(val) and next(val) ~= nil
end

function stringify(object, depth, maxlen)
    return object
end

function table.cmp2(a, b)
    if a == b then
        return true, a, b
    elseif type(a) == 'table' and type(b) == 'table' then
        local s, xs, ys = true, {}, {}
        for k, _ in pairs(a) do
            if k =="tb" then
                goto continue;
            end
            local r, r1, r2 = table.cmp2(a[k], b[k])
            if not r then
                xs[k] = r1 or "nil"
                ys[k] = r2 or "nil"
                return false, xs, ys
            end
            ::continue::
        end
        return s, xs, ys
    elseif a ~= b then
        return false, a, b
    else
        return true, a, b
    end
end

function table.cmp(a, b)
    if a == b then
        return true, {}, {}
    elseif type(a) == 'table' and type(b) == 'table' then
        local s, xs, ys = true, {}, {}

        local watched = {}
        for k, _ in pairs(a) do
            local r, x, y = table.cmp(a[k], b[k])
            if not r then
                s, xs[k], ys[k] = false, x, y
            end
            watched[k] = true
        end
        for k, _ in pairs(b) do
            if not watched[k] then
                s, xs[k], ys[k] = false, a[k], b[k]
            end
        end
        return s, xs, ys
    elseif a ~= b then
        return false, a, b
    else
        return true, {}, {}
    end
end

-- 拷贝table
function table.clone(tb, is_deep)
    if type(tb) ~= "table" then
        return nil
    end
    local copy = {}
    if not is_deep then
        for k, v in pairs(tb) do
            copy[k] = v
        end
    else
        -- 深拷贝没处理循环引用
        for k, v in pairs(tb) do
            if type(v) == "table" then
                copy[k] = table.clone(v, true)
            else
                copy[k] = v
            end
        end
        setmetatable(copy, table.clone(getmetatable(tb), true))
    end
    return copy
end

function table.copy(t)
    return table.clone(t, true)
end

function table.merge(tab1, tab2)
    tab1 = tab1 or {}
    for k, v in pairs(tab2 or {}) do
        tab1[k] = v
    end
    return tab1
end

function table.mergeM(t1, t2)
    for k, v in pairs(t2 or {}) do t1[k] = v end
    return t1
end

function table.extend(t1, ...)
    for _, t2 in pairs({...}) do
        for _, v in pairs(t2) do
            t1[#t1 + 1] = v
        end
    end
    return t1
end

function table.sum(t)
    local sum = 0
    for _, v in pairs(t) do
        sum = sum + v
    end
    return sum
end

-- key值列表
-- {a=b} => {a}
function table.keys(t)
    local res = {}
    for k, v in pairs(t) do
        table.insert(res, k)
    end
    return res
end

function table.values(t)
    local res = {}
    for k, v in pairs(t) do
        table.insert(res, v)
    end
    return res
end

-- 可以在遍历过程中删除元素
function table.safe_foreach(tb, func)
    if type(tb) == "table" then
        local copy = table.clone(tb)
        for k, v in pairs(copy) do
            func(k, v)
        end
    end
end

--递归merge
function table.recurse_merge(tab1, tab2)
    tab1 = tab1 or {}
    for k, v in pairs(tab2 or {}) do
        if type(v) == "table" then
            tab1[k] = table.recurse_merge(tab1[k], v)
        else
            tab1[k] = v
        end
    end
    return tab1
end

function table.ssort(list, func)
    local len = #list
    for l = len -1, 1, -1 do
        for i = 1, l do
            local a = list[i]
            local b = list[i + 1]
            local rt = func(a, b)
            if rt >= 0 then
                list[i] = b
                list[i + 1] = a
            end
        end
    end
end

-- 返回数组的随机一个元素
function table.get_random(tb)
    return tb[math.random(1, #tb)]
end
