#ifndef LUA_REQUIRE_H
#define LUA_REQUIRE_H

#include "Dependencies/LuaIntf/LuaIntf/LuaIntf.h"
#include "Dependencies/LuaIntf/LuaIntf/LuaRef.h"
#define LUA_MACRO_STR(__LUA_CLASS) #__LUA_CLASS
#define LD1(P_TYPE, P_VALUE) \
public: \
	P_TYPE P_VALUE; \
	P_TYPE Get##P_VALUE() \
	{ \
		return P_VALUE; \
	} \
	void Set##P_VALUE(P_TYPE value) \
	{ \
		P_VALUE = value; \
	} \

#define LD2(P_TYPE, P_VALUE) \
	.addProperty(#P_VALUE, &LUA_CLASS::Get##P_VALUE, &LUA_CLASS::Set##P_VALUE)

#define LP1 LUA_PS
#define LP2 \
public:\
void static RC(LuaIntf::LuaContext* context)\
{\
	LuaIntf::LuaBinding(*context).beginClass<LUA_CLASS>(LUA_MACRO_STR(LUA_CLASS))\
		LUA_PS\
		.endClass();\
}\
LuaIntf::CppBindClass<LUA_CLASS, LuaIntf::LuaBinding> static RC_Begin(LuaIntf::LuaContext* context)\
	{\
		auto binding = LuaIntf::LuaBinding(*context).beginClass<LUA_CLASS>(LUA_MACRO_STR(LUA_CLASS));\
		binding \
			LUA_PS\
			;\
		return binding;\
	}

#define LUA_CLASS_REGISTER(_CLASS) \
	_CLASS::RC(((LuaIntf::LuaContext*)GetLuaContext()));

#define LUA_CLASS_REGISTER_BEGIN(_CLASS) \
	_CLASS::RC_Begin(((LuaIntf::LuaContext*)GetLuaContext()))

#define LUA_CLASS_REGISTER_END .endClass();

//class TestClassBMacro
//{
//#define LUA_CLASS TestClassBMacro
//#define LUA_PS \
//	LD(int, mValue)\
//	LD(int, mValue2)
//
//#define LD LD1
//	LP1
//#undef LD
//#define LD LD2
//		LP2
//#undef LD
//#undef LUA_CLASS
//};

////---------------use LP2
	//TestClassBMacro::RC(((LuaIntf::LuaContext*)GetLuaContext()));



namespace LuaIntf
{
	LUA_USING_SHARED_PTR_TYPE(std::shared_ptr)
}

class NFILuaScriptModule;

#define NF_PROPERTY(TYPE, PN) \
public: \
	TYPE Get##PN() const { return PN; } \
	void Set##PN(const TYPE& value) { PN = value; } \
	TYPE PN;


#define NF_LUA_PROPERTY(TYPE, __PN) addProperty(#__PN, &TYPE::Get##__PN, &TYPE::Set##__PN)


//#define LUA_MODULE_FUNC_DEFINE2(FUNCTION_NAME, RETURN_TYPE, TYPE1, VALUE1, TYPE2, VALUE2) \
//	RETURN_TYPE FUNCTION_NAME(TYPE1 VALUE1, TYPE2 VALUE2);

#define LUA_MODULE_FUNC_DEFINE2(FUNCTION_NAME, RETURN_TYPE, TYPE1, VALUE1, TYPE2, VALUE2) \
	RETURN_TYPE FUNCTION_NAME_(TYPE1 VALUE1, TYPE2 VALUE2);\
	LuaIntf::LuaRef FUNCTION_NAME##Wrapper_; \
	RETURN_TYPE FUNCTION_NAME(TYPE1 VALUE1, TYPE2 VALUE2);\

#define LUA_MODULE_FUNC_IMGL2(FUNCTION_NAME, RETURN_TYPE, TYPE1, VALUE1, TYPE2, VALUE2) \
RETURN_TYPE LUA_MODULE_CLASS::FUNCTION_NAME(TYPE1 VALUE1, TYPE2 VALUE2)\
{ \
	if (FUNCTION_NAME##Wrapper_.isFunction()) \
	{ \
		return FUNCTION_NAME##Wrapper_.call<RETURN_TYPE>(VALUE1, VALUE2); \
	} \
	return FUNCTION_NAME_(VALUE1, VALUE2);\
}\
RETURN_TYPE LUA_MODULE_CLASS::FUNCTION_NAME_(TYPE1 VALUE1, TYPE2 VALUE2)\



#define LUA_MODULE_REGISTER(FUNCTION_NAME) \
	.addFunction(#FUNCTION_NAME, &LUA_MODULE_CLASS::FUNCTION_NAME)\
	.addVariableRef(#FUNCTION_NAME"Wrapper_", &LUA_MODULE_CLASS::FUNCTION_NAME##Wrapper_, true)\

#define LUA_MODULE_REGISTER2(_NON, FUNCTION_NAME) LUA_MODULE_REGISTER(FUNCTION_NAME)

#endif