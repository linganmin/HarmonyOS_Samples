//
// Created on 2025/5/21.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
//FAQ:如何在Native侧添加debug版本声明
// [Start native_debug_cpp]
#include "napi/native_api.h" 
#include "hilog/log.h" 
#define LOG_TAG "Pure" 
 
static napi_value DefDebug(napi_env env, napi_callback_info info) { 
#ifdef _DEBUG 
    OH_LOG_INFO(LOG_APP, "debug enter Project"); 
#else 
    OH_LOG_INFO(LOG_APP, "release enter Project"); 
#endif 
    return nullptr; 
}
// [End native_debug_cpp]