# the minimum version of CMake.
cmake_minimum_required(VERSION 3.16.5)
set(CMAKE_CXX_STANDARD 20)
project(fido2_test)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

set(ONLINEAUTHENTICATIONKIT_SOURCES
    hcts/src/connect_service.cpp
    hcts/src/fido2_serializer.cpp
    napi_init.cpp
)

set(ONLINEAUTHENTICATIONKIT_COMPILE_OPTIONS
    -fno-exceptions
    -fno-rtti
    -Wall
    -Werror
    -Wextra
    -Wpedantic
    -Wshadow
)

set(ONLINEAUTHENTICATIONKIT_INCLUDE_DIRECTORIES
    hcts/include
    third_party/include
)

add_library(entry SHARED
    ${ONLINEAUTHENTICATIONKIT_SOURCES}
)

find_library(fido2_ndk-lib libfido2_ndk.z.so REQUIRED)

set(ONLINEAUTHENTICATIONKIT_lINK_LIBRARIES
    libace_napi.z.so
    libhilog_ndk.z.so
    ${fido2_ndk-lib}
)

target_link_libraries(entry PUBLIC ${ONLINEAUTHENTICATIONKIT_lINK_LIBRARIES})

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

include_directories(${HMOS_SDK_NATIVE}/sysroot/usr/lib)

target_include_directories(entry PRIVATE
    ${ONLINEAUTHENTICATIONKIT_INCLUDE_DIRECTORIES}
)