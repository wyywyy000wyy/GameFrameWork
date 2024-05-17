local module_net = module_def("module_net")


function module_net:init()
    if self.args.cpp then
        lrequire("module_net_cpp_impl")
        self._impl = T.module_net_cpp_impl()
    end
end

function module_net:connect(ip, port)
    self._net = self._impl:connet(ip, port)
    self._net:AddEventCallBack(function(sockIndex,eventId, pNet)
        self:on_receive_event(sockIndex,eventId, pNet)
    end)
    self._net:AddReceiveCallBack(function(sockIndex,msgID, msg, len)
        self:on_receive_msg(sockIndex,msgID, msg, len)
    end)
end

function module_net:update()
    if self._net then
        self._net:Execute()
    end
end

function module_net:on_receive_event(sockIndex,eventId, pNet)
    LOG("module_net:on_receive_event()", sockIndex, eventId, pNet)
    if eventId == NF_NET_EVENT.NF_NET_EVENT_CONNECTED then
        self._sockIndx = sockIndex
        self:on_connected()
    end
end



function module_net:on_connected()
    LOG("module_net:on_connected()")
    self:send_msg(99999, "hello")
end

function module_net:send_msg(msgID, msg)
    if self._net then
        self._net:SendMsgWithOutHead(msgID, msg, 0)
    end
end

function module_net:on_receive_msg(sockIndex,msgID, msg, len)
    LOG("module_net:on_receive_msg()", sockIndex, msgID, msg, len)
end