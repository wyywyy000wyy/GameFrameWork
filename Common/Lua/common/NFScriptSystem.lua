-- package.path = '../NFDataCfg/Lua/?.lua;../NFDataCfg/Lua/json/?.lua;../NFDataCfg/Lua/cfg/?.lua;../NFDataCfg/Lua/game/scenario/?.lua;../NFDataCfg/Lua/game/?.lua;../NFDataCfg/Lua/world/?.lua;../NFDataCfg/Lua/proxy/?.lua;../NFDataCfg/ScriptModule/master/?.lua;../NFDataCfg/ScriptModule/login/?.lua;'
LOG("aaaaa2", package.path)
package.path = package.path .. ";" .. '?.lua;../../../Code/Lua/?.lua'

local function _dump_value(v, depth,map)
    depth = depth or 1
    map = map or {}

    if type(v) == 'string' then
        return string.format('%q', v)
    elseif type(v) == 'number' then
        return tostring(v)
    elseif type(v) == 'boolean' then
        return (v and 'true') or 'false'
    elseif type(v) == 'table' then
        if(map[v]) then
            return map[v];
        end
        map[v] = tostring(v);
        if(depth > 100) then
            return "too many depth; ignore"
        end
        local rt = "";
        for k, v in pairs(v) do
            rt = string.format("%s%s[%s] = %s;\n",rt,string.rep('\t', depth),_dump_value(k, depth + 1,map),_dump_value(v, depth + 1,map))
        end
        return string.format("{\n%s%s}",rt,string.rep('\t', depth - 1))
    elseif type(v) == 'userdata' then
        return "userdata"
    elseif type(v) == 'function' then
        return "function"
    else
        return "unknown type"
    end
end
-- require("NFScriptEnum");
local function contact_parm(...)
    local n = select('#',...)
    local tb = table.pack(...)
    local s = ""
    for i = 1,n do
        s = s .. _dump_value(tb[i]) .."\t"
    end
    return s
end


LOG = LOG or function (...)
    if not _PUBLISH then
        script_module:log_info(  contact_parm(...).."\r\n")--.. debug.traceback("",2))
    end
end

LOGF = LOGF or function(format, ...)
    if not _PUBLISH then
        script_module:log_info(  string.format(format, ...).."\r\n")--.. debug.traceback("",2))
    end
end

ELOG = ELOG or function (...)
    script_module:log_error(  contact_parm(...) ..  debug.traceback())
end

DLOG = DLOG or function (...)
    if not _PUBLISH then
        script_module:log_info(  contact_parm(...).."\r\n")--.. debug.traceback("",2))
    end
end


script_module = nil;
function init_script_system(xLuaScriptModule)
	script_module = xLuaScriptModule;
	-- require("main")


    -- local dbg =  _G.emmy_core
    -- if dbg then
    --     LOG("dbgdbgdbg" .. (dbg and "true" or "false"))
    --     local port = 9966
    --     dbg.tcpListen("localhost", port)
    --     -- local ret = dbg.tcpListen("localhost", port)
    --     -- LOG("dbgdbgdbg ret=" .. tostring(ret))

    --     -- for i = 0, 100 do
    --     --     local ret = xpcall(
    --     --         function()
    --     --             port = port + i
    --     --             return true
    --     --         end,
    --     --         function(err)
    --     --             -- print("dbgdbgdbg LUA ERROR: " .. tostring(err))
    --     --             return false
    --     --         end
    --     --     )
    --     --     LOG("dbgdbgdbg ret=" .. tostring(ret))
    --     --     if ret then
    --     --         -- CS.Hugula.FPS.dbgListenPort = port
    --     --          break
    --     --     end
    --     -- end
    -- end

	-- require("common/framework/class")
	-- require("framework/file_system")
	-- require("common/framework/hot_require")
	-- require_folder("framework/type")
	-- require_folder("data", true)
	-- require_folder("framework")
	-- PM:load_module("task_manager")
	
	LOG("~~~~~~~~~~~~~~good")
end

function load_script_file(fileList, isReload)

end
---------------------------------------------
function module_awake(...)
	LOG("lua module awake");
	
    -- PM:load(require("modules/module_manifest"))
    
    -- local PlayerType = StructDef("Player", 
    -- PD(String, "name", "default_name"),
    -- PD(Int, "Lv", 1))

    -- local guoguo = PlayerType("player_guoguo", 55)

    -- task
    -- :persistent_save("Player", 1, guoguo)
    -- :persistent_load("Player", 1)
    -- :call(function(t, tv1, tv2)
    --     local result = t:pr()
    --     LOG("persistent_load_call__", result)
    -- end, 22, 33)
    -- :excute()

	LOG("lua module awake ~~~~~~~~~~~~~~~~~");

end


function module_init(...)

    require("common/framework/global_func")
    require("common/framework/class")
    require("common/framework/file_system")
    require("common/framework/hot_require")
    -- dofile("common/framework/type.lua")
    require_folder("framework/type")



	LOG("Hello Lua, init script_module, " .. tostring(script_module));

    
	LOG("lua module init");
    -- T_AddClass = {
    --     ClassName = "T_AddClass666",
    -- }
    -- GAddClass();


end

function _module_after_init(...)
    require("define")
	LOG("lua module after init", SERVER);
    require("common/framework/cmain")
    if _CLIENT then
		require("main")
	end
    -- require("test")
    if SERVER then
        PM:load(require("modules/module_manifest_server"))
        require("test_main_server")
    else
        PM:load(require("modules/module_manifest_client"))
        require("test_main_client")
    end
end

function module_after_init(...)
    SAFE_CALL(_module_after_init, ...)
end

function module_ready_execute(...)
	LOG("lua module execute");

end

function module_before_shut(...)
	LOG("lua module before shut");

end

function module_update(...)
    -- -- PM:update()
    -- local a  = 1
    -- a = 2
	-- local script_module = script_module;
    PM:update()

	-- LOG("lua module module_update");
end

function module_shut(...)
	LOG("lua module shut");

end

----------------------------------------------
