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

#ifndef NDKCREATEUI_NATIVEENTRY_H
#define NDKCREATEUI_NATIVEENTRY_H

#include <arkui/native_node_napi.h>
#include "ArkUIBaseNode.h"

namespace NativeModule {
// Manage the lifecycle and memory of native components.
class NativeEntry {
public:
    // Set handle content.
    void SetContentHandle(ArkUI_NodeContentHandle handle) { handle_ = handle; }

    void SetRootNode(const std::shared_ptr<ArkUIBaseNode> &baseNode)
    {
        root_ = baseNode;
        // Add Native components to NodeContent for mounting display.
        OH_ArkUI_NodeContent_AddNode(handle_, root_->GetHandle());
    }

    void DisposeRootNode()
    {
        // Uninstall components from NodeContent and destroy native components.
        OH_ArkUI_NodeContent_RemoveNode(handle_, root_->GetHandle());
        root_.reset();
    }

private:
    std::shared_ptr<ArkUIBaseNode> root_;
    ArkUI_NodeContentHandle handle_;
};
} // namespace NativeModule

#endif // NDKCREATEUI_NATIVEENTRY_H