//
// Created on 2025/5/21.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
//FAQ:在Native侧如何精准获取ArkTS侧传入的字符串长度
#include "napi/native_api.h"

// [Start get_str_len]
static napi_value TestFunc(napi_env env, napi_callback_info info) 
{ 
    size_t argc = 1; 
    napi_value args[1] = {nullptr}; 
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr); 
     
    size_t len = 0; 
    napi_get_value_string_utf8(env, args[0], nullptr, 0, &len);    // Get string length to len 
    char* buf = new char[len+1];                                   // Allocate a char array of appropriate size
    napi_get_value_string_utf8(env, args[0], buf, len + 1, &len);  // get string 
    // ... 
}
// [End get_str_len]