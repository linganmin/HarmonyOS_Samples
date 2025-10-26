/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License")
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

#ifndef NATIVE_NODE_NAPI_SAMPLE_MANAGER_H
#define NATIVE_NODE_NAPI_SAMPLE_MANAGER_H

#include "ArkUIBaseNode.h"
#include <arkui/native_interface.h>
#include <arkui/native_node.h>
#include <arkui/native_node_napi.h>
#include <arkui/native_type.h>
#include <hilog/log.h>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <napi/native_api.h>

napi_value createNativeRootAnimation1(napi_env env, napi_callback_info info);
napi_value createNativeRootAnimation2(napi_env env, napi_callback_info info);
napi_value createNativeRootAnimation3(napi_env env, napi_callback_info info);
napi_value createNativeRootAnimation4(napi_env env, napi_callback_info info);
napi_value createNativeRootAnimation5(napi_env env, napi_callback_info info);
napi_value createNativeRootVisualEffects1(napi_env env, napi_callback_info info);
napi_value createNativeRootVisualEffects2(napi_env env, napi_callback_info info);
napi_value createNativeRootVisualEffects3(napi_env env, napi_callback_info info);
napi_value createNativeRootVisualEffects4(napi_env env, napi_callback_info info);
napi_value createNativeRootVisualEffects5(napi_env env, napi_callback_info info);
napi_value createNativeRootVisualEffects6(napi_env env, napi_callback_info info);
napi_value createNativeRootVisualEffects7(napi_env env, napi_callback_info info);
napi_value createNativeRootVisualEffects8(napi_env env, napi_callback_info info);
napi_value createNativeRootVisualEffects9(napi_env env, napi_callback_info info);
napi_value createNativeRootVisualEffects10(napi_env env, napi_callback_info info);
napi_value DestroyNativeRoot(napi_env env, napi_callback_info info);

const unsigned int LOG_PRINT_DOMAIN = 0xFF00;
const int32_t CNT_NUMBER = 1;
class Manager {
public:
    static ArkUI_NativeNodeAPI_1 *nodeAPI_;
    ~Manager(){};
    
    static Manager *GetInstance()
    {
        static Manager nativeEntry;
        return &nativeEntry;
    }

    void SetContentHandle(ArkUI_NodeContentHandle handle)
    {
        handle_ = handle;
    }

    void SetRootNode(const std::shared_ptr<NativeModule::ArkUIBaseNode> &baseNode)
    {
        cnt++;
        root_ = baseNode;
        OH_ArkUI_NodeContent_AddNode(handle_, root_->GetHandle());
    }
    void DisposeRootNode()
    {
        if (cnt != CNT_NUMBER) {
            cnt--;
            return;
        }
        OH_ArkUI_NodeContent_RemoveNode(handle_, root_->GetHandle());
        root_.reset();
    }
    
    static napi_value CreateNativeNaviNode(napi_env env, napi_callback_info info);
    static napi_value ProcessDrawable(napi_env env, napi_callback_info info);
    static napi_value ProcessDrawable2(napi_env env, napi_callback_info info);
private:
    int32_t cnt = 0;
    static Manager manager_;
    std::shared_ptr<NativeModule::ArkUIBaseNode> root_;
    ArkUI_NodeContentHandle handle_;
};

#endif // NATIVE_NODE_NAPI_SAMPLE_MANAGER_H
