#pragma once

#include "NFComm/NFPluginModule/NFIFileSystemModule.h"


class NFFileSystemModule
	: public NFIFileSystemModule
{
public:
    NFFileSystemModule(NFIPluginManager* p)
    {
        m_bIsExecute = true;
        pPluginManager = p;
    }

    virtual bool Init();
    virtual bool Shut();

    virtual bool BeforeShut();
    virtual bool AfterInit();

    virtual bool Execute();

    bool IsFileExist(const std::string& strFileName);
    std::string GetFilePath(const std::string& strFileName);
    long FileWriteTime(const std::string& strFileName);
    std::vector<string> GetFolderFiles(const std::string& strPath, bool recursive);

    virtual ~NFFileSystemModule()
    {
    }
};