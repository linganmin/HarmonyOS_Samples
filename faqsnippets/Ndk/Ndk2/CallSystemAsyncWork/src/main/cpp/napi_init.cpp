/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * FAQ: Native侧如何访问ArkTS侧系统定义的异步方法
 */
// [Start call_system_async_work_cpp]
#include "napi/native_api.h" 
#include <future> 
#include <hilog/log.h> 
 
#define LOG_TAG "Pure" // Global tag macro, identifying module log tags
 
// Context data, used for transferring data between threads
struct CallbackData { 
    napi_threadsafe_function tsfn; 
    napi_async_work work; 
    napi_deferred deferred = nullptr; 
    double res; 
}; 
static napi_value ResolvedCallback(napi_env env, napi_callback_info info) { 
    void *data = nullptr; 
    size_t argc = 1; 
    napi_value argv[1]; 
    napi_get_cb_info(env, info, &argc, argv, nullptr, &data); 
    napi_value widthProp = nullptr; 
    napi_get_named_property(env, argv[0], "width", &widthProp); 
    double result = 0; 
    napi_get_value_double(env, widthProp, &result); 
    OH_LOG_INFO(LOG_APP, "width in ResolvedCallback is %{public}f", result); 
    // Data is reinterpreted as a pointer to std:: promise<double>and the value of the promise is set to width 
    reinterpret_cast<std::promise<double> *>(data)->set_value(result); 
    return nullptr; 
} 
static void CallJs(napi_env env, napi_value jsCb, void *context, void *data) { 
    // Import system library modules and call down to methods layer by layer
    napi_value systemModule; 
    napi_load_module(env, "@ohos.display", &systemModule); 
    napi_value displayFunc = nullptr; 
    napi_get_named_property(env, systemModule, "getDefaultDisplay", &displayFunc); 
    napi_value promise = nullptr; 
    napi_call_function(env, systemModule, displayFunc, 0, nullptr, &promise); 
    napi_value thenFunc = nullptr; 
    napi_get_named_property(env, promise, "then", &thenFunc); 
    napi_value resolvedCallback; 
    // Promise resolve callback
    napi_create_function(env, "resolvedCallback", NAPI_AUTO_LENGTH, ResolvedCallback, data, &resolvedCallback); 
    napi_value argv[] = {resolvedCallback}; 
    napi_call_function(env, promise, thenFunc, 1, argv, nullptr); 
} 
static void ExecuteWork(napi_env env, void *data) { 
    CallbackData *callbackData = reinterpret_cast<CallbackData *>(data); 
    std::promise<double> promise; 
    auto future = promise.get_future(); 
    napi_call_threadsafe_function(callbackData->tsfn, &promise, napi_tsfn_nonblocking); 
    try { 
        auto result = future.get(); 
        callbackData->res = result; 
        OH_LOG_INFO(LOG_APP, "width in ExecuteWork %{public}f", result); 
    } catch (const std::exception &e) { 
        OH_LOG_INFO(LOG_APP, "XXX, Result from JS %{public}s", e.what()); 
    } 
} 
static void WorkComplete(napi_env env, napi_status status, void *data) { 
    CallbackData *callbackData = reinterpret_cast<CallbackData *>(data); 
    // Return the calculation results of the business code to the application 
    napi_value result = nullptr; 
    napi_create_double(env, callbackData->res, &result); 
    napi_resolve_deferred(env, callbackData->deferred, result); 
    // Release thread safety methods 
    napi_release_threadsafe_function(callbackData->tsfn, napi_tsfn_release); 
    // Delete asynchronous work items 
    napi_delete_async_work(env, callbackData->work); 
    callbackData->tsfn = nullptr; 
    callbackData->work = nullptr; 
} 
static napi_value getDisplayWidthAsync(napi_env env, napi_callback_info info) { 
    size_t argc = 1; 
    napi_value jsCb = nullptr; 
    CallbackData *callbackData = nullptr; 
    napi_get_cb_info(env, info, &argc, &jsCb, nullptr, reinterpret_cast<void **>(&callbackData)); 
     
    napi_value sysModule; 
    napi_load_module(env, "@ohos.display", &sysModule); 
    napi_value getDefaultDisplay; 
    napi_get_named_property(env, sysModule, "getDefaultDisplay", &getDefaultDisplay); 
    // Create a thread safe function 
    napi_value resourceName = nullptr; 
    napi_create_string_utf8(env, "getDisplayWidthAsync", NAPI_AUTO_LENGTH, &resourceName); 
    napi_create_threadsafe_function(env, getDefaultDisplay, nullptr, resourceName, 0, 1, callbackData, nullptr, 
                                    callbackData, CallJs, &callbackData->tsfn); 
    // Create an asynchronous task 
    napi_create_async_work(env, nullptr, resourceName, ExecuteWork, WorkComplete, callbackData, &callbackData->work); 
    // Add asynchronous tasks to the asynchronous queue and have them executed by the underlying scheduling system 
    napi_queue_async_work(env, callbackData->work); 
    // Method returns promise 
    napi_value result = nullptr; 
    napi_create_promise(env, &callbackData->deferred, &result); 
    return result; 
}
// [End call_system_async_work_cpp]

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    CallbackData *callbackData = new CallbackData();
    napi_property_descriptor desc[] = {
        {"getDisplayWidthAsync", nullptr, getDisplayWidthAsync, nullptr, nullptr, nullptr, napi_default, callbackData}};
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "callsystemasyncwork",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterCallSystemAsyncWorkModule(void)
{
    napi_module_register(&demoModule);
}
