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

#ifndef NDKCREATEUI_ARKUILISTITEMNODE_H
#define NDKCREATEUI_ARKUILISTITEMNODE_H

#include "ArkUINode.h"

namespace NativeModule {
class ArkUIListItemNode : public ArkUINode {
public:
    ArkUIListItemNode()
        : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_LIST_ITEM)) {}

    ~ArkUIListItemNode()
    {
        if (swipeAction_) {
            OH_ArkUI_ListItemSwipeActionOption_Dispose(swipeAction_);
        }
        if (swipeItem_) {
            OH_ArkUI_ListItemSwipeActionItem_Dispose(swipeItem_);
        }
    }

    void SetSwiperAction(std::shared_ptr<ArkUINode> node);

    std::shared_ptr<ArkUINode> GetSwipeContent() const;

private:
    ArkUI_ListItemSwipeActionOption *swipeAction_ = nullptr;
    ArkUI_ListItemSwipeActionItem *swipeItem_ = nullptr;
    std::shared_ptr<ArkUINode> swipeContent_ = nullptr;
};
} // namespace NativeModule

#endif // NDKCREATEUI_ARKUILISTITEMNODE_H