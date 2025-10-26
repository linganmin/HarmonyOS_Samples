//
// Created on 2024/10/12.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef NATIVESOINTEGRATION_SUB_H
#define NATIVESOINTEGRATION_SUB_H
extern "C" {
double sub(double a, double b);
}
#endif // NATIVESOINTEGRATION_SUB_H
