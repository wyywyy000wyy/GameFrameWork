set(ProjectName "GameFrameWorkClientLib")
project(${ProjectName})


file(GLOB NFServer_ROOT_Cpp CPP/*.cpp EXCLUDE CPP/*NFClient.cpp)
file(GLOB NFServer_ROOT_Hpp CPP/*.h)

# message(STATUS "NFServer_ROOT_Cpp: " ${NFServer_ROOT_Cpp})

list(REMOVE_ITEM NFServer_ROOT_Cpp *.CPP/NFClient.cpp)

add_library(GameFrameWorkClientLib SHARED ${NFServer_ROOT_Cpp} ${NFServer_ROOT_Hpp})

#link_NFSDK("GameFrameWorkClient")
message(STATUS "GameFrameWorkServer__CommonCPPDir: " ${CommonCPPDir})

target_include_directories(GameFrameWorkClientLib PRIVATE ${CommonCPPDir})
target_link_libraries(GameFrameWorkClientLib NFPluginLoader)

if (UNIX)
	add_dependencies(GameFrameWorkClientLib NFCore)

	#if (CMAKE_BUILD_TYPE MATCHES "Release")
	#	target_link_libraries(GameFrameWorkClientLib libSDL2.a)
	#else()
	#	target_link_libraries(GameFrameWorkClientLib libSDL2d.a)
	#endif()

	target_link_libraries(GameFrameWorkClientLib -static-libstdc++ -pthread)

else()

endif()

set_target_properties( GameFrameWorkClientLib PROPERTIES OUTPUT_NAME_DEBUG "GameFrameWorkClientLib")
set_target_properties( GameFrameWorkClientLib PROPERTIES
	FOLDER "GameFrameWorkClientLib"
	ARCHIVE_OUTPUT_DIRECTORY ${NFOutPutDir}
	RUNTIME_OUTPUT_DIRECTORY ${NFOutPutDir}
	LIBRARY_OUTPUT_DIRECTORY ${NFOutPutDir} )


add_definitions(-D_X64 -D_CONSOLE)

# add_executable(GameFrameWorkClient CPP/NFClient.cpp) #${NFServer_ROOT_Cpp} ${NFServer_ROOT_Hpp})
# target_link_libraries(GameFrameWorkClient PRIVATE GameFrameWorkClientLib )


# set_target_properties( GameFrameWorkClient PROPERTIES
# 	FOLDER "GameFrameWorkClient"
# 	ARCHIVE_OUTPUT_DIRECTORY ${NFOutPutDir}
# 	RUNTIME_OUTPUT_DIRECTORY ${NFOutPutDir}
# 	LIBRARY_OUTPUT_DIRECTORY ${NFOutPutDir} )

#add_definitions(-D_X64 -D_CONSOLE -DNF_DYNAMIC_PLUGIN)

add_executable(GameFrameWorkClient CPP/NFClient.cpp) #${NFServer_ROOT_Cpp} ${NFServer_ROOT_Hpp})
add_dependencies(GameFrameWorkClient GameFrameWorkClientLib)
# target_include_directories(GameFrameWorkClient PUBLIC ${SolutionDir}/Client/CPP)
target_link_libraries(GameFrameWorkClient PRIVATE GameFrameWorkClientLib )


set_target_properties( GameFrameWorkClient PROPERTIES
	FOLDER "GameFrameWorkClient"
	
	ARCHIVE_OUTPUT_DIRECTORY ${NFOutPutDir}
	RUNTIME_OUTPUT_DIRECTORY ${NFOutPutDir}
	LIBRARY_OUTPUT_DIRECTORY ${NFOutPutDir} 
)

# set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG  ${NFOutPutDir})
# set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG  ${NFOutPutDir})
# set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${NFOutPutDir})

# set_property(TARGET GameFrameWorkClient PROPERTY VS_DEBUGGER_WORKING_DIRECTORY ${NFOutPutDir})
# set_target_properties(GameFrameWorkClient PROPERTIES DEBUG_POSTFIX "")

add_definitions(-D_X64 -D_CONSOLE)