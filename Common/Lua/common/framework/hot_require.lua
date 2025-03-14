-- module("hot_require", package.seeall)
local table_insert = table.insert
local file_system = T.file_system

local function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end
local function starts_with(str, start)
    return str:sub(1, #start) == start
end

local get_file_path = function(path) 
    local tp = T.file_system.get_file_path(path)
    -- if ends_with(tp, ".lua") then
    --     tp = string.sub(tp, 1, -5)
    -- end
    return tp 
end
local get_file_time = T.file_system.get_file_time
local get_files = T.file_system.get_files
g_require = g_require or require
local prequire = g_require
hot_require = hot_require or{}

local search_paths = {
    luaRootPath() .. "common/",
    luaRootPath() ,
}

local LOG_REQUIRE = function(...)
    -- LOG(...)
end


local function get_folder(path)
    if not path then
        return ""
    end
    local paths = {}
    for match in (path .."/"):gmatch("(.-)".."/") do
        table.insert(paths, match)
    end
    -- local paths = string.split(path, "/")
    local folder = table.concat(paths, "/", 1, #paths - 1)
    return folder
end

local function getCurrentLuaPath(upnum)
    local info = debug.getinfo(upnum, "S")
    local path = info.source
    -- LOG("getCurrentLuaPath", path, "upnum", upnum, debug.traceback()) 
    local LuaIdx = string.find(path, "Lua")
    local path2 = path --
    if LuaIdx then
        path2 = string.sub(path, LuaIdx + 4)
    end
    -- LOG("getCurrentLuaPath", path, "path2", path2, "upnum", upnum, debug.traceback())
    return path2
end

local require_file = class("require_file", function(self, modname, folder)
    self.modname = modname
    self.path = modname
    self.time = 0
    self.file_count = 0

    local files = {}
    for _, path in ipairs(search_paths) do
        local filepath = path .. self.path .. ".lua"
        -- LOG("**************require_file", self.modname, "path", self.path, "filepath", filepath)
        table_insert(files, filepath)
    end
    self.files = files
    self.search_folder = {}
    -- self.filePaths = {}
end)



function require_file:dirty(can_empty)
    local file_count = self:get_files_count()
    if file_count == 0 and not can_empty then
        ELOG("GGGGGGGG....... require failed", self.modname)
        return true
    end
    if file_count ~= self.file_count then
        return true
    end
    for _, path in ipairs(self.files) do
        LOG_REQUIRE("dirty ", path, file_system.exsit_file(path))
        if file_system.exsit_file(path) then
            local require_path = get_file_path(path) --string.sub(path, 1, -5))
            local file_time = file_system.get_file_time(path)
            LOG_REQUIRE("file_time____", path, file_time, self.time)
            if file_time > self.time then
                return true
            end
        end
    end
    return false
end

function require_file:get_files_count()
    local file_count = 0
    for _, path in ipairs(self.files) do
        if file_system.exsit_file(path) then
            file_count = file_count + 1
        end
    end
    return file_count
end


function require_file:require(can_empty)
    LOG_REQUIRE("require_a?", self.modname, "dirty", self:dirty(can_empty), "time", self.time, "file_count", self.file_count, "files", self.files[1], "search_folder", self.search_folder)
    if not self:dirty(can_empty) then
        return self._ret
    end
    self.file_count = 0
    local first = self.time == 0
    local ret = nil
    local r
    for i, path in ipairs(self.files) do
        if file_system.exsit_file(path) then
            -- if not require_path then
            --     self.filePaths[i] = require_path
            -- end
            -- local require_path = get_file_path(string.sub(path, 1, -5))
            self.time = math.max(self.time, get_file_time(path))
            self.file_count = self.file_count + 1
            if not first then
                ELOG("GGGGGGGG....... hot reload" .. path)
            end

            -- local rp1 = require_path
            -- if ends_with(rp1, ".lua") then
            --     rp1 = string.sub(rp1, 1, -5)
            -- end

            LOG_REQUIRE("GGGGGGGG....... hot reload file:" .. path)
            ret = dofile(path)
            self.search_folder[i] = get_folder(require_path)
            r = true
            -- LOG("require_file", self.modname, "path", path, "require_path", require_path, "folder", self.search_folder[i])
        else
            self.search_folder[i] = nil
        end
    end
    if not r and not can_empty then
        ELOG("GGGGGGGG....... require failed", self.modname)
    end
    self._ret = ret
    return ret
end

hot_require.init_map = hot_require.init_map or {}
local init_map = hot_require.init_map
hot_require.init_list = hot_require.init_list or {}
local init_list = hot_require.init_list

lrequire = function(modname)
    local path = getCurrentLuaPath(3)
    local folder = get_folder(path)
    local modname_with_folder = string.format( "%s/%s", folder, modname)
    -- LOG("lrequire", modname, "path", path, "folder", folder, "modname_with_folder", modname_with_folder)
    return require(modname_with_folder)
end

require = function(modname, can_empty)
    if starts_with(modname, "@") then
        modname = string.sub(modname, 2)
    end

    -- LOG("require____", modname, debug.traceback())

    local require_info = init_map[modname]
    if not require_info then
        require_info = require_file(modname)
        init_map[modname] = require_info
        table.insert(init_list, require_info)
    end
    return require_info:require(can_empty)
end

function require_folder(folder, recursive)
    for _, path in ipairs(search_paths) do
        local filepath = path .. folder
        local files = get_files(filepath, recursive)
        local len = files.Count
        if false and files.Count then
            for i = 0, len - 1 do
                LOG_REQUIRE("path", len, i, filepath, files and files[i])
                local filepath = filepath .. "/" .. files[i]
                require(filepath, true)
            end
        else
            len = #files
            for i = 1, len do
                local filepath2 = filepath .. "/" .. files[i]
                LOG_REQUIRE("path_2", len, i, filepath2, folder, files and files[i])
                require(folder .. "/" .. files[i], true)
            end
        end
        
    end

    -- local files = get_files(folder, recursive)

    -- local len = files.Count
    -- for i = 0, len - 1 do
    --     local filepath = folder .. "/" .. files[i]
    --     -- ELOG("require_folder", filepath)
    --     require(filepath)
    -- end
end

function hot_require.force_require(modname)
    hot_require.rrquire_all(modname)
end

function hot_require.rrquire_all(modname)
    ELOG("GGGGGGGG....... lua hotreload")
    for _, info in ipairs(init_list) do
        info:require()
    end
end