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

#include "NFKernelModule.h"
#include "NFSceneModule.h"
#include "NFComm/NFCore/NFMemManager.hpp"
#include "NFComm/NFCore/NFObject.h"
#include "NFComm/NFCore/NFRecord.h"
#include "NFComm/NFCore/NFPerformance.hpp"
#include "NFComm/NFCore/NFPropertyManager.h"
#include "NFComm/NFCore/NFRecordManager.h"
#include "NFComm/NFCore/NFMemoryCounter.h"
#include "NFComm/NFPluginModule/NFGUID.h"
#include "NFComm/NFMessageDefine/NFProtocolDefine.hpp"

NFKernelModule::NFKernelModule(NFIPluginManager* p)
{
    m_bIsExecute = true;
	nGUIDIndex = 0;
	nLastTime = 0;

	pPluginManager = p;

	nLastTime = pPluginManager->GetNowTime();
	InitRandom();
}

NFKernelModule::~NFKernelModule()
{
	ClearAll();
}

void NFKernelModule::InitRandom()
{
	mvRandom.clear();

	constexpr int nRandomMax = 100000;
	mvRandom.reserve(nRandomMax);

	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_real_distribution<> dis(0, 1.0f);

	for (int i = 0; i < nRandomMax; i++)
	{
		mvRandom.emplace_back((float)dis(gen));
	}

	mxRandomItor = mvRandom.cbegin();
}

bool NFKernelModule::Init()
{
	mtDeleteSelfList.clear();

	m_pSceneModule = pPluginManager->FindModule<NFISceneModule>();
	m_pClassModule = pPluginManager->FindModule<NFIClassModule>();
	m_pElementModule = pPluginManager->FindModule<NFIElementModule>();
	m_pLogModule = pPluginManager->FindModule<NFILogModule>();
	m_pScheduleModule = pPluginManager->FindModule<NFIScheduleModule>();
	m_pEventModule = pPluginManager->FindModule<NFIEventModule>();
	m_pCellModule = pPluginManager->FindModule<NFICellModule>();
	m_pThreadPoolModule = pPluginManager->FindModule<NFIThreadPoolModule>();


	return true;
}

bool NFKernelModule::Shut()
{
	return true;
}

bool NFKernelModule::Execute()
{
	ProcessMemFree();

	mnCurExeObject.nHead64 = 0;
	mnCurExeObject.nData64 = 0;

	if (mtDeleteSelfList.size() > 0)
	{
		std::list<NFGUID>::iterator it = mtDeleteSelfList.begin();
		for (; it != mtDeleteSelfList.end(); it++)
		{
			DestroyObject(*it);
		}
		mtDeleteSelfList.clear();
	}

	return true;
}

NF_SHARE_PTR<NFIObject> NFKernelModule::CreateObject(const NFGUID& self, const int sceneID, const int groupID, const std::string& className, const std::string& configIndex, const NFDataList& arg)
{
	NF_SHARE_PTR<NFIObject> pObject;
	NFGUID ident = self;

	NF_SHARE_PTR<NFSceneInfo> pContainerInfo = m_pSceneModule->GetElement(sceneID);
	if (!pContainerInfo)
	{
		m_pLogModule->LogError(NFGUID(0, sceneID), "There is no scene " + std::to_string(sceneID), __FUNCTION__, __LINE__);
		return pObject;
	}

	if (!pContainerInfo->GetElement(groupID))
	{
		m_pLogModule->LogError("There is no group " + std::to_string(groupID), __FUNCTION__, __LINE__);
		return pObject;
	}

	//  if (!m_pElementModule->ExistElement(configIndex))
	//  {
	//      m_pLogModule->LogError(NFGUID(0, sceneID), "There is no group", groupID, __FUNCTION__, __LINE__);
	//      return pObject;
	//  }


	if (ident.IsNull())
	{
		ident = CreateGUID();
	}

	if (GetElement(ident))
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, ident, "The object has Exists", __FUNCTION__, __LINE__);
		return pObject;
	}

	pObject = NF_SHARE_PTR<NFIObject>(NF_NEW NFObject(ident, pPluginManager));
	AddElement(ident, pObject);

	if (pPluginManager->UsingBackThread())
	{
		m_pThreadPoolModule->DoAsyncTask(NFGUID(), "",
			[=](NFThreadTask& task) -> void
			{
				//backup thread for async task
				{
					NF_SHARE_PTR<NFIPropertyManager> pStaticClassPropertyManager = m_pClassModule->GetThreadClassModule()->GetClassPropertyManager(className);
					NF_SHARE_PTR<NFIRecordManager> pStaticClassRecordManager = m_pClassModule->GetThreadClassModule()->GetClassRecordManager(className);
					if (pStaticClassPropertyManager && pStaticClassRecordManager)
					{
						NF_SHARE_PTR<NFIPropertyManager> pPropertyManager = pObject->GetPropertyManager();
						NF_SHARE_PTR<NFIRecordManager> pRecordManager = pObject->GetRecordManager();

						NF_SHARE_PTR<NFIProperty> pStaticConfigPropertyInfo = pStaticClassPropertyManager->First();
						while (pStaticConfigPropertyInfo)
						{
							NF_SHARE_PTR<NFIProperty> xProperty = pPropertyManager->AddProperty(ident, pStaticConfigPropertyInfo->GetKey(), pStaticConfigPropertyInfo->GetType());

							xProperty->SetPublic(pStaticConfigPropertyInfo->GetPublic());
							xProperty->SetPrivate(pStaticConfigPropertyInfo->GetPrivate());
							xProperty->SetSave(pStaticConfigPropertyInfo->GetSave());
							xProperty->SetCache(pStaticConfigPropertyInfo->GetCache());
							xProperty->SetRef(pStaticConfigPropertyInfo->GetRef());
							xProperty->SetUpload(pStaticConfigPropertyInfo->GetUpload());

							//
							pObject->AddPropertyCallBack(pStaticConfigPropertyInfo->GetKey(), this, &NFKernelModule::OnPropertyCommonEvent);

							pStaticConfigPropertyInfo = pStaticClassPropertyManager->Next();
						}

						NF_SHARE_PTR<NFIRecord> pConfigRecordInfo = pStaticClassRecordManager->First();
						while (pConfigRecordInfo)
						{
							NF_SHARE_PTR<NFIRecord> xRecord = pRecordManager->AddRecord(ident,
								pConfigRecordInfo->GetName(),
								pConfigRecordInfo->GetInitData(),
								pConfigRecordInfo->GetTag(),
								pConfigRecordInfo->GetRows());

							xRecord->SetPublic(pConfigRecordInfo->GetPublic());
							xRecord->SetPrivate(pConfigRecordInfo->GetPrivate());
							xRecord->SetSave(pConfigRecordInfo->GetSave());
							xRecord->SetCache(pConfigRecordInfo->GetCache());
							xRecord->SetUpload(pConfigRecordInfo->GetUpload());

							//
							pObject->AddRecordCallBack(pConfigRecordInfo->GetName(), this, &NFKernelModule::OnRecordCommonEvent);

							pConfigRecordInfo = pStaticClassRecordManager->Next();
						}
					}
				}
			},
			[=](NFThreadTask& task) -> void
			{
				//no data--main thread
				{
					NFVector3 vRelivePos = m_pSceneModule->GetRelivePosition(sceneID, 0);

					pObject->SetPropertyString(NFrame::IObject::ConfigID(), configIndex);
					pObject->SetPropertyString(NFrame::IObject::ClassName(), className);
					pObject->SetPropertyInt(NFrame::IObject::SceneID(), sceneID);
					pObject->SetPropertyInt(NFrame::IObject::GroupID(), groupID);
					pObject->SetPropertyVector3(NFrame::IObject::Position(), vRelivePos);

					pContainerInfo->AddObjectToGroup(groupID, ident, className == NFrame::Player::ThisName() ? true : false);

					DoEvent(ident, className, pObject->GetState(), arg);
				}

				m_pThreadPoolModule->DoAsyncTask(NFGUID(), "",
					[=](NFThreadTask& task) -> void
					{
						//backup thread
						{
							NF_SHARE_PTR<NFIPropertyManager> pPropertyManager = pObject->GetPropertyManager();
							NF_SHARE_PTR<NFIPropertyManager> pConfigPropertyManager = m_pElementModule->GetThreadElementModule()->GetPropertyManager(configIndex);
							NF_SHARE_PTR<NFIRecordManager> pConfigRecordManager = m_pElementModule->GetThreadElementModule()->GetRecordManager(configIndex);

							if (pConfigPropertyManager && pConfigRecordManager)
							{
								NF_SHARE_PTR<NFIProperty> pConfigPropertyInfo = pConfigPropertyManager->First();
								while (nullptr != pConfigPropertyInfo)
								{
									if (pConfigPropertyInfo->Changed())
									{
										pPropertyManager->SetProperty(pConfigPropertyInfo->GetKey(), pConfigPropertyInfo->GetValue());
									}

									pConfigPropertyInfo = pConfigPropertyManager->Next();
								}
							}
						}
					},
					[=](NFThreadTask& task) -> void
					{

						//main thread
						{
							NF_SHARE_PTR<NFIPropertyManager> pPropertyManager = pObject->GetPropertyManager();
							for (int i = 0; i < arg.GetCount() - 1; i += 2)
							{
								const std::string& propertyName = arg.String(i);
								if (NFrame::IObject::ConfigID() != propertyName
									&& NFrame::IObject::ClassName() != propertyName
									&& NFrame::IObject::SceneID() != propertyName
									&& NFrame::IObject::ID() != propertyName
									&& NFrame::IObject::GroupID() != propertyName)
								{
									NF_SHARE_PTR<NFIProperty> pArgProperty = pPropertyManager->GetElement(propertyName);
									if (pArgProperty)
									{
										switch (pArgProperty->GetType())
										{
										case TDATA_INT:
											pObject->SetPropertyInt(propertyName, arg.Int(i + 1));
											break;
										case TDATA_FLOAT:
											pObject->SetPropertyFloat(propertyName, arg.Float(i + 1));
											break;
										case TDATA_STRING:
											pObject->SetPropertyString(propertyName, arg.String(i + 1));
											break;
										case TDATA_OBJECT:
											pObject->SetPropertyObject(propertyName, arg.Object(i + 1));
											break;
										case TDATA_VECTOR2:
											pObject->SetPropertyVector2(propertyName, arg.Vector2(i + 1));
											break;
										case TDATA_VECTOR3:
											pObject->SetPropertyVector3(propertyName, arg.Vector3(i + 1));
											break;
										default:
											break;
										}
									}
								}
							}

							std::ostringstream stream;
							stream << " create object: " << ident.ToString();
							stream << " config_name: " << configIndex;
							stream << " scene_id: " << sceneID;
							stream << " group_id: " << groupID;
							stream << " position: " << pObject->GetPropertyVector3(NFrame::IObject::Position()).ToString();

							m_pLogModule->LogInfo(stream);

							pObject->SetState(COE_CREATE_BEFORE_ATTACHDATA);
							DoEvent(ident, className, pObject->GetState(), arg);

						}

						m_pThreadPoolModule->DoAsyncTask(NFGUID(), "",
							[=](NFThreadTask& task) -> void
							{
								//back up thread
								{
									pObject->SetState(COE_CREATE_LOADDATA);
									DoEvent(ident, className, pObject->GetState(), arg);
								}
							},
							[=](NFThreadTask& task) -> void
							{
								//below are main thread
								{
									pObject->SetState(COE_CREATE_AFTER_ATTACHDATA);
									DoEvent(ident, className, pObject->GetState(), arg);

									pObject->SetState(COE_CREATE_BEFORE_EFFECT);
									DoEvent(ident, className, pObject->GetState(), arg);

									pObject->SetState(COE_CREATE_EFFECTDATA);
									DoEvent(ident, className, pObject->GetState(), arg);

									pObject->SetState(COE_CREATE_AFTER_EFFECT);
									DoEvent(ident, className, pObject->GetState(), arg);

									pObject->SetState(COE_CREATE_READY);
									DoEvent(ident, className, pObject->GetState(), arg);

									pObject->SetState(COE_CREATE_HASDATA);
									DoEvent(ident, className, pObject->GetState(), arg);

									pObject->SetState(COE_CREATE_FINISH);
									DoEvent(ident, className, pObject->GetState(), arg);
								}
							});

					});
			});

	}
	else
	{
		//backup thread for async task
		{
			NF_SHARE_PTR<NFIPropertyManager> pStaticClassPropertyManager = m_pClassModule->GetClassPropertyManager(className);
			NF_SHARE_PTR<NFIRecordManager> pStaticClassRecordManager = m_pClassModule->GetClassRecordManager(className);
			if (pStaticClassPropertyManager && pStaticClassRecordManager)
			{
				NF_SHARE_PTR<NFIPropertyManager> pPropertyManager = pObject->GetPropertyManager();
				NF_SHARE_PTR<NFIRecordManager> pRecordManager = pObject->GetRecordManager();

				NF_SHARE_PTR<NFIProperty> pStaticConfigPropertyInfo = pStaticClassPropertyManager->First();
				while (pStaticConfigPropertyInfo)
				{
					NF_SHARE_PTR<NFIProperty> xProperty = pPropertyManager->AddProperty(ident, pStaticConfigPropertyInfo->GetKey(), pStaticConfigPropertyInfo->GetType());

					xProperty->SetPublic(pStaticConfigPropertyInfo->GetPublic());
					xProperty->SetPrivate(pStaticConfigPropertyInfo->GetPrivate());
					xProperty->SetSave(pStaticConfigPropertyInfo->GetSave());
					xProperty->SetCache(pStaticConfigPropertyInfo->GetCache());
					xProperty->SetRef(pStaticConfigPropertyInfo->GetRef());
					xProperty->SetUpload(pStaticConfigPropertyInfo->GetUpload());


					pObject->AddPropertyCallBack(pStaticConfigPropertyInfo->GetKey(), this, &NFKernelModule::OnPropertyCommonEvent);

					pStaticConfigPropertyInfo = pStaticClassPropertyManager->Next();
				}

				NF_SHARE_PTR<NFIRecord> pConfigRecordInfo = pStaticClassRecordManager->First();
				while (pConfigRecordInfo)
				{
					NF_SHARE_PTR<NFIRecord> xRecord = pRecordManager->AddRecord(ident,
						pConfigRecordInfo->GetName(),
						pConfigRecordInfo->GetInitData(),
						pConfigRecordInfo->GetTag(),
						pConfigRecordInfo->GetRows());

					xRecord->SetPublic(pConfigRecordInfo->GetPublic());
					xRecord->SetPrivate(pConfigRecordInfo->GetPrivate());
					xRecord->SetSave(pConfigRecordInfo->GetSave());
					xRecord->SetCache(pConfigRecordInfo->GetCache());
					xRecord->SetUpload(pConfigRecordInfo->GetUpload());

					pObject->AddRecordCallBack(pConfigRecordInfo->GetName(), this, &NFKernelModule::OnRecordCommonEvent);

					pConfigRecordInfo = pStaticClassRecordManager->Next();
				}
			}
		}

		//no data--main thread
		{
			NFVector3 vRelivePos = m_pSceneModule->GetRelivePosition(sceneID, 0);

			pObject->SetPropertyObject(NFrame::IObject::ID(), ident);
			pObject->SetPropertyString(NFrame::IObject::ConfigID(), configIndex);
			pObject->SetPropertyString(NFrame::IObject::ClassName(), className);
			pObject->SetPropertyInt(NFrame::IObject::SceneID(), sceneID);
			pObject->SetPropertyInt(NFrame::IObject::GroupID(), groupID);
			pObject->SetPropertyVector3(NFrame::IObject::Position(), vRelivePos);

			pContainerInfo->AddObjectToGroup(groupID, ident, className == NFrame::Player::ThisName() ? true : false);

			DoEvent(ident, className, pObject->GetState(), arg);
		}

		//////////////////////////////////////////////////////////////////////////
		//backup thread
		{
			NF_SHARE_PTR<NFIPropertyManager> pPropertyManager = pObject->GetPropertyManager();
			NF_SHARE_PTR<NFIPropertyManager> pConfigPropertyManager = m_pElementModule->GetPropertyManager(configIndex);
			NF_SHARE_PTR<NFIRecordManager> pConfigRecordManager = m_pElementModule->GetRecordManager(configIndex);

			if (pConfigPropertyManager && pConfigRecordManager)
			{
				NF_SHARE_PTR<NFIProperty> pConfigPropertyInfo = pConfigPropertyManager->First();
				while (nullptr != pConfigPropertyInfo)
				{
					if (pConfigPropertyInfo->Changed())
					{
						pPropertyManager->SetProperty(pConfigPropertyInfo->GetKey(), pConfigPropertyInfo->GetValue());
					}

					pConfigPropertyInfo = pConfigPropertyManager->Next();
				}
			}
		}

		//main thread
		{
			NF_SHARE_PTR<NFIPropertyManager> pPropertyManager = pObject->GetPropertyManager();
			for (int i = 0; i < arg.GetCount() - 1; i += 2)
			{
				const std::string& propertyName = arg.String(i);
				if (NFrame::IObject::ConfigID() != propertyName
					&& NFrame::IObject::ClassName() != propertyName
					&& NFrame::IObject::SceneID() != propertyName
					&& NFrame::IObject::ID() != propertyName
					&& NFrame::IObject::GroupID() != propertyName)
				{
					NF_SHARE_PTR<NFIProperty> pArgProperty = pPropertyManager->GetElement(propertyName);
					if (pArgProperty)
					{
						switch (pArgProperty->GetType())
						{
						case TDATA_INT:
							pObject->SetPropertyInt(propertyName, arg.Int(i + 1));
							break;
						case TDATA_FLOAT:
							pObject->SetPropertyFloat(propertyName, arg.Float(i + 1));
							break;
						case TDATA_STRING:
							pObject->SetPropertyString(propertyName, arg.String(i + 1));
							break;
						case TDATA_OBJECT:
							pObject->SetPropertyObject(propertyName, arg.Object(i + 1));
							break;
						case TDATA_VECTOR2:
							pObject->SetPropertyVector2(propertyName, arg.Vector2(i + 1));
							break;
						case TDATA_VECTOR3:
							pObject->SetPropertyVector3(propertyName, arg.Vector3(i + 1));
							break;
						default:
							break;
						}
					}
				}
			}

			std::ostringstream stream;
			stream << " create object: " << ident.ToString();
			stream << " config_name: " << configIndex;
			stream << " scene_id: " << sceneID;
			stream << " group_id: " << groupID;
			stream << " position: " << pObject->GetPropertyVector3(NFrame::IObject::Position()).ToString();

			//m_pLogModule->LogInfo(stream);

			pObject->SetState(COE_CREATE_BEFORE_ATTACHDATA);
			DoEvent(ident, className, pObject->GetState(), arg);

		}

		//back up thread
		{
			pObject->SetState(COE_CREATE_LOADDATA);
			DoEvent(ident, className, pObject->GetState(), arg);
		}

		//below are main thread
		{
			pObject->SetState(COE_CREATE_AFTER_ATTACHDATA);
			DoEvent(ident, className, pObject->GetState(), arg);

			pObject->SetState(COE_CREATE_BEFORE_EFFECT);
			DoEvent(ident, className, pObject->GetState(), arg);

			pObject->SetState(COE_CREATE_EFFECTDATA);
			DoEvent(ident, className, pObject->GetState(), arg);

			pObject->SetState(COE_CREATE_AFTER_EFFECT);
			DoEvent(ident, className, pObject->GetState(), arg);

			pObject->SetState(COE_CREATE_READY);
			DoEvent(ident, className, pObject->GetState(), arg);

			pObject->SetState(COE_CREATE_HASDATA);
			DoEvent(ident, className, pObject->GetState(), arg);

			pObject->SetState(COE_CREATE_FINISH);
			DoEvent(ident, className, pObject->GetState(), arg);
		}
	}

	return pObject;
}

NF_SHARE_PTR<NFIObject> NFKernelModule::CreateObject(const NFGUID& self)
{
	NFGUID ident = self;

	if (ident.IsNull())
	{
		ident = CreateGUID();
	}
	NF_SHARE_PTR<NFIObject> pObject;

	pObject = NF_SHARE_PTR<NFIObject>(NF_NEW NFObject(ident, pPluginManager));
	AddElement(ident, pObject);

	return pObject;
}

bool NFKernelModule::DestroyObject(const NFGUID& self)
{
	if (self == mnCurExeObject
		&& !self.IsNull())
	{

		return DestroySelf(self);
	}

	const int sceneID = GetPropertyInt32(self, NFrame::IObject::SceneID());
	const int groupID = GetPropertyInt32(self, NFrame::IObject::GroupID());

	NF_SHARE_PTR<NFSceneInfo> pContainerInfo = m_pSceneModule->GetElement(sceneID);
	if (pContainerInfo)
	{
		const std::string& className = GetPropertyString(self, NFrame::IObject::ClassName());
		if (className == NFrame::Player::ThisName())
		{
			m_pSceneModule->LeaveSceneGroup(self);
		}

		DoEvent(self, className, COE_BEFOREDESTROY, NFDataList::Empty());
		DoEvent(self, className, COE_DESTROY, NFDataList::Empty());

		if (className != NFrame::Player::ThisName())
		{
			pContainerInfo->RemoveObjectFromGroup(groupID, self, false);
		}

		RemoveElement(self);
		
		m_pEventModule->RemoveEventCallBack(self);
		m_pScheduleModule->RemoveSchedule(self);

		return true;

	}

	m_pLogModule->LogError(self, "There is no scene " + std::to_string(sceneID), __FUNCTION__, __LINE__);

	return false;
}

bool NFKernelModule::FindProperty(const NFGUID& self, const std::string& propertyName)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->FindProperty(propertyName);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no object", __FUNCTION__, __LINE__);

	return false;
}

bool NFKernelModule::SetPropertyInt(const NFGUID& self, const std::string& propertyName, const NFINT64 nValue, const NFINT64 reason)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->SetPropertyInt(propertyName, nValue, reason);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no object", __FUNCTION__, __LINE__);

	return false;
}

bool NFKernelModule::SetPropertyFloat(const NFGUID& self, const std::string& propertyName, const double dValue, const NFINT64 reason)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->SetPropertyFloat(propertyName, dValue, reason);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no object", __FUNCTION__, __LINE__);

	return false;
}

bool NFKernelModule::SetPropertyString(const NFGUID& self, const std::string& propertyName, const std::string& value, const NFINT64 reason)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->SetPropertyString(propertyName, value, reason);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no object", __FUNCTION__, __LINE__);

	return false;
}

bool NFKernelModule::SetPropertyObject(const NFGUID& self, const std::string& propertyName, const NFGUID& objectValue, const NFINT64 reason)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->SetPropertyObject(propertyName, objectValue, reason);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no object", __FUNCTION__, __LINE__);

	return false;
}

bool NFKernelModule::SetPropertyVector2(const NFGUID& self, const std::string& propertyName, const NFVector2& value, const NFINT64 reason)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->SetPropertyVector2(propertyName, value, reason);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no vector2", __FUNCTION__, __LINE__);

	return false;
}

bool NFKernelModule::SetPropertyVector3(const NFGUID& self, const std::string& propertyName, const NFVector3& value, const NFINT64 reason)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->SetPropertyVector3(propertyName, value, reason);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no vector3", __FUNCTION__, __LINE__);

	return false;
}

NFINT64 NFKernelModule::GetPropertyInt(const NFGUID& self, const std::string& propertyName)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetPropertyInt(propertyName);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no object", __FUNCTION__, __LINE__);

	return NULL_INT;
}

int NFKernelModule::GetPropertyInt32(const NFGUID& self, const std::string& propertyName)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetPropertyInt32(propertyName);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no object", __FUNCTION__, __LINE__);

	return (int)NULL_INT;
}

double NFKernelModule::GetPropertyFloat(const NFGUID& self, const std::string& propertyName)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetPropertyFloat(propertyName);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no object", __FUNCTION__, __LINE__);

	return NULL_FLOAT;
}

const std::string& NFKernelModule::GetPropertyString(const NFGUID& self, const std::string& propertyName)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetPropertyString(propertyName);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no object", __FUNCTION__, __LINE__);

	return NULL_STR;
}

const NFGUID& NFKernelModule::GetPropertyObject(const NFGUID& self, const std::string& propertyName)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetPropertyObject(propertyName);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no object", __FUNCTION__, __LINE__);

	return NULL_OBJECT;
}

const NFVector2& NFKernelModule::GetPropertyVector2(const NFGUID& self, const std::string& propertyName)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetPropertyVector2(propertyName);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no vector2", __FUNCTION__, __LINE__);

	return NULL_VECTOR2;
}

const NFVector3& NFKernelModule::GetPropertyVector3(const NFGUID& self, const std::string& propertyName)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetPropertyVector3(propertyName);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, propertyName + "| There is no vector3", __FUNCTION__, __LINE__);

	return NULL_VECTOR3;
}

NF_SHARE_PTR<NFIRecord> NFKernelModule::FindRecord(const NFGUID& self, const std::string& recordName)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetRecordManager()->GetElement(recordName);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no object", __FUNCTION__, __LINE__);

	return nullptr;
}

bool NFKernelModule::ClearRecord(const NFGUID& self, const std::string& recordName)
{
	NF_SHARE_PTR<NFIRecord> pRecord = FindRecord(self, recordName);
	if (pRecord)
	{
		return pRecord->Clear();
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no record", __FUNCTION__, __LINE__);

	return false;
}

bool NFKernelModule::SetRecordInt(const NFGUID& self, const std::string& recordName, const int row, const int col, const NFINT64 nValue)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		if (!pObject->SetRecordInt(recordName, row, col, nValue))
		{
			m_pLogModule->LogError(self, recordName + " error for row or col", __FUNCTION__, __LINE__);
		}
		else
		{
			return true;
		}
	}
	else
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no object", __FUNCTION__, __LINE__);
	}


	return false;
}

bool NFKernelModule::SetRecordInt(const NFGUID& self, const std::string& recordName, const int row, const std::string& colTag, const NFINT64 value)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		if (!pObject->SetRecordInt(recordName, row, colTag, value))
		{
			m_pLogModule->LogError(self, recordName + " error for row or col", __FUNCTION__, __LINE__);
		}
		else
		{
			return true;
		}
	}
	else
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no object", __FUNCTION__, __LINE__);
	}

	return false;
}

bool NFKernelModule::SetRecordFloat(const NFGUID& self, const std::string& recordName, const int row, const int col, const double dwValue)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		if (!pObject->SetRecordFloat(recordName, row, col, dwValue))
		{
			m_pLogModule->LogError(self, recordName + " error SetRecordFloat for row  or col", __FUNCTION__, __LINE__);
		}
		else
		{
			return true;
		}
	}
	else
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no object", __FUNCTION__, __LINE__);
	}

	return false;
}

bool NFKernelModule::SetRecordFloat(const NFGUID& self, const std::string& recordName, const int row, const std::string& colTag, const double value)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		if (!pObject->SetRecordFloat(recordName, row, colTag, value))
		{
			m_pLogModule->LogError(self, recordName + " error SetRecordFloat for row  or col", __FUNCTION__, __LINE__);
		}
		else
		{
			return true;
		}
	}
	else
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no object", __FUNCTION__, __LINE__);
	}

	return false;
}

bool NFKernelModule::SetRecordString(const NFGUID& self, const std::string& recordName, const int row, const int col, const std::string& value)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		if (!pObject->SetRecordString(recordName, row, col, value))
		{
			m_pLogModule->LogError(self, recordName + " error SetRecordString for row  or col", __FUNCTION__, __LINE__);
		}
		else
		{
			return true;
		}
	}
	else
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no object", __FUNCTION__, __LINE__);
	}

	return false;
}

bool NFKernelModule::SetRecordString(const NFGUID& self, const std::string& recordName, const int row, const std::string& colTag, const std::string& value)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		if (!pObject->SetRecordString(recordName, row, colTag, value))
		{
			m_pLogModule->LogError(self, recordName + " error SetRecordObject for row  or col", __FUNCTION__, __LINE__);
		}
		else
		{
			return true;
		}
	}
	else
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no object", __FUNCTION__, __LINE__);
	}

	return false;
}

bool NFKernelModule::SetRecordObject(const NFGUID& self, const std::string& recordName, const int row, const int col, const NFGUID& objectValue)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		if (!pObject->SetRecordObject(recordName, row, col, objectValue))
		{
			m_pLogModule->LogError(self, recordName + " error SetRecordObject for row  or col", __FUNCTION__, __LINE__);
		}
		else
		{
			return true;
		}
	}
	else
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no object", __FUNCTION__, __LINE__);
	}

	return false;
}

bool NFKernelModule::SetRecordObject(const NFGUID& self, const std::string& recordName, const int row, const std::string& colTag, const NFGUID& value)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		if (!pObject->SetRecordObject(recordName, row, colTag, value))
		{
			m_pLogModule->LogError(self, recordName + " error SetRecordObject for row  or col", __FUNCTION__, __LINE__);
		}
		else
		{
			return true;
		}
	}
	else
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no object", __FUNCTION__, __LINE__);
	}

	return false;
}

bool NFKernelModule::SetRecordVector2(const NFGUID& self, const std::string& recordName, const int row, const int col, const NFVector2& value)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		if (!pObject->SetRecordVector2(recordName, row, col, value))
		{
			m_pLogModule->LogError(self, recordName + " error SetRecordVector2 for row  or col", __FUNCTION__, __LINE__);
		}
		else
		{
			return true;
		}
	}
	else
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no object", __FUNCTION__, __LINE__);
	}

	return false;
}

bool NFKernelModule::SetRecordVector2(const NFGUID& self, const std::string& recordName, const int row, const std::string& colTag, const NFVector2& value)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		if (!pObject->SetRecordVector2(recordName, row, colTag, value))
		{
			m_pLogModule->LogError(self, recordName + " error SetRecordVector2 for row  or col", __FUNCTION__, __LINE__);
		}
		else
		{
			return true;
		}
	}
	else
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no object", __FUNCTION__, __LINE__);
	}

	return false;
}

bool NFKernelModule::SetRecordVector3(const NFGUID& self, const std::string& recordName, const int row, const int col, const NFVector3& value)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		if (!pObject->SetRecordVector3(recordName, row, col, value))
		{
			m_pLogModule->LogError(self, recordName + " error SetRecordVector3 for row  or col", __FUNCTION__, __LINE__);
		}
		else
		{
			return true;
		}
	}
	else
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no object", __FUNCTION__, __LINE__);
	}

	return false;
}

bool NFKernelModule::SetRecordVector3(const NFGUID& self, const std::string& recordName, const int row, const std::string& colTag, const NFVector3& value)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		if (!pObject->SetRecordVector3(recordName, row, colTag, value))
		{
			m_pLogModule->LogError(self, recordName  + " error SetRecordVector3 for row  or col", __FUNCTION__, __LINE__);
		}
		else
		{
			return true;
		}
	}
	else
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, recordName + "| There is no object", __FUNCTION__, __LINE__);
	}

	return false;
}

NFINT64 NFKernelModule::GetRecordInt(const NFGUID& self, const std::string& recordName, const int row, const int col)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetRecordInt(recordName, row, col);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, "There is no object", __FUNCTION__, __LINE__);

	return 0;
}

NFINT64 NFKernelModule::GetRecordInt(const NFGUID& self, const std::string& recordName, const int row, const std::string& colTag)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetRecordInt(recordName, row, colTag);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, "There is no object", __FUNCTION__, __LINE__);

	return 0;
}

double NFKernelModule::GetRecordFloat(const NFGUID& self, const std::string& recordName, const int row, const int col)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetRecordFloat(recordName, row, col);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, "There is no object", __FUNCTION__, __LINE__);

	return 0.0;
}

double NFKernelModule::GetRecordFloat(const NFGUID& self, const std::string& recordName, const int row, const std::string& colTag)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetRecordFloat(recordName, row, colTag);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, "There is no object", __FUNCTION__, __LINE__);

	return 0.0;
}

const std::string& NFKernelModule::GetRecordString(const NFGUID& self, const std::string& recordName, const int row, const int col)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetRecordString(recordName, row, col);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, "There is no object", __FUNCTION__, __LINE__);

	return NULL_STR;
}

const std::string& NFKernelModule::GetRecordString(const NFGUID& self, const std::string& recordName, const int row, const std::string& colTag)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetRecordString(recordName, row, colTag);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, "There is no object", __FUNCTION__, __LINE__);

	return NULL_STR;
}

const NFGUID& NFKernelModule::GetRecordObject(const NFGUID& self, const std::string& recordName, const int row, const int col)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetRecordObject(recordName, row, col);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, "There is no object", __FUNCTION__, __LINE__);

	return NULL_OBJECT;
}

const NFGUID& NFKernelModule::GetRecordObject(const NFGUID& self, const std::string& recordName, const int row, const std::string& colTag)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetRecordObject(recordName, row, colTag);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, "There is no object", __FUNCTION__, __LINE__);

	return NULL_OBJECT;
}

const NFVector2& NFKernelModule::GetRecordVector2(const NFGUID& self, const std::string& recordName, const int row, const int col)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetRecordVector2(recordName, row, col);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, "There is no vector2", __FUNCTION__, __LINE__);

	return NULL_VECTOR2;
}

const NFVector2& NFKernelModule::GetRecordVector2(const NFGUID& self, const std::string& recordName, const int row, const std::string& colTag)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetRecordVector2(recordName, row, colTag);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, "There is no vector2", __FUNCTION__, __LINE__);

	return NULL_VECTOR2;
}

const NFVector3& NFKernelModule::GetRecordVector3(const NFGUID& self, const std::string& recordName, const int row, const int col)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetRecordVector3(recordName, row, col);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, "There is no vector3", __FUNCTION__, __LINE__);

	return NULL_VECTOR3;
}

const NFVector3& NFKernelModule::GetRecordVector3(const NFGUID& self, const std::string& recordName, const int row, const std::string& colTag)
{
	NF_SHARE_PTR<NFIObject> pObject = GetElement(self);
	if (pObject)
	{
		return pObject->GetRecordVector3(recordName, row, colTag);
	}

	m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, self, "There is no vector3", __FUNCTION__, __LINE__);

	return NULL_VECTOR3;
}

NFGUID NFKernelModule::CreateGUID()
{
	int64_t value = 0;
	uint64_t time = NFGetTimeMS();


	//value = time << 16;
	value = time * 1000000;


	//value |= nGUIDIndex++;
	value += nGUIDIndex++;

	//if (sequence_ == 0x7FFF)
	if (nGUIDIndex == 999999)
	{
		nGUIDIndex = 0;
	}

	NFGUID xID;
	xID.nHead64 = pPluginManager->GetAppID();
	xID.nData64 = value;

	return xID;
}

bool NFKernelModule::CreateScene(const int sceneID)
{
	NF_SHARE_PTR<NFSceneInfo> pSceneInfo = m_pSceneModule->GetElement(sceneID);
	if (pSceneInfo)
	{
		return false;
	}

	pSceneInfo = NF_SHARE_PTR<NFSceneInfo>(NF_NEW NFSceneInfo(sceneID));
	if (pSceneInfo)
	{
		m_pSceneModule->AddElement(sceneID, pSceneInfo);
		RequestGroupScene(sceneID);
		return true;
	}

	return false;
}

bool NFKernelModule::DestroyScene(const int sceneID)
{
	m_pSceneModule->RemoveElement(sceneID);

	return true;
}

int NFKernelModule::GetOnLineCount()
{
	int count = 0;
	NF_SHARE_PTR<NFSceneInfo> pSceneInfo = m_pSceneModule->First();
	while (pSceneInfo)
	{
		NF_SHARE_PTR<NFSceneGroupInfo> pGroupInfo = pSceneInfo->First();
		while (pGroupInfo)
		{
			count += pGroupInfo->mxPlayerList.Count();
			pGroupInfo = pSceneInfo->Next();
		}

		pSceneInfo = m_pSceneModule->Next();
	}

	return count;
}

int NFKernelModule::GetMaxOnLineCount()
{
	// test count 5000
	// and it should be define in a xml file

	return 10000;
}

int NFKernelModule::RequestGroupScene(const int sceneID)
{
	return m_pSceneModule->RequestGroupScene(sceneID);
}

bool NFKernelModule::ReleaseGroupScene(const int sceneID, const int groupID)
{
	return m_pSceneModule->ReleaseGroupScene(sceneID, groupID);
}

bool NFKernelModule::ExitGroupScene(const int sceneID, const int groupID)
{
	NF_SHARE_PTR<NFSceneInfo> pSceneInfo = m_pSceneModule->GetElement(sceneID);
	if (pSceneInfo)
	{
		NF_SHARE_PTR<NFSceneGroupInfo> pGroupInfo = pSceneInfo->GetElement(groupID);
		if (pGroupInfo)
		{
			return true;
		}
	}

	return false;
}

bool NFKernelModule::GetGroupObjectList(const int sceneID, const int groupID, NFDataList & list, const NFGUID & noSelf)
{
	NF_SHARE_PTR<NFSceneInfo> pSceneInfo = m_pSceneModule->GetElement(sceneID);
	if (pSceneInfo)
	{

		NF_SHARE_PTR<NFSceneGroupInfo> pGroupInfo = pSceneInfo->GetElement(groupID);
		if (pGroupInfo)
		{
			NFGUID ident = NFGUID();
			NF_SHARE_PTR<int> pRet = pGroupInfo->mxPlayerList.First(ident);
			while (!ident.IsNull())
			{
				if (ident != noSelf)
				{
					list.Add(ident);
				}

				ident = NFGUID();
				pRet = pGroupInfo->mxPlayerList.Next(ident);
			}

			ident = NFGUID();
			pRet = pGroupInfo->mxOtherList.First(ident);
			while (!ident.IsNull())
			{
				if (ident != noSelf)
				{
					list.Add(ident);
				}

				ident = NFGUID();
				pRet = pGroupInfo->mxOtherList.Next(ident);
			}

			return true;
		}
	}

	return false;
}

int NFKernelModule::GetGroupObjectList(const int sceneID, const int groupID, const bool bPlayer, const NFGUID & noSelf)
{
	int objectCount = 0;
	NF_SHARE_PTR<NFSceneInfo> pSceneInfo = m_pSceneModule->GetElement(sceneID);
	if (pSceneInfo)
	{
		NF_SHARE_PTR<NFSceneGroupInfo> pGroupInfo = pSceneInfo->GetElement(groupID);
		if (pGroupInfo)
		{
			NFGUID ident = NFGUID();
			NF_SHARE_PTR<int> pRet = pGroupInfo->mxPlayerList.First(ident);
			while (!ident.IsNull())
			{
				if (ident != noSelf)
				{
					objectCount++;
				}

				ident = NFGUID();
				pRet = pGroupInfo->mxPlayerList.Next(ident);
			}

			ident = NFGUID();
			pRet = pGroupInfo->mxOtherList.First(ident);
			while (!ident.IsNull())
			{
				if (ident != noSelf)
				{
					objectCount++;
				}

				ident = NFGUID();
				pRet = pGroupInfo->mxOtherList.Next(ident);
			}
		}
	}

	return objectCount;
}

bool NFKernelModule::GetGroupObjectList(const int sceneID, const int groupID, NFDataList& list)
{
	return GetGroupObjectList(sceneID, groupID, list, NFGUID());
}

bool NFKernelModule::GetGroupObjectList(const int sceneID, const int groupID, NFDataList & list, const bool bPlayer, const NFGUID & noSelf)
{
	NF_SHARE_PTR<NFSceneInfo> pSceneInfo = m_pSceneModule->GetElement(sceneID);
	if (pSceneInfo)
	{

		NF_SHARE_PTR<NFSceneGroupInfo> pGroupInfo = pSceneInfo->GetElement(groupID);
		if (pGroupInfo)
		{
			if (bPlayer)
			{
				NFGUID ident = NFGUID();
				NF_SHARE_PTR<int> pRet = pGroupInfo->mxPlayerList.First(ident);
				while (!ident.IsNull())
				{
					if (ident != noSelf)
					{
						list.Add(ident);
					}

					ident = NFGUID();
					pRet = pGroupInfo->mxPlayerList.Next(ident);
				}
			}
			else
			{
				NFGUID ident = NFGUID();
				NF_SHARE_PTR<int> pRet = pGroupInfo->mxOtherList.First(ident);
				while (!ident.IsNull())
				{
					if (ident != noSelf)
					{
						list.Add(ident);
					}
					ident = NFGUID();
					pRet = pGroupInfo->mxOtherList.Next(ident);
				}
			}

			return true;
		}
	}
	return false;
}

bool NFKernelModule::GetGroupObjectList(const int sceneID, const int groupID, NFDataList & list, const bool bPlayer)
{
	return GetGroupObjectList(sceneID, groupID, list, bPlayer, NFGUID());
}

bool NFKernelModule::GetGroupObjectList(const int sceneID, const int groupID, const std::string & className, NFDataList& list, const NFGUID& noSelf)
{
	NFDataList xDataList;
	if (GetGroupObjectList(sceneID, groupID, xDataList))
	{
		for (int i = 0; i < xDataList.GetCount(); i++)
		{
			NFGUID xID = xDataList.Object(i);
			if (xID.IsNull())
			{
				continue;
			}

			if (this->GetPropertyString(xID, NFrame::IObject::ClassName()) == className
				&& xID != noSelf)
			{
				list.AddObject(xID);
			}
		}

		return true;
	}

	return false;
}

bool NFKernelModule::GetGroupObjectList(const int sceneID, const int groupID, const std::string & className, NFDataList & list)
{
	return GetGroupObjectList(sceneID, groupID, className, list, NFGUID());
}

bool NFKernelModule::LogStack()
{
#if NF_PLATFORM == NF_PLATFORM_WIN
	SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),
		FOREGROUND_RED | FOREGROUND_INTENSITY);
#else
#endif

#if NF_PLATFORM == NF_PLATFORM_WIN
	SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),
		FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE);
#else
#endif // NF_PLATFORM

	return true;
}

bool NFKernelModule::LogInfo(const NFGUID ident)
{

	NF_SHARE_PTR<NFIObject> pObject = GetObject(ident);
	if (pObject)
	{
		int sceneID = GetPropertyInt32(ident, NFrame::IObject::SceneID());
		int groupID = GetPropertyInt32(ident, NFrame::IObject::GroupID());

		m_pLogModule->LogInfo(ident, "//----------child object list-------- SceneID = " + std::to_string(sceneID));
	}
	else
	{
		m_pLogModule->LogObject(NFILogModule::NLL_ERROR_NORMAL, ident, "", __FUNCTION__, __LINE__);
	}

	return true;
}

int NFKernelModule::OnPropertyCommonEvent(const NFGUID& self, const std::string& propertyName, const NFData& oldVar, const NFData& newVar, const NFINT64 reason)
{
	NFPerformance performance;

	NF_SHARE_PTR<NFIObject> xObject = GetElement(self);
	if (xObject)
	{
		if (xObject->GetState() >= CLASS_OBJECT_EVENT::COE_CREATE_HASDATA)
		{
			std::list<PROPERTY_EVENT_FUNCTOR_PTR>::iterator it = mtCommonPropertyCallBackList.begin();
			for (; it != mtCommonPropertyCallBackList.end(); it++)
			{
				PROPERTY_EVENT_FUNCTOR_PTR& pFunPtr = *it;
				PROPERTY_EVENT_FUNCTOR* pFun = pFunPtr.get();
				pFun->operator()(self, propertyName, oldVar, newVar, reason);
			}

			const std::string& className = xObject->GetPropertyString(NFrame::IObject::ClassName());
			std::map<std::string, std::list<PROPERTY_EVENT_FUNCTOR_PTR>>::iterator itClass = mtClassPropertyCallBackList.find(className);
			if (itClass != mtClassPropertyCallBackList.end())
			{
				std::list<PROPERTY_EVENT_FUNCTOR_PTR>::iterator itList = itClass->second.begin();
				for (; itList != itClass->second.end(); itList++)
				{
					PROPERTY_EVENT_FUNCTOR_PTR& pFunPtr = *itList;
					PROPERTY_EVENT_FUNCTOR* pFun = pFunPtr.get();
					pFun->operator()(self, propertyName, oldVar, newVar, reason);
				}
			}
		}
	}

	if (performance.CheckTimePoint(1))
	{
		std::ostringstream os;
		os << "--------------- performance problem------------------- ";
		os << performance.TimeScope();
		os << "---------- ";
		os << propertyName;
		//m_pLogModule->LogWarning(self, os, __FUNCTION__, __LINE__);
	}


	return 0;
}

NF_SHARE_PTR<NFIObject> NFKernelModule::GetObject(const NFGUID& ident)
{
	return GetElement(ident);
}

int NFKernelModule::GetObjectByProperty(const int sceneID, const int groupID, const std::string& propertyName, const NFDataList& valueArg, NFDataList& list)
{
	NFDataList varObjectList;
	GetGroupObjectList(sceneID, groupID, varObjectList);

	int nWorldCount = varObjectList.GetCount();
	for (int i = 0; i < nWorldCount; i++)
	{
		NFGUID ident = varObjectList.Object(i);
		if (this->FindProperty(ident, propertyName))
		{
			NFDATA_TYPE eType = valueArg.Type(0);
			switch (eType)
			{
			case TDATA_INT:
			{
				int64_t nValue = GetPropertyInt(ident, propertyName.c_str());
				if (valueArg.Int(0) == nValue)
				{
					list.Add(ident);
				}
			}
			break;
			case TDATA_STRING:
			{
				std::string strValue = GetPropertyString(ident, propertyName.c_str());
				std::string strCompareValue = valueArg.String(0);
				if (strValue == strCompareValue)
				{
					list.Add(ident);
				}
			}
			break;
			case TDATA_OBJECT:
			{
				NFGUID identObject = GetPropertyObject(ident, propertyName.c_str());
				if (valueArg.Object(0) == identObject)
				{
					list.Add(ident);
				}
			}
			break;
			default:
				break;
			}
		}
	}

	return list.GetCount();
}

bool NFKernelModule::ExistScene(const int sceneID)
{
	NF_SHARE_PTR<NFSceneInfo> pSceneInfo = m_pSceneModule->GetElement(sceneID);
	if (pSceneInfo)
	{
		return true;
	}

	return false;
}

bool NFKernelModule::ExistObject(const NFGUID & ident)
{
	return ExistElement(ident);
}

bool NFKernelModule::ObjectReady(const NFGUID& ident)
{
	auto gameObject = GetElement(ident);
	if (gameObject)
	{
		return gameObject->ObjectReady();
	}

	return false;
}

bool NFKernelModule::ExistObject(const NFGUID & ident, const int sceneID, const int groupID)
{
	NF_SHARE_PTR<NFSceneInfo> pSceneInfo = m_pSceneModule->GetElement(sceneID);
	if (!pSceneInfo)
	{
		return false;
	}

	return pSceneInfo->ExistObjectInGroup(groupID, ident);
}

bool NFKernelModule::DestroySelf(const NFGUID& self)
{
	mtDeleteSelfList.push_back(self);
	return true;
}

int NFKernelModule::OnRecordCommonEvent(const NFGUID& self, const RECORD_EVENT_DATA& eventData, const NFData& oldVar, const NFData& newVar)
{
	NFPerformance performance;

	NF_SHARE_PTR<NFIObject> xObject = GetElement(self);
	if (xObject)
	{
		if (xObject->GetState() >= CLASS_OBJECT_EVENT::COE_CREATE_HASDATA)
		{
			std::list<RECORD_EVENT_FUNCTOR_PTR>::iterator it = mtCommonRecordCallBackList.begin();
			for (; it != mtCommonRecordCallBackList.end(); it++)
			{
				RECORD_EVENT_FUNCTOR_PTR& pFunPtr = *it;
				RECORD_EVENT_FUNCTOR* pFun = pFunPtr.get();
				pFun->operator()(self, eventData, oldVar, newVar);
			}
		}

		const std::string& className = xObject->GetPropertyString(NFrame::IObject::ClassName());
		std::map<std::string, std::list<RECORD_EVENT_FUNCTOR_PTR>>::iterator itClass = mtClassRecordCallBackList.find(className);
		if (itClass != mtClassRecordCallBackList.end())
		{
			std::list<RECORD_EVENT_FUNCTOR_PTR>::iterator itList = itClass->second.begin();
			for (; itList != itClass->second.end(); itList++)
			{
				RECORD_EVENT_FUNCTOR_PTR& pFunPtr = *itList;
				RECORD_EVENT_FUNCTOR* pFun = pFunPtr.get();
				pFun->operator()(self, eventData, oldVar, newVar);
			}
		}
	}

	if (performance.CheckTimePoint(1))
	{
		std::ostringstream os;
		os << "--------------- performance problem------------------- ";
		os << performance.TimeScope();
		os << "---------- ";
		os << eventData.recordName;
		os << " event type " << eventData.nOpType;
		//m_pLogModule->LogWarning(self, os, __FUNCTION__, __LINE__);
	}

	return 0;
}

int NFKernelModule::OnClassCommonEvent(const NFGUID& self, const std::string& className, const CLASS_OBJECT_EVENT classEvent, const NFDataList& var)
{
	NFPerformance performance;

	std::list<CLASS_EVENT_FUNCTOR_PTR>::iterator it = mtCommonClassCallBackList.begin();
	for (; it != mtCommonClassCallBackList.end(); it++)
	{
		CLASS_EVENT_FUNCTOR_PTR& pFunPtr = *it;
		CLASS_EVENT_FUNCTOR* pFun = pFunPtr.get();
		pFun->operator()(self, className, classEvent, var);
	}

	if (performance.CheckTimePoint(1))
	{
		std::ostringstream os;
		os << "--------------- performance problem------------------- ";
		os << performance.TimeScope();
		os << "---------- ";
		os << className;
		os << " event type " << classEvent;
		//m_pLogModule->LogWarning(self, os, __FUNCTION__, __LINE__);
	}

	return 0;
}

bool NFKernelModule::RegisterCommonClassEvent(const CLASS_EVENT_FUNCTOR_PTR& cb)
{
	mtCommonClassCallBackList.push_back(cb);
	return true;
}

bool NFKernelModule::RegisterCommonPropertyEvent(const PROPERTY_EVENT_FUNCTOR_PTR& cb)
{
	mtCommonPropertyCallBackList.push_back(cb);
	return true;
}

bool NFKernelModule::RegisterCommonRecordEvent(const RECORD_EVENT_FUNCTOR_PTR& cb)
{
	mtCommonRecordCallBackList.push_back(cb);
	return true;
}

bool NFKernelModule::RegisterClassPropertyEvent(const std::string & className, const PROPERTY_EVENT_FUNCTOR_PTR & cb)
{
	if (mtClassPropertyCallBackList.find(className) == mtClassPropertyCallBackList.end())
	{
		std::list<PROPERTY_EVENT_FUNCTOR_PTR> xList;
		xList.push_back(cb);

		mtClassPropertyCallBackList.insert(std::map< std::string, std::list<PROPERTY_EVENT_FUNCTOR_PTR>>::value_type(className, xList));

		return true;
	}


	std::map< std::string, std::list<PROPERTY_EVENT_FUNCTOR_PTR>>::iterator it = mtClassPropertyCallBackList.find(className);
	it->second.push_back(cb);


	return false;
}

bool NFKernelModule::RegisterClassRecordEvent(const std::string & className, const RECORD_EVENT_FUNCTOR_PTR & cb)
{
	if (mtClassRecordCallBackList.find(className) == mtClassRecordCallBackList.end())
	{
		std::list<RECORD_EVENT_FUNCTOR_PTR> xList;
		xList.push_back(cb);

		mtClassRecordCallBackList.insert(std::map< std::string, std::list<RECORD_EVENT_FUNCTOR_PTR>>::value_type(className, xList));

		return true;
	}


	std::map< std::string, std::list<RECORD_EVENT_FUNCTOR_PTR>>::iterator it = mtClassRecordCallBackList.find(className);
	it->second.push_back(cb);

	return true;
}

bool NFKernelModule::LogSelfInfo(const NFGUID ident)
{

	return false;
}

bool NFKernelModule::AfterInit()
{
	NF_SHARE_PTR<NFIClass> pClass = m_pClassModule->First();
	while (pClass)
	{
		NFIKernelModule::AddClassCallBack(pClass->GetClassName(), this, &NFKernelModule::OnClassCommonEvent);

		pClass = m_pClassModule->Next();
	}

	return true;
}

bool NFKernelModule::DestroyAll()
{
	NF_SHARE_PTR<NFIObject> pObject = First();
	while (pObject)
	{
		mtDeleteSelfList.push_back(pObject->Self());

		pObject = Next();
	}


	Execute();

	m_pSceneModule->ClearAll();

	return true;
}

bool NFKernelModule::BeforeShut()
{
	DestroyAll();

	mvRandom.clear();
	mtCommonClassCallBackList.clear();
	mtCommonPropertyCallBackList.clear();
	mtCommonRecordCallBackList.clear();

	mtClassPropertyCallBackList.clear();
	mtClassRecordCallBackList.clear();

	return true;
}

int NFKernelModule::Random(int nStart, int nEnd)
{
	if (++mxRandomItor == mvRandom.cend())
	{
		mxRandomItor = mvRandom.cbegin();
	}

	return static_cast<int>((nEnd - nStart) * *mxRandomItor) + nStart;
}

float NFKernelModule::Random()
{
	if (++mxRandomItor == mvRandom.cend())
	{
		mxRandomItor = mvRandom.cbegin();
	}

	return *mxRandomItor;
}

bool NFKernelModule::AddClassCallBack(const std::string& className, const CLASS_EVENT_FUNCTOR_PTR& cb)
{
	return m_pClassModule->AddClassCallBack(className, cb);
}

void NFKernelModule::ProcessMemFree()
{
	if (nLastTime + 30 > pPluginManager->GetNowTime())
	{
		return;
	}

	nLastTime = pPluginManager->GetNowTime();

	std::string info;
	NFMemoryCounter::PrintMemoryInfo(info);

	//m_pLogModule->LogInfo(info, __FUNCTION__, __LINE__);
	//MemManager::GetSingletonPtr()->FreeMem();
	//MallocExtension::instance()->ReleaseFreeMemory();
}

bool NFKernelModule::DoEvent(const NFGUID& self, const std::string& className, CLASS_OBJECT_EVENT eEvent, const NFDataList& valueList)
{
	return m_pClassModule->DoEvent(self, className, eEvent, valueList);
}