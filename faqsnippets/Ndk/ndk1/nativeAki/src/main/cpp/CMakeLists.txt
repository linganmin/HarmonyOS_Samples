# 如何通过AKI三方库实现ArkTS与C/C++之间的跨语言调用
# [Start aki_cmakelist1]
# [StartExclude aki_cmakelist1]
# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(ndk1)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
# [EndExclude aki_cmakelist1]

# 1. Set the AKI root path
set(AKI_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../../oh_modules/@ohos/aki)
set(CMAKE_MODULE_PATH ${AKI_ROOT_PATH})
find_package(Aki REQUIRED)

# [StartExclude aki_cmakelist1]
if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)
# [EndExclude aki_cmakelist1]

add_library(entry SHARED napi_init.cpp)
# 2. To link the binary dependencies & header file, you need to make sure that the target (e.g. entry) is the same as the target in the add_library() method
target_link_libraries(entry PUBLIC Aki::libjsbind)
# [End aki_cmakelist1]