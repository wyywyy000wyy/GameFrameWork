

local PlayerType = StructDef("Player", 
    PD(String, "name", "default_name"),
    PD(Int, "Lv", 1)
)

local guoguo = PlayerType("player_guoguo", 55)

LOG("lua test ~~~~~~~~~~~~~~~~~", guoguo);

LOG("__lua test ~~~~~~~~~~~~~~~~~", NFLuaScriptModule.NFLuaScriptModuleIns);

NFLuaScriptModule.NFLuaScriptModuleIns:testFunc()

local reta = NFLuaScriptModule.NFLuaScriptModuleIns:TestFuntionA(1,2)
LOG("lua test ~~~~~~~~~~~~~~~~~", reta);
NFLuaScriptModule.NFLuaScriptModuleIns.TestFuntionAWrapper_ = function(a, b)
    return a + b * 5
end
local reta = NFLuaScriptModule.NFLuaScriptModuleIns:TestFuntionA(1,2)
LOG("lua test ~~~~~~~~~~~~~~~~~", reta); 

NFLuaScriptModule.NFLuaScriptModuleIns.TestFuntionAWrapper_ = nil
local reta = NFLuaScriptModule.NFLuaScriptModuleIns:TestFuntionA(1,2)
LOG("lua test ~~~~~~~~~~~~~~~~~", reta);   
-- task
-- :persistent_save("Player", 1, guoguo)
-- :persistent_load("Player", 1)
-- :call(function(t, tv1, tv2)
--     local result = t:pr()
--     LOG("persistent_load_call__", result)
-- end, 22, 33)
-- :excute() 

-- local guoguo_data = cmsgpack.pack(guoguo)
-- local guoguo_table = cmsgpack.unpack(guoguo_data)

-- LOG("lua test ~~~~~~~~~~~~~~~~~", guoguo_data);
-- LOG("lua test ~~~~~~~~~~~~~~~~~", guoguo_table);


local times = 1000 * 1000

-- local t = {}
-- LOG("lua construct begin ~~~~~~~~~~~~~~~~~");

-- for i = 1, times do
--     local guoguo = PlayerType("player_guoguo", i)
--     -- table.insert(t, guoguo)
-- end

-- LOG("lua construct finish ~~~~~~~~~~~~~~~~~", #t);


-- local conn = ConnectData()
-- LOG("lua test ~~~~~~~~~~~~~~~~~", conn.nGameID);
-- -- conn.ip = "127.0.0.1"
-- conn.nGameID = 1
-- LOG("lua test2 ~~~~~~~~~~~~~~~~~", conn.nGameID);

local service_net = PM:find_module("service_net")

if not service_net._net then
    service_net:listen(9877)
end