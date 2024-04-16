class NFILuaScriptModule
	: public NFIModule
{
public:
	virtual void* GetLuaContext() = 0;
};