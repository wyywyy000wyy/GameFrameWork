local module_net = module_def("module_net")


function module_net:init()
    if self.args.cpp then
        lrequire("module_net_cpp_impl")
        self._impl = T.module_net_cpp_impl()
    end
end

function module_net:connect(ip, port)
    self._net = self._impl:connet(ip, port)
end

function module_net:update()
    if self._net then
        self._net:Execute()
    end
end