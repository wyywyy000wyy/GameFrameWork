#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "event_core_shared" for configuration "Release"
set_property(TARGET event_core_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(event_core_shared PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libevent_core-2.1.7.dylib"
  IMPORTED_SONAME_RELEASE "/usr/local/lib/libevent_core-2.1.7.dylib"
  )

list(APPEND _cmake_import_check_targets event_core_shared )
list(APPEND _cmake_import_check_files_for_event_core_shared "${_IMPORT_PREFIX}/lib/libevent_core-2.1.7.dylib" )

# Import target "event_extra_shared" for configuration "Release"
set_property(TARGET event_extra_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(event_extra_shared PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libevent_extra-2.1.7.dylib"
  IMPORTED_SONAME_RELEASE "/usr/local/lib/libevent_extra-2.1.7.dylib"
  )

list(APPEND _cmake_import_check_targets event_extra_shared )
list(APPEND _cmake_import_check_files_for_event_extra_shared "${_IMPORT_PREFIX}/lib/libevent_extra-2.1.7.dylib" )

# Import target "event_pthreads_shared" for configuration "Release"
set_property(TARGET event_pthreads_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(event_pthreads_shared PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libevent_pthreads-2.1.7.dylib"
  IMPORTED_SONAME_RELEASE "/usr/local/lib/libevent_pthreads-2.1.7.dylib"
  )

list(APPEND _cmake_import_check_targets event_pthreads_shared )
list(APPEND _cmake_import_check_files_for_event_pthreads_shared "${_IMPORT_PREFIX}/lib/libevent_pthreads-2.1.7.dylib" )

# Import target "event_shared" for configuration "Release"
set_property(TARGET event_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(event_shared PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libevent-2.1.7.dylib"
  IMPORTED_SONAME_RELEASE "/usr/local/lib/libevent-2.1.7.dylib"
  )

list(APPEND _cmake_import_check_targets event_shared )
list(APPEND _cmake_import_check_files_for_event_shared "${_IMPORT_PREFIX}/lib/libevent-2.1.7.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
