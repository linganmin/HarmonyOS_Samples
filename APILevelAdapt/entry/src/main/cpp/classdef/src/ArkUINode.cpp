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

#include "ArkUINode.h"

namespace NativeModule {
void ArkUINode::SetWidth(float width)
{
    assert(handle_);
    ArkUI_NumberValue value[] = {{.f32 = width}};
    ArkUI_AttributeItem item = {value, 1};
    nativeModule_->setAttribute(handle_, NODE_WIDTH, &item);
}

void ArkUINode::SetPercentWidth(float percent)
{
    assert(handle_);
    ArkUI_NumberValue value[] = {{.f32 = percent}};
    ArkUI_AttributeItem item = {value, 1};
    nativeModule_->setAttribute(handle_, NODE_WIDTH_PERCENT, &item);
}

void ArkUINode::SetHeight(float height)
{
    assert(handle_);
    ArkUI_NumberValue value[] = {{.f32 = height}};
    ArkUI_AttributeItem item = {value, 1};
    nativeModule_->setAttribute(handle_, NODE_HEIGHT, &item);
}

void ArkUINode::SetPercentHeight(float percent)
{
    assert(handle_);
    ArkUI_NumberValue value[] = {{.f32 = percent}};
    ArkUI_AttributeItem item = {value, 1};
    nativeModule_->setAttribute(handle_, NODE_HEIGHT_PERCENT, &item);
}

void ArkUINode::SetBackgroundColor(uint32_t color)
{
    assert(handle_);
    ArkUI_NumberValue value[] = {{.u32 = color}};
    ArkUI_AttributeItem item = {value, 1};
    nativeModule_->setAttribute(handle_, NODE_BACKGROUND_COLOR, &item);
}

// Handle general events.
void ArkUINode::RegisterOnClick(const std::function<void()> &onClick)
{
    assert(handle_);
    onClick_ = onClick;
    // 注册点击事件。
    nativeModule_->registerNodeEvent(handle_, NODE_ON_CLICK, 0, nullptr);
}

// Node disappearance event.
void ArkUINode::RegisterOnDisappear(const std::function<void()> &onDisappear)
{
    if (!handle_) {
        throw std::runtime_error("handle_ is null!");
    }
    onDisappear_ = onDisappear;
    // Register for uninstallation events.
    nativeModule_->registerNodeEvent(handle_, NODE_EVENT_ON_DISAPPEAR, 0, nullptr);
}

// Node occurrence event.
void ArkUINode::RegisterOnAppear(const std::function<void()> &onAppear)
{
    if (!handle_) {
        throw std::runtime_error("handle_ is null!");
    }
    onAppear_ = onAppear;
    // Register mount event.
    nativeModule_->registerNodeEvent(handle_, NODE_EVENT_ON_APPEAR, 0, nullptr);
}

// Pointer to the event listener function.
void ArkUINode::NodeEventReceiver(ArkUI_NodeEvent *event)
{
    // Retrieve the UI component object where the event occurred.
    auto nodeHandle = OH_ArkUI_NodeEvent_GetNodeHandle(event);
    // Retrieve custom data held in the UI component object and return the wrapper class pointer.
    auto *node =
        reinterpret_cast<ArkUINode *>(NativeModuleInstance::GetInstance()->GetNativeNodeAPI()->getUserData(nodeHandle));
    // Process events based on encapsulated class instance objects.
    node->ProcessNodeEvent(event);
}

void ArkUINode::ProcessNodeEvent(ArkUI_NodeEvent *event)
{
    auto eventType = OH_ArkUI_NodeEvent_GetEventType(event);
    switch (eventType) {
        case NODE_ON_CLICK: {
            if (onClick_) {
                onClick_();
            }
            break;
        }
        case NODE_TOUCH_EVENT: {
            if (onTouch_) {
                auto *uiInputEvent = OH_ArkUI_NodeEvent_GetInputEvent(event);
                float x = OH_ArkUI_PointerEvent_GetX(uiInputEvent);
                float y = OH_ArkUI_PointerEvent_GetY(uiInputEvent);
                auto type = OH_ArkUI_UIInputEvent_GetAction(uiInputEvent);
                onTouch_(type, x, y);
            }
        }
        case NODE_EVENT_ON_DISAPPEAR: {
            if (onDisappear_) {
                onDisappear_();
            }
            break;
        }
        case NODE_EVENT_ON_APPEAR: {
            if (onAppear_) {
                onAppear_();
            }
            break;
        }
        default: {
        // Assign component specific events to subclasses for processing.
            OnNodeEvent(event);
        }
    }
}

void ArkUINode::OnAddChild(const std::shared_ptr<ArkUIBaseNode> &child)
{
    nativeModule_->addChild(handle_, child->GetHandle());
}

void ArkUINode::OnRemoveChild(const std::shared_ptr<ArkUIBaseNode> &child)
{
    nativeModule_->removeChild(handle_, child->GetHandle());
}

void ArkUINode::OnInsertChild(const std::shared_ptr<ArkUIBaseNode> &child, int32_t index)
{
    nativeModule_->insertChildAt(handle_, child->GetHandle(), index);
}
} // namespace NativeModule