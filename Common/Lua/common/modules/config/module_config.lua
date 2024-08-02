local module_config = module_def("module_config")

function module_config:init()
    resmng = {
        load_config = function(name)
            load_config(name)
        end
    }
    require("config/config_require")

    load_config = function(name)
        -- local config = resmng[name]
        -- if not config then
        --     config = require("config/" .. name)
        --     resmng[name] = config
        -- end
        -- return config
        require("config/" .. name)
    end
end