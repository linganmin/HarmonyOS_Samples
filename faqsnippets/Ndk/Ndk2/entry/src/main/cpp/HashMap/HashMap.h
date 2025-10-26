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

#ifndef PROJECT5_HASHMAP_H
#define PROJECT5_HASHMAP_H
#include "napi/native_api.h"
#include <string>
class HashMap {
public:
    static napi_value TsPutMap(napi_env env, napi_callback_info info);
    static napi_value MapJson(napi_env env, napi_callback_info info);
    static std::string value2String(napi_env env, napi_value value);
};
#endif // PROJECT5_HASHMAP_H
