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
 * FAQ: 如何在Native侧直接使用其他模块的ArkTS方法
 */
// [Start call_custom_method_cpp]
#include "napi/native_api.h" 
#include <string> 
 
static napi_value LoadModule(napi_env env, napi_callback_info info) { 
    napi_value result; 
    // 1. Load modules from the Test file using napi_load_module 
    napi_status status = napi_load_module(env, "ets/pages/Test", &result); 
    napi_value testFn; 
    // 2. Use napi_get_named_property to obtain the test function 
    napi_get_named_property(env, result, "test", &testFn); 
    // 3. Call the function test using napi_call_function 
    napi_call_function(env, result, testFn, 0, nullptr, nullptr); 
    napi_value value; 
    napi_value key; 
    std::string keyStr = "value"; 
    napi_create_string_utf8(env, keyStr.c_str(), keyStr.size(), &key); 
    // 4. Get variable value using napi_get_property 
    napi_get_property(env, result, key, &value); 
    return value; 
}
// [End call_custom_method_cpp]

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "loadModule", nullptr, LoadModule, nullptr, nullptr, nullptr, napi_default, nullptr }
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
    .nm_modname = "callcustommethod",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterCallCustomMethodModule(void)
{
    napi_module_register(&demoModule);
}
