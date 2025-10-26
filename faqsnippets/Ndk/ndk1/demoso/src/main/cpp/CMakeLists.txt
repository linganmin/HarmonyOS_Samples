# FAQ:多so相互依赖场景下如何解耦
# [Start demo_so]
# CMakeLists.txt
cmake_minimum_required(VERSION 3.4.1)
project(DemoSO)
set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)
# Add libdemoso. so file
add_library(demoso SHARED hello.cpp)
# Add dependency libraries liba.so and libb.so. Please note to include the path, otherwise the corresponding SO library cannot be found
target_link_libraries(demoso PUBLIC libace_napi.z.so ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/liba.so ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/${OHOS_ARCH}/libb.so)
# [End demo_so]