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

#include "ArkUICustomContainerNode.h"

namespace NativeModule {
void ArkUICustomContainerNode::OnStaticCustomEvent(ArkUI_NodeCustomEvent *event)
{
    // Retrieve component instance objects and call relevant real instance methods.
    auto customNode = reinterpret_cast<ArkUICustomContainerNode *>(OH_ArkUI_NodeCustomEvent_GetUserData(event));
    auto type = OH_ArkUI_NodeCustomEvent_GetEventType(event);
    switch (type) {
        case ARKUI_NODE_CUSTOM_EVENT_ON_MEASURE:
            customNode->OnMeasure(event);
            break;
        case ARKUI_NODE_CUSTOM_EVENT_ON_LAYOUT:
            customNode->OnLayout(event);
            break;
        default:
            break;
    }
}

// Custom calculation logic.
void ArkUICustomContainerNode::OnMeasure(ArkUI_NodeCustomEvent *event)
{
    auto layoutConstrain = OH_ArkUI_NodeCustomEvent_GetLayoutConstraintInMeasure(event);
    // Create child node layout restrictions and reuse percentage parameter values from parent component layouts.
    auto childLayoutConstrain = OH_ArkUI_LayoutConstraint_Copy(layoutConstrain);
    OH_ArkUI_LayoutConstraint_SetMaxHeight(childLayoutConstrain, MAX_HEIGHT);
    OH_ArkUI_LayoutConstraint_SetMaxWidth(childLayoutConstrain, MAX_WIDTH);
    OH_ArkUI_LayoutConstraint_SetMinHeight(childLayoutConstrain, MIN_HEIGHT);
    OH_ArkUI_LayoutConstraint_SetMinWidth(childLayoutConstrain, MIN_WIDTH);

    // Test operator nodes to obtain the maximum value of child nodes.
    auto totalSize = nativeModule_->getTotalChildCount(handle_);
    int32_t maxWidth = 0;
    int32_t maxHeight = 0;
    for (uint32_t i = 0; i < totalSize; i++) {
        auto child = nativeModule_->getChildAt(handle_, i);
        // Call the calculation interface to calculate the Native component.
        nativeModule_->measureNode(child, childLayoutConstrain);
        auto size = nativeModule_->getMeasuredSize(child);
        if (size.width > maxWidth) {
            maxWidth = size.width;
        }
        if (size.height > maxHeight) {
            maxHeight = size.height;
        }
    }
    // Customize calculation to reinforce margins for all child node sizes.
    nativeModule_->setMeasuredSize(handle_, maxWidth + SIDES_COUNT  * padding_, maxHeight + SIDES_COUNT  * padding_);
}

void ArkUICustomContainerNode::OnLayout(ArkUI_NodeCustomEvent *event)
{
    // Get the expected location of the parent component and set it.
    auto position = OH_ArkUI_NodeCustomEvent_GetPositionInLayout(event);
    nativeModule_->setLayoutPosition(handle_, position.x, position.y);

    // Set sub components to be centered and aligned.
    auto totalSize = nativeModule_->getTotalChildCount(handle_);
    auto selfSize = nativeModule_->getMeasuredSize(handle_);
    for (uint32_t i = 0; i < totalSize; i++) {
        auto child = nativeModule_->getChildAt(handle_, i);
        // Get sub component size.
        auto childSize = nativeModule_->getMeasuredSize(child);
        // Layout sub component positions.
        nativeModule_->layoutNode(child, (selfSize.width - childSize.width) / SIDES_COUNT,
                                  (selfSize.height - childSize.height) / SIDES_COUNT);
    }
}
} // namespace NativeModule
