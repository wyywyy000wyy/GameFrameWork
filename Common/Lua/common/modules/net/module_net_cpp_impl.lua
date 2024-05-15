local module_net_cpp_impl = class("module_net_cpp_impl", function(self)
end)


function module_net_cpp_impl:connet(ip, port)
    -- local _net = NFNetModule.New()
    local _net = NFNetModule.New(NFNetModule.ins)
    _net:InitializationC(ip, port)
    return _net
end
