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


    void OnRegisterLua() override;

    bool IsFileExist(const std::string& strFileName);
    std::string GetFilePath(const std::string& strFileName);
    long FileWriteTime(const std::string& strFileName);
    std::vector<string> GetFolderFiles(const std::string& strPath, bool recursive);
    std::vector<string> GetFolderFiles2(const char* strPath, bool recursive);

    std::vector<char> ReadFile(const std::string& strFileName) override;
    std::string ReadFile2(const std::string& strFileName);

    bool WriteFile2(const std::string& strFileName, string content);
    bool WriteFile(const std::string& strFileName, const char* data, const unsigned int size) override;

    virtual ~NFFileSystemModule()
    {
    }
};