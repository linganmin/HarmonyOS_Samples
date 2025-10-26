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
#include <js_native_api.h>
#include "ArkUIListNode.h"
#include "IntegratingWithArkts.h"
#include "NativeEntry.h"
#include "ListeningForComponentEvents.h"

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200 // Global domain macro, identifying the business domain
#define LOG_TAG "MY_TAG"  // Global tag macro, identifying module log tags

namespace NativeModule {
NativeEntry nativeEntry1;

napi_value CreateMonitorEventListNativeRoot(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    // Get parameters passed in from JS
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // Get NodeContent.
    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    nativeEntry1.SetContentHandle(contentHandle);

    // Create a text list.
    auto list = CreateTextEventListExample();
    // Keep the Native side objects in the management class and maintain their lifecycle.
    nativeEntry1.SetRootNode(list);

    return nullptr;
}

std::shared_ptr<ArkUIBaseNode> CreateTextEventListExample()
{
    // Create components and mount them.
    // 1：Create a List component.
    auto list = std::make_shared<ArkUIListNode>();
    list->SetPercentWidth(1);
    list->SetPercentHeight(1);
    // 2：Create a ListItem sub component and mount it onto the List.
    for (int32_t i = 0; i < List_NUM; ++i) {
        auto listItem = std::make_shared<ArkUIListItemNode>();
        auto textNode = std::make_shared<ArkUITextNode>();
        textNode->SetTextContent(std::to_string(i));
        textNode->SetFontSize(TEXT_FONTSIZE);
        textNode->SetPercentWidth(1);
        textNode->SetHeight(TEXT_HEIGHT);
        textNode->SetBackgroundColor(0xFFfffacd);
        textNode->SetTextAlign(ARKUI_TEXT_ALIGNMENT_CENTER);
        listItem->AddChild(textNode);
        // Capture the listItem pointer and change the background color when clicked.
        listItem->RegisterOnClick([textNode]() {
            textNode->SetBackgroundColor(0xFF00FF00);
            OH_LOG_INFO(LOG_APP, "list item background color changed");
        });
        list->AddChild(listItem);
    }

    // 3：Register List related listening events.
    list->RegisterOnScrollIndex([](int32_t index) { OH_LOG_INFO(LOG_APP, "on list scroll index: %{public}d", index); });
    // 4: Register mount event.
    list->RegisterOnAppear([]() { OH_LOG_INFO(LOG_APP, "on list mount to tree"); });
    // 4: Register for uninstallation events.
    list->RegisterOnDisappear([]() { OH_LOG_INFO(LOG_APP, "on list unmount from tree"); });
    return list;
}

napi_value DestroyMonitorEventListNativeRoot(napi_env env, napi_callback_info info)
{
    nativeEntry1.DisposeRootNode();
    return nullptr;
}
} // namespace NativeModule