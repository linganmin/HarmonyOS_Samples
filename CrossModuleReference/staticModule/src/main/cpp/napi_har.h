/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
// [Start napi_har_start]
// [Start har_start]
// staticModule\src\main\cpp\napi_har.h
#ifndef CROSSMODULEREFERENCE_NAPI_HAR_H
#define CROSSMODULEREFERENCE_NAPI_HAR_H
#include <js_native_api_types.h>
// [StartExclude napi_har_start]
napi_env g_main_env;
void setHarEnv(napi_env env);
// [EndExclude napi_har_start]
double harNativeAdd(double a, double b);
napi_value harArkTSAdd(double a, double b);
#endif //CROSSMODULEREFERENCE_NAPI_HAR_H
// [End har_start]
// [End napi_har_start]