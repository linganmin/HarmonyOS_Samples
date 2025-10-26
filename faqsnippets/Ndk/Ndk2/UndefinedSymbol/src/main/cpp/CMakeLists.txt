# FAQ:CPP编译报错"A 'undefined symbol' error has occurred
# [Start cmake_minimum_required]
cmake_minimum_required(VERSION 3.10)
project(MyProject)
set(CMAKE_CXX_STANDARD 17)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}
                    ${CMAKE_CURRENT_SOURCE_DIR}/include)
# Add all source files
add_library(myProgram SHARED main.cpp myLibrary.cpp)
# [End cmake_minimum_required]