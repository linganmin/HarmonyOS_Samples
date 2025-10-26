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

#include "manager.h"
#include "ArkUIAnimationNode.h"
#include "ArkUIVisualEffectsNode.h"
#include "NavigationContext.h"
#include "napi/native_api.h"
#include <arkui/native_interface.h>
#include <arkui/native_node.h>
#include <arkui/native_node_napi.h>
#include <arkui/native_type.h>
#include <cstring>
#include <hilog/log.h>
#include <arkui/native_node_napi.h>
#include <js_native_api.h>

Manager Manager::manager_;
ArkUI_NativeNodeAPI_1 *Manager::nodeAPI_ = reinterpret_cast<ArkUI_NativeNodeAPI_1*>(
    OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_NODE, "ArkUI_NativeNodeAPI_1"));

napi_value Manager::CreateNativeNaviNode(napi_env env, napi_callback_info info)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Manager", "CreateNativeNode BEGIN");
    if ((env == nullptr) || (info == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Manager", "CreateNativeNode env or info is null");
        return nullptr;
    }
    size_t argCnt = 1;
    napi_value args[1] = {nullptr};
    if (napi_get_cb_info(env, info, &argCnt, args, nullptr, nullptr) != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Manager", "CreateNativeNode napi_get_cb_info failed");
    }

    ArkUI_NodeContentHandle nodeContentHandle = nullptr;

    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &nodeContentHandle);

    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Manager", "OH_ArkUI_GetBasicNodeAPI after");
    if (nodeAPI_ != nullptr) {
        if (nodeAPI_->createNode != nullptr && nodeAPI_->addChild != nullptr) {
            auto columnNode = Manager::nodeAPI_->createNode(ARKUI_NODE_COLUMN);
            OH_ArkUI_NodeContent_AddNode(nodeContentHandle, columnNode);
            OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Manager",
                         "******************NavigationInfoTest******************");
            NavigationContext::NavigationInfoTest1(columnNode);
            NavigationContext::NavigationInfoTest2(columnNode);
            OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Manager",
                         "******************RouterPageInfoTest******************");
            NavigationContext::RouterPageInfoTest(columnNode);
        }
    }
    return nullptr;
}

napi_value Manager::ProcessDrawable(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    // 获取JS层传入的参数
    napi_status status = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (status != napi_ok || argc < 1) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Manager", "获取参数失败");
        return nullptr;
    }
    napi_value resourceValue = args[0];  // 这是ArkTS侧传入的Resource对象
    // 核心接口：将napi_value转换为DrawableDescriptor
    ArkUI_DrawableDescriptor* drawable = nullptr;
    int32_t res = OH_ArkUI_GetDrawableDescriptorFromNapiValue(env, resourceValue, &drawable);
    // 处理转换结果
    if (res != ArkUI_ErrorCode::ARKUI_ERROR_CODE_NO_ERROR) {
        // 转换失败：根据错误码处理（参数无效等）
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Manager", "Failed to get drawable descriptor");
        napi_throw_error(env, nullptr, "Failed to get drawable descriptor");
        return nullptr;
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Manager", "success to get drawable descriptor");
    // 返回处理结果给JS层
    napi_value result;
    napi_create_int32(env, res, &result);
    return result;
}

napi_value Manager::ProcessDrawable2(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    // 获取JS层传入的参数
    napi_status status = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (status != napi_ok || argc < 1) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Manager", "获取参数失败");
        return nullptr;
    }
    napi_value resourceValue = args[0];  // 这是ArkTS侧传入的Resource对象
    // 核心接口：将napi_value转换为DrawableDescriptor
    ArkUI_DrawableDescriptor* drawable = nullptr;
    int32_t res = OH_ArkUI_GetDrawableDescriptorFromResourceNapiValue (env, resourceValue, &drawable);
    // 3. 处理转换结果
    if (res != ArkUI_ErrorCode::ARKUI_ERROR_CODE_NO_ERROR) {
        // 转换失败：根据错误码处理（参数无效等）
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Manager", "Failed to get drawable descriptor");
        return nullptr;
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Manager", "success to get drawable descriptor");
    // 返回处理结果给JS层
    napi_value result;
    napi_create_int32(env, res, &result);
    return result;
}

napi_value createNativeRootAnimation1(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateAnimationFrameNode1();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootAnimation2(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateAnimationFrameNode2();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootAnimation3(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateAnimationFrameNode3();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootAnimation4(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateAnimationFrameNode4();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootAnimation5(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateAnimationFrameNode5();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootVisualEffects1(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateVisualEffectsFrameNode1();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootVisualEffects2(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateVisualEffectsFrameNode2();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootVisualEffects3(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateVisualEffectsFrameNode3();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootVisualEffects4(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateVisualEffectsFrameNode4();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootVisualEffects5(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateVisualEffectsFrameNode5();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootVisualEffects6(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateVisualEffectsFrameNode6();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootVisualEffects7(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateVisualEffectsFrameNode7();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootVisualEffects8(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateVisualEffectsFrameNode8();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootVisualEffects9(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateVisualEffectsFrameNode9();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value createNativeRootVisualEffects10(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    Manager::GetInstance()->SetContentHandle(contentHandle);
    
    auto column = NativeModule::CreateVisualEffectsFrameNode10();
    Manager::GetInstance()->SetRootNode(column);
    return nullptr;
}

napi_value DestroyNativeRoot(napi_env env, napi_callback_info info)
{
    Manager::GetInstance()->DisposeRootNode();
    return nullptr;
}