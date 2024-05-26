set(ProjectName "GamePlugin")

file(GLOB_RECURSE GamePlugin_ROOT_Cpp *.cpp)
file(GLOB_RECURSE GamePlugin_ROOT_Hpp *.h)

add_library(GamePlugin STATIC
	${GamePlugin_ROOT_Cpp}
	${GamePlugin_ROOT_Hpp})


message("-------------UNIX???" UNIX)
if(UNIX)
	add_dependencies(GamePlugin NFCore NFConfigPlugin)
	if (CMAKE_BUILD_TYPE MATCHES "Release")
	else()
	endif()
		
	target_link_libraries(GamePlugin  NFCore boost_filesystem)
	target_link_libraries(GamePlugin -static-libstdc++)
else()
	add_dependencies(GamePlugin NFCore NFConfigPlugin)

	target_link_libraries(GamePlugin -static-libstdc++)

endif()

set_target_properties( GamePlugin PROPERTIES OUTPUT_NAME_DEBUG "GamePlugin")
set_target_properties( GamePlugin PROPERTIES PREFIX "")
set_target_properties( GamePlugin PROPERTIES
	FOLDER "NFComm/GamePlugin"
	ARCHIVE_OUTPUT_DIRECTORY ${NFOutPutDir}
	RUNTIME_OUTPUT_DIRECTORY ${NFOutPutDir}
	LIBRARY_OUTPUT_DIRECTORY ${NFOutPutDir} )

