-- package.path = '../NFDataCfg/Lua/?.lua;../NFDataCfg/Lua/json/?.lua;../NFDataCfg/Lua/cfg/?.lua;../NFDataCfg/Lua/game/scenario/?.lua;../NFDataCfg/Lua/game/?.lua;../NFDataCfg/Lua/world/?.lua;../NFDataCfg/Lua/proxy/?.lua;../NFDataCfg/ScriptModule/master/?.lua;../NFDataCfg/ScriptModule/login/?.lua;'
package.path = '?.lua;../../../Code/Lua/?.lua'

-- require("NFScriptEnum");
local function contact_parm(...)
    local n = select('#',...)
    local tb = table.pack(...)
    local s = ""
    for i = 1,n do
        s = s .. tostring(tb[i]) .."\t"
    end
    return s
end

function LOG(...)
    if not _PUBLISH then
        script_module:log_info(  contact_parm(...).."\r\n")--.. debug.traceback("",2))
    end
end

function LOGF(format, ...)
    if not _PUBLISH then
        script_module:log_info(  string.format(format, ...).."\r\n")--.. debug.traceback("",2))
    end
end

function ELOG(...)
    script_module:log_error(  contact_parm(...) ..  debug.traceback())
end

function DLOG(...)
    if not _PUBLISH then
        script_module:log_info(  contact_parm(...).."\r\n")--.. debug.traceback("",2))
    end
end


script_module = nil;
function init_script_system(xLuaScriptModule)
	script_module = xLuaScriptModule;
	-- require("main")
	if _CLIENT then
		require("main")
	end
	LOG("Hello Lua, init script_module, " .. tostring(script_module));

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
	-- PM:load_plugin("task_manager")
	
	LOG("~~~~~~~~~~~~~~good")
end

function load_script_file(fileList, isReload)

end
---------------------------------------------
function module_awake(...)
	LOG("lua module awake");
	
    -- PM:load(require("plugins/plugin_manifest"))
    
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
	LOG("lua module init");
    T_AddClass = {
        ClassName = "T_AddClass666",
    }
    GAddClass();
end

function module_after_init(...)
	LOG("lua module after init");

end

function module_ready_execute(...)
	LOG("lua module execute");

end

function module_before_shut(...)
	LOG("lua module before shut");

end

function module_update(...)
    -- PM:update()
    local a  = 1
    a = 2
	local script_module = script_module;

	-- LOG("lua module module_update");
end

function module_shut(...)
	LOG("lua module shut");

end

----------------------------------------------
