//
// Created on 2025/5/21.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
//FAQ:如何在Native侧构建一个ArkTS对象
#include "napi/native_api.h"

static napi_value CallbackToArkTS(napi_env env, napi_callback_info info) {
    // [Start napi_create_arkts1]
    // Create object arg_order in the native layer
    napi_value arg_object;
    napi_create_object(env, &arg_object);
    // [End napi_create_arkts1]
    
    // [Start napi_create_arkts2]
    napi_value testNum, testString;
    // Set the property testNum and assign a value of 123 to the arg_order object created above
    napi_create_int32(env, 123, &testNum);
    napi_set_named_property(env, arg_object, "testNum", testNum);
    // Set the property testString and assign 'Pure' to the arg_order object created above
    napi_create_string_utf8(env, "Pure", NAPI_AUTO_LENGTH, &testString);
    napi_set_named_property(env, arg_object, "testString", testString);
    // [End napi_create_arkts2]
} 
