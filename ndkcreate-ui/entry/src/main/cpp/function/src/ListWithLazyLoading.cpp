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
#include "ArkUIListItemGroupNode.h"
#include "ArkUIListNode.h"
#include "ListItemGroup.h"
#include "NativeEntry.h"
#include "ListWithLazyLoading.h"

namespace NativeModule {
NativeEntry nativeEntry2;

napi_value CreateLazyTextListNativeRoot(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    // Get parameters passed in from JS.
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // Get NodeContent.
    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    nativeEntry2.SetContentHandle(contentHandle);

    // Create a lazy loading text list.
    auto node = CreateLazyTextListExample();
    // Keep the Native side objects in the management class and maintain their lifecycle.
    nativeEntry2.SetRootNode(node);

    auto list = std::dynamic_pointer_cast<ArkUIListNode>(node);
    // Scroll to the fifth item in the list.
    list->ScrollToIndex(SCROLL_TO_INDEX);

    return nullptr;
}

std::shared_ptr<ArkUIBaseNode> CreateLazyTextListExample()
{
    // Create components and mount them
    // 1：Create a List component.
    auto list = std::make_shared<ArkUIListNode>();
    list->SetPercentWidth(1);
    list->SetPercentHeight(1);
    // 2：Create a ListItem sub component and mount it onto the List.
    auto adapter = std::make_shared<ArkUIListItemAdapter>();
    list->SetLazyAdapter(adapter);
    return list;
}

napi_value DestroyLazyTextListNativeRoot(napi_env env, napi_callback_info info)
{
    nativeEntry2.DisposeRootNode();
    return nullptr;
}
}