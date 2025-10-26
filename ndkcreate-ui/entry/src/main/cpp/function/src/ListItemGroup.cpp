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
#include "IntegratingWithArkts.h"
#include "NativeEntry.h"
#include "ListItemGroup.h"

namespace NativeModule {
NativeEntry nativeEntry3;

napi_value CreateTextGroupListNativeRoot(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    // Retrieve parameters passed from JS.
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // Get NodeContent.
    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    nativeEntry3.SetContentHandle(contentHandle);

    // Create a text group list.
    auto node = CreateTextGroupListExample();
    // Keep the Native side objects in the management class and maintain their lifecycle.
    nativeEntry3.SetRootNode(node);

    return nullptr;
}

std::shared_ptr<ArkUIBaseNode> CreateTextGroupListExample()
{
    // reate components and mount them.
    // 1：Create a List component.
    auto list = std::make_shared<ArkUIListNode>();
    list->SetPercentWidth(1);
    list->SetPercentHeight(1);
    // Set the ceiling.
    // 2：Create a ListItem sub component and mount it onto the List.
    for (int32_t i = 0; i < HEADER_NUM; i++) {
        auto header = std::make_shared<ArkUITextNode>();
        header->SetTextContent("header");
        header->SetFontSize(HEADER_FONTSIZE);
        header->SetPercentWidth(1);
        header->SetHeight(HEADER_HEIGHT);
        header->SetBackgroundColor(0xFFDCDCDC);
        header->SetTextAlign(ARKUI_TEXT_ALIGNMENT_CENTER);
        auto listItemGroup = std::make_shared<ArkUIListItemGroupNode>();
        listItemGroup->SetHeader(header);

        for (int32_t i = 0; i < TEXT_NUM; ++i) {
            auto listItem = std::make_shared<ArkUIListItemNode>();
            auto textNode = std::make_shared<ArkUITextNode>();
            textNode->SetTextContent(std::to_string(i));
            textNode->SetFontSize(TEXT_FONTSIZE);
            textNode->SetPercentWidth(1);
            textNode->SetHeight(TEXT_HEIGHT);
            textNode->SetBackgroundColor(0xFFfffacd);
            textNode->SetTextAlign(ARKUI_TEXT_ALIGNMENT_CENTER);
            listItem->AddChild(textNode);
            listItemGroup->AddChild(listItem);
        }
        list->AddChild(listItemGroup);
    }
    return list;
}

napi_value DestroyTextGroupListNativeRoot(napi_env env, napi_callback_info info)
{
    nativeEntry3.DisposeRootNode();
    return nullptr;
}
} // namespace NativeModule