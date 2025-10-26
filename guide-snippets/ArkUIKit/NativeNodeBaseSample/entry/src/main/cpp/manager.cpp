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
#include "GridMaker.h"
#include "TextMaker.h"
#include "SwiperMaker.h"
#include "AccessibilityMaker.h"
#include "EmbeddedComponentMaker.h"
#include "WaterFlowMaker.h"
#include "ScrollMaker.h"
#include "RefreshMaker.h"
#include "ListMaker.h"
#include "PublicEvent.h"
#include "baseUtils.h"
#include "napi/native_api.h"
#include "XComponentMaker.h"
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <arkui/native_interface.h>
#include <arkui/native_node.h>
#include <arkui/native_node_napi.h>
#include <arkui/native_type.h>
#include <hilog/log.h>
#include <string>

namespace ConstIde {
const uint32_t NUMBER_0 = 0;
const uint32_t NUMBER_1 = 1;
const uint32_t NUMBER_2 = 2;
const uint32_t MARGIN_NUMBER_30 = 30;
constexpr const char *K_LOG_DOMAIN = "Manager";
} // namespace ConstIde

Manager Manager::manager_;
ArkUI_NativeNodeAPI_1 *Manager::nodeAPI_ = reinterpret_cast<ArkUI_NativeNodeAPI_1 *>(
    OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_NODE, "ArkUI_NativeNodeAPI_1"));

template <class MakeNodeFn>
static napi_value CreateNativeNode(napi_env env, napi_callback_info info, const char *who, MakeNodeFn makeNodeFn)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, ConstIde::K_LOG_DOMAIN, "%{public}s BEGIN", who);

    if ((env == nullptr) || (info == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, ConstIde::K_LOG_DOMAIN, "%{public}s env or info is null",
                     who);
        return nullptr;
    }

    size_t argc = ConstIde::NUMBER_1;
    napi_value args[ConstIde::NUMBER_1] = {nullptr};
    napi_status st = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (st != napi_ok || argc < ConstIde::NUMBER_1) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, ConstIde::K_LOG_DOMAIN, "%{public}s napi_get_cb_info failed",
                     who);
        return nullptr;
    }

    ArkUI_NodeContentHandle nodeContentHandle = nullptr;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[ConstIde::NUMBER_0], &nodeContentHandle);
    if (nodeContentHandle == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, ConstIde::K_LOG_DOMAIN,
                     "%{public}s nodeContentHandle is null", who);
        return nullptr;
    }

    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, ConstIde::K_LOG_DOMAIN, "%{public}s after GetNodeContent", who);
    
    if (Manager::nodeAPI_ == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, ConstIde::K_LOG_DOMAIN, "%{public}s nodeAPI_ is null", who);
        return nullptr;
    }

    // 构建具体节点 & 挂载
    ArkUI_NodeHandle page = makeNodeFn();
    if (page == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, ConstIde::K_LOG_DOMAIN, "%{public}s makeNodeFn return null",
                     who);
        return nullptr;
    }

    OH_ArkUI_NodeContent_AddNode(nodeContentHandle, page);
    return nullptr;
}

napi_value Manager::CreateSwiperNativeNode(napi_env env, napi_callback_info info)
{
    return CreateNativeNode(env, info, "CreateNativeSwiperNode",
                            []() -> ArkUI_NodeHandle { return SwiperMaker::createSwiperPage(); });
}

napi_value Manager::CreateNativeTextNode(napi_env env, napi_callback_info info)
{
    return CreateNativeNode(env, info, "CreateNativeTextNode",
                            []() -> ArkUI_NodeHandle { return TextMaker::createTextPage(); });
}

napi_value Manager::CreateNativeAccessibilityNode(napi_env env, napi_callback_info info)
{
    return CreateNativeNode(env, info, "CreateNativeAccessibilityNode",
                            []() -> ArkUI_NodeHandle { return AccessibilityMaker::CreateNativeNode(); });
}

napi_value Manager::CreateNativeEmbeddedComponentNode(napi_env env, napi_callback_info info)
{
    return CreateNativeNode(env, info, "CreateNativeEmbeddedComponentNode",
                            []() -> ArkUI_NodeHandle { return EmbeddedComponentMaker::CreateNativeNode(); });
}

napi_value Manager::CreateWaterFlowNativeNode(napi_env env, napi_callback_info info)
{
    return CreateNativeNode(env, info, "CreateWaterFlowNativeNode",
                            []() -> ArkUI_NodeHandle { return WaterFlowMaker::CreateNativeNode(); });
}

napi_value Manager::CreateGridNativeNode(napi_env env, napi_callback_info info)
{
    return CreateNativeNode(env, info, "CreateGridNativeNode",
                            []() -> ArkUI_NodeHandle { return GridMaker::CreateNativeNode(); });
}

napi_value Manager::CreateScrollNativeNode(napi_env env, napi_callback_info info)
{
    return CreateNativeNode(env, info, "CreateScrollNativeNode",
                            []() -> ArkUI_NodeHandle { return ScrollMaker::CreateNativeNode(); });
}

napi_value Manager::CreateRefreshNativeNode(napi_env env, napi_callback_info info)
{
    return CreateNativeNode(env, info, "CreateRefreshNativeNode",
                            []() -> ArkUI_NodeHandle { return RefreshMaker::CreateNativeNode(); });
}

napi_value Manager::CreateListNativeNode(napi_env env, napi_callback_info info)
{
    return CreateNativeNode(env, info, "CreateListNativeNode",
                            []() -> ArkUI_NodeHandle { return ListMaker::CreateNativeNode(); });
}

napi_value Manager::CreatePublicNativeNode(napi_env env, napi_callback_info info)
{
        return CreateNativeNode(
            env, info, "CreatePublicNativeNode",
            []() -> ArkUI_NodeHandle { return PublicMaker::CreateNativeNode(); });
}

ArkUI_NativeNodeAPI_1 *Manager::XnodeAPI = reinterpret_cast<ArkUI_NativeNodeAPI_1 *>(
        OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_NODE, "ArkUI_NativeNodeAPI_1"));

napi_value Manager::createNativeXComponentNode(napi_env env, napi_callback_info info)
{
    OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Manager", "CreateNativeNode BEGIN");
    if ((env == nullptr) || (info == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Manager", "CreateNativeNode env or info is null");
        return nullptr;
    }
    
    size_t argc = 2;
    napi_value args[2] = {nullptr, nullptr};
    if (napi_get_cb_info(env, info, &argc, args, nullptr, nullptr) != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Manager", "CreateNativeNode napi_get_cb_info failed");
    }
    
    if (argc != 1 + 1) {
        napi_throw_type_error(env, NULL, "Wrong number of arguments");
        return nullptr;
    }
    ArkUI_NodeContentHandle nodeContentHandle_ = nullptr;
    int32_t ret = OH_ArkUI_NodeContent_SetUserData(nodeContentHandle_,
                                                   new int32_t(123));
    void *userDataNull =
        OH_ArkUI_NodeContent_GetUserData(nodeContentHandle_); // 非法获取，返回空指针
    
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &nodeContentHandle_);
    
    if (XnodeAPI == nullptr) {
        return nullptr;
    }
    if (XnodeAPI->createNode == nullptr || XnodeAPI->addChild == nullptr) {
        return nullptr;
    }
    auto nodeContentEvent = [](ArkUI_NodeContentEvent *event) {
        ArkUI_NodeContentHandle handle = OH_ArkUI_NodeContentEvent_GetNodeContentHandle(event);
        std::string *userData = reinterpret_cast<std::string *>(OH_ArkUI_NodeContent_GetUserData(handle));
        if (OH_ArkUI_NodeContentEvent_GetEventType(event) == NODE_CONTENT_EVENT_ON_ATTACH_TO_WINDOW) {
            ArkUI_NodeHandle testNode;
            if (userData) {
                testNode = XComponentMaker::CreateNodeHandle(*userData);
            } else {
                testNode = XComponentMaker::CreateNodeHandle("noUserData");
            }
            OH_ArkUI_NodeContent_InsertNode(handle, testNode, 0); // 接口使用示例
            OH_ArkUI_NodeContent_RemoveNode(handle, testNode);
            OH_ArkUI_NodeContent_AddNode(handle, testNode);
        } else {
            if (userData) {
                delete userData;
                userData = nullptr;
            }
        }
    };
    OH_ArkUI_NodeContent_RegisterCallback(nodeContentHandle_, nodeContentEvent);

    return nullptr;
}