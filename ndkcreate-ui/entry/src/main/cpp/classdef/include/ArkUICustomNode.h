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

#ifndef NDKCREATEUI_ARKUICUSTOMNODE_H
#define NDKCREATEUI_ARKUICUSTOMNODE_H

#include <cstdint>
#include "ArkUINode.h"

namespace NativeModule {
class ArkUICustomNode : public ArkUINode {
public:
    static constexpr double ONE_FOURTH = 0.25;
    static constexpr double THREE_FOURTHS = 0.75;
    
    // Create a component using the custom component type ARKUI-Node_CUSTOM.
    ArkUICustomNode()
        : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_CUSTOM))
    {
        // Register a custom event listener.
        nativeModule_->addNodeCustomEventReceiver(handle_, OnStaticCustomEvent);
        // Declare custom events and pass themselves as custom data.
        nativeModule_->registerNodeCustomEvent(handle_, ARKUI_NODE_CUSTOM_EVENT_ON_DRAW, 0, this);
    }

    ~ArkUICustomNode() override
    {
        // Anti registration custom event listener.
        nativeModule_->removeNodeCustomEventReceiver(handle_, OnStaticCustomEvent);
        // Cancel declaring custom events.
        nativeModule_->unregisterNodeCustomEvent(handle_, ARKUI_NODE_CUSTOM_EVENT_ON_DRAW);
    }

    void SetRectColor(uint32_t color);

private:
    static void OnStaticCustomEvent(ArkUI_NodeCustomEvent *event);

    // Customize drawing logic.
    void OnDraw(ArkUI_NodeCustomEvent *event);

    uint32_t color_ = 0xFFFFE4B5;
};
} // namespace NativeModule

#endif // NDKCREATEUI_ARKUICUSTOMNODE_H