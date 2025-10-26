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
 * FAQ: Native侧如何获取ArkTS侧类实例
 */
// [Start c_get_ark_ts_object_cpp]
// Get class information and call class functions
#include "CGetArkTSObject.h" 
napi_value CGetArkTSObject::Cal(napi_env env, napi_callback_info info) { 
    size_t argc = 4; 
    napi_value args[4] = {nullptr}; 
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr); 
 
    double value0; 
    napi_get_value_double(env, args[0], &value0); 
 
    double value1; 
    napi_get_value_double(env, args[1], &value1); 
 
    // Construct class instances
    napi_value demo; 
    napi_create_object(env, &demo); 
    napi_coerce_to_object(env, args[2], &demo); 
 
    bool flag; 
    napi_get_value_bool(env, args[3], &flag); 
 
    // Obtain the add and sub functions of the class instance
    napi_value add, sub, num; 
    napi_get_named_property(env, demo, "add", &add); 
    napi_get_named_property(env, demo, "sub", &sub); 
 
    // Call the ArkTS function
    napi_value result; 
    if (flag) { 
        napi_call_function(env, nullptr, add, 2, args, &result); 
    } else { 
        napi_call_function(env, nullptr, sub, 2, args, &result); 
    } 
 
    return result; 
}
// [End c_get_ark_ts_object_cpp]