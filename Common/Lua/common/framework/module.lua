local module = class("module", function(self, module_mamager)
    self._manager = module_mamager
end)

function module_def(name, _class)
    local module_class = _class or class(name, module, function(self, module_manager)
        module._ctor(self, module_manager)
    end)
    module_class.name = name
    return module_class
end

function module:init()
end

function module:enable()
end

function module:disable()
end

function module:destroy()
end