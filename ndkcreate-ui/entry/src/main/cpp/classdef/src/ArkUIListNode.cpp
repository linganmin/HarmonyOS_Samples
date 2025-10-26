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

#include "ArkUIListNode.h"

namespace NativeModule {
// Scroll the control list to the specified offset element
void ArkUIListNode::ScrollToIndex(int32_t index)
{
    ArkUI_NumberValue value[] = {{.i32 = index}};
    ArkUI_AttributeItem Item = {.value = value, .size = 1};
    nativeModule_->setAttribute(handle_, NODE_LIST_SCROLL_TO_INDEX, &Item);
}

// Registration list related events.
void ArkUIListNode::RegisterOnScrollIndex(const std::function<void(int32_t index)> &onScrollIndex)
{
    assert(handle_);
    onScrollIndex_ = onScrollIndex;
    nativeModule_->registerNodeEvent(handle_, NODE_LIST_ON_SCROLL_INDEX, 0, nullptr);
}

// Introduce lazy loading module.
void ArkUIListNode::SetLazyAdapter(const std::shared_ptr<ArkUIListItemAdapter> &adapter)
{
    assert(handle_);
    ArkUI_AttributeItem item{nullptr, 0, nullptr, adapter->GetHandle()};
    nativeModule_->setAttribute(handle_, NODE_LIST_NODE_ADAPTER, &item);
    adapter_ = adapter;
}

void ArkUIListNode::OnNodeEvent(ArkUI_NodeEvent *event)
{
    auto eventType = OH_ArkUI_NodeEvent_GetEventType(event);
    switch (eventType) {
        case NODE_LIST_ON_SCROLL_INDEX: {
            auto index = OH_ArkUI_NodeEvent_GetNodeComponentEvent(event)->data[0];
            if (onScrollIndex_) {
                onScrollIndex_(index.i32);
            }
        }
        default: {
        }
    }
}
} // namespace NativeModule
