cmake_minimum_required(VERSION 3.16)
# Set project name and target type
project(sl_platform C)
add_library(sl_platform SHARED)

include(CheckCCompilerFlag)
include(GNUInstallDirs)

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

include(sl_helpers)
include(sl_options)

# Determine library versions.
file(READ "platform_define.h" sl_platform_ver_h)
string(REGEX MATCH "SL_PLATFORM_MAJOR_VERSION ([0-9]*)" _ ${sl_platform_ver_h})
set(SL_PLATFORM_MAJOR_VERSION ${CMAKE_MATCH_1})
string(REGEX MATCH "SL_PLATFORM_MINOR_VERSION ([0-9]*)" _ ${sl_platform_ver_h})
set(SL_PLATFORM_MINOR_VERSION ${CMAKE_MATCH_1})
string(REGEX MATCH "SL_PLATFORM_PATCH_VERSION ([0-9]*)" _ ${sl_platform_ver_h})
set(SL_PLATFORM_PATCH_VERSION ${CMAKE_MATCH_1})
string(REGEX MATCH "SL_PLATFORM_RELEASE_SUFFIX \"([a-z0-9]*)\"" _ ${sl_platform_ver_h})
if (NOT ("${CMAKE_MATCH_1}" STREQUAL ""))
    set(SL_PLATFORM_PRERELEASE "-${CMAKE_MATCH_1}")
endif ()

set(SL_PLATFORM_ABI_SOVERSION 1)
set(SL_PLATFORM_ABI_VERSION "${SL_PLATFORM_MAJOR_VERSION}.${SL_PLATFORM_MINOR_VERSION}.${SL_PLATFORM_PATCH_VERSION}${SL_PLATFORM_PRERELEASE}")
set(SL_PLATFORM_PACKAGE_VERSION "${SL_PLATFORM_ABI_VERSION}")
message(STATUS "Configuring for sl_platform version ${SL_PLATFORM_ABI_VERSION}")

if (CMAKE_SYSTEM_NAME MATCHES "Linux")
    add_definitions(-DSL_PLATFORM_POSIX)
    add_definitions(-DSL_PLATFORM_LINUX)
    add_definitions(-DSL_PLATFORM_USE_EVENTFD)
    add_definitions(-DSL_PLATFORM_HAVE_ABSTRACT_SOCKETS)
    # Windows subsystem for Linux -- smells like Linux, but it has
    # some differences (SO_REUSEADDR for one).
    if (CMAKE_SYSTEM_VERSION MATCHES "Microsoft")
        add_definitions(-DSL_PLATFORM_WSL)
    endif ()
    set(SL_PLATFORM_POSIX ON)

elseif (CMAKE_SYSTEM_NAME MATCHES "Android")
    add_definitions(-DSL_PLATFORM_POSIX)
    add_definitions(-DSL_PLATFORM_LINUX)
    add_definitions(-DSL_PLATFORM_ANDROID)
    add_definitions(-DSL_PLATFORM_USE_EVENTFD)
    set(SL_PLATFORM_POSIX ON)

elseif (CMAKE_SYSTEM_NAME MATCHES "Windows")
    add_definitions(-DSL_PLATFORM_WINDOWS)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    add_definitions(-D_CRT_RAND_S)
    set(SL_PLATFORM_WINDOWS ON)

    # Target Windows Vista and later
    add_definitions(-D_WIN32_WINNT=0x0600)
    list(APPEND CMAKE_REQUIRED_DEFINITIONS -D_WIN32_WINNT=0x0600)

elseif (CMAKE_SYSTEM_NAME MATCHES "QNX")
    add_definitions(-DSL_PLATFORM_POSIX)
    add_definitions(-D__EXT_BSD)
    add_definitions(-D_QNX_SOURCE)
    add_definitions(-DSL_PLATFORM_QNX)
    set(SL_PLATFORM_POSIX ON)

else ()
    message(AUTHOR_WARNING "WARNING: This platform may not be supported: ${CMAKE_SYSTEM_NAME}")
    message(AUTHOR_WARNING "${ISSUE_REPORT_MSG}")
    # blithely hope for POSIX to work
    add_definitions(-DSL_PLATFORM_POSIX)
    set(SL_PLATFORM_POSIX ON)
endif ()

add_subdirectory(posix)
add_subdirectory(windows)
add_subdirectory(cmsis_rtos2)

set_target_properties(sl_platform PROPERTIES SOVERSION ${SL_PLATFORM_ABI_SOVERSION} VERSION "${SL_PLATFORM_ABI_VERSION}")
set_target_properties(sl_platform PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})
set_target_properties(sl_platform PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})
set_target_properties(sl_platform PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})
set_target_properties(sl_platform PROPERTIES FRAMEWORK OFF)
