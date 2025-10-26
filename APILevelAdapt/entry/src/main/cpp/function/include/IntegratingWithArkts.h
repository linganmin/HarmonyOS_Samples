/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

#ifndef NDKCREATEUI_INTEGRATINGWITHARKTS_H
#define NDKCREATEUI_INTEGRATINGWITHARKTS_H

#include <cstdint>
#include <js_native_api.h>
#include "ArkUIBaseNode.h"

namespace NativeModule {
constexpr int32_t List_NUM = 30;
constexpr int32_t TEXT_FONTSIZE = 16;
constexpr int32_t TEXT_HEIGHT = 100;

napi_value CreateButtonNativeRoot(napi_env env, napi_callback_info info);

napi_value DestroyButtonNativeRoot(napi_env env, napi_callback_info info);

std::shared_ptr<ArkUIBaseNode> CreateButtonExample();
} // namespace NativeModule

#endif // NDKCREATEUI_INTEGRATINGWITHARKTS_H
