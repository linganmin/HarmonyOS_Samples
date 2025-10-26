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

#ifndef NDKCREATEUI_ARKUINODE_H
#define NDKCREATEUI_ARKUINODE_H

#include "ArkUIBaseNode.h"
#include "NativeModuleInstance.h"

namespace NativeModule {
class ArkUINode : public ArkUIBaseNode {
public:
    explicit ArkUINode(ArkUI_NodeHandle handle) : ArkUIBaseNode(handle)
    {
        nativeModule_ = NativeModuleInstance::GetInstance()->GetNativeNodeAPI();
        // When an event is triggered, the corresponding event object needs to be obtained through a function.
        // Here, the encapsulated class pointer is kept on the component by setting node custom data,
        // which facilitates subsequent event distribution.
        nativeModule_->setUserData(handle_, this);
        // Register a node to listen for event receivers.
        nativeModule_->addNodeEventReceiver(handle_, ArkUINode::NodeEventReceiver);
    }

    ~ArkUINode() override
    {
        if (onClick_) {
            nativeModule_->unregisterNodeEvent(handle_, NODE_ON_CLICK);
        }
        if (onTouch_) {
            nativeModule_->unregisterNodeEvent(handle_, NODE_TOUCH_EVENT);
        }
        if (onDisappear_) {
            nativeModule_->unregisterNodeEvent(handle_, NODE_EVENT_ON_DISAPPEAR);
        }
        if (onAppear_) {
            nativeModule_->unregisterNodeEvent(handle_, NODE_EVENT_ON_APPEAR);
        }
        nativeModule_->removeNodeEventReceiver(handle_, ArkUINode::NodeEventReceiver);
    }

    void SetWidth(float width);

    void SetPercentWidth(float percent);

    void SetHeight(float height);

    void SetPercentHeight(float percent);

    void SetBackgroundColor(uint32_t color);

    // Handle general events.
    void RegisterOnClick(const std::function<void()> &onClick);

    // Node disappearance event.
    void RegisterOnDisappear(const std::function<void()> &onDisappear);

    // Node occurrence event.
    void RegisterOnAppear(const std::function<void()> &onAppear);

protected:
    // Pointer to the event listener function.
    static void NodeEventReceiver(ArkUI_NodeEvent *event);

    void ProcessNodeEvent(ArkUI_NodeEvent *event);

    virtual void OnNodeEvent(ArkUI_NodeEvent *event) {}

    void OnAddChild(const std::shared_ptr<ArkUIBaseNode> &child) override;

    void OnRemoveChild(const std::shared_ptr<ArkUIBaseNode> &child) override;

    void OnInsertChild(const std::shared_ptr<ArkUIBaseNode> &child, int32_t index) override;

private:
    std::function<void()> onClick_;
    std::function<void()> onDisappear_;
    std::function<void()> onAppear_;
    std::function<void(int32_t type, float x, float y)> onTouch_;
};
} // namespace NativeModule

#endif // NDKCREATEUI_ARKUINODE_H