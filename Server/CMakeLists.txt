set(ProjectName "GameFrameWorkServer")
project(${ProjectName})


file(GLOB NFServer_ROOT_Cpp CPP/*.cpp)
file(GLOB NFServer_ROOT_Hpp CPP/*.h)

add_executable(GameFrameWorkServer ${NFServer_ROOT_Cpp} ${NFServer_ROOT_Hpp})

#link_NFSDK("GameFrameWorkServer")
message(STATUS "GameFrameWorkServer__CommonCPPDir: " ${CommonCPPDir})

target_include_directories(GameFrameWorkServer PRIVATE ${CommonCPPDir})
target_link_libraries(GameFrameWorkServer NFPluginLoader)

if (UNIX)
	add_dependencies(GameFrameWorkServer NFCore)

	#if (CMAKE_BUILD_TYPE MATCHES "Release")
	#	target_link_libraries(GameFrameWorkServer libSDL2.a)
	#else()
	#	target_link_libraries(GameFrameWorkServer libSDL2d.a)
	#endif()

	target_link_libraries(GameFrameWorkServer -static-libstdc++ -pthread)

else()

endif()

set_target_properties( GameFrameWorkServer PROPERTIES OUTPUT_NAME_DEBUG "GameFrameWorkServer")
set_target_properties( GameFrameWorkServer PROPERTIES
	FOLDER "GameFrameWorkServer"
	ARCHIVE_OUTPUT_DIRECTORY ${NFOutPutDir}
	RUNTIME_OUTPUT_DIRECTORY ${NFOutPutDir}
	LIBRARY_OUTPUT_DIRECTORY ${NFOutPutDir} )


add_definitions(-D_X64 -D_CONSOLE)
#add_definitions(-D_X64 -D_CONSOLE -DNF_DYNAMIC_PLUGIN)