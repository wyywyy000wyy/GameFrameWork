# Install script for directory: /Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib/libevent_core-2.1.7.dylib")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_core-2.1.7.dylib" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_core-2.1.7.dylib")
    execute_process(COMMAND "/usr/bin/install_name_tool"
      -id "/usr/local/lib/libevent_core-2.1.7.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_core-2.1.7.dylib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip" -x "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_core-2.1.7.dylib")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/event2" TYPE FILE FILES
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/buffer.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/bufferevent.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/bufferevent_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/bufferevent_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/buffer_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/dns.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/dns_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/dns_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/event.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/event_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/event_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/http.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/http_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/http_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/keyvalq_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/listener.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/rpc.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/rpc_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/rpc_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/tag.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/tag_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/thread.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/util.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/visibility.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/include/event2/event-config.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE FILE FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib/libevent_core.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/lib/pkgconfig/libevent_core.pc")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/lib/pkgconfig" TYPE FILE FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/libevent_core.pc")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib/libevent_extra-2.1.7.dylib")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_extra-2.1.7.dylib" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_extra-2.1.7.dylib")
    execute_process(COMMAND "/usr/bin/install_name_tool"
      -id "/usr/local/lib/libevent_extra-2.1.7.dylib"
      -change "@rpath/libevent_core-2.1.7.dylib" "/usr/local/lib/libevent_core-2.1.7.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_extra-2.1.7.dylib")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_extra-2.1.7.dylib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip" -x "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_extra-2.1.7.dylib")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/event2" TYPE FILE FILES
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/buffer.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/bufferevent.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/bufferevent_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/bufferevent_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/buffer_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/dns.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/dns_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/dns_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/event.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/event_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/event_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/http.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/http_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/http_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/keyvalq_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/listener.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/rpc.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/rpc_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/rpc_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/tag.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/tag_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/thread.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/util.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/visibility.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/include/event2/event-config.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE FILE FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib/libevent_extra.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/lib/pkgconfig/libevent_extra.pc")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/lib/pkgconfig" TYPE FILE FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/libevent_extra.pc")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib/libevent_pthreads-2.1.7.dylib")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_pthreads-2.1.7.dylib" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_pthreads-2.1.7.dylib")
    execute_process(COMMAND "/usr/bin/install_name_tool"
      -id "/usr/local/lib/libevent_pthreads-2.1.7.dylib"
      -change "@rpath/libevent_core-2.1.7.dylib" "/usr/local/lib/libevent_core-2.1.7.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_pthreads-2.1.7.dylib")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_pthreads-2.1.7.dylib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip" -x "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent_pthreads-2.1.7.dylib")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/event2" TYPE FILE FILES
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/buffer.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/bufferevent.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/bufferevent_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/bufferevent_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/buffer_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/dns.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/dns_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/dns_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/event.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/event_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/event_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/http.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/http_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/http_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/keyvalq_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/listener.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/rpc.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/rpc_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/rpc_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/tag.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/tag_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/thread.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/util.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/visibility.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/include/event2/event-config.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE FILE FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib/libevent_pthreads.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/lib/pkgconfig/libevent_pthreads.pc")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/lib/pkgconfig" TYPE FILE FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/libevent_pthreads.pc")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib/libevent-2.1.7.dylib")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent-2.1.7.dylib" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent-2.1.7.dylib")
    execute_process(COMMAND "/usr/bin/install_name_tool"
      -id "/usr/local/lib/libevent-2.1.7.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent-2.1.7.dylib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip" -x "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libevent-2.1.7.dylib")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/event2" TYPE FILE FILES
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/buffer.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/bufferevent.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/bufferevent_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/bufferevent_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/buffer_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/dns.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/dns_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/dns_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/event.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/event_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/event_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/http.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/http_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/http_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/keyvalq_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/listener.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/rpc.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/rpc_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/rpc_struct.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/tag.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/tag_compat.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/thread.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/util.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event2/visibility.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/include/event2/event-config.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE FILE FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/lib/libevent.dylib")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/lib/pkgconfig/libevent.pc")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/lib/pkgconfig" TYPE FILE FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/libevent.pc")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/evdns.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/evrpc.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/event.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/evhttp.h"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/include/evutil.h"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/lib/cmake/libevent/LibeventConfig.cmake;/usr/local/lib/cmake/libevent/LibeventConfigVersion.cmake")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  file(INSTALL DESTINATION "/usr/local/lib/cmake/libevent" TYPE FILE FILES
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build//CMakeFiles/LibeventConfig.cmake"
    "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/LibeventConfigVersion.cmake"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/libevent/LibeventTargets.cmake")
    file(DIFFERENT _cmake_export_file_changed FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/libevent/LibeventTargets.cmake"
         "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/CMakeFiles/Export/56b5b35a8a8960f99895e755e78d0976/LibeventTargets.cmake")
    if(_cmake_export_file_changed)
      file(GLOB _cmake_old_config_files "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/libevent/LibeventTargets-*.cmake")
      if(_cmake_old_config_files)
        string(REPLACE ";" ", " _cmake_old_config_files_text "${_cmake_old_config_files}")
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/libevent/LibeventTargets.cmake\" will be replaced.  Removing files [${_cmake_old_config_files_text}].")
        unset(_cmake_old_config_files_text)
        file(REMOVE ${_cmake_old_config_files})
      endif()
      unset(_cmake_old_config_files)
    endif()
    unset(_cmake_export_file_changed)
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/libevent" TYPE FILE FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/CMakeFiles/Export/56b5b35a8a8960f99895e755e78d0976/LibeventTargets.cmake")
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/libevent" TYPE FILE FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/CMakeFiles/Export/56b5b35a8a8960f99895e755e78d0976/LibeventTargets-release.cmake")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE PROGRAM FILES "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/event_rpcgen.py")
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/Users/yiyiwang/develop/GameFrameWork/Common/CPP/Dependencies/libevent/build/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
