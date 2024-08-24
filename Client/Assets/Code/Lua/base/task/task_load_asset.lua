local task_load_asset = class("task_load_asset", T.task_c, function(self, asset_path)
    T.task_c._ctor(self)
    self._asset_path = asset_path
end)

function task_load_asset:on_execute()
    T.YSLoader.InstantiateAsync(self._asset_path, function(asset)
        self._asset = asset
        self:finish()
    end)
end

g_load_asset = function(path, end_func)
    if string.find(path, "_animator") then
        path = "model_hero_dizaozheaidehua_animator"
    elseif string.find(path, "ef_") then
        path = "ef_tmp_test"
    end
    local load_task = T.task_load_asset(path)

    load_task:add_fcb(function()
        end_func(path, load_task._asset)
    end)
    g_task_manager:execute(load_task)
end

g_release_asset = function(path, asset)
    T.YSLoader.ReleaseInstance(asset)
end