# Generated by CMake

if("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" LESS 2.8)
   message(FATAL_ERROR "CMake >= 2.8.0 required")
endif()
if(CMAKE_VERSION VERSION_LESS "2.8.3")
   message(FATAL_ERROR "CMake >= 2.8.3 required")
endif()
cmake_policy(PUSH)
cmake_policy(VERSION 2.8.3...3.25)
#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Protect against multiple inclusion, which would fail when already imported targets are added once more.
set(_cmake_targets_defined "")
set(_cmake_targets_not_defined "")
set(_cmake_expected_targets "")
foreach(_cmake_expected_target IN ITEMS event_core_shared event_extra_shared event_pthreads_shared event_shared)
  list(APPEND _cmake_expected_targets "${_cmake_expected_target}")
  if(TARGET "${_cmake_expected_target}")
    list(APPEND _cmake_targets_defined "${_cmake_expected_target}")
  else()
    list(APPEND _cmake_targets_not_defined "${_cmake_expected_target}")
  endif()
endforeach()
unset(_cmake_expected_target)
if(_cmake_targets_defined STREQUAL _cmake_expected_targets)
  unset(_cmake_targets_defined)
  unset(_cmake_targets_not_defined)
  unset(_cmake_expected_targets)
  unset(CMAKE_IMPORT_FILE_VERSION)
  cmake_policy(POP)
  return()
endif()
if(NOT _cmake_targets_defined STREQUAL "")
  string(REPLACE ";" ", " _cmake_targets_defined_text "${_cmake_targets_defined}")
  string(REPLACE ";" ", " _cmake_targets_not_defined_text "${_cmake_targets_not_defined}")
  message(FATAL_ERROR "Some (but not all) targets in this export set were already defined.\nTargets Defined: ${_cmake_targets_defined_text}\nTargets not yet defined: ${_cmake_targets_not_defined_text}\n")
endif()
unset(_cmake_targets_defined)
unset(_cmake_targets_not_defined)
unset(_cmake_expected_targets)


# Create imported target event_core_shared
add_library(event_core_shared SHARED IMPORTED)

# Create imported target event_extra_shared
add_library(event_extra_shared SHARED IMPORTED)

set_target_properties(event_extra_shared PROPERTIES
  INTERFACE_LINK_LIBRARIES "event_core_shared"
)

# Create imported target event_pthreads_shared
add_library(event_pthreads_shared SHARED IMPORTED)

set_target_properties(event_pthreads_shared PROPERTIES
  INTERFACE_LINK_LIBRARIES "event_core_shared"
)

# Create imported target event_shared
add_library(event_shared SHARED IMPORTED)

# Import target "event_core_shared" for configuration "Release"
set_property(TARGET event_core_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(event_core_shared PROPERTIES
  IMPORTED_LOCATION_RELEASE "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib/libevent_core-2.1.7.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libevent_core-2.1.7.dylib"
  )

# Import target "event_extra_shared" for configuration "Release"
set_property(TARGET event_extra_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(event_extra_shared PROPERTIES
  IMPORTED_LOCATION_RELEASE "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib/libevent_extra-2.1.7.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libevent_extra-2.1.7.dylib"
  )

# Import target "event_pthreads_shared" for configuration "Release"
set_property(TARGET event_pthreads_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(event_pthreads_shared PROPERTIES
  IMPORTED_LOCATION_RELEASE "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib/libevent_pthreads-2.1.7.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libevent_pthreads-2.1.7.dylib"
  )

# Import target "event_shared" for configuration "Release"
set_property(TARGET event_shared APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(event_shared PROPERTIES
  IMPORTED_LOCATION_RELEASE "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib/libevent-2.1.7.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libevent-2.1.7.dylib"
  )

# This file does not depend on other imported targets which have
# been exported from the same project but in a separate export set.

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)