#include "NFFileSystemModule.h"
#include <boost/filesystem.hpp>

bool NFFileSystemModule::Init()
{
	return true;
}

bool NFFileSystemModule::Shut()
{
	return true;
}

bool NFFileSystemModule::BeforeShut()
{
	return true;
}

bool NFFileSystemModule::AfterInit()
{
	return true;
}

bool NFFileSystemModule::Execute()
{
	return true;
}

bool NFFileSystemModule::IsFileExist(const std::string& strFileName)
{
	return boost::filesystem::exists(strFileName);
}

std::string NFFileSystemModule::GetFilePath(const std::string& strFileName)
{
	return boost::filesystem::path(strFileName).parent_path().string();
}

long NFFileSystemModule::FileWriteTime(const std::string& strFileName)
{
	auto time = boost::filesystem::last_write_time(strFileName);


	return time;
}

std::vector<string> NFFileSystemModule::GetFolderFiles(const std::string& strPath, bool recursive)
{
	std::vector<string> fileList;

	try
	{
		boost::filesystem::path p(strPath);
		boost::filesystem::directory_iterator end_itr;
		for (boost::filesystem::directory_iterator itr(p); itr != end_itr; ++itr)
		{
			if (boost::filesystem::is_regular_file(itr->status()) && itr->path().extension() == ".lua")
			{
				fileList.push_back(boost::filesystem::relative(itr->path(), p).stem().string());
			}
			else if (recursive && boost::filesystem::is_directory(itr->status()))
			{
				std::vector<string> subList = GetFolderFiles(itr->path().string(), recursive);
				fileList.insert(fileList.end(), subList.begin(), subList.end());
			}
		}
	}
	catch (const std::exception& e)
	{
		
	}
	

	return fileList;
}