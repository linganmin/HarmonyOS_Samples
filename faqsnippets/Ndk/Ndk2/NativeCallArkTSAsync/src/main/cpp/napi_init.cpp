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
 * FAQ: 如何在Native侧调用ArkTS侧异步方法，并获取异步计算结果到Native侧
 */

// [Start native_call_ark_ts_async_cpp]
#include "napi/native_api.h" 
#include "hilog/log.h" 
 
// Define callback methods for the then property of Promise objects 
// The callback method of the then attribute can have no return value 
// In the following text, it is necessary to create an ArkTS function object through napi_make_function, so set the return value to napi_value and return nullptr at the end of the function
napi_value ThenCallBack(napi_env env, napi_callback_info info) { 
    size_t argc = 1; 
    napi_value args[1] = {nullptr}; 
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr); 
    int32_t asyncResult = 0; // ArkTS side asynchronous method calculation results 
    napi_get_value_int32(env, args[0], &asyncResult); 
    OH_LOG_Print(LOG_APP, LOG_INFO, 0xFF00, "testTag-Native", "ArkTS Async Method Calculation Success, Result: %{public}d", 
                 asyncResult); 
    return nullptr; 
} 
// Define callback methods for catch properties of Promise objects 
// The callback method of the catch property can have no return value 
// In the following text, it is necessary to create an ArkTS function object through napi_make_function, so set the return value to napi_value and return nullptr at the end of the function 
napi_value CatchCallBack(napi_env env, napi_callback_info info) { 
    size_t argc = 1; 
    napi_value args[1] = {nullptr}; 
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr); 
    size_t strLen = 0; 
    napi_get_value_string_utf8(env, args[0], nullptr, 0, &strLen);            // Get string length to strLen 
    char *strBuffer = new char[strLen + 1];                                   // Allocate a char array of appropriate size 
    napi_get_value_string_utf8(env, args[0], strBuffer, strLen + 1, &strLen); // Get a string representing the information about the abnormal calculation of the ArkTS side asynchronous method
    OH_LOG_Print(LOG_APP, LOG_INFO, 0xFF00, "testTag-Native", 
                 "ArkTS Async Method Calculation Exception: %{public}s", strBuffer); 
    return nullptr; 
} 
static napi_value TestPromise(napi_env env, napi_callback_info info) { 
    size_t argc = 1; 
    napi_value args[1] = {nullptr}; 
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr); // Analyze the callback passed by ArkTS side 
 
    napi_value arktsPromise = nullptr; 
    // Execute callback through napi_call_function to return the promise object created by ArkTS side
    napi_call_function(env, nullptr, args[0], 0, nullptr, &arktsPromise); 
 
    // Get the then property of the promise object, whose callback method is used to handle the asynchronous calculation results on the ArkTS side
    napi_value thenProperty = nullptr; 
    napi_get_named_property(env, arktsPromise, "then", &thenProperty); 
    // Convert the then property callback method defined in the C++language into an ArkTS function object, which is a napi_value type value
    napi_value thenCallback = nullptr; 
    napi_create_function(env, "thenCallback", NAPI_AUTO_LENGTH, ThenCallBack, nullptr, &thenCallback); 
 
    // Get the catch property of the promise object, whose callback method is used to handle information about ArkTS side asynchronous computation exceptions 
    napi_value catchProperty = nullptr; 
    napi_get_named_property(env, arktsPromise, "catch", &catchProperty); 
    // Convert the catch property callback method defined in the C++language into an ArkTS function object, i.e. a napi_value type value
    napi_value catchCallback = nullptr; 
    napi_create_function(env, "catchCallback", NAPI_AUTO_LENGTH, CatchCallBack, nullptr, &catchCallback); 
     
    // Execute the callback of the then attribute through napi_call_function, similar to calling promise. then()=>{} on the ArkTS side
    napi_call_function(env, arktsPromise, thenProperty, 1, &thenCallback, nullptr); 
    // Execute a callback for the catch property through napi_call_function, similar to calling promise. catch (()=>{}) on the ArkTS side
    napi_call_function(env, arktsPromise, catchProperty, 1, &catchCallback, nullptr); 
    return nullptr; 
}
// [End native_call_ark_ts_async_cpp]

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "testPromise", nullptr, TestPromise, nullptr, nullptr, nullptr, napi_default, nullptr }
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterNativeCallArkTSAsyncModule(void)
{
    napi_module_register(&demoModule);
}
