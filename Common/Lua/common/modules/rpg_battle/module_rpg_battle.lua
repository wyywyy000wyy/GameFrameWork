local module_rpg_battle = module_def("module_rpg_battle")

function module_rpg_battle:init()

    BASIC_SKILL_MAX_LV = 11

    common_do_load = function(path)
        LOG("common_do_load: " .. path)
        require("modules/rpg_battle/" .. path)
    end

    cskit = {
        is_server = function()
            return SERVER
        end
    }

    common_do_load("rpg_battle/rpg_require")
end