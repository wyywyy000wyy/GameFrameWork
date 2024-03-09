set(ProjectName "GameFrameWorkClient")
project(${ProjectName})


file(GLOB NFServer_ROOT_Cpp CPP/*.cpp)
file(GLOB NFServer_ROOT_Hpp CPP/*.h)

add_executable(GameFrameWorkClient ${NFServer_ROOT_Cpp} ${NFServer_ROOT_Hpp})

#link_NFSDK("GameFrameWorkClient")
message(STATUS "GameFrameWorkServer__CommonCPPDir: " ${CommonCPPDir})

target_include_directories(GameFrameWorkClient PRIVATE ${CommonCPPDir})
target_link_libraries(GameFrameWorkClient NFPluginLoader)

if (UNIX)
	add_dependencies(GameFrameWorkClient NFCore)

	#if (CMAKE_BUILD_TYPE MATCHES "Release")
	#	target_link_libraries(GameFrameWorkClient libSDL2.a)
	#else()
	#	target_link_libraries(GameFrameWorkClient libSDL2d.a)
	#endif()

	target_link_libraries(GameFrameWorkClient -static-libstdc++ -pthread)

else()

endif()

set_target_properties( GameFrameWorkClient PROPERTIES OUTPUT_NAME_DEBUG "GameFrameWorkClient")
set_target_properties( GameFrameWorkClient PROPERTIES
	FOLDER "GameFrameWorkClient"
	ARCHIVE_OUTPUT_DIRECTORY ${NFOutPutDir}
	RUNTIME_OUTPUT_DIRECTORY ${NFOutPutDir}
	LIBRARY_OUTPUT_DIRECTORY ${NFOutPutDir} )


add_definitions(-D_X64 -D_CONSOLE)
#add_definitions(-D_X64 -D_CONSOLE -DNF_DYNAMIC_PLUGIN)