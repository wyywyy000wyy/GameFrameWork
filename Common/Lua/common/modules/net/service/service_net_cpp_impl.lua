local service_net_cpp_impl = class("service_net_cpp_impl", function(self)
end)


function service_net_cpp_impl:listen(port)
    -- local _net = NFNetModule.New()
    local _net = NFNetModule.New(NFNetModule.ins)
    _net:Initialization(20000, port,1)
    return _net
end
