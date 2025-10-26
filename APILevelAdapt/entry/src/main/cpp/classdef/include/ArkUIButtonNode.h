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

#ifndef NDKCREATEUI_ARKUI_BUTTON_H
#define NDKCREATEUI_ARKUI_BUTTON_H

#include "ArkUINode.h"

namespace NativeModule {
class ArkUIButtonNode : public ArkUINode {
public:
    ArkUIButtonNode()
        : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_BUTTON)) {}

    // Text attribute NDK interface encapsulation.
    void SetFontSize(float fontSize);

    void SetFontColor(uint32_t color);

    void SetTextContent(const std::string &content);

    void SetTextAlign(ArkUI_TextAlignment align);
    
    void SetButtonType(int32_t buttonType);
};
} // namespace NativeModule

#endif // NDKCREATEUI_ARKUITEXTNODE_H