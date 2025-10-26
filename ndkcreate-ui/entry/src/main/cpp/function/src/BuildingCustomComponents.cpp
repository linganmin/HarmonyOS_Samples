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

#include <arkui/native_node_napi.h>
#include "ArkUICustomContainerNode.h"
#include "ArkUICustomNode.h"
#include "NativeEntry.h"
#include "UITimer.h"
#include "BuildingCustomComponents.h"

namespace NativeModule {
NativeEntry nativeEntry4;

napi_value CreateCustomContainerNativeRoot(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    // Get parameters passed in from JS.
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // Get NodeContent.
    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    nativeEntry4.SetContentHandle(contentHandle);

    // Custom containers and custom drawing components.
    auto node = std::make_shared<ArkUICustomContainerNode>();
    node->SetBackgroundColor(0xFFE0FFFF);
    auto customNode = std::make_shared<ArkUICustomNode>();
    customNode->SetBackgroundColor(0xFFD3D3D3);
    customNode->SetWidth(CUSTOM_WIDTH);
    customNode->SetHeight(CUSTOM_HEIGHT);
    node->AddChild(customNode);
    CreateNativeTimer(env, customNode.get(), 1, [](void *userData, int32_t count) {
        auto customNode = reinterpret_cast<ArkUICustomNode *>(userData);
        customNode->SetRectColor(0xFF00FF7F);
    });

    // Keep the Native side objects in the management class and maintain their lifecycle.
    nativeEntry4.SetRootNode(node);

    return nullptr;
}

napi_value DestroyCustomContainerNativeRoot(napi_env env, napi_callback_info info)
{
    nativeEntry4.DisposeRootNode();
    return nullptr;
}
} // namespace NativeModule