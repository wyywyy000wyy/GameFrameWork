

local module_net = PM:find_module("module_net")

if not module_net._net then
    module_net:connect("127.0.0.1", 9877)
end
