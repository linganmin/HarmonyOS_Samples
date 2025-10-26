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

#ifndef NDKCREATEUI_ARKUIBASENODE_H
#define NDKCREATEUI_ARKUIBASENODE_H

#include <arkui/native_type.h>
#include <list>
#include <memory>
#include "NativeModuleInstance.h"

namespace NativeModule {
class ArkUIBaseNode {
public:
    explicit ArkUIBaseNode(ArkUI_NodeHandle handle)
        : handle_(handle), nativeModule_(NativeModuleInstance::GetInstance()->GetNativeNodeAPI()) {}

    virtual ~ArkUIBaseNode()
    {
        // Encapsulate destructor to implement the function of removing child nodes.
        if (!children_.empty()) {
            for (const auto &child : children_) {
                nativeModule_->removeChild(handle_, child->GetHandle());
            }
            children_.clear();
        }
        // Encapsulate destructors to uniformly recycle node resources.
        nativeModule_->disposeNode(handle_);
    }

    void AddChild(const std::shared_ptr<ArkUIBaseNode> &child);

    std::list<std::shared_ptr<ArkUIBaseNode>> GetChildren();

    ArkUI_NodeHandle GetHandle() const;

protected:
    virtual void OnAddChild(const std::shared_ptr<ArkUIBaseNode> &child) {}
    virtual void OnRemoveChild(const std::shared_ptr<ArkUIBaseNode> &child) {}
    virtual void OnInsertChild(const std::shared_ptr<ArkUIBaseNode> &child, int32_t index) {}

    ArkUI_NodeHandle handle_;
    ArkUI_NativeNodeAPI_1 *nativeModule_ = nullptr;

private:
    std::list<std::shared_ptr<ArkUIBaseNode>> children_;
};
} // namespace NativeModule

#endif // NDKCREATEUI_ARKUIBASENODE_H