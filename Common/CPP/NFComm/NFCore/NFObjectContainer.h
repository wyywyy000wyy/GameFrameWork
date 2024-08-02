#ifndef NF_OBJECT_CONTAINER_H
#define NF_OBJECT_CONTAINER_H

#include "NFComm/NFCore/NFIObject.h"
#include "NFComm/NFPluginModule/NFPlatform.h"
#include "NFComm/NFLuaScriptPlugin/NFLuaRequire.h"

class NFIContainerFilter
{
public:
	
};

class _NFExport NFObjectContainer
{
	using ObjType = NF_SHARE_PTR<NFIObject>;
	#define LUA_CLASS NFObjectContainer

public:
	NFObjectContainer()
	{
	}

	virtual ~NFObjectContainer()
	{
	}

	virtual bool AddElement(const NFGUID& self, const ObjType& object)
	{
		if (mObject.find(self) == mObject.end())
		{
			mObject.insert(std::map<NFGUID, ObjType>::value_type(self, object));
			return true;
		}

		return false;
	}

	virtual bool RemoveElement(const NFGUID& self)
	{
		if (mObject.find(self) != mObject.end())
		{
			mObject.erase(self);
			return true;
		}

		return false;
	}

	virtual ObjType GetElement(const NFGUID& self)
	{
		auto it = mObject.find(self);
		if (it != mObject.end())
		{
			return it->second;
		}

		return nullptr;
	}

	virtual bool ExistElement(const NFGUID& self)
	{
		auto it = mObject.find(self);
		if (it != mObject.end())
		{
			return true;
		}

		return false;
	}

	virtual bool ClearAll()
	{
		mObject.clear();
		return true;
	}

	virtual bool Foreach(std::function<void(const NFGUID& self, ObjType& object)> func)
	{
		for (auto it : mObject)
		{
			func(it.first, it.second);
		}

		return true;
	}

	virtual bool Foreach(std::function<void(const NFGUID& self, const ObjType& object)> func) const
	{
		for (auto it : mObject)
		{
			func(it.first, it.second);
		}

		return true;
	}

	virtual bool Foreach(std::function<void(const NFGUID& self)> func)
	{
		for (auto it : mObject)
		{
			func(it.first);
		}

		return true;
	}

	virtual bool Foreach(std::function<void(const NFGUID& self)> func) const
	{
		for (auto it : mObject)
		{
			func(it.first);
		}

		return true;
	}

	virtual bool Foreach(std::function<void(ObjType& object)> func)
	{
		for (auto it : mObject)
		{
			func(it.second);
		}

		return true;
	}

	
protected:

	std::map <NFGUID, ObjType> mObject;
	std::list <NFIContainerFilter*> mFilters;
};



#endif // !NF_OBJECT_CONTAINER_H