# the minimum version of CMake.
cmake_minimum_required(VERSION 3.16.5)
project(VulkanFGDemo)
set(CMAKE_CXX_STANDARD 20)
project(VulkanFGDemo CXX)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

ADD_DEFINITIONS(-DVK_USE_PLATFORM_OHOS=1)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Now build app's shared lib
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -Wall")
set(sample_src_files
    asset/AassetImporter.cpp
    vulkan_utils/Blit.cpp
    vulkan_utils/Camera.cpp
    vulkan_utils/MainSceneRenderer.cpp
    vulkan_utils/UIRenderer.cpp
    vulkan_utils/Utils.cpp
    vulkan_utils/DescriptorPool.cpp
    vulkan_utils/CommandPool.cpp
    vulkan_utils/Buffer.cpp
    vulkan_utils/Image.cpp
    vulkan_utils/Device.cpp
    common/timer.cpp
    common/log.cpp
    begin/core.cpp
    begin/hellovk.cpp
    napi_init.cpp
)

set(sample_include_dirs
    ./asset
    ./vulkan_utils
    ./third_party
    ./third_party/securec/include
    ./common
    ./begin
)

find_library(ace-lib ace_ndk.z REQUIRED)
find_library(hilog-lib hilog_ndk.z REQUIRED)
find_library(napi-lib ace_napi.z REQUIRED)
find_library(rawfile-lib rawfile.z REQUIRED)
find_library(uv-lib uv REQUIRED)
find_library(vulkan-lib vulkan REQUIRED)
find_library(window-lib native_window REQUIRED)
find_library(framegeneration-lib libframegeneration.so REQUIRED)

set(sample_link_library
    ${ace-lib}
    ${hilog-lib}
    ${rawfile-lib}
    ${napi-lib}
    ${uv-lib}
    ${vulkan-lib}
    ${window-lib}
    ${framegeneration-lib}
    libc++.a
)

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(entry SHARED
    ${sample_src_files}
)
target_link_libraries(entry PUBLIC ${sample_link_library})
target_link_libraries(entry PUBLIC ${NATIVERENDER_ROOT_PATH}/../../../libs/${OHOS_ARCH}/libsecurec.so)

target_include_directories(entry PRIVATE ${sample_include_dirs})