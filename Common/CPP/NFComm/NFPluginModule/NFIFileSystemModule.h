#pragma once	
#include "NFIModule.h"
#include <vector>

class NFIFileSystemModule
	: public NFIModule
{
public:

	virtual bool IsFileExist(const std::string& strFileName) = 0;
	virtual std::string GetFilePath(const std::string& strFileName) = 0;
	virtual long FileWriteTime(const std::string& strFileName) = 0;
	virtual std::vector<string> GetFolderFiles(const std::string& strPath, bool recursive) = 0;

	virtual std::vector<char> ReadFile(const std::string& strFileName) = 0;

	virtual bool WriteFile(const std::string& strFileName, const char* data, const unsigned int size) = 0;

};