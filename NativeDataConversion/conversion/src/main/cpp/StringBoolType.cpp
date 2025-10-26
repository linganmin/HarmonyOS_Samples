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
#include "StringBoolType.h"
#include <string>
#include <hilog/log.h>

napi_value StringBoolType::StrAdd(napi_env env, napi_callback_info info) {
    size_t argc = 3;                // Number of parameters.
    napi_value args[3] = {nullptr}; // A napi array that stores parameters.

    // Obtain the parameters and store them in the NAPI parameter array.
    if (napi_ok != napi_get_cb_info(env, info, &argc, args, nullptr, nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "StringBoolType", "api_get_cb_info failed");
        return nullptr;
    }

    // Store the obtained string parameters and bool parameters, and store the string in the char pointer.
    char strTemp1[20] = {};
    char strTemp2[20] = {};
    bool flag = false;
    size_t len1 = 0, len2 = 0; // Stores the length of the string.
    /* Obtain the C-side String data from the NAPI parameter array to the Char pointer, 20 represents the length of the
     * data to be retrieved, the string will be truncated if the length is insufficient, and len1 stores the number of
     * bytes to be copied.
    */
    if (napi_ok != napi_get_value_string_utf8(env, args[0], strTemp1, 20, &len1) ||
        napi_ok != napi_get_value_string_utf8(env, args[1], strTemp2, 20, &len2) ||
        napi_ok != napi_get_value_bool(env, args[2], &flag)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "StringBoolType",
                     "napi_get_value_string_utf8 or napi_get_value_bool failed");
        return nullptr;
    }

    // Convert the char pointer to the string type.
    std::string str1 = strTemp1;
    std::string str2 = strTemp2;

    // The strings are added according to the passed flag and passed to the parameter sum.
    napi_value sum;
    if (flag) {
        str1 += str2;
        /* Construct a string parameter on the arkTs side, a char pointer to be passed str1.c_str(), NAPI_AUTO_LENGTH:
         * the maximum length to be passed.
        */
        if (napi_ok != napi_create_string_utf8(env, str1.c_str(), NAPI_AUTO_LENGTH, &sum)) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "StringBoolType", "napi_create_string_utf8 failed");
            return nullptr;
        }
    } else {
        str2 += str1;
        if (napi_ok != napi_create_string_utf8(env, str2.c_str(), NAPI_AUTO_LENGTH, &sum)) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "StringBoolType", "napi_create_string_utf8 failed");
            return nullptr;
        }
    }

    return sum;
}