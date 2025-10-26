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
#include <hilog/log.h>
#include "ArkUIListNode.h"
#include "ArkUIMixedRefresh.h"
#include "IntegratingWithArkts.h"
#include "NativeEntry.h"
#include "UITimer.h"
#include "EmbeddingArkTSComponents.h"

namespace  NativeModule {
NativeEntry nativeEntry5;

napi_value CreateMixedRefreshListNativeRoot(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    // Get parameters passed in from JS.
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // Get NodeContent.
    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    nativeEntry5.SetContentHandle(contentHandle);

    // Create Refresh Text List.
    auto refresh = CreateMixedRefreshList(env);
    // Keep the Native side objects in the management class and maintain their lifecycle.
    nativeEntry5.SetRootNode(refresh);

    return nullptr;
}

std::shared_ptr<ArkUIBaseNode> CreateMixedRefreshList(napi_env env)
{
    auto list = CreateTextListExample();
    // Create Refresh component in mixed mode and mount List component.
    NativeRefreshAttribute nativeRefreshAttribute{
        .backgroundColor = 0xFF89CFF0, .refreshOffset = 64, .pullToRefresh = true};
    auto refresh = ArkUIMixedRefresh::Create(nativeRefreshAttribute);
    refresh->AddChild(list);

    // Set events in mixed mode.
    refresh->SetOnOffsetChange(
        [](float offset) { OH_LOG_INFO(LOG_APP, "on refresh offset changed: %{public}f", offset); });
    refresh->SetRefreshCallback([refreshPtr = refresh.get(), env]() {
        OH_LOG_INFO(LOG_APP, "on refreshing");
        // Start the timer and simulate data acquisition.
        CreateNativeTimer(env, refreshPtr, 1, [](void *userData, int32_t count) {
            // Turn off refresh after data acquisition.
            auto refresh = reinterpret_cast<ArkUIMixedRefresh *>(userData);
            refresh->SetRefreshState(false);
            refresh->FlushMixedModeCmd();
        });
    });

    // Update events to ArkTS side.
    refresh->FlushMixedModeCmd();
    return refresh;
}

napi_value DestroyMixedRefreshListNativeRoot(napi_env env, napi_callback_info info)
{
    // Release native side objects from the management class.
    nativeEntry5.DisposeRootNode();
    return nullptr;
}
} // namespace NativeModule