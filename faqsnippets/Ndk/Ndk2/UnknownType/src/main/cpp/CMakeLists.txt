# CPP编译报错"A 'unknown type name' error has occurred"
# [Start cmake_minimum_required]
cmake_minimum_required(VERSION 3.10)
project(MyProject)
set(CMAKE_CXX_STANDARD 17)
# Add header file directory
include_directories(${CMAKE_SOURCE_DIR}/include)
# Add source file
add_library(myProgram SHARED src/main.cpp src/myLibrary.cpp)
# [End cmake_minimum_required]

# [Start CMAKE_VERBOSE_MAKEFILE]
set(CMAKE_VERBOSE_MAKEFILE ON)
# [End CMAKE_VERBOSE_MAKEFILE]

# [Start msg_directory]
message(STATUS "Source directory: ${CMAKE_SOURCE_DIR}")
message(STATUS "Include directories: ${CMAKE_INCLUDE_PATH}")
# [Start msg_directory]