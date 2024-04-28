local service_data = module_service_def("service_data")

-- service_data.actiion.get_proxy = function(self, data_type, key)
--     local proxy = self._proxy[data_type]
--     if not proxy then
--         proxy = data_proxy(data_type)
--         self._proxy[data_type] = proxy
--     end
--     return proxy:get(key)
-- end

function service_data:init()
    self._data_lists = {}
    self._proxy = {}
    -- self._module_persistent = PM:find_module("module_persistent")
end

function service_data:load(action)
    local data_list = self._data_lists[action.table] 
    if not data_list then
        data_list = {}
        self._data_lists[action.table] = data_list
    end
    local data = data_list[action.key]
    if data then
        action:result(data)
        return 
    end

end



return service_data 