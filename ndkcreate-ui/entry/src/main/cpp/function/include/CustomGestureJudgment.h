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

#ifndef NDKCREATEUI_CUSTOMGESTUREJUDGMENT_H
#define NDKCREATEUI_CUSTOMGESTUREJUDGMENT_H

#include <js_native_api.h>
#include "ArkUIBaseNode.h"

namespace NativeModule {
napi_value CreateCustomGestureViewNativeRoot(napi_env env, napi_callback_info info);

napi_value DestroyCustomGestureViewNativeRoot(napi_env env, napi_callback_info info);

void CustomGestureViewMethod(ArkUI_NodeContentHandle handle);
} // namespace NativeModule

#endif // NDKCREATEUI_CUSTOMGESTUREJUDGMENT_H
