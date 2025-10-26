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

#include <string>
#include "ArkUIButtonNode.h"

namespace NativeModule {
// Text attribute NDK interface encapsulation.
void ArkUIButtonNode::SetFontSize(float fontSize)
{
    assert(handle_);
    ArkUI_NumberValue value[] = {{.f32 = fontSize}};
    ArkUI_AttributeItem item = {value, 1};
    nativeModule_->setAttribute(handle_, NODE_FONT_SIZE, &item);
}

void ArkUIButtonNode::SetFontColor(uint32_t color)
{
    assert(handle_);
    ArkUI_NumberValue value[] = {{.u32 = color}};
    ArkUI_AttributeItem item = {value, 1};
    nativeModule_->setAttribute(handle_, NODE_FONT_COLOR, &item);
}

void ArkUIButtonNode::SetTextContent(const std::string &content)
{
    assert(handle_);
    ArkUI_AttributeItem item = {nullptr, 0, content.c_str()};
    nativeModule_->setAttribute(handle_, NODE_BUTTON_LABEL, &item);
}

void ArkUIButtonNode::SetTextAlign(ArkUI_TextAlignment align)
{
    assert(handle_);
    ArkUI_NumberValue value[] = {{.i32 = align}};
    ArkUI_AttributeItem item = {value, 1};
    nativeModule_->setAttribute(handle_, NODE_TEXT_ALIGN, &item);
}
// [Start button_api]
void ArkUIButtonNode::SetButtonType(int32_t buttonType)
{
    assert(handle_);
    ArkUI_NumberValue value[] = {{.i32 = buttonType}};
    ArkUI_AttributeItem item = {value, 1};
    nativeModule_->setAttribute(handle_, NODE_BUTTON_TYPE , &item);
}
// [End button_api]
} // namespace NativeModule