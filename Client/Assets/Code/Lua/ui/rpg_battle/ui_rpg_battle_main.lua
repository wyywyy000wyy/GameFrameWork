local ui_rpg_battle_main = class("ui_rpg_battle_main",T.ui_window, function(self)
end)


function ui_rpg_battle_main:on_active()
    LOG("ui_rpg_battle_main:on_active")
end

function ui_rpg_battle_main:on_show()
    LOG("ui_rpg_battle_main:on_show")
end

function ui_rpg_battle_main:on_hide()
    LOG("ui_rpg_battle_main:on_hide") 
end
  
function ui_rpg_battle_main:on_deactive()
    LOG("ui_rpg_battle_main:on_deactive") 
end  