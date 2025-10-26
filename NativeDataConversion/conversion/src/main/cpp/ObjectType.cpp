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

// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
#include "ObjectType.h"
#include "hilog/log.h"

napi_value ObjectType::Obj(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    if (napi_ok != napi_get_cb_info(env, info, &argc, args, nullptr, nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ObjectType", "api_get_cb_info failed");
        return nullptr;
    }

    char strTemp[20] = {};
    size_t len;
    int32_t num;
    // Get strings and numbers.
    if (napi_ok != napi_get_value_string_utf8(env, args[0], strTemp, 20, &len) ||
        napi_ok != napi_get_value_int32(env, args[1], &num)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ObjectType",
                     "napi_get_value_string_utf8 or napi_get_value_int32 failed");
        return nullptr;
    }

    // Construct string types and int types.
    napi_value name, age;
    if (napi_ok != napi_create_string_utf8(env, strTemp, NAPI_AUTO_LENGTH, &name) ||
        napi_ok != napi_create_int32(env, num, &age)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ObjectType", "napi_create_string_utf8 or napi_create_int32 failed");
        return nullptr;
    }
    // Construct an object type.
    napi_value obj;
    if (napi_ok != napi_create_object(env, &obj)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ObjectType", "napi_create_object failed");
        return nullptr;
    }

    // Set and assign values to the name and age attributes.
    if (napi_ok != napi_set_named_property(env, obj, "name", name) || napi_set_named_property(env, obj, "age", age)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ObjectType",
                     "napi_set_named_property or napi_set_named_property failed");
        return nullptr;
    }

    return obj;
}