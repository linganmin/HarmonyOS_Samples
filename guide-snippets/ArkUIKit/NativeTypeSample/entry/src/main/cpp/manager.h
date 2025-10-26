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
#include <arkui/native_dialog.h>
#include <hilog/log.h>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include <napi/native_api.h>
#include <string>

const unsigned int LOG_PRINT_DOMAIN = 0xFF00;
napi_value createNativeRootAnimation1(napi_env env, napi_callback_info info);
napi_value createNativeRootAnimation2(napi_env env, napi_callback_info info);
napi_value createNativeRootAnimation3(napi_env env, napi_callback_info info);
napi_value createNativeRootAnimation4(napi_env env, napi_callback_info info);
napi_value createNativeRootAnimation5(napi_env env, napi_callback_info info);
napi_value createNativeRootVisualEffects1(napi_env env, napi_callback_info info);
napi_value createNativeRootVisualEffects2(napi_env env, napi_callback_info info);
napi_value createNativeRootVisualEffects3(napi_env env, napi_callback_info info);
napi_value DestroyNativeRoot(napi_env env, napi_callback_info info);

class Manager {
public:
    static ArkUI_NativeNodeAPI_1 *nodeAPI_;
    static ArkUI_NativeNodeAPI_1 *XnodeAPI;
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
        root_ = baseNode;
        OH_ArkUI_NodeContent_AddNode(handle_, root_->GetHandle());
    }
    void DisposeRootNode()
    {
        OH_ArkUI_NodeContent_RemoveNode(handle_, root_->GetHandle());
        root_.reset();
    }

    static napi_value CreateNativeSwiperNode(napi_env env, napi_callback_info info);
    static napi_value CreateNativeTextNode(napi_env env, napi_callback_info info);
    static napi_value CreateNativeAccessibilityNode(napi_env env, napi_callback_info info);
    static napi_value CreateNativeEmbeddedComponentNode(napi_env env, napi_callback_info info);
    static napi_value CreateWaterFlowNativeNode(napi_env env, napi_callback_info info);
    static napi_value CreateGridNativeNode(napi_env env, napi_callback_info info);
    static napi_value CreateScrollNativeNode(napi_env env, napi_callback_info info);
    static napi_value CreateRefreshNativeNode(napi_env env, napi_callback_info info);
    static napi_value CreateListNativeNode(napi_env env, napi_callback_info info);
    static napi_value createNativeXComponentNode(napi_env env, napi_callback_info info);
    static napi_value CreateNativeButtonNode(napi_env env, napi_callback_info info);
    static napi_value CreateNativeSliderNode(napi_env env, napi_callback_info info);
    static napi_value CreateNativeCheckboxShapePage(napi_env env, napi_callback_info info);
    static napi_value CreateHoverModeAreaTypePage(napi_env env, napi_callback_info info);
    static napi_value createPublicNativeNode(napi_env env, napi_callback_info info);

private:
    static Manager manager_;
    std::shared_ptr<NativeModule::ArkUIBaseNode> root_;
    ArkUI_NodeContentHandle handle_;
};

#endif // NATIVE_NODE_NAPI_SAMPLE_MANAGER_H
