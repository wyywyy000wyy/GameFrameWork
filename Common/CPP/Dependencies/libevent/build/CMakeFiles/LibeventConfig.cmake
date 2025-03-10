# - Config file for the Libevent package
# It defines the following variables
#  LIBEVENT_INCLUDE_DIRS     - include directories
#  LIBEVENT_STATIC_LIBRARIES - libraries to link against (archive/static)
#  LIBEVENT_SHARED_LIBRARIES - libraries to link against (shared)

# Get the path of the current file.
get_filename_component(LIBEVENT_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

# Set the include directories.
set(LIBEVENT_INCLUDE_DIRS "${LIBEVENT_CMAKE_DIR}/../../../include")

# Include the project Targets file, this contains definitions for IMPORTED targets.
include(${LIBEVENT_CMAKE_DIR}/LibeventTargets.cmake)

# IMPORTED targets from LibeventTargets.cmake
set(LIBEVENT_STATIC_LIBRARIES "")
set(LIBEVENT_SHARED_LIBRARIES "event_core_shared;event_extra_shared;event_pthreads_shared;event_shared")
