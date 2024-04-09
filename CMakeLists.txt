cmake_minimum_required(VERSION 3.5)

option(BUILD_CLIENT "help string describing option" OFF)

message("***********************************************************")
foreach(arg ${PLUGINS})
	message("ARGV: ${arg}")
endforeach(arg ${PLUGINS})

message("BUILD_CLIENT__: ${BUILD_CLIENT}")
message("***********************************************************")

if(BUILD_CLIENT)
    set(ProjectName "GameFrameWorkClient")
else()
    set(ProjectName "GameFrameWorkServer")
endif(BUILD_CLIENT)

project(${ProjectName})

set(SolutionDir ${PROJECT_SOURCE_DIR})
set(CommonCPPDir ${SolutionDir}/Common/CPP)
set(CommonDir ${SolutionDir}/Common/CPP/NFComm)
if (BUILD_CLIENT)
	set(CommonLuaDir ${PROJECT_SOURCE_DIR}/Client/Assets/Code/Lua)
else()
	set(CommonLuaDir ${PROJECT_SOURCE_DIR}/Server/Lua)
endif()
set(CommonLuaPluginDir ${CommonLuaDir}/common/plugins)

# if( CMAKE_BUILD_TYPE STREQUAL "Debug" )
#     link_directories(${CommonCPPDir}/Dependencies/lib/Debug/)
# else()
#     link_directories(${CommonCPPDir}/Dependencies/lib/Release/)
# endif()
link_directories(${CommonCPPDir}/Dependencies/lib/Debug/)


if (APPLE)
	link_directories(/Boost/lib/)
	include_directories(
		/Boost/include/boost-1_84/
		${CommonCPPDir}
		${CommonCPPDir}/Dependencies/
		${CommonCPPDir}/Dependencies/NFMessageDefine/
		${CommonCPPDir}/Dependencies/boost/
		${CommonCPPDir}/NFComm/NFPluginModule/
		${CommonCPPDir}/Dependencies/hiredis/hiredis_linux
		${CommonCPPDir}/Dependencies/vcpkg/installed/x64-osx/include/
		${CommonCPPDir}/Dependencies/vcpkg/installed/x64-osx/include/SDL2
		${CommonCPPDir}/Dependencies/vcpkg/installed/x64-osx/include/google/protobuf/ 
		${CommonCPPDir}/Dependencies/vcpkg/installed/x64-osx/include/google/protobuf/src/
	)
elseif(UNIX)
	link_directories(/Boost/lib/)
	include_directories(
		/Boost/include/boost-1_84/
		${CommonCPPDir}
		${CommonCPPDir}/Dependencies/
		${CommonCPPDir}/Dependencies/NFMessageDefine/
		${CommonCPPDir}/Dependencies/boost/
		${CommonCPPDir}/NFComm/NFPluginModule/
		${CommonCPPDir}/Dependencies/hiredis/hiredis_linux
		${CommonCPPDir}/Dependencies/vcpkg/installed/x64-linux/include/
		${CommonCPPDir}/Dependencies/vcpkg/installed/x64-linux/include/SDL2
		${CommonCPPDir}/Dependencies/vcpkg/installed/x64-linux/include/google/protobuf/ 
		${CommonCPPDir}/Dependencies/vcpkg/installed/x64-linux/include/google/protobuf/src/
	)
else()
	link_directories(C:/Boost//lib/)
	include_directories(
		C:/Boost/include/boost-1_84/
		${CommonCPPDir}
		${CommonCPPDir}/Dependencies/
		${CommonCPPDir}/Dependencies/NFMessageDefine/
		${CommonCPPDir}/Dependencies/boost/
		${CommonCPPDir}/NFComm/NFPluginModule/
		${CommonCPPDir}/Dependencies/hiredis/hiredis_win
		${CommonCPPDir}/Dependencies/vcpkg/installed/x64-windows-static/include/
		${CommonCPPDir}/Dependencies/vcpkg/installed/x64-windows-static/include/SDL2
		${CommonCPPDir}/Dependencies/vcpkg/installed/x64-windows-static/include/google/protobuf/ 
		${CommonCPPDir}/Dependencies/vcpkg/installed/x64-windows-static/include/google/protobuf/src/
	)
endif()


if(WIN32)
	if(BUILD_CLIENT)
		set(NFOutPutDir ${PROJECT_SOURCE_DIR}/Client/Assets/Xlua/x86_64)
	else()
		set(NFOutPutDir ${PROJECT_SOURCE_DIR}/_Out)
	endif()
else()
	if( CMAKE_BUILD_TYPE STREQUAL "Debug" )
		set(NFOutPutDir ${PROJECT_SOURCE_DIR}/_Out/Debug)
	else()
		set(NFOutPutDir ${PROJECT_SOURCE_DIR}/_Out/Release)
	endif()
endif()

if(UNIX)
	if( CMAKE_BUILD_TYPE STREQUAL "Debug" )
		set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -fPIC")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -O0 -Wall -g -ggdb -DDEBUG -fPIC")
	else()
		set(CMAKE_BUILD_TYPE "Release")
		set(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -fPIC")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}  -fPIC -std=c++17 -O3 -Wall")
	endif()

	set(LDFLAGS "$ENV{LDFLAGS} -stdlib=libc++")
	#MAC不需要这一行
	if (NOT APPLE)
		add_definitions(-std=c++17)
	endif()
else()
	set(CMAKE_CXX_STANDARD 17)
	SET ( CMAKE_CXX_FLAGS "-D_X64 -D_WINDOWS /EHsc /MT" )
	include_directories(${SolutionDir}/Dependencies/libevent/WIN32-Code/)
endif()

if( CMAKE_BUILD_TYPE STREQUAL "Debug" )
	set(DependenciesLibPath ${SolutionDir}/Dependencies/lib ${SolutionDir}/_Out/Debug/ ${SolutionDir}/Dependencies/lib/Debug)
else()
	set(DependenciesLibPath ${SolutionDir}/Dependencies/lib ${SolutionDir}/_Out/Release/ ${SolutionDir}/Dependencies/lib/Release)
endif()

macro(link_NFSDK projName)
	add_dependencies(${projName} NFNetPlugin NFCore NFMessageDefine)
	target_link_libraries(${projName} NFCore NFMessageDefine NFNetPlugin)
endmacro(link_NFSDK)


# add_subdirectory(${CommonCPPDir}/Dependencies)
# # add_subdirectory(${CommonCPPDir}/NFComm)
# macro(CheckFolderExists FOLDER_PATH)
#     if(EXISTS ${FOLDER_PATH} AND IS_DIRECTORY ${FOLDER_PATH})
#         message("Folder ${FOLDER_PATH} exists.")
# 		set(MY_RESULT TRUE)
#     endif()
# 	# message("Folder ${FOLDER_PATH} does not exist.")
# 	set(MY_RESULT FALSE)
# endmacro()

macro(add_subdirectory_common dir)
	set(plugin_name ${CommonDir}/${dir})
	message(STATUS "add_plugin__ ${plugin_name}")
    add_subdirectory(${plugin_name})
	# CheckFolderExists(${plugin_name}/Lua)
	if(${MY_RESULT})
        message(STATUS "add_plugin__ ${plugin_name} Lua")
	else()
		# message(STATUS "add_plugin__ ${plugin_name} Lua not exists")
    endif()
endmacro(add_subdirectory_common)



include_directories(${CommonCPPDir} ${CMAKE_SOURCE_DIR}/Common/CPP/Dependencies/vcpkg/installed/x64-windows-static/include)

add_subdirectory(${CommonCPPDir}/Dependencies)
foreach(plugin ${PLUGINS})
	add_subdirectory_common(${plugin})
	endforeach(plugin ${PLUGINS})
if(BUILD_CLIENT)
	
    add_subdirectory(Client)
else()
    # add_subdirectory_common(NFPluginLoader)
    # add_subdirectory_common(NFActorPlugin)
    # add_subdirectory_common(NFConfigPlugin)
    # add_subdirectory_common(NFCore)
    # add_subdirectory_common(NFKernelPlugin)
    # add_subdirectory_common(NFLogPlugin)
    # add_subdirectory_common(NFMessageDefine)
    # add_subdirectory_common(NFNetPlugin)
    # add_subdirectory_common(NFSecurityPlugin)
    # add_subdirectory_common(NFNavigationPlugin)
    # add_subdirectory_common(NFNoSqlPlugin)
    # # add_subdirectory_common(NFTestPlugin)
    # add_subdirectory_common(NFLuaScriptPlugin)
    add_subdirectory(Server)
endif(BUILD_CLIENT)