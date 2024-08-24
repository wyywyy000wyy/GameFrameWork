local module_audio = module_def("module_audio")
rpg_require = function(path)
    return require("modules/rpg_battle_client/rpg_battle/".. path)
end

function module_audio:init()
end

function module_audio:play_sound(sound)

end

function module_audio:stop_sound(sound)

end

function module_audio:post_event(sound)
end