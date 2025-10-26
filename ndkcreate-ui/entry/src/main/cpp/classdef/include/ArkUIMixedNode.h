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

#ifndef NDKCREATEUI_ARKUIMIXEDNODE_H
#define NDKCREATEUI_ARKUIMIXEDNODE_H

#include <js_native_api.h>
#include "ArkUIBaseNode.h"
#include "NativeModuleInstance.h"

namespace NativeModule {
// Wrap ArkTS Node
class ArkUIMixedNode : public ArkUIBaseNode {
public:
    ArkUIMixedNode(ArkUI_NodeHandle handle, napi_env env, napi_ref componentContent)
        : ArkUIBaseNode(handle), env_(env), componentContent_(componentContent) {}

    // When base class parsing, it is necessary to release the mixed mode objects on the ArkTS side.
    ~ArkUIMixedNode() override { napi_delete_reference(env_, componentContent_); }

protected:
    napi_env env_;
    napi_ref componentContent_;
};
} // namespace NativeModule

#endif // NDKCREATEUI_ARKUIMIXEDNODE_H