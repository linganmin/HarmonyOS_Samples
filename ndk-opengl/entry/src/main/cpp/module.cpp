/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
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

#include "log.h"
#include "napi_manager.h"
#include "app_napi.h"

#ifdef __cplusplus
extern "C" {
#endif

/*
 * function for module exports
 */
EXTERN_C_START
// [Start ArkTS2Native]
// Responsible for transferring data from ArkTS to Native.
static napi_value objectPassingTs2Napi(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1];
    napi_get_cb_info(env, info, &argc, args, NULL, NULL);
    
    if (argc < 1) {
        napi_throw_error(env, NULL, "Wrong number of arguments");
        return NULL;
    }
    
    napi_value obj = args[0];
    napi_value keys;
    napi_get_property_names(env, obj, &keys); // Get all attribute names.
    
    uint32_t length;
    napi_get_array_length(env, keys, &length); // Obtain the number of attributes.
    
    for (uint32_t i = 0; i < length; ++i) {
        napi_value key;
        napi_get_element(env, keys, i, &key); // Get the i-th attribute name.
        
        // Convert attribute names to strings.
        char keyStr[128];
        size_t keyLen;
        napi_get_value_string_utf8(env, key, keyStr, sizeof(keyStr), &keyLen);
        
        // Get attribute values.
        napi_value value;
        napi_get_property(env, obj, key, &value);
        
        // Determine the type of attribute value and process it.
        napi_valuetype type;
        napi_typeof(env, value, &type);
        
        if (type == napi_string) {
            char valueStr[4];
            size_t valueLen;
            napi_get_value_string_utf8(env, value, valueStr, sizeof(valueStr), &valueLen);
        }
        if (type == napi_number) {
            double num;
            napi_get_value_double(env, value, &num);
        }
    }
    return NULL;
}

// Define data transfer function.
static napi_value objectPassing(napi_env env, napi_callback_info info)
{
    objectPassingTs2Napi(env, info);
    return nullptr;
}
// [End ArkTS2Native]

static napi_value Init(napi_env env, napi_value exports)
{
    LOGE("Init");
    napi_property_descriptor desc[] = {
        DECLARE_NAPI_FUNCTION("getContext", NapiManager::GetContext),
        DECLARE_NAPI_FUNCTION("updateAngle", AppNapi::UpdateAngle),
        DECLARE_NAPI_FUNCTION("setRotate", AppNapi::SetRotate),
        {"objectPassing", nullptr, objectPassing, nullptr, nullptr, nullptr, napi_default, nullptr}
    };

    NAPI_CALL(env, napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc));

    bool ret = NapiManager::GetInstance()->Export(env, exports);
    if (!ret) {
        LOGE("Init failed");
    }

    return exports;
}
EXTERN_C_END

/*
 * Napi Module define
 */
static napi_module appNapiModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "tetrahedron_napi",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

/*
 * Module register function
 */
extern "C" __attribute__((constructor)) void RegisterModule(void)
{
    napi_module_register(&appNapiModule);
}

#ifdef __cplusplus
}
#endif