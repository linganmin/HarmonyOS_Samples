# 应用事件
# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(ApmAbilityBuilding)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)


# [Start application_events]
# Add json cpp (parsing json strings in subscription events) source file
add_library(entry SHARED napi_init.cpp jsoncpp.cpp)
# Add dynamic library dependencies libhiappevent_ndk. z.so and libhilog_ndk. z.so (log output)
target_link_libraries(entry PUBLIC libace_napi.z.so libhilog_ndk.z.so libhiappevent_ndk.z.so)
# [End application_events]