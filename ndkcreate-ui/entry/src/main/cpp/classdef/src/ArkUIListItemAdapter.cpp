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

#include <hilog/log.h>
#include "ArkUIListItemAdapter.h"

namespace NativeModule {
ArkUI_NodeAdapterHandle ArkUIListItemAdapter::GetHandle() const { return handle_; }

void ArkUIListItemAdapter::RemoveItem(int32_t index)
{
    // Delete the index data.
    data_.erase(data_.begin() + index);
    // If the index causes a change in the visibility of visible area elements,
    // it will call back the Node-Adapter-EVENT_ON-REMOVENOTEDEFROM_SDAPTER event to delete the elements,
    // According to whether there are new elements added, call back the events of NODE-Adapter-EVENT_ONVNet.
    OH_ArkUI_NodeAdapter_RemoveItem(handle_, index, 1);
    // Update the new quantity.
    OH_ArkUI_NodeAdapter_SetTotalNodeCount(handle_, data_.size());
}

void ArkUIListItemAdapter::OnStaticAdapterEvent(ArkUI_NodeAdapterEvent *event)
{
    // Retrieve instance objects and call back instance events.
    auto itemAdapter = reinterpret_cast<ArkUIListItemAdapter *>(OH_ArkUI_NodeAdapterEvent_GetUserData(event));
    itemAdapter->OnAdapterEvent(event);
}

void ArkUIListItemAdapter::OnAdapterEvent(ArkUI_NodeAdapterEvent *event)
{
    auto type = OH_ArkUI_NodeAdapterEvent_GetType(event);
    switch (type) {
        case NODE_ADAPTER_EVENT_ON_GET_NODE_ID:
            OnNewItemIdCreated(event);
            break;
        case NODE_ADAPTER_EVENT_ON_ADD_NODE_TO_ADAPTER:
            OnNewItemAttached(event);
            break;
        case NODE_ADAPTER_EVENT_ON_REMOVE_NODE_FROM_ADAPTER:
            OnItemDetached(event);
            break;
        default:
            break;
    }
}

// Assign an ID to the item that needs to be displayed for element diff in the ReloadAllItems scenario.
void ArkUIListItemAdapter::OnNewItemIdCreated(ArkUI_NodeAdapterEvent *event)
{
    auto index = OH_ArkUI_NodeAdapterEvent_GetItemIndex(event);
    static std::hash<std::string> hashId = std::hash<std::string>();
    auto id = hashId(data_[index]);
    OH_ArkUI_NodeAdapterEvent_SetNodeId(event, id);
}

// New items need to be displayed in the visible area.
void ArkUIListItemAdapter::OnNewItemAttached(ArkUI_NodeAdapterEvent *event)
{
    auto index = OH_ArkUI_NodeAdapterEvent_GetItemIndex(event);
    ArkUI_NodeHandle handle = nullptr;
    if (!cachedItems_.empty()) {
        // Use and update the cache for recycling and reuse.
        auto recycledItem = cachedItems_.top();
        auto textItem = std::dynamic_pointer_cast<ArkUITextNode>(recycledItem->GetChildren().back());
        textItem->SetTextContent(data_[index]);
        handle = recycledItem->GetHandle();

        auto swipeContent = recycledItem->GetSwipeContent();
        swipeContent->RegisterOnClick([this, data = data_[index]]() {
            auto it = std::find(data_.begin(), data_.end(), data);
            if (it != data_.end()) {
                auto index = std::distance(data_.begin(), it);
                RemoveItem(index);
            }
        });
        // Release the reference to the cache pool.
        cachedItems_.pop();
    } else {
        // Create a new element.
        auto listItem = std::make_shared<ArkUIListItemNode>();
        auto textNode = std::make_shared<ArkUITextNode>();
        textNode->SetTextContent(data_[index]);
        textNode->SetFontSize(FONT_SIZE);
        textNode->SetPercentWidth(PERCENT_WIDTH);
        textNode->SetHeight(ITEM_HEIGHT);
        textNode->SetBackgroundColor(0xFFfffacd);
        textNode->SetTextAlign(ARKUI_TEXT_ALIGNMENT_CENTER);
        listItem->AddChild(textNode);
        listItem->RegisterOnClick([index]() { OH_LOG_INFO(LOG_APP, "on %{public}d list item click", index); });

        // Create ListItem and Draw Menu.
        auto swipeNode = std::make_shared<ArkUITextNode>();
        swipeNode->SetTextContent("del");
        swipeNode->SetFontSize(FONT_SIZE);
        swipeNode->SetFontColor(0xFFFFFFFF);
        swipeNode->SetWidth(ITEM_WIDTH);
        swipeNode->SetHeight(ITEM_HEIGHT);
        swipeNode->SetBackgroundColor(0xFFFF0000);
        swipeNode->SetTextAlign(ARKUI_TEXT_ALIGNMENT_CENTER);
        swipeNode->RegisterOnClick([this, data = data_[index]]() {
            auto it = std::find(data_.begin(), data_.end(), data);
            if (it != data_.end()) {
                auto index = std::distance(data_.begin(), it);
                RemoveItem(index);
            }
        });
        listItem->SetSwiperAction(swipeNode);

        handle = listItem->GetHandle();
        // Maintain references to text list items.
        items_.emplace(handle, listItem);
    }
    // Set the elements to be displayed.
    OH_ArkUI_NodeAdapterEvent_SetItem(event, handle);
}

// Remove the item from the visible area.
void ArkUIListItemAdapter::OnItemDetached(ArkUI_NodeAdapterEvent *event)
{
    auto item = OH_ArkUI_NodeAdapterEvent_GetRemovedNode(event);
    // Put it into the cache pool for recycling and reuse.
    cachedItems_.emplace(items_[item]);
}
} // namespace NativeModule