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

#ifndef NFI_MODULE_H
#define NFI_MODULE_H
#define LUAINTF_LINK_LUA_COMPILED_IN_CXX 0

#include <string>
#include "NFIPluginManager.h"
#include "NFComm/NFCore/NFMap.hpp"
#include "NFComm/NFCore/NFList.hpp"
#include "NFComm/NFCore/NFDataList.hpp"
#include "NFComm/NFCore/NFSmartEnum.hpp"

#include "NFComm/NFLuaScriptPlugin/NFLuaRequire.h"


class NFIModule
{

public:
    NFIModule() : m_bIsExecute(false), pPluginManager(NULL)
    {
    }

    virtual ~NFIModule() {}

    virtual bool Awake()
    {
        return true;
    }

    virtual bool Init()
    {

        return true;
    }

    virtual bool AfterInit()
    {
        return true;
    }

    virtual bool CheckConfig()
    {
        return true;
    }

    virtual bool ReadyExecute()
    {
        return true;
    }

    virtual bool Execute()
    {
        return true;
    }

    virtual bool BeforeShut()
    {
        return true;
    }

    virtual bool Shut()
    {
        return true;
    }

    virtual bool Finalize()
    {
        return true;
    }

	virtual bool OnReloadPlugin()
	{
		return true;
	}

    virtual NFIPluginManager* GetPluginManager() const
    {
        return pPluginManager;
    }

    virtual void OnRegisterLua() {};


    void RegisterLua(NFILuaScriptModule* p)
    {
        m_pLuaScriptModule = p;
        OnRegisterLua();
    }

    std::string name;
    bool m_bIsExecute;
protected:
	NFIPluginManager* pPluginManager;
    NFILuaScriptModule* m_pLuaScriptModule;
};


#endif
#include "NFComm/NFPluginModule/NFILuaScriptModule.h"
