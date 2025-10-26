# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(NdkRawfile2)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(preloadso SHARED preloadso.cpp)
add_library(global_handlers SHARED global_handlers.cpp)
target_link_directories(preloadso PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/)
target_link_libraries(preloadso PUBLIC libhilog_ndk.z.so libace_napi.z.so global_handlers libentry.so)

# Compile the rawfile_demo.cpp configuration.
# After rawfile_demo.cpp is modified, delete the following code comments, compile a new libentry.so file.
# Replace the files in the libs directory with the new compilation files.
# add_library(entry SHARED rawfile_demo.cpp)
# target_link_libraries(entry PUBLIC libace_napi.z.so libhilog_ndk.z.so librawfile.z.so)