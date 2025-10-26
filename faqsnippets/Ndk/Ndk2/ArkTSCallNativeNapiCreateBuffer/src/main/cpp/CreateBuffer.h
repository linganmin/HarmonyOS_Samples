//
// Created on 2025/5/23.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef NDK5_CREATBUFFER_H
#define NDK5_CREATBUFFER_H

#include <js_native_api_types.h>
class CreateBuffer {
    public:
    static napi_value TestBuffer(napi_env env, napi_callback_info info);
};

#endif //NDK5_CREATBUFFER_H
