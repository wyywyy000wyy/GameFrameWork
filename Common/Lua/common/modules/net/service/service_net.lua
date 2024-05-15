local service_net = module_service_def("service_net")

function service_net:init()
    if self.args.cpp then
        lrequire("service_net_cpp_impl")
        self._impl = T.service_net_cpp_impl()
    end
end

function service_net:listen(port)
    LOG("service_net:listen()", port)
    self._net = self._impl:listen(port)
end

function service_net:update()
    -- LOG("service_net:update()", self._net)
    if self._net then
        self._net:Execute()
    end
end