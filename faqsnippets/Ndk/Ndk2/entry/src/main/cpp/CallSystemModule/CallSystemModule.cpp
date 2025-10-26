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
 * FAQ: 如何在Native侧调用ArkTS侧的系统能力
 */
// [Start call_system_module_cpp]
#include "CallSystemModule.h" 
#include "napi/native_api.h" 
#include <hilog/log.h> 
#define LOG_TAG "Pure" 
 
napi_value CallSystemModule::GetDisplaySize(napi_env env, napi_callback_info info) { 
    // Obtain the system library path on the arkts side
    char path[64] = "@ohos.display"; 
    size_t typeLen = 0; 
    napi_value string; 
    napi_create_string_utf8(env, path, typeLen, &string); 
    // Loading system libraries 
    napi_value sysModule; 
    napi_load_module(env, path, &sysModule); 
    // Retrieve the 'getDefault Display Sync' method from the system library 
    napi_value func = nullptr; 
    napi_get_named_property(env, sysModule, "getDefaultDisplaySync", &func); 
    napi_value funcResult; 
    napi_call_function(env, sysModule, func, 0, nullptr, &funcResult); 
    napi_value widthValue = nullptr; 
    napi_get_named_property(env, funcResult, "width", &widthValue); 
    double width; 
    napi_get_value_double(env, widthValue, &width); 
    OH_LOG_INFO(LOG_APP, "width: %{public}f", width); 
    napi_value heightValue = nullptr; 
    napi_get_named_property(env, funcResult, "height", &heightValue); 
    double height; 
    napi_get_value_double(env, heightValue, &height); 
    OH_LOG_INFO(LOG_APP, "height: %{public}f", height); 
    // By obtaining the width and height of the business, specific business logic can be further processed
    return nullptr; 
}
// [End call_system_module_cpp]