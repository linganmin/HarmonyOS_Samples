# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(CppCrash)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

#add_library(entry SHARED napi_init.cpp CppCrashAdvise1.cpp CppCrashCaseAnalyse1.cpp CppCrashCaseAnalyse2.cpp
#    CppCrashCaseAnalyse3.cpp CppCrashCaseAnalyse4.cpp CppCrashCaseAnalyse5.cpp CppCrashCaseAnalyse6.cpp
#    CppCrashCaseAnalyse7.cpp CppCrashCaseAnalysis8.cpp CppCrashQuestionCheck1.cpp CppCrashQuestionCheck2.cpp)
add_library(entry SHARED napi_init.cpp CppCrashAdvise1.cpp CppCrashAdvise2.cpp CppCrashAdvise3.cpp CppCrashAdvise4.cpp
    CppCrashQuestionCheck1.cpp CppCrashQuestionCheck2.cpp CppCrashCaseAnalyse5.cpp CppCrashCaseAnalyse6.cpp
    CppCrashCaseAnalyse7.cpp CppCrashCaseAnalysis8.cpp)
target_link_libraries(entry PUBLIC libace_napi.z.so)