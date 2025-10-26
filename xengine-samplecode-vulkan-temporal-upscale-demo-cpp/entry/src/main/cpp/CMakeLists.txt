# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(XComponent)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

ADD_DEFINITIONS(-DVK_USE_PLATFORM_OHOS=1)
ADD_DEFINITIONS(-DVK_NO_PROTOTYPES=1)
add_definitions(-DOHOS_PLATFORM)
add_definitions(-DSTB_IMAGE_IMPLEMENTATION)

include_directories(
    ${NATIVERENDER_ROOT_PATH}
    ${NATIVERENDER_ROOT_PATH}/include
)

add_library(nativerender SHARED
    render/plugin_render.cpp
    render/algorithm/fsr.cpp
    manager/plugin_manager.cpp
    napi_init.cpp
    vulkanbase/VulkanOhos.cpp
    vulkanbase/VulkanBuffer.cpp
    vulkanbase/VulkanDevice.cpp
    vulkanbase/vulkanexamplebase.cpp
    vulkanbase/VulkanInitializers.hpp
    vulkanbase/VulkanSwapChain.cpp
    vulkanbase/VulkanTools.cpp
    vulkanbase/VulkanTexture.cpp
    file/file_operator.cpp
    file/file.cpp
    render/model_3d_sponza.cpp
    render/vulkan_obj_model.cpp
    render/vulkan_obj_mesh.cpp
)

# ktx
set(KTX_SOURCES
	${NATIVERENDER_ROOT_PATH}/3rdParty/ktx/lib/texture.c
	${NATIVERENDER_ROOT_PATH}/3rdParty/ktx/lib/hashlist.c
	${NATIVERENDER_ROOT_PATH}/3rdParty/ktx/lib/checkheader.c
	${NATIVERENDER_ROOT_PATH}/3rdParty/ktx/lib/swap.c
	${NATIVERENDER_ROOT_PATH}/3rdParty/ktx/lib/memstream.c
	${NATIVERENDER_ROOT_PATH}/3rdParty/ktx/lib/filestream.c
)
set(KTX_INCLUDE
	${NATIVERENDER_ROOT_PATH}/3rdParty/ktx/include
	${NATIVERENDER_ROOT_PATH}/3rdParty/ktx/lib
	${NATIVERENDER_ROOT_PATH}/3rdParty/ktx/other_include
)

add_library(libktx ${KTX_SOURCES})

target_include_directories(libktx PUBLIC ${KTX_INCLUDE})
target_include_directories(nativerender PRIVATE
        3rdParty
        3rdParty/glm
        vulkanbase
        )

find_library(
    # Sets the name of the path variable.
    hilog-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    hilog_ndk.z
)

find_library(
    # Sets the name of the path variable.
    libace-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    ace_ndk.z
)

find_library(
    # Sets the name of the path variable.
    libnapi-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    ace_napi.z
)

find_library(
    # Sets the name of the path variable.
    libuv-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    uv
)

add_library(libassimp SHARED IMPORTED)
set_target_properties(
        libassimp
        PROPERTIES
        IMPORTED_LOCATION
        ${CMAKE_CURRENT_SOURCE_DIR}/libs/arm64-v8a/libassimp.so
)

find_library(
# Sets the name of the path variable.
xengine-lib
# Specifies the name of the NDK library that
# you want CMake to locate.
xengine
)

target_link_libraries(nativerender PUBLIC
    ${hilog-lib} ${libace-lib} ${libnapi-lib} ${libuv-lib} libnative_window.so libc++.a libktx librawfile.z.so libassimp ${xengine-lib})