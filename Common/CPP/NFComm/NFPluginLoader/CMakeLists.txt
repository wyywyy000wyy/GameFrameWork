set(ProjectName "NFPluginLoader")
file(GLOB NFPluginLoader_ROOT_Cpp *.cpp)
file(GLOB NFPluginLoader_ROOT_Hpp *.h)

add_library(NFPluginLoader STATIC
		${NFPluginLoader_ROOT_Cpp}
		${NFPluginLoader_ROOT_Hpp})

foreach(plugin ${G_PLUGINS})
	# add_subdirectory_common(${plugin})
	# target_link_libraries(NFPluginLoader ${plugin})
	if(NOT NFPluginLoader STREQUAL ${plugin})
		target_link_libraries(NFPluginLoader ${plugin})
		message(STATUS "_____________target_link_libraries: ${plugin}")
	endif()
endforeach(plugin ${G_PLUGINS})

# if(BUILD_CLIENT)
# target_link_libraries(NFPluginLoader NFCore)
# target_link_libraries(NFPluginLoader NFMessageDefine)
# target_link_libraries(NFPluginLoader NFActorPlugin)
# target_link_libraries(NFPluginLoader NFConfigPlugin)
# target_link_libraries(NFPluginLoader NFKernelPlugin)
# target_link_libraries(NFPluginLoader NFLogPlugin)
# target_link_libraries(NFPluginLoader NFLuaScriptPlugin)
# # target_link_libraries(NFPluginLoader NFNavigationPlugin)
# target_link_libraries(NFPluginLoader NFNetPlugin)
# # target_link_libraries(NFPluginLoader NFNoSqlPlugin)
# # target_link_libraries(NFPluginLoader NFSecurityPlugin)
# else()
# target_link_libraries(NFPluginLoader NFCore)
# target_link_libraries(NFPluginLoader NFMessageDefine)
# target_link_libraries(NFPluginLoader NFActorPlugin)
# target_link_libraries(NFPluginLoader NFConfigPlugin)
# target_link_libraries(NFPluginLoader NFKernelPlugin)
# target_link_libraries(NFPluginLoader NFLogPlugin)
# target_link_libraries(NFPluginLoader NFLuaScriptPlugin)
# # target_link_libraries(NFPluginLoader NFNavigationPlugin)
# target_link_libraries(NFPluginLoader NFNetPlugin)
# target_link_libraries(NFPluginLoader NFNoSqlPlugin)
# target_link_libraries(NFPluginLoader NFSecurityPlugin)
# # target_link_libraries(NFPluginLoader NFTestPlugin)
# # target_link_libraries(NFPluginLoader NFChatPlugin)
# # target_link_libraries(NFPluginLoader NFConsumeManagerPlugin)
# # target_link_libraries(NFPluginLoader NFInventoryPlugin)
# endif()


if (UNIX)
	target_link_libraries(NFPluginLoader -static-libstdc++ -pthread ${CMAKE_DL_LIBS})
else()
endif()

set_target_properties( NFPluginLoader PROPERTIES OUTPUT_NAME_DEBUG "NFPluginLoader")
set_target_properties( NFPluginLoader PROPERTIES PREFIX "")
set_target_properties( NFPluginLoader PROPERTIES
	FOLDER "NFComm/NFPluginLoader"
	ARCHIVE_OUTPUT_DIRECTORY ${NFOutPutDir}
	RUNTIME_OUTPUT_DIRECTORY ${NFOutPutDir}
	LIBRARY_OUTPUT_DIRECTORY ${NFOutPutDir} )


add_definitions(-D_X64 -D_CONSOLE)