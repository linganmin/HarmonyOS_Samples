# 在CMakeLists文件中如何获取模块版本信息

# [Start c_make_get_module_version]
cmake_minimum_required(VERSION 3.4.1)
project(CmakeModuleInfo)

set(JSON_FILE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/../../../oh-package.json5)
file(READ ${JSON_FILE_PATH} JSON_STRING)
message("json string:${JSON_STRING}")
if("${JSON_STRING}" MATCHES "1.0.0")
set(SRC_LIST napi_init.cpp)
else()
set(SRC_LIST hello.cpp)
endif()
message("src_file:${SRC_LIST}")

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(entry SHARED ${SRC_LIST})
target_link_libraries(entry PUBLIC libace_napi.z.so)
# [End c_make_get_module_version]