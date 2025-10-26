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

#ifndef NDKCREATEUI_BUILDINGADIALOGBOX_H
#define NDKCREATEUI_BUILDINGADIALOGBOX_H

#include <arkui/native_node.h>
#include <arkui/native_type.h>
#include <js_native_api.h>

namespace NativeModule {
constexpr float DIALOG_CORNER_RADIUS = 6.0f;
constexpr int32_t BUTTON_CLICK_ID = 1;
static bool isShown = false;

napi_value CreatePopupNativeRoot(napi_env env, napi_callback_info info);

napi_value DestroyPopupNativeRoot(napi_env env, napi_callback_info info);

void MainViewMethod(ArkUI_NodeContentHandle handle);

void OnButtonClicked(ArkUI_NodeEvent *event);

ArkUI_NodeHandle CreateDialogContent();

void ShowDialog();

void CloseDialog();
} // namespace NativeModule

#endif // NDK_BUILDINGADIALOGBOX_H
