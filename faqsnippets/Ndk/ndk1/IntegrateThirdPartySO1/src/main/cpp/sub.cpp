//
// Created on 2025/5/29.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
/**
 * FAQ:在Native侧如何集成三方SO库
 */
// [Start native_sub]
// sub.cpp 
#include <iostream> 
#include "sub.h" 
double sub(double a, double b) 
{ 
    return a - b; 
}
// [End native_sub]