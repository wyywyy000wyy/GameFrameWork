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

#include "NFClient.h"
#include <iostream>

NFPluginServer* pPluginServer = nullptr;

extern "C" {
	__declspec(dllexport) void nfclient_lib_clear()
	{
		if (pPluginServer)
		{
			pPluginServer->Final();
			delete pPluginServer;
			pPluginServer = nullptr;
		}
	}

	__declspec(dllexport) void nfclient_lib_init(const char* strArgvList)
	{
		std::cout << "nfclient_lib_init:" << std::endl;
		nfclient_lib_clear();
		pPluginServer = NF_NEW NFPluginServer(strArgvList);
		pPluginServer->SetBasicWareLoader(BasicPluginLoader);
		pPluginServer->SetMidWareLoader(MidWareLoader);
		pPluginServer->Init();
	}

	__declspec(dllexport) void nfclient_lib_loop()
	{
		if (pPluginServer)
		{
			pPluginServer->Execute();
		}
	}

	
}