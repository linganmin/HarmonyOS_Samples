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

#include "imagespan_manager.h"
#include "manager.h"
#include "form_manager.h"
#include <hilog/log.h>

napi_property_descriptor desc[] = {
    {"createNativeTextNode", nullptr, Manager::CreateNativeTextNode, nullptr, nullptr, nullptr, napi_default, nullptr},
    {"createSwiperNativeNode", nullptr, Manager::CreateSwiperNativeNode, nullptr, nullptr, nullptr, napi_default,
     nullptr},
    {"createWaterFlowNativeNode", nullptr, Manager::CreateWaterFlowNativeNode, nullptr, nullptr, nullptr, napi_default,
     nullptr},
    {"createGridNativeNode", nullptr, Manager::CreateGridNativeNode, nullptr, nullptr, nullptr, napi_default, nullptr},
    {"createScrollNativeNode", nullptr, Manager::CreateScrollNativeNode, nullptr, nullptr, nullptr, napi_default,
     nullptr},
    {"createRefreshNativeNode", nullptr, Manager::CreateRefreshNativeNode, nullptr, nullptr, nullptr, napi_default,
     nullptr},
    {"createListNativeNode", nullptr, Manager::CreateListNativeNode, nullptr, nullptr, nullptr, napi_default, nullptr},
    {"CreatePublicNativeNode", nullptr, Manager::CreatePublicNativeNode, nullptr, nullptr, nullptr, napi_default,
     nullptr},
    {"createNativeNodexc", nullptr, Manager::createNativeXComponentNode, nullptr, nullptr, nullptr, napi_default,
     nullptr},
    {"createFormPage", nullptr, NativeNode::Form::TransTool::CreateFormPage, nullptr, nullptr, nullptr, napi_default,
     nullptr},
    {"createFormNode", nullptr, NativeNode::Form::TransTool::CreateFormNode, nullptr, nullptr, nullptr, napi_default,
     nullptr},
    {"setFormAttribute", nullptr, NativeNode::Form::TransTool::SetFormAttribute, nullptr, nullptr, nullptr,
     napi_default, nullptr},
    {"getFormAttribute", nullptr, NativeNode::Form::TransTool::GetFormAttribute, nullptr, nullptr, nullptr,
     napi_default, nullptr},
    {"resetFormAttribute", nullptr, NativeNode::Form::TransTool::ResetFormAttribute, nullptr, nullptr, nullptr,
     napi_default, nullptr},
    {"removeFormNode", nullptr, NativeNode::Form::TransTool::RemoveFormNode, nullptr, nullptr, nullptr, napi_default,
     nullptr},
    // 参考新增其他createNative方法和Maker类
    {"createImageSpanPage", nullptr, NativeNode::ImageSpan::TransTool::CreateImageSpanPage, nullptr, nullptr,
     nullptr, napi_default, nullptr},
    {"createImageSpanNode", nullptr, NativeNode::ImageSpan::TransTool::CreateImageSpanNode, nullptr, nullptr,
    nullptr, napi_default, nullptr},
    {"removeImageSpanNode", nullptr, NativeNode::ImageSpan::TransTool::RemoveImageSpanNode, nullptr, nullptr,
     nullptr, napi_default, nullptr},
    {"setImageSpanAttribute", nullptr, NativeNode::ImageSpan::TransTool::SetImageSpanAttribute, nullptr, nullptr,
     nullptr, napi_default, nullptr},
    {"resetImageSpanAttribute", nullptr, NativeNode::ImageSpan::TransTool::ResetImageSpanAttribute, nullptr,
     nullptr, nullptr, napi_default, nullptr},
    {"getImageSpanAttribute", nullptr, NativeNode::ImageSpan::TransTool::GetImageSpanAttribute, nullptr, nullptr,
     nullptr, napi_default, nullptr},
};

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Init", "Init begins");
    if ((env == nullptr) || (exports == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Init", "env or exports is null");
        return nullptr;
    }

    if (napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc) != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Init", "napi_define_properties failed");
        return nullptr;
    }
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&demoModule); }