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
 * FAQ: 如何将Native侧的函数封装到类中导出到ArkTS侧使用
 */
// [Start func_encapsulation_cpp]
#include "napi/native_api.h" 
#include <string> 
 
static napi_value Sub(napi_env env, napi_callback_info info) { 
    size_t requireArgc = 2; 
    size_t argc = 2; 
    napi_value args[2] = {nullptr}; 
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr); 
    napi_valuetype valuetype0; 
    napi_typeof(env, args[0], &valuetype0); 
    napi_valuetype valuetype1; 
    napi_typeof(env, args[1], &valuetype1); 
    double value0; 
    napi_get_value_double(env, args[0], &value0); 
    double value1; 
    napi_get_value_double(env, args[1], &value1); 
    napi_value sub; 
    napi_create_double(env, value0 - value1, &sub); 
    return sub; 
} 
static napi_value Sum(napi_env env, napi_callback_info info) { 
    size_t requireArgc = 2; 
    size_t argc = 2; 
    napi_value args[2] = {nullptr}; 
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr); 
    napi_valuetype valuetype0; 
    napi_typeof(env, args[0], &valuetype0); 
    napi_valuetype valuetype1; 
    napi_typeof(env, args[1], &valuetype1); 
    double value0; 
    napi_get_value_double(env, args[0], &value0); 
    double value1; 
    napi_get_value_double(env, args[1], &value1); 
    napi_value sum; 
    napi_create_double(env, value0 + value1, &sum); 
    return sum; 
} 
napi_value Constructor(napi_env env, napi_callback_info info) { return nullptr; } 
EXTERN_C_START 
static napi_value Init(napi_env env, napi_value exports) { 
    std::string class_name = "TestEntryA"; 
    napi_property_descriptor desc[] = {{"sub", nullptr, Sub, nullptr, nullptr, nullptr, napi_static, nullptr}, 
                                       {"sum", nullptr, Sum, nullptr, nullptr, nullptr, napi_static, nullptr}}; 
    napi_value defined_class = nullptr; 
    napi_define_class(env, class_name.c_str(), class_name.length(), Constructor, nullptr, 2, desc, &defined_class); 
    const napi_property_descriptor exports_desc[] = { 
        {class_name.c_str(), nullptr, nullptr, nullptr, nullptr, defined_class, napi_default, nullptr}, 
    }; 
    napi_define_properties(env, exports, 2, exports_desc); 
    return exports; 
} 
EXTERN_C_END
// [End func_encapsulation_cpp]

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "funcencapsulation",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterFuncEncapsulationModule(void) {
    napi_module_register(&demoModule);
}
