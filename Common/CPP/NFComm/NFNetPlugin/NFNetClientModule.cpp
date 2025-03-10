/*
            This file is part of: 
                NoahFrame
            https://github.com/ketoo/NoahGameFrame

   Copyright 2009 - 2021 NoahFrame(NoahGameFrame)

   File creator: lvsheng.huang
   
   NoahFrame is open-source software and you can redistribute it and/or modify
   it under the terms of the License; besides, anyone who use this file/software must include this copyright announcement.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

#include "NFNetModule.h"
#include "NFNetClientModule.h"

NFNetClientModule::NFNetClientModule(NFIPluginManager* p)
{
    m_bIsExecute = true;
    mnBufferSize = 0;
    pPluginManager = p;

	mnLastActionTime = GetPluginManager()->GetNowTime();
}

bool NFNetClientModule::Init()
{
	m_pLogModule = pPluginManager->FindModule<NFILogModule>();

    for (int i = 0; i < NF_SERVER_TYPES::NF_ST_MAX; ++i)
    {
        NFINetClientModule::AddEventCallBack((NF_SERVER_TYPES) i, this, &NFNetClientModule::OnSocketEvent);
    }

    return true;
}

bool NFNetClientModule::AfterInit()
{


    return true;
}

bool NFNetClientModule::BeforeShut()
{
    return true;
}

bool NFNetClientModule::Shut()
{
    return true;
}

bool NFNetClientModule::Execute()
{
    ProcessExecute();
    ProcessAddNetConnect();

	if (mnLastActionTime + 10 > GetPluginManager()->GetNowTime())
	{
		return true;
	}

	mnLastActionTime = GetPluginManager()->GetNowTime();

	//LogServerInfo();

    return true;
}

void NFNetClientModule::RemoveReceiveCallBack(const NF_SERVER_TYPES eType, const uint16_t msgID)
{
    NF_SHARE_PTR<CallBack> xCallBack = mxCallBack.GetElement(eType);
    if (xCallBack)
    {
        std::map<int, std::list<NET_RECEIVE_FUNCTOR_PTR>>::iterator it = xCallBack->mxReceiveCallBack.find(msgID);
        if (xCallBack->mxReceiveCallBack.end() != it)
        {
            xCallBack->mxReceiveCallBack.erase(it);
        }
    }
}

void NFNetClientModule::AddServer(const ConnectData& xInfo)
{
    mxTempNetList.push_back(xInfo);
}

unsigned int NFNetClientModule::ExpandBufferSize(const unsigned int size)
{
    if (size > 0)
    {
        mnBufferSize = size;
    }
    return mnBufferSize;
}

int NFNetClientModule::AddReceiveCallBack(const NF_SERVER_TYPES eType, const uint16_t msgID,
                                           NET_RECEIVE_FUNCTOR_PTR functorPtr)
{
    NF_SHARE_PTR<CallBack> xCallBack = mxCallBack.GetElement(eType);
    if (!xCallBack)
    {
        xCallBack = NF_SHARE_PTR<CallBack>(NF_NEW CallBack);
        mxCallBack.AddElement(eType, xCallBack);
    }

	std::map<int, std::list<NET_RECEIVE_FUNCTOR_PTR>>::iterator itor = xCallBack->mxReceiveCallBack.find(msgID);
	if (itor == xCallBack->mxReceiveCallBack.end())
	{
		std::list<NET_RECEIVE_FUNCTOR_PTR> xList;
		xList.push_back(functorPtr);

    	xCallBack->mxReceiveCallBack.insert(std::map<int, std::list<NET_RECEIVE_FUNCTOR_PTR>>::value_type(msgID, xList));
	}
	else
	{
		xCallBack->mxReceiveCallBack.at(msgID).push_back(functorPtr);
	}

    return 0;
}

int NFNetClientModule::AddReceiveCallBack(const NF_SERVER_TYPES eType, NET_RECEIVE_FUNCTOR_PTR functorPtr)
{
    NF_SHARE_PTR<CallBack> xCallBack = mxCallBack.GetElement(eType);
    if (!xCallBack)
    {
        xCallBack = NF_SHARE_PTR<CallBack>(NF_NEW CallBack);
        mxCallBack.AddElement(eType, xCallBack);
    }

    xCallBack->mxCallBackList.push_back(functorPtr);

    return 0;
}


int NFNetClientModule::AddEventCallBack(const NF_SERVER_TYPES eType, NET_EVENT_FUNCTOR_PTR functorPtr)
{
    NF_SHARE_PTR<CallBack> xCallBack = mxCallBack.GetElement(eType);
    if (!xCallBack)
    {
        xCallBack = NF_SHARE_PTR<CallBack>(NF_NEW CallBack);
        mxCallBack.AddElement(eType, xCallBack);
    }

    xCallBack->mxEventCallBack.push_back(functorPtr);
    return 0;
}

void NFNetClientModule::SendByServerIDWithOutHead(const int serverID, const uint16_t msgID, const std::string & strData)
{
	NF_SHARE_PTR<ConnectData> pServer = mxServerMap.GetElement(serverID);
	if (pServer)
	{
		NF_SHARE_PTR<NFINetModule> pNetModule = pServer->mxNetModule;
		if (pNetModule.get())
		{
			if (!pNetModule->SendMsgWithOutHead(msgID, strData, 0))
			{
				std::ostringstream stream;
				stream << " SendMsgWithOutHead failed " << serverID;
				stream << " msg id " << msgID;
				m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
			}
		}
	}
	else
	{
		std::ostringstream stream;
		stream << " can't find the server " << serverID;
		stream << " msg id " << msgID;
		m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
	}
}

void NFNetClientModule::SendByServerID(const int serverID, const uint16_t msgID, const std::string& strData)
{
	NF_SHARE_PTR<ConnectData> pServer = mxServerMap.GetElement(serverID);
	if (pServer)
	{
		NF_SHARE_PTR<NFINetModule> pNetModule = pServer->mxNetModule;
		if (pNetModule.get())
		{
			if (!pNetModule->SendMsg(msgID, strData, 0))
			{
				std::ostringstream stream;
				stream << " SendMsgWithOutHead failed " << serverID;
				stream << " msg id " << msgID;
				m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
			}
		}
	}
	else
	{
		std::ostringstream stream;
		stream << " can't find the server " << serverID;
		stream << " msg id " << msgID;
		m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
	}
}

void NFNetClientModule::SendByServerID(const int serverID, const uint16_t msgID, const std::string & strData, const NFGUID id)
{
	NF_SHARE_PTR<ConnectData> pServer = mxServerMap.GetElement(serverID);
	if (pServer)
	{
		NF_SHARE_PTR<NFINetModule> pNetModule = pServer->mxNetModule;
		if (pNetModule.get())
		{
			if (!pNetModule->SendMsg(msgID, strData, 0, id))
			{
				std::ostringstream stream;
				stream << " SendMsgWithOutHead failed " << serverID;
				stream << " msg id " << msgID;
				m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
			}
		}
	}
	else
	{
		std::ostringstream stream;
		stream << " can't find the server " << serverID;
		stream << " msg id " << msgID;
		m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
	}
}

void NFNetClientModule::SendToAllServerWithOutHead(const uint16_t msgID, const std::string & strData)
{
	NF_SHARE_PTR<ConnectData> pServer = mxServerMap.First();
	while (pServer)
	{
		NF_SHARE_PTR<NFINetModule> pNetModule = pServer->mxNetModule;
		if (pNetModule)
		{
			if (!pNetModule->SendMsgWithOutHead(msgID, strData, 0))
			{
				std::ostringstream stream;
				stream << " SendMsgWithOutHead failed " << pServer->nGameID;
				stream << " msg id " << msgID;
				m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
			}
		}

		pServer = mxServerMap.Next();
	}
}

void NFNetClientModule::SendToAllServer(const uint16_t msgID, const std::string& strData)
{
    NF_SHARE_PTR<ConnectData> pServer = mxServerMap.First();
    while (pServer)
    {
        NF_SHARE_PTR<NFINetModule> pNetModule = pServer->mxNetModule;
        if (pNetModule)
        {
			if (!pNetModule->SendMsg(msgID, strData, 0))
			{
				std::ostringstream stream;
				stream << " SendMsgWithOutHead failed " << pServer->nGameID;
				stream << " msg id " << msgID;
				m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
			}
        }

        pServer = mxServerMap.Next();
    }
}

void NFNetClientModule::SendToAllServer(const uint16_t msgID, const std::string & strData, const NFGUID id)
{
	NF_SHARE_PTR<ConnectData> pServer = mxServerMap.First();
	while (pServer)
	{
		NF_SHARE_PTR<NFINetModule> pNetModule = pServer->mxNetModule;
		if (pNetModule)
		{
			if (!pNetModule->SendMsg(msgID, strData, 0, id))
			{
				std::ostringstream stream;
				stream << " SendMsgWithOutHead failed " << pServer->nGameID;
				stream << " msg id " << msgID;
				m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
			}
		}

		pServer = mxServerMap.Next();
	}
}

void NFNetClientModule::SendToAllServerWithOutHead(const NF_SERVER_TYPES eType, const uint16_t msgID, const std::string & strData)
{
	NF_SHARE_PTR<ConnectData> pServer = mxServerMap.First();
	while (pServer)
	{
		NF_SHARE_PTR<NFINetModule> pNetModule = pServer->mxNetModule;
		if (pNetModule && eType == pServer->eServerType)
		{
			if (!pNetModule->SendMsgWithOutHead(msgID, strData, 0))
			{
				std::ostringstream stream;
				stream << " SendMsgWithOutHead failed " << pServer->nGameID;
				stream << " msg id " << msgID;
				m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
			}
		}

		pServer = mxServerMap.Next();
	}
}

void NFNetClientModule::SendToAllServer(const NF_SERVER_TYPES eType, const uint16_t msgID, const std::string& strData)
{
    NF_SHARE_PTR<ConnectData> pServer = mxServerMap.First();
    while (pServer)
    {
        NF_SHARE_PTR<NFINetModule> pNetModule = pServer->mxNetModule;
        if (pNetModule && eType == pServer->eServerType)
        {
			if (!pNetModule->SendMsg(msgID, strData, 0))
			{
				std::ostringstream stream;
				stream << " SendMsgWithOutHead failed " << pServer->nGameID;
				stream << " msg id " << msgID;
				m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
			}
        }

        pServer = mxServerMap.Next();
    }
}

void NFNetClientModule::SendToAllServer(const NF_SERVER_TYPES eType, const uint16_t msgID, const std::string & strData, const NFGUID id)
{
	NF_SHARE_PTR<ConnectData> pServer = mxServerMap.First();
	while (pServer)
	{
		NF_SHARE_PTR<NFINetModule> pNetModule = pServer->mxNetModule;
		if (pNetModule && eType == pServer->eServerType)
		{
			if (!pNetModule->SendMsg(msgID, strData, 0, id))
			{
				std::ostringstream stream;
				stream << " SendMsgWithOutHead failed " << pServer->nGameID;
				stream << " msg id " << msgID;
				m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
			}
		}

		pServer = mxServerMap.Next();
	}
}

void NFNetClientModule::SendToServerByPB(const int serverID, const uint16_t msgID, const google::protobuf::Message& xData)
{
    NF_SHARE_PTR<ConnectData> pServer = mxServerMap.GetElement(serverID);
    if (pServer)
    {
        NF_SHARE_PTR<NFINetModule> pNetModule = pServer->mxNetModule;
        if (pNetModule)
        {
			if (!pNetModule->SendMsgPB(msgID, xData, 0))
			{
				std::ostringstream stream;
				stream << " SendMsgPB failed " << pServer->nGameID;
				stream << " msg id " << msgID;
				m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
		   }
        }
    }
	else
	{
		std::ostringstream stream;
		stream << " can't find the server " << serverID;
		stream << " msg id " << msgID;
		m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
	}
}

void NFNetClientModule::SendToServerByPB(const int serverID, const uint16_t msgID, const google::protobuf::Message & xData, const NFGUID id)
{
	NF_SHARE_PTR<ConnectData> pServer = mxServerMap.GetElement(serverID);
	if (pServer)
	{
		NF_SHARE_PTR<NFINetModule> pNetModule = pServer->mxNetModule;
		if (pNetModule)
		{
			if (!pNetModule->SendMsgPB(msgID, xData, 0, id))
			{
				std::ostringstream stream;
				stream << " SendMsgPB failed " << pServer->nGameID;
				stream << " msg id " << msgID;
				m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
			}
		}
	}
	else
	{
		std::ostringstream stream;
		stream << " can't find the server " << serverID;
		stream << " msg id " << msgID;
		m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
	}
}

void NFNetClientModule::SendToAllServerByPB(const uint16_t msgID, const google::protobuf::Message& xData, const NFGUID id)
{
    NF_SHARE_PTR<ConnectData> pServer = mxServerMap.First();
    while (pServer)
    {
        NF_SHARE_PTR<NFINetModule> pNetModule = pServer->mxNetModule;
        if (pNetModule)
        {
			if (!pNetModule->SendMsgPB(msgID, xData, 0, id))
			{
				std::ostringstream stream;
				stream << " SendMsgPB failed " << pServer->nGameID;
				stream << " msg id " << msgID;
				m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
			}
        }

        pServer = mxServerMap.Next();
    }
}

void NFNetClientModule::SendToAllServerByPB(const NF_SERVER_TYPES eType, const uint16_t msgID, const google::protobuf::Message& xData, const NFGUID id)
{
    NF_SHARE_PTR<ConnectData> pServer = mxServerMap.First();
    while (pServer)
    {
        NF_SHARE_PTR<NFINetModule> pNetModule = pServer->mxNetModule;
        if (pNetModule && eType == pServer->eServerType && pServer->eState == ConnectDataState::NORMAL)
        {
            if (!pNetModule->SendMsgPB(msgID, xData, 0, id))
			{
				std::ostringstream stream;
				stream << " SendMsgPB failed " << pServer->nGameID;
				stream << " msg id " << msgID;
				m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
			}
        }

        pServer = mxServerMap.Next();
    }
}

void NFNetClientModule::SendBySuitWithOutHead(const NF_SERVER_TYPES eType, const std::string & strHashKey, const uint16_t msgID, const std::string & strData)
{
	uint32_t nCRC32 = NFrame::CRC32(strHashKey);
	SendBySuitWithOutHead(eType, nCRC32, msgID, strData);
}

void NFNetClientModule::SendBySuit(const NF_SERVER_TYPES eType, const std::string& strHashKey, const uint16_t msgID,
                                    const std::string& strData)
{
    uint32_t nCRC32 = NFrame::CRC32(strHashKey);
    SendBySuit(eType, nCRC32, msgID, strData);
}

void NFNetClientModule::SendBySuit(const NF_SERVER_TYPES eType, const std::string & strHashKey, const uint16_t msgID, const std::string & strData, const NFGUID id)
{
	uint32_t nCRC32 = NFrame::CRC32(strHashKey);
	SendBySuit(eType, nCRC32, msgID, strData, id);
}

void NFNetClientModule::SendBySuitWithOutHead(const NF_SERVER_TYPES eType, const int nHashKey32, const uint16_t msgID, const std::string & strData)
{
	NF_SHARE_PTR<NFConsistentHashMapEx<int, ConnectData>> xConnectDataMap = mxServerTypeMap.GetElement(eType);
	if (xConnectDataMap)
	{
		NF_SHARE_PTR<ConnectData> pConnectData = xConnectDataMap->GetElementBySuit(nHashKey32);
		if (pConnectData)
		{
			SendByServerIDWithOutHead(pConnectData->nGameID, msgID, strData);
		}
	}
	else
	{
		std::ostringstream stream;
		stream << " can't find the server type " << eType;
		stream << " msg id " << msgID;
		m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
	}
}

void NFNetClientModule::SendBySuit(const NF_SERVER_TYPES eType, const int nHashKey, const uint16_t msgID, const std::string& strData)
{
	NF_SHARE_PTR<NFConsistentHashMapEx<int, ConnectData>> xConnectDataMap = mxServerTypeMap.GetElement(eType);
	if (xConnectDataMap)
	{
		NF_SHARE_PTR<ConnectData> pConnectData = xConnectDataMap->GetElementBySuit(nHashKey);
		if (pConnectData)
		{
			SendByServerID(pConnectData->nGameID, msgID, strData);
		}
	}
	else
	{
		std::ostringstream stream;
		stream << " can't find the server type " << eType;
		stream << " msg id " << msgID;
		m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
	}
}

void NFNetClientModule::SendBySuit(const NF_SERVER_TYPES eType, const int nHashKey32, const uint16_t msgID, const std::string & strData, const NFGUID id)
{
	NF_SHARE_PTR<NFConsistentHashMapEx<int, ConnectData>> xConnectDataMap = mxServerTypeMap.GetElement(eType);
	if (xConnectDataMap)
	{
		NF_SHARE_PTR<ConnectData> pConnectData = xConnectDataMap->GetElementBySuit(nHashKey32);
		if (pConnectData)
		{
			SendByServerID(pConnectData->nGameID, msgID, strData, id);
		}
	}
	else
	{
		std::ostringstream stream;
		stream << " can't find the server type " << eType;
		stream << " msg id " << msgID;
		m_pLogModule->LogError(stream, __FUNCTION__, __LINE__);
	}
}

void NFNetClientModule::SendSuitByPB(const NF_SERVER_TYPES eType, const std::string& strHashKey, const uint16_t msgID, const google::protobuf::Message& xData)
{
    uint32_t nCRC32 = NFrame::CRC32(strHashKey);
    SendSuitByPB(eType, nCRC32, msgID, xData);
}

void NFNetClientModule::SendSuitByPB(const NF_SERVER_TYPES eType, const std::string & strHashKey, const uint16_t msgID, const google::protobuf::Message & xData, const NFGUID id)
{
	uint32_t nCRC32 = NFrame::CRC32(strHashKey);
	SendSuitByPB(eType, nCRC32, msgID, xData, id);
}

void NFNetClientModule::SendSuitByPB(const NF_SERVER_TYPES eType, const int nHashKey, const uint16_t msgID, const google::protobuf::Message& xData)
{
    NF_SHARE_PTR<NFConsistentHashMapEx<int, ConnectData>> xConnectDataMap = mxServerTypeMap.GetElement(eType);
    if (xConnectDataMap)
    {
        NF_SHARE_PTR<ConnectData> pConnectData = xConnectDataMap->GetElementBySuit(nHashKey);
        if (pConnectData)
        {
            SendToServerByPB(pConnectData->nGameID, msgID, xData);
        }
    }
}

void NFNetClientModule::SendSuitByPB(const NF_SERVER_TYPES eType, const int nHashKey32, const uint16_t msgID, const google::protobuf::Message & xData, const NFGUID id)
{
	NF_SHARE_PTR<NFConsistentHashMapEx<int, ConnectData>> xConnectDataMap = mxServerTypeMap.GetElement(eType);
	if (xConnectDataMap)
	{
		NF_SHARE_PTR<ConnectData> pConnectData = xConnectDataMap->GetElementBySuit(nHashKey32);
		if (pConnectData)
		{
			SendToServerByPB(pConnectData->nGameID, msgID, xData, id);
		}
	}
}

NF_SHARE_PTR<ConnectData> NFNetClientModule::GetServerNetInfo(const NF_SERVER_TYPES eType)
{
    NF_SHARE_PTR<NFConsistentHashMapEx<int, ConnectData>> xConnectDataMap = mxServerTypeMap.GetElement(eType);
    if (xConnectDataMap)
    {
        return xConnectDataMap->GetElementBySuitRandom();
    }

    return nullptr;
}

NF_SHARE_PTR<ConnectData> NFNetClientModule::GetServerNetInfo(const int serverID)
{
    return mxServerMap.GetElement(serverID);
}

NFMapEx<int, ConnectData>& NFNetClientModule::GetServerList()
{
    return mxServerMap;
}

NF_SHARE_PTR<ConnectData> NFNetClientModule::GetServerNetInfo(const NFINet* pNet)
{
    int serverID = 0;
    for (NF_SHARE_PTR<ConnectData> pData = mxServerMap.First(serverID);
         pData != NULL; pData = mxServerMap.Next(serverID))
    {
        if (pData->mxNetModule && pNet == pData->mxNetModule->GetNet())
        {
            return pData;
        }
    }

    return NF_SHARE_PTR<ConnectData>(NULL);
}

#define NF_PROPERTY_2(TYPE, PN) \
	TYPE Get##PN() const { return PN; } \
	void Set##PN(const TYPE& value) { PN = value; }\
	TYPE PN;


#define NF_STRUCT_BEGIN(STRUCT_NAME) struct STRUCT_NAME{
#define NF_STRUCT_END() };

NF_STRUCT_BEGIN(ConnectData2)
NF_PROPERTY_2(int, nGameID)
NF_PROPERTY_2(NF_SERVER_TYPES, eServerType)
NF_STRUCT_END();

#define NF_STRUCT_DEFINE(STRUCT_NAME) \
NF_STRUCT_BEGIN(STRUCT_NAME)\
NF_PROPERTY_2(int, nGameID)\
NF_PROPERTY_2(NF_SERVER_TYPES, eServerType)\
NF_STRUCT_END()

NF_STRUCT_DEFINE(ConnectData3)

void NFNetClientModule::OnRegisterLua()
{
	LuaIntf::LuaContext* context = (LuaIntf::LuaContext*)m_pLuaScriptModule->GetLuaContext();
	LuaIntf::LuaBinding(*context).beginClass<ConnectData>("ConnectData")
	.addConstructor(LUA_ARGS())
		//.addProperty("nGameID", &ConnectData::GetnGameID, &ConnectData::SetnGameID)
		.NF_LUA_PROPERTY(ConnectData, nGameID)
		.NF_LUA_PROPERTY(ConnectData, eServerType)
		.NF_LUA_PROPERTY(ConnectData, ip)
		.NF_LUA_PROPERTY(ConnectData, nPort)
		.NF_LUA_PROPERTY(ConnectData, nWorkLoad)
		.NF_LUA_PROPERTY(ConnectData, name)
		.NF_LUA_PROPERTY(ConnectData, eState)
		.NF_LUA_PROPERTY(ConnectData, mnLastActionTime)
		.NF_LUA_PROPERTY(ConnectData, mxNetModule)
    .endClass();

	LuaIntf::LuaBinding(*context).beginModule("NFNetClientModule")
		//.addFunction("AddServer", &NFNetClientModule::AddServer)
		.endModule();
}

void NFNetClientModule::InitCallBacks(NF_SHARE_PTR<ConnectData> pServerData)
{
	std::ostringstream stream;
	stream << "AddServer Type: " << pServerData->eServerType << " Server ID: " << pServerData->nGameID << " State: "
		<< pServerData->eState << " IP: " << pServerData->ip << " Port: " << pServerData->nPort;

	m_pLogModule->LogInfo(stream.str());

    NF_SHARE_PTR<CallBack> xCallBack = mxCallBack.GetElement(pServerData->eServerType);
    if (!xCallBack)
    {
        xCallBack = NF_SHARE_PTR<CallBack>(NF_NEW CallBack);
        mxCallBack.AddElement(pServerData->eServerType, xCallBack);
    }

    //add msg callback
    std::map<int, std::list<NET_RECEIVE_FUNCTOR_PTR>>::iterator itReciveCB = xCallBack->mxReceiveCallBack.begin();
    for (; xCallBack->mxReceiveCallBack.end() != itReciveCB; ++itReciveCB)
    {
		std::list<NET_RECEIVE_FUNCTOR_PTR>& xList = itReciveCB->second;
		for (std::list<NET_RECEIVE_FUNCTOR_PTR>::iterator itList = xList.begin(); itList != xList.end(); ++itList)
		{
			pServerData->mxNetModule->AddReceiveCallBackMsgId(itReciveCB->first, *itList);
		}
    }

    //add event callback
    std::list<NET_EVENT_FUNCTOR_PTR>::iterator itEventCB = xCallBack->mxEventCallBack.begin();
    for (; xCallBack->mxEventCallBack.end() != itEventCB; ++itEventCB)
    {
        pServerData->mxNetModule->AddEventCallBack(*itEventCB);
    }

    std::list<NET_RECEIVE_FUNCTOR_PTR>::iterator itCB = xCallBack->mxCallBackList.begin();
    for (; xCallBack->mxCallBackList.end() != itCB; ++itCB)
    {
        pServerData->mxNetModule->AddReceiveCallBack(*itCB);
    }
}

void NFNetClientModule::ProcessExecute()
{
    NF_SHARE_PTR<ConnectData> pServerData = mxServerMap.First();
    while (pServerData)
    {
        switch (pServerData->eState)
        {
            case ConnectDataState::DISCONNECT:
            {
                if (NULL != pServerData->mxNetModule)
                {
                    pServerData->mxNetModule = nullptr;
                    pServerData->eState = ConnectDataState::RECONNECT;
                }
            }
                break;
            case ConnectDataState::CONNECTING:
            {
                if (pServerData->mxNetModule)
                {
                    pServerData->mxNetModule->Execute();
                }
            }
                break;
            case ConnectDataState::NORMAL:
            {
                if (pServerData->mxNetModule)
                {
                    pServerData->mxNetModule->Execute();

                    KeepState(pServerData);
                }
            }
                break;
            case ConnectDataState::RECONNECT:
            {
                if ((pServerData->mnLastActionTime + 10) >= GetPluginManager()->GetNowTime())
                {
                    break;
                }

                if (nullptr != pServerData->mxNetModule)
                {
                    pServerData->mxNetModule = nullptr;
                }

                pServerData->eState = ConnectDataState::CONNECTING;
                pServerData->mxNetModule = NF_SHARE_PTR<NFINetModule>(NF_NEW NFNetModule(pPluginManager));

				pServerData->mxNetModule->Awake();
				pServerData->mxNetModule->Init();
				pServerData->mxNetModule->AfterInit();
				pServerData->mxNetModule->ReadyExecute();

                pServerData->mxNetModule->InitializationC(pServerData->ip.c_str(), pServerData->nPort);

                InitCallBacks(pServerData);
            }
                break;
            default:
                break;
        }

        pServerData = mxServerMap.Next();
    }
}

void NFNetClientModule::LogServerInfo()
{
	bool error = false;
	std::ostringstream stream;
	stream << "This is a client, begin to print Server Info-------------------" << std::endl;

    ConnectData* pServerData = mxServerMap.FirstNude();
    while (nullptr != pServerData)
    {
        stream << "Type: " << pServerData->eServerType << " Server ID: " << pServerData->nGameID << " State: " << pServerData->eState << " IP: " << pServerData->ip << " Port: " << pServerData->nPort;

		if (pServerData->eState != ConnectDataState::NORMAL)
		{
			error = true;
		}

        pServerData = mxServerMap.NextNude();
    }

	stream << "This is a client, end to print Server Info---------------------" << std::endl;

    if (error)
	{
		m_pLogModule->LogError(stream.str());
	}
	else
	{
		m_pLogModule->LogInfo(stream.str());
	}
}

void NFNetClientModule::KeepState(NF_SHARE_PTR<ConnectData> pServerData)
{
    if (pServerData->mnLastActionTime + 10 > GetPluginManager()->GetNowTime())
    {
        return;
    }

    pServerData->mnLastActionTime = GetPluginManager()->GetNowTime();

	//send message
}

void NFNetClientModule::OnSocketEvent(const NFSOCK fd, const NF_NET_EVENT eEvent, NFINet* pNet)
{
    if (eEvent & NF_NET_EVENT::NF_NET_EVENT_CONNECTED)
    {
        OnConnected(fd, pNet);
    }
	else
    {
        OnDisConnected(fd, pNet);
    }
}

int NFNetClientModule::OnConnected(const NFSOCK fd, NFINet* pNet)
{
    NF_SHARE_PTR<ConnectData> pServerInfo = GetServerNetInfo(pNet);
    if (pServerInfo)
    {
        /////////////////////////////////////////////////////////////////////////////////////
        //AddServerWeightData(pServerInfo);
        pServerInfo->eState = ConnectDataState::NORMAL;

        //for type--suit
        NF_SHARE_PTR<NFConsistentHashMapEx<int, ConnectData>> xConnectDataMap = mxServerTypeMap.GetElement(pServerInfo->eServerType);
        if (!xConnectDataMap)
        {
            xConnectDataMap = NF_SHARE_PTR<NFConsistentHashMapEx<int, ConnectData>>(NF_NEW NFConsistentHashMapEx<int, ConnectData>());
            mxServerTypeMap.AddElement(pServerInfo->eServerType, xConnectDataMap);
        }

        xConnectDataMap->AddElement(pServerInfo->nGameID, pServerInfo);
    }

    return 0;
}

int NFNetClientModule::OnDisConnected(const NFSOCK fd, NFINet* pNet)
{
    NF_SHARE_PTR<ConnectData> pServerInfo = GetServerNetInfo(pNet);
    if (nullptr != pServerInfo)
    {
        /////////////////////////////////////////////////////////////////////////////////////
        //RemoveServerWeightData(pServerInfo);
        pServerInfo->eState = ConnectDataState::DISCONNECT;
        pServerInfo->mnLastActionTime = GetPluginManager()->GetNowTime();

        //for type--suit
        NF_SHARE_PTR<NFConsistentHashMapEx<int, ConnectData>> xConnectDataMap = mxServerTypeMap.GetElement(pServerInfo->eServerType);
        if (xConnectDataMap)
        {
			xConnectDataMap->RemoveElement(pServerInfo->nGameID);
        }
    }

    return 0;
}

void NFNetClientModule::ProcessAddNetConnect()
{
    std::list<ConnectData>::iterator it = mxTempNetList.begin();
    for (; it != mxTempNetList.end(); ++it)
    {
        const ConnectData& xInfo = *it;
        NF_SHARE_PTR<ConnectData> xServerData = mxServerMap.GetElement(xInfo.nGameID);
        if (nullptr == xServerData)
        {
            xServerData = NF_SHARE_PTR<ConnectData>(NF_NEW ConnectData());

            xServerData->nGameID = xInfo.nGameID;
            xServerData->eServerType = xInfo.eServerType;
            xServerData->ip = xInfo.ip;
            xServerData->name = xInfo.name;
            xServerData->eState = ConnectDataState::CONNECTING;
            xServerData->nPort = xInfo.nPort;
            xServerData->mnLastActionTime = GetPluginManager()->GetNowTime();

            xServerData->mxNetModule = NF_SHARE_PTR<NFINetModule>(NF_NEW NFNetModule(pPluginManager));

			xServerData->mxNetModule->Awake();
			xServerData->mxNetModule->Init();
			xServerData->mxNetModule->AfterInit();
			xServerData->mxNetModule->ReadyExecute();

            xServerData->mxNetModule->InitializationC(xServerData->ip.c_str(), xServerData->nPort);
            xServerData->mxNetModule->ExpandBufferSize((unsigned int)mnBufferSize);

            InitCallBacks(xServerData);

            mxServerMap.AddElement(xInfo.nGameID, xServerData);
        }
		else
		{
			xServerData->nWorkLoad = xInfo.nWorkLoad;
		}
    }

    mxTempNetList.clear();
}