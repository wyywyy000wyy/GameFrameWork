local module_rpg_battle = module_def("module_rpg_battle")

function module_rpg_battle:init()
    GN = GN or {}
    BASIC_SKILL_MAX_LV = 11
    class2 = class

    common_do_load = function(path)
        LOG("common_do_load: " .. path)
        require("modules/rpg_battle/" .. path)
    end

    cskit = {
        is_server = function()
            return SERVER
        end
    }

    is_server = function()
        return SERVER
    end

    unpack = table.unpack

    BattleResult = {
        NONE = 0,
        FAIL = 1,   -- 失败
        WIN = 2,    -- 胜利
        DRAW = 3,   -- 平局
    }
    

    common_do_load("rpg_battle/rpg_require")
end