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


#include "NFComm/NFPluginLoader/NFPluginServer.h"

//#pragma comment( lib, "lua.lib" )
#ifndef NF_DYNAMIC_PLUGIN
//for nf-sdk plugins
#include "NFComm/NFActorPlugin/NFActorPlugin.h"
#include "NFComm/NFConfigPlugin/NFConfigPlugin.h"
#include "NFComm/NFKernelPlugin/NFKernelPlugin.h"
#include "NFComm/NFLogPlugin/NFLogPlugin.h"
#include "NFComm/NFLuaScriptPlugin/NFLuaScriptPlugin.h"
#include "NFComm/NFNavigationPlugin/NFNavigationPlugin.h"
#include "NFComm/NFNetPlugin/NFNetPlugin.h"
#include "NFComm/NFNoSqlPlugin/NFNoSqlPlugin.h"
#include "NFComm/NFSecurityPlugin/NFSecurityPlugin.h"


#if NF_PLATFORM == NF_PLATFORM_WIN

#pragma comment( lib, "NFCore.lib" )
#pragma comment( lib, "NFMessageDefine.lib" )
//#pragma comment( lib, "NFNetPlugin.lib" )
#pragma comment( lib, "NFActorPlugin.lib" )
#pragma comment( lib, "NFConfigPlugin.lib" )
#pragma comment( lib, "NFKernelPlugin.lib" )
#pragma comment( lib, "NFLogPlugin.lib" )
#pragma comment( lib, "NFLuaScriptPlugin.lib" )
//#pragma comment( lib, "NFNavigationPlugin.lib" )
//#pragma comment( lib, "NFNetPlugin.lib" )
#pragma comment( lib, "NFNoSqlPlugin.lib" )
#pragma comment( lib, "NFSecurityPlugin.lib" )
#pragma comment( lib, "NFPluginLoader.lib" )



#endif
#endif



void BasicPluginLoader(NFIPluginManager* pPluginManager)
{

#ifndef NF_DYNAMIC_PLUGIN

	//for nf-sdk plugins

	CREATE_PLUGIN(pPluginManager, NFActorPlugin)
	CREATE_PLUGIN(pPluginManager, NFConfigPlugin)
	CREATE_PLUGIN(pPluginManager, NFKernelPlugin)
	CREATE_PLUGIN(pPluginManager, NFLogPlugin)
	//CREATE_PLUGIN(pPluginManager, NFLuaScriptPlugin)
	CREATE_PLUGIN(pPluginManager, NFNavigationPlugin)
	CREATE_PLUGIN(pPluginManager, NFNetPlugin)
	// CREATE_PLUGIN(pPluginManager, NFNoSqlPlugin)
	CREATE_PLUGIN(pPluginManager, NFSecurityPlugin)
	//CREATE_PLUGIN(pPluginManager, NFTestPlugin)

#if NF_PLATFORM == NF_PLATFORM_APPLE || NF_PLATFORM == NF_PLATFORM_WIN
#ifdef NF_DEBUG_MODE
		//CREATE_PLUGIN(pPluginManager, NFRenderPlugin)
		//CREATE_PLUGIN(pPluginManager, NFBluePrintPlugin)
#endif
#endif

#endif
}

void MidWareLoader(NFIPluginManager* pPluginManager)
{
	//CREATE_PLUGIN(pPluginManager, NFChatPlugin)
}
