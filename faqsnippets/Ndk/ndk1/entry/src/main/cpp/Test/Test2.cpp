//
// Created on 2025/5/23.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
/**
 * FAQ: 在Native侧如何处理ArkTS侧传入的字符串被截断的异常场景
 */
#include "napi/native_api.h"
// [Start test_func2]
static napi_value TestFunc(napi_env env, napi_callback_info info) 
{ 
    size_t argc = 1; 
    napi_value args[1] = {nullptr}; 
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr); 
     
    size_t len = 0; 
    char buf[1024];                                                 
    napi_get_value_string_utf8(env, args[0], buf, 5, &len);                    // Get string, buf result is' abcde '
    // ... 
}
// [End test_func2]