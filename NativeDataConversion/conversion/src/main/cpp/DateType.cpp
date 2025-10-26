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

#include "napi/native_api.h"
#include <cstdio>
#include <hilog/log.h>
#include <ctime>
#include "DateType.h"

napi_value DateType::CreateDate(napi_env env, napi_callback_info info) {
    // Get the current Unix Time Stamp time.
    double value = time(nullptr) * 1000;
    OH_LOG_Print(LOG_APP, LOG_INFO, 0xFF00, "CreateDate", "nowTime = %lf", value);
    // Call the napi_make_date interface to convert a double value to represent a date and time,
    // and create an ArkTS object to be placed in the returnValue.
    napi_value returnValue = nullptr;
    napi_create_date(env, value, &returnValue);
    return returnValue;
}

napi_value DateType::GetDateValue(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // Get the incoming time.
    double value = 0;
    napi_status status = napi_get_date_value(env, args[0], &value);
    if (status != napi_ok) {
        napi_throw_error(env, nullptr, "napi_get_date_value fail");
        return nullptr;
    }
    OH_LOG_INFO(LOG_APP, "Node-API gets the incoming Green time:%{public}lf.", value);

    // Create the converted Unix Time Stamp as an ArkTS double value and place it in the returnValue.
    napi_value returnValue = nullptr;
    napi_create_double(env, value, &returnValue);
    return returnValue;
}

napi_value DateType::IsDate(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // Call the napi_is_date interface to determine if the given input parameter is Date data.
    bool result = false;
    napi_status status = napi_is_date(env, args[0], &result);
    if (status != napi_ok) {
        napi_throw_error(env, nullptr, "Node-API napi_is_date fail");
        return nullptr;
    }
    // Convert the result to napi_value type and return it.
    napi_value returnValue = nullptr;
    napi_get_boolean(env, result, &returnValue);

    return returnValue;
}