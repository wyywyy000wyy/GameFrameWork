# set(ProjectName "GameFrameWorkClient")
# project(${ProjectName})


# add_executable(GameFrameWorkClient NFClient.cpp) #${NFServer_ROOT_Cpp} ${NFServer_ROOT_Hpp})
# add_dependencies(GameFrameWorkClient GameFrameWorkClientLib)
# target_include_directories(GameFrameWorkClient PUBLIC ${SolutionDir}/Client/CPP)
# target_link_libraries(GameFrameWorkClient PRIVATE GameFrameWorkClientLib )


# set_target_properties( GameFrameWorkClient PROPERTIES
# 	FOLDER "GameFrameWorkClient"
# 	ARCHIVE_OUTPUT_DIRECTORY ${NFOutPutDir}
# 	RUNTIME_OUTPUT_DIRECTORY ${NFOutPutDir}
# 	LIBRARY_OUTPUT_DIRECTORY ${NFOutPutDir} )

# add_definitions(-D_X64 -D_CONSOLE)

# #add_definitions(-D_X64 -D_CONSOLE -DNF_DYNAMIC_PLUGIN)