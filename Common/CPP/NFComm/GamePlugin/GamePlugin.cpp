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

#include "GamePlugin.h"
#include <entt/entity/registry.hpp>

#ifdef NF_DYNAMIC_PLUGIN

NF_EXPORT void DllStartPlugin(NFIPluginManager* pm)
{
    CREATE_PLUGIN(pm, GamePlugin)

};

NF_EXPORT void DllStopPlugin(NFIPluginManager* pm)
{
    DESTROY_PLUGIN(pm, GamePlugin)
};

#endif

//////////////////////////////////////////////////////////////////////////

const int GamePlugin::GetPluginVersion()
{
    return 0;
}

const std::string GamePlugin::GetPluginName()
{
	return GET_CLASS_NAME(GamePlugin);
}

class testPosition
{	
public:
	float x;
	float y;
	float z;
	testPosition(float x, float y, float z) : x(x), y(y), z(z) {}
	virtual int getTestValue() { return 6; }
};

class testPosition2 : public testPosition
{
public:
	virtual int getTestValue() { return 7; }
};


void GamePlugin::Install()
{
	entt::registry registry;

	auto entity = registry.create();

	registry.emplace<testPosition>(entity, 1.0f, 2.0f, 3.0f);

	//testPosition tt;

	//registry.emplace(tt);

	std::cout << "ECS ?" << registry.valid(entity) << " " << registry.get<testPosition>(entity).x << std::endl;
	registry.patch<testPosition>(entity, [](testPosition& pos) {
		pos.x = 2.0f;
		pos.y = 3.0f;
		pos.z = 4.0f;
	});
	std::cout << "ECS ?" << registry.valid(entity) << " " << registry.get<testPosition>(entity).x << std::endl;

	/*
	REGISTER_TEST_MODULE(pPluginManager, NFIKernelModule, NFKernelTestModule)
	REGISTER_TEST_MODULE(pPluginManager, NFIEventModule, NFEventTestModule)
	REGISTER_TEST_MODULE(pPluginManager, NFIScheduleModule, NFScheduleTestModule)
	*/
}

void GamePlugin::Uninstall()
{
	/*
	UNREGISTER_TEST_MODULE(pPluginManager, NFIEventModule, NFEventTestModule)
	UNREGISTER_TEST_MODULE(pPluginManager, NFIKernelModule, NFKernelTestModule)
	UNREGISTER_TEST_MODULE(pPluginManager, NFIScheduleModule, NFScheduleTestModule)
*/

}