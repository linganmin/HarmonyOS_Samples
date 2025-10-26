# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(Project5)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include
                    ${NATIVERENDER_ROOT_PATH}/../../../libs/${OHOS_ARCH})

add_library(entry SHARED napi_init.cpp UintArr/UintArr.cpp CGetArkTSObject/CGetArkTSObject.cpp
                         CreatBuffer/CreatBuffer.cpp CharToArrBuffer/CharToArrBuffer.cpp CustomObject/CustomObject.cpp
                         RevArkTSObj/RevArkTSObj.cpp BindCObject/BindCObject.cpp IsMainThread/IsMainThread.cpp
                         HashMap/HashMap.cpp ScreenBrightness/ScreenBrightness.cpp WriteFile/WriteFile.cpp
                         CGetAppPackageName/CGetAppPackageName.cpp CallSystemModule/CallSystemModule.cpp
                         WorkerCallNapiLoop/WorkerCallNapiLoop.cpp)
target_link_libraries(entry PUBLIC libace_napi.z.so libhilog_ndk.z.so libbundle_ndk.z.so libuv.so)