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

#ifndef CROSSMODULEREFERENCE_NAPI_HSP_H
#define CROSSMODULEREFERENCE_NAPI_HSP_H
#include <js_native_api_types.h>
napi_env main_env;
void setHspEnv(napi_env env);
double hspNativeAdd(double a, double b);
napi_value hspArkTSAdd(double a, double b);
#endif //CROSSMODULEREFERENCE_NAPI_HSP_H
