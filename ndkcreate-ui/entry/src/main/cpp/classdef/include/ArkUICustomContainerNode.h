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

#ifndef NDKCREATEUI_ARKUICUSTOMCONTAINERNODE_H
#define NDKCREATEUI_ARKUICUSTOMCONTAINERNODE_H

#include <cstdint>
#include "ArkUINode.h"

namespace NativeModule {
class ArkUICustomContainerNode : public ArkUINode {
public:
    // Create a component using the custom component type ARKUI-Node_CUSTOM.
    ArkUICustomContainerNode()
        : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_CUSTOM))
    {
        // Register custom component listener.
        nativeModule_->addNodeCustomEventReceiver(handle_, OnStaticCustomEvent);
        // Declare custom events and pass themselves as custom data
        nativeModule_->registerNodeCustomEvent(handle_, ARKUI_NODE_CUSTOM_EVENT_ON_MEASURE, 0, this);
        nativeModule_->registerNodeCustomEvent(handle_, ARKUI_NODE_CUSTOM_EVENT_ON_LAYOUT, 0, this);
    }

    ~ArkUICustomContainerNode() override
    {
        // Anti registration custom event listener.
        nativeModule_->addNodeCustomEventReceiver(handle_, OnStaticCustomEvent);
        // Cancel declaring custom events.
        nativeModule_->unregisterNodeCustomEvent(handle_, ARKUI_NODE_CUSTOM_EVENT_ON_MEASURE);
        nativeModule_->unregisterNodeCustomEvent(handle_, ARKUI_NODE_CUSTOM_EVENT_ON_LAYOUT);
    }

private:
    static void OnStaticCustomEvent(ArkUI_NodeCustomEvent *event);

    // Custom calculation logic
    void OnMeasure(ArkUI_NodeCustomEvent *event);

    void OnLayout(ArkUI_NodeCustomEvent *event);

    int32_t padding_ = 100;
    int32_t MAX_HEIGHT = 1000;
    int32_t MAX_WIDTH = 1000;
    int32_t MIN_HEIGHT = 0;
    int32_t MIN_WIDTH = 0;
    int32_t SIDES_COUNT = 2;
};
} // namespace NativeModule

#endif // NDKCREATEUI_ARKUICUSTOMCONTAINERNODE_H