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

void NFFileSystemModule::OnRegisterLua()
{
	LuaIntf::LuaContext* context = (LuaIntf::LuaContext*)m_pLuaScriptModule->GetLuaContext();



	LuaIntf::LuaBinding(*context).beginClass< NFFileSystemModule >("NFFileSystemModule")
		.addStaticVariable("ins", this)
		.addFunction("IsFileExist", &NFFileSystemModule::IsFileExist)
		.addFunction("GetFilePath", &NFFileSystemModule::GetFilePath)
		.addFunction("FileWriteTime", &NFFileSystemModule::FileWriteTime)
		//.addFunction("GetFolderFiles", &NFFileSystemModule::GetFolderFiles)
		.addStaticFunction("GetFolderFiles",[this, context](const std::string& path, bool recursive) {
		auto list = this->GetFolderFiles(path, recursive);
		LuaIntf::LuaRef tbl = LuaIntf::LuaRef::createTable(context->state());
		for (int i = 0; i < list.size(); ++i)
		{
			tbl.set(i + 1, list[i]);
		}

		return tbl;
			})

		.addFunction("ReadFile", &NFFileSystemModule::ReadFile2)
		.addFunction("WriteFile", &NFFileSystemModule::WriteFile)
		.endClass();
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

std::vector<string> NFFileSystemModule::GetFolderFiles2(const char* strPath, bool recursive)
{
	return GetFolderFiles(std::string(strPath), recursive);
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

std::vector<char> NFFileSystemModule::ReadFile(const std::string& strFileName)
{
	std::ifstream file(strFileName, std::ios::binary);
	if (file)
	{
		file.seekg(0, std::ios::end);
		std::streampos pos = file.tellg();
		std::vector<char>  data(pos);
		file.seekg(0, std::ios::beg);
		file.read(&data[0], pos);
		file.close();

		return data;
	}
	return std::vector<char>();
}

std::string NFFileSystemModule::ReadFile2(const std::string& strFileName)
{
	std::ifstream file(strFileName, std::ios::binary);
	if (file)
	{
		file.seekg(0, std::ios::end);
		std::streampos pos = file.tellg();
		std::vector<char>  data(pos);
		file.seekg(0, std::ios::beg);
		file.read(&data[0], pos);
		file.close();

		return std::string(data.begin(), data.end());
	}
	return "";
}

bool NFFileSystemModule::WriteFile(const std::string& strFileName, const char* data, const unsigned int size)
{
	std::ofstream file(strFileName, std::ios::binary);
	if (file)
	{
		file.write(data, size);
		file.close();
		return true;
	}
	return false;
}
