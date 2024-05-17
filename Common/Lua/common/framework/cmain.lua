



require("framework/data/nf_object")
require_folder("framework")
PM:load_module("task_manager")
PM:load(require("modules/module_manifest"))



LOG("lua cmain awake ~~~~~~~~~~~~~~~~~", PM);


-- local empty_guid = script_module:create_object_e()

-- local a = {
--     ss = "aa"
-- }

-- if empty_guid then
--     LOG("**************empty_obj is not nil")
-- else
--     LOG("**************empty_obj is nil")
-- end

-- local obj = T.nf_object(empty_guid)
-- obj:set_prop_int("aa",100)

-- LOG("a=", empty_guid.head, empty_guid.data)
-- LOG("a=", obj._guid.head, obj._guid.data, obj:get_prop_int("aa"))
 

