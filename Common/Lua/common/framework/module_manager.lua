local module_manager = class("module_manager", function(self)
    self._modules = {}
    self._update_modules = {}
end) 

P = P or {}

local function PCALL (module, func_name,...)
    local func = module[func_name]
    local ok, err = pcall(func, module, ...)
    if not ok then
        ELOG(string.format("call %s %s failed: %s", module.name, func_name, err))
    else
        LOG("[module] %s %s", module.name, func_name)
    end
end

local function MCALL(module, func_name,...)
    local func = module[func_name]
    local ok, err = pcall(func, module, ...)
    if not ok then
        ELOG(string.format("call %s %s failed: %s", module.name, func_name, err))
    end
end

function module_manager:load(config)
    for i, v in ipairs(config) do
        self:_load_module(v)
    end
end

function module_manager:load_module(name, is_service)
    local path 
    local module_root 
    local module_name
    if is_service then
        path = string.format("modules/%s/service/", name)
        module_root = string.format("modules/%s/", name)
        module_name = string.format("service_%s", name)
    else
        path = string.format("modules/%s/", name)
        module_root = path
        module_name = string.format("module_%s", name)
    end
    local load = function()
        local module_path = string.format("%s%s", path, module_name)
        require(module_path)
        local module_class = T[module_name]
        if module_class.requires then
            for i, v in ipairs(module_class.requires) do
                local require_path = string.format("%s%s", module_root, v)
                require(require_path)
            end
        end

        local module = module_class(module_name)
        module.is_s = is_service
        self._modules[module_name] = module
        if module_name == "task_manager" then
            self._tm = module
        end
        PCALL(module, "init")

        local define_path = string.format("%sdefine_%s", module_root, name)
        local define = require(define_path)
        if define then
            TM:_module_loaded(module, define)
        end
        if module.update then
            table.insert(self._update_modules, module)
        end
    end
    local ok, err = pcall(load)
    if not ok then
        ELOG(string.format("load module failed: %s \n %s", module_name, err))
    end
    return self._modules[module_name]
end

function module_manager:_load_module(config)
    local module = self._modules[config.name]
    if module then
        return
    end
    if config.service then
        self:load_module(config.name, config.service)
        -- self:load_module(config.name)
    else
        self:load_module(config.name)
    end
end

function module_manager:find_module(name)
    return self._modules[name]
end

function module_manager:update()
    for i, v in ipairs(self._update_modules) do
        -- MCALL(v, "update")
        v:update()
    end
end

g_module_manager = g_module_manager or module_manager()
PM = g_module_manager