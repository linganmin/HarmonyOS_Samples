//
// Created on 2024/3/7.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef NDKAPP_TEST_H
#define NDKAPP_TEST_H
#include "napi/native_api.h"
class Test {
public:
    static napi_value TestFunc(napi_env env, napi_callback_info info);
};
#endif //NDKAPP_TEST_H
