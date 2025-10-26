//
// Created on 2024/10/12.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
#include "sub.h"
double sub(double a, double b) { return a - b; }