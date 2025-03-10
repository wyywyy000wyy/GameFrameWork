local module_config = module_def("module_config")

function module_config:init()
    resmng = resmng or {}
    resmng.load_config = function(name)
        load_config(name)
    end
    resmng.get_conf = function(name, conf_id)
        return resmng[name][conf_id]
    end
    require("config/config_require")

    load_config = function(name)
        -- local config = resmng[name]
        -- if not config then
        --     config = require("config/" .. name)
        --     resmng[name] = config
        -- end
        -- return config
        require("config/" .. name)
        if string.find(name ,"prop_") then
            local func_name = name .. "ById"
            resmng[func_name] = function(id)
                return resmng[name][id]
            end
        end
    end
end