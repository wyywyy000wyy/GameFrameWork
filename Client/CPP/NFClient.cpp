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

// #include "NFClient.h"
#include <iostream>
#include <vector>
#include <thread>
#include <chrono>
#include "lua.h"
//#include "NFClient.h"
#include "NFComm/NFPluginModule/NFIModule.h"
#include "NFComm/NFPluginModule/NFILuaScriptModule.h"
#include "NFComm/NFPluginLoader/NFPluginServer.h"
#if _WIN32
#include <windows.h>
#endif


extern "C" {
	extern NFPluginServer* pPluginServer;
	extern void nfclient_lib_clear();

	extern void nfclient_lib_init(const char* strArgvList, lua_State* L);

	extern void nfclient_lib_loop();
	extern void nfclient_hot_reload();

}

int main(int argc, char* argv[])
{
	std::cout << "__cplusplus:" << __cplusplus << std::endl;

	// std::vector<NF_SHARE_PTR<NFPluginServer>> serverList;

	std::string strArgvList;
	for (int i = 0; i < argc; i++)
	{
		strArgvList += " ";
		strArgvList += argv[i];
	}

	nfclient_lib_init("", NULL);


	int dt = 0;
	while (true)
	{
		std::this_thread::sleep_for(std::chrono::milliseconds(1));
		nfclient_lib_loop();
#if _WIN32
		if (GetAsyncKeyState(VK_F5) & 0x8000  && dt < 0) {
			printf("F5 key pressed.\n");
			dt = 10;
			nfclient_hot_reload();
			//pLuaScriptModule->HotReload();
			// 处理F5键消息
			// ...
		}
#endif
		dt--;
	}

	//if (argc == 1)
	//{
	//	//IDE
	//	serverList.push_back(NF_SHARE_PTR<NFPluginServer>(NF_NEW NFPluginServer(strArgvList + " Server=MasterServer ID=3 Plugin=Plugin.xml")));
	//	serverList.push_back(NF_SHARE_PTR<NFPluginServer>(NF_NEW NFPluginServer(strArgvList + " Server=WorldServer ID=7 Plugin=Plugin.xml")));
	//	serverList.push_back(NF_SHARE_PTR<NFPluginServer>(NF_NEW NFPluginServer(strArgvList + " Server=LoginServer ID=4 Plugin=Plugin.xml")));
	//	serverList.push_back(NF_SHARE_PTR<NFPluginServer>(NF_NEW NFPluginServer(strArgvList + " Server=DBServer ID=8 Plugin=Plugin.xml")));
	//	serverList.push_back(NF_SHARE_PTR<NFPluginServer>(NF_NEW NFPluginServer(strArgvList + " Server=ProxyServer ID=5 Plugin=Plugin.xml")));
	//	serverList.push_back(NF_SHARE_PTR<NFPluginServer>(NF_NEW NFPluginServer(strArgvList + " Server=GameServer ID=16001 Plugin=Plugin.xml")));
	//}
	//else
	//{
	//	serverList.push_back(NF_SHARE_PTR<NFPluginServer>(NF_NEW NFPluginServer(strArgvList)));
	//}
	// serverList.push_back(NF_SHARE_PTR<NFPluginServer>(NF_NEW NFPluginServer(strArgvList + " Server=GameServer ID=16001 Plugin=Plugin.xml")));


	// for (auto item : serverList)
	// {
	// 	item->SetBasicWareLoader(BasicPluginLoader);
	// 	item->SetMidWareLoader(MidWareLoader);
	// 	item->Init();
	// }


	// ////////////////
	// uint64_t nIndex = 0;
	// while (true)
	// {
	// 	nIndex++;

	// 	std::this_thread::sleep_for(std::chrono::milliseconds(1));
	// 	for (auto item : serverList)
	// 	{
	// 		item->Execute();
	// 	}
	// }

	// ////////////////

	// for (auto item : serverList)
	// {
	// 	item->Final();
	// }

	// serverList.clear();
	nfclient_lib_clear();
    return 0;
}