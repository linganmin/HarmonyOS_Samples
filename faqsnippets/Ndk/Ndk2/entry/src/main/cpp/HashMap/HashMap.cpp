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
 * FAQ: 如何实现ArkTS与C/C++的HashMap转换
 */
#include "HashMap.h"
#include <string>
#include <map>
#include <hilog/log.h>
#include <nlohmann/json.hpp>

// [Start hash_map_one_cpp]
// Convert value to string and return
std::string HashMap::value2String(napi_env env, napi_value value) {
    size_t stringSize = 0;
    napi_get_value_string_utf8(env, value, nullptr, 0, &stringSize); // 获取字符串长度
    std::string valueString;
    valueString.resize(stringSize + 1);
    napi_get_value_string_utf8(env, value, &valueString[0], stringSize + 1, &stringSize); // 根据长度转换成字符串
    return valueString;
}
napi_value HashMap::TsPutMap(napi_env env, napi_callback_info info) {
    std::map<std::string, int> myMap;
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    napi_value mapKey = args[0]; // key
    napi_value mapVal = args[1]; // value
    napi_value mapNum = args[2]; // length


    uint32_t mapCNum = 0;
    napi_get_value_uint32(env, mapNum, &mapCNum);
    for (uint32_t i = 0; i < mapCNum; i++) {
        napi_value keyNIndex, valNIndex;
        napi_get_element(env, mapKey, i, &keyNIndex);
        napi_get_element(env, mapVal, i, &valNIndex);
        std::string keyIndex = value2String(env, keyNIndex);
        int valIndex = 0;
        napi_get_value_int32(env, valNIndex, &valIndex);
        myMap[keyIndex] = valIndex;
        OH_LOG_Print(LOG_APP, LOG_INFO, 0x0000, "Pure", "%{public}s %{public}d", keyIndex.c_str(), myMap[keyIndex]);
    }
    return nullptr;
}
// [End hash_map_one_cpp]

// [Start hash_map_two_cpp]
napi_value HashMap::MapJson(napi_env env, napi_callback_info info) {

    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    std::string jsonStr = value2String(env, args[0]);

    std::map<std::string, int> myMap = nlohmann::json::parse(jsonStr.c_str());

    OH_LOG_Print(LOG_APP, LOG_INFO, 0x0000, "Pure", "%{public}d %{public}d %{public}d", myMap["Abc"], myMap["Bcd"],
                 myMap["Cde"]);

    return nullptr;
}
// [End hash_map_two_cpp]