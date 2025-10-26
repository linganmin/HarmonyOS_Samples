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

#ifndef NDKCREATEUI_USINGPROPERTYANIMATIONS_H
#define NDKCREATEUI_USINGPROPERTYANIMATIONS_H

#include <arkui/native_animate.h>
#include <arkui/native_node.h>
#include <arkui/native_type.h>
#include <cerrno>
#include <cstdint>
#include <js_native_api.h>

namespace NativeModule {
static constexpr int32_t F_DATA = 101;
static constexpr int32_t E_DATA = 201;
static constexpr int32_t ANIMATION_DURATION = 2000;
static constexpr double ANIMATION_TEMPO = 1.1;
static constexpr int32_t ANIMATION_DELAY = 20;
static constexpr int32_t ANIMATION_ITERATIONS = 1;
static constexpr int32_t MIN_FRAME_RATE = 10;
static constexpr int32_t MAX_FRAME_RATE = 120;
static constexpr int32_t EXPECTED_FRAME_RATE = 60;
static bool isback = false;

static ArkUI_NativeAnimateAPI_1 *animateApi = nullptr;
static ArkUI_ContextHandle context = nullptr;
static ArkUI_AnimateOption *option = nullptr;
static ArkUI_ContextCallback *update = nullptr;
static ArkUI_AnimateCompleteCallback *completeCallback = nullptr;

struct UserData {
    int32_t data;
};

napi_value CreateAttributeAnimationNativeRoot(napi_env env, napi_callback_info info);

napi_value DestroyAttributeAnimationNativeRoot(napi_env env, napi_callback_info info);

void CreateAttributeAnimation(ArkUI_NodeContentHandle handle, ArkUI_ContextHandle context1);

void OnButtonShowClicked2(ArkUI_NodeEvent *event);

ArkUI_NodeHandle CreateAndSetupStack(ArkUI_NativeNodeAPI_1 *nodeAPI);

ArkUI_NodeHandle CreateAndSetupButton(ArkUI_NativeNodeAPI_1 *nodeAPI);

void SetupAnimationOptions(ArkUI_AnimateOption *option);
} // namespace NativeModule

#endif // NDKCREATEUI_USINGPROPERTYANIMATIONS_H
