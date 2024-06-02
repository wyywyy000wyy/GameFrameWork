#ifndef NFI_LUA_SCRIPT_MODULE_H
#define NFI_LUA_SCRIPT_MODULE_H



class NFILuaScriptModule
	: public NFIModule
{
public:
	virtual void* GetLuaContext() = 0;
	virtual void* HotReload() = 0;
	
};

#endif