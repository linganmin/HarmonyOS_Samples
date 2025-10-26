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

#ifndef NDKCREATEUI_ARKUILISTNODE_H
#define NDKCREATEUI_ARKUILISTNODE_H

#include "ArkUIListItemAdapter.h"
#include "ArkUINode.h"

namespace NativeModule {
class ArkUIListNode : public ArkUINode {
public:
    ArkUIListNode()
        : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_LIST)) {}

    ~ArkUIListNode() override
    {
        nativeModule_->unregisterNodeEvent(handle_, NODE_LIST_ON_SCROLL_INDEX);
        if (adapter_) {
            // Uninstall UI components under adapter during analysis.
            nativeModule_->resetAttribute(handle_, NODE_LIST_NODE_ADAPTER);
            adapter_.reset();
        }
    }
    
    // Scroll the control list to the specified offset element.
    void ScrollToIndex(int32_t index);

    // Registration list related events.
    void RegisterOnScrollIndex(const std::function<void(int32_t index)> &onScrollIndex);

    // Introduce lazy loading module.
    void SetLazyAdapter(const std::shared_ptr<ArkUIListItemAdapter> &adapter);

protected:
    // Handle List related events.
    void OnNodeEvent(ArkUI_NodeEvent *event) override;

private:
    std::function<void(int32_t index)> onScrollIndex_;
    std::shared_ptr<ArkUIListItemAdapter> adapter_;
};
} // namespace NativeModule

#endif // NDKCREATEUI_ARKUILISTNODE_H