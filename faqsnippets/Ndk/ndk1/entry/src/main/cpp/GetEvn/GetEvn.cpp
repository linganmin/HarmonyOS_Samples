//
// Created on 2025/5/22.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
/**
 * FAQ: NAPI执行上层回调时，如何获取env
 */
// [Start get_evn]
#include "napi/native_api.h" 
#include <thread> 
#include "hilog/log.h" 
 
napi_ref cbObj = nullptr; 
// Thread safety function
napi_threadsafe_function tsfn; 
// Native side Value Value
static int cValue; 
 
 
// Subthread running function 
static void CallJs(napi_env env, napi_value js_cb, void *context, void *data) { 
    std::thread::id this_id = std::this_thread::get_id(); 
    OH_LOG_INFO(LOG_APP, "threadId3 is +%{public}d", this_id); 
    // Get reference value 
    napi_get_reference_value(env, cbObj, &js_cb); 
 
    // Create an ArkTS number as an input parameter for the ArkTS function.
    napi_value argv; 
    napi_create_int32(env, cValue, &argv); 
 
    napi_value result = nullptr; 
    napi_call_function(env, nullptr, js_cb, 1, &argv, &result); 
 
    napi_get_value_int32(env, result, &cValue); 
 
    napi_delete_reference(env, cbObj); 
} 
 
// Native main thread
static napi_value ThreadsTest(napi_env env, napi_callback_info info) { 
    // The number of parameters obtained from ArkTS side
    size_t argc = 1; 
    napi_value js_cb, work_name; 
 
    // Get ArkTS parameters
    napi_get_cb_info(env, info, &argc, &js_cb, nullptr, nullptr); 
 
    // Napi_ref cbObj pointing to napi_value js_cb
    napi_create_reference(env, js_cb, 1, &cbObj); 
 
    // Create workname using UTF8 encoded C string data 
    napi_create_string_utf8(env, "Work Item", NAPI_AUTO_LENGTH, &work_name); 
 
    // Create thread safe function
    napi_create_threadsafe_function(env, js_cb, NULL, work_name, 0, 1, NULL, NULL, NULL, CallJs, &tsfn); 
 
    std::thread::id this_id = std::this_thread::get_id(); 
    OH_LOG_INFO(LOG_APP, "threadId1 is +%{public}d", this_id); 
 
    // Calling thread safe functions in other threads
    std::thread t([]() { 
        // Can obtain thread ID
        std::thread::id this_id = std::this_thread::get_id(); 
        OH_LOG_INFO(LOG_APP, "threadId2 is +%{public}d", this_id); 
        napi_acquire_threadsafe_function(tsfn); 
        napi_call_threadsafe_function(tsfn, NULL, napi_tsfn_blocking); 
    }); 
    t.detach(); 
 
    return NULL; 
}
// [End get_evn]