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

#ifndef MYAPPLICATION_ARKUICOLUMNNODE_H
#define MYAPPLICATION_ARKUICOLUMNNODE_H

#include "ArkUINode.h"
namespace NativeModule {
class ArkUIColumnNode : public ArkUINode {
public:
    // 创建ArkUI的列表组件
    ArkUIColumnNode()
        : ArkUINode((NativeModuleInstance::GetInstance()->GetNativeNodeAPI())->createNode(ARKUI_NODE_COLUMN)) {}

    ~ArkUIColumnNode() override {}
};
} // namespace NativeModule

#endif // MYAPPLICATION_ARKUICOLUMNNODE_H