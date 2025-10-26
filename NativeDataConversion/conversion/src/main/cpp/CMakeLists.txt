# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(DataConversionDemo)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(conversion SHARED hello.cpp NumberType.cpp StringBoolType.cpp ArrayType.cpp ArraybufferType.cpp ObjectType.cpp DateType.cpp)
target_link_libraries(conversion PUBLIC libace_napi.z.so libhilog_ndk.z.so)