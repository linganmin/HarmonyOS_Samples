# FAQ:在Native侧如何集成三方SO库
# [Start native_sub]
# CMakeLists.txt
cmake_minimum_required(VERSION 3.4.1)
project(libSub)
# Compile source code 
add_library(nativeSub SHARED sub.cpp)
# [End native_sub]