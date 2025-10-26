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
#ifndef PROJECT5_SCREENBRIGHTNESS_H
#define PROJECT5_SCREENBRIGHTNESS_H
#include "napi/native_api.h"
class ScreenBrightness {
public:
    static napi_value NapiLoadModule(napi_env env, napi_callback_info info);
    static napi_value Success(napi_env env, napi_callback_info info);
    static napi_value Fail(napi_env env, napi_callback_info info);
    static napi_value Complete(napi_env env, napi_callback_info info);
};
#endif //PROJECT5_SCREENBRIGHTNESS_H
