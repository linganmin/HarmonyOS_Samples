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
#ifndef CAPI_MANAGER_H
#define CAPI_MANAGER_H

#include <functional>
#include <arkui/native_node.h>
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <unordered_map>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <napi/native_api.h>


namespace NativeNode::Manager {
using EventCallback = std::function<void(ArkUI_NodeEvent*)>;

class NodeManager {
public:
    ~NodeManager() = default;
    static NodeManager& GetInstance();
    void SetContentHandle(ArkUI_NodeContentHandle contentHandle);
    void CreateNativeNode();
    void CreateUintNativeNode(napi_env env, napi_callback_info info);
private:
    NodeManager() = default;
    ArkUI_NodeContentHandle contentHandle_;
    std::unordered_map<int32_t, EventCallback> callbackMap_;
};
}

#endif //CAPI_MANAGER_H
