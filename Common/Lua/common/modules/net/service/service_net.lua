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
    self._net:AddEventCallBack(function(sockIndex,eventId, pNet)
        self:on_receive_event(sockIndex,eventId, pNet)
    end)
    self._net:AddReceiveCallBack(function(sockIndex,msgID, msg, len)
        self:on_receive_msg(sockIndex,msgID, msg, len)
    end)
end

function service_net:on_receive_event(sockIndex,eventId, pNet)
    LOG("service_net:on_receive_event()", sockIndex, eventId, pNet)
end

function service_net:on_receive_msg(sockIndex,msgID, msg, len)
    LOG("service_net:on_receive_msg()", sockIndex, msgID, msg, len)
end

function service_net:update()
    -- LOG("service_net:update()", self._net)
    if self._net then
        self._net:Execute()
    end
end