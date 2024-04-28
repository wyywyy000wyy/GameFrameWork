local module_service = class("module_service", T.module, function(self, module_manager)
    T.module._ctor(self, module_manager)
end)

function module_service_def(name)
    local service_class = class(name, module_service, function(self, module_manager)
        module_service._ctor(self, module_manager)
    end)
    module_def(name, service_class)
    service_class.action = {}
    return service_class
end