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

#include <arkui/native_node_napi.h>
#include <hilog/log.h>
#include <napi/native_api.h>
#include "ArkUIMixedRefresh.h"

namespace NativeModule {
namespace {
napi_env g_env;
napi_ref g_createRefresh;
napi_ref g_updateRefresh;
} // namespace

// Create a data structure that interacts with the ArkTS side using the Napi interface for creating
// and updating Refresh components.
napi_value ArkUIMixedRefresh::CreateRefreshAttribute(const NativeRefreshAttribute &attribute, void *userData)
{
    napi_property_descriptor desc[] = {
        {"width", nullptr, nullptr, nullptr, nullptr, nullptr, napi_default, userData},
        {"height", nullptr, nullptr, nullptr, nullptr, nullptr, napi_default, userData},
        {"backgroundColor", nullptr, nullptr, nullptr, nullptr, nullptr, napi_default, userData},
        {"pullToRefresh", nullptr, nullptr, nullptr, nullptr, nullptr, napi_default, userData},
        {"isRefreshing", nullptr, nullptr, nullptr, nullptr, nullptr, napi_default, userData},
        {"refreshOffset", nullptr, nullptr, nullptr, nullptr, nullptr, napi_default, userData},
        {"onRefreshing", nullptr, nullptr, nullptr, nullptr, nullptr, napi_default, userData},
        {"onOffsetChange", nullptr, nullptr, nullptr, nullptr, nullptr, napi_default, userData},
    };
    
    SetDoubleValue(g_env, desc[0], attribute.width);
    SetDoubleValue(g_env, desc[1], attribute.height);
    SetUint32Value(g_env, desc[2], attribute.backgroundColor);
    SetInt32Value(g_env, desc[3], attribute.pullToRefresh);
    SetInt32Value(g_env, desc[4], attribute.isRefreshing);
    SetDoubleValue(g_env, desc[5], attribute.refreshOffset);
    SetOnRefreshingMethod(g_env, desc[6], userData);
    SetOnOffsetChangeMethod(g_env, desc[7], userData);

    napi_value refreshAttribute = nullptr;
    auto result = napi_create_object_with_properties(g_env, &refreshAttribute, sizeof(desc) / sizeof(desc[0]), desc);
    if (result != napi_ok) {
        return nullptr;
    }
    return refreshAttribute;
}

void ArkUIMixedRefresh::SetDoubleValue(napi_env env, napi_property_descriptor &desc,
                                       const std::optional<double> &value)
{
    if (value) {
        napi_value napiValue;
        napi_create_double(env, value.value(), &napiValue);
        desc.value = napiValue;
    }
}

void ArkUIMixedRefresh::SetUint32Value(napi_env env, napi_property_descriptor &desc,
                                       const std::optional<uint32_t> &value)
{
    if (value) {
        napi_value napiValue;
        napi_create_uint32(env, value.value(), &napiValue);
        desc.value = napiValue;
    }
}

void ArkUIMixedRefresh::SetInt32Value(napi_env env, napi_property_descriptor &desc,
                                      const std::optional<int32_t> &value)
{
    if (value) {
        napi_value napiValue;
        napi_create_int32(env, value.value(), &napiValue);
        desc.value = napiValue;
    }
}

void ArkUIMixedRefresh::SetOnRefreshingMethod(napi_env env, napi_property_descriptor &desc, void *userData)
{
    auto refresh = reinterpret_cast<ArkUIMixedRefresh *>(userData);
    if (refresh && refresh->attribute_.onRefreshing) {
        OH_LOG_INFO(LOG_APP, "onRefreshing start");
        desc.method = [](napi_env env, napi_callback_info info) -> napi_value {
            OH_LOG_INFO(LOG_APP, "onRefreshing callback");
            size_t argc = 0;
            napi_value args[0];
            void *data;
            napi_get_cb_info(env, info, &argc, args, nullptr, &data);
            auto refresh = reinterpret_cast<ArkUIMixedRefresh *>(data);
            if (refresh && refresh->attribute_.onRefreshing) {
                refresh->attribute_.onRefreshing();
            }
            return nullptr;
        };
        desc.data = userData;
    }
}

void ArkUIMixedRefresh::SetOnOffsetChangeMethod(napi_env env, napi_property_descriptor &desc, void *userData)
{
    auto refresh = reinterpret_cast<ArkUIMixedRefresh *>(userData);
    if (refresh && refresh->attribute_.onOffsetChange) {
        OH_LOG_INFO(LOG_APP, "onOffsetChange start");
        desc.method = [](napi_env env, napi_callback_info info) -> napi_value {
            OH_LOG_INFO(LOG_APP, "onOffsetChange callback");
            size_t argc = 1;
            napi_value args[1] = {nullptr};
            void *data;
            napi_get_cb_info(env, info, &argc, args, nullptr, &data);
            double offset = 0.0;
            napi_get_value_double(env, args[0], &offset);
            auto refresh = reinterpret_cast<ArkUIMixedRefresh *>(data);
            if (refresh && refresh->attribute_.onOffsetChange) {
                refresh->attribute_.onOffsetChange(offset);
            }
            return nullptr;
        };
        desc.data = userData;
    }
}

// Create components on the ArkTS side and save them in encapsulated objects on the Native side.
const std::shared_ptr<ArkUIMixedRefresh> ArkUIMixedRefresh::Create(const NativeRefreshAttribute &attribute)
{
    napi_handle_scope scope;
    napi_open_handle_scope(g_env, &scope);
    auto refresh = std::make_shared<ArkUIMixedRefresh>();
    auto refreshAttribute = CreateRefreshAttribute(attribute, refresh.get());
    if (refreshAttribute == nullptr) {
        napi_close_handle_scope(g_env, scope);
        return nullptr;
    }
    napi_value result = nullptr;
    napi_value argv[1] = {refreshAttribute};
    napi_value createRefresh = nullptr;
    napi_get_reference_value(g_env, g_createRefresh, &createRefresh);
    // Call ArkTS's Create function to create ArkTS's WidgetContent.
    napi_call_function(g_env, nullptr, createRefresh, 1, argv, &result);

    // Retrieve the Refresh component of ArkTS.
    napi_value componentContent = nullptr;
    napi_get_named_property(g_env, result, "content", &componentContent);
    ArkUI_NodeHandle handle;
    OH_ArkUI_GetNodeHandleFromNapiValue(g_env, componentContent, &handle);
    assert(handle);
    // Retrieve the sub component slot of the Refresh component of ArkTS.
    napi_value nodeContent = nullptr;
    napi_get_named_property(g_env, result, "childSlot", &nodeContent);
    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(g_env, nodeContent, &contentHandle);
    assert(contentHandle);
    // Save the Component Content of ArkTS to prevent the release of ArkTS side objects and subsequent updates.
    napi_ref componentContentRef;
    napi_create_reference(g_env, componentContent, 1, &componentContentRef);
    // Save the NodeContent of ArkTS to prevent the release of ArkTS side objects and subsequent updates.
    napi_ref nodeContentRef;
    napi_create_reference(g_env, nodeContent, 1, &nodeContentRef);
    // Update the parameters related to the Refresh component.
    refresh->handle_ = handle;
    refresh->env_ = g_env;
    refresh->componentContent_ = componentContentRef;
    refresh->nodeContent_ = nodeContentRef;
    refresh->contentHandle_ = contentHandle;
    refresh->attribute_ = attribute;
    return refresh;
}

// Update function implementation.
void ArkUIMixedRefresh::FlushMixedModeCmd()
{
    napi_handle_scope scope;
    napi_open_handle_scope(g_env, &scope);
    // Create and call ArkTS interface parameters.
    auto refreshAttribute = CreateRefreshAttribute(attribute_, this);
    if (refreshAttribute == nullptr) {
        napi_close_handle_scope(g_env, scope);
        return;
    }
    // Retrieve the remaining two interface parameters for updating the interface.
    napi_value componentContent = nullptr;
    napi_get_reference_value(g_env, componentContent_, &componentContent);
    napi_value nodeContent = nullptr;
    napi_get_reference_value(g_env, nodeContent_, &nodeContent);

    napi_value argv[3] = {componentContent, nodeContent, refreshAttribute};
    napi_value updateRefresh = nullptr;
    napi_get_reference_value(g_env, g_updateRefresh, &updateRefresh);
    // Call ArkTS' Update function to update.
    napi_value result = nullptr;
    napi_call_function(g_env, nullptr, updateRefresh, ARGV_COUNT, argv, &result);
}

napi_value ArkUIMixedRefresh::RegisterCreateRefresh(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    g_env = env;
    napi_ref refer;
    // Save after creating a reference to prevent release.
    napi_create_reference(env, args[0], 1, &refer);

    g_createRefresh = refer;
    return nullptr;
}

napi_value ArkUIMixedRefresh::RegisterUpdateRefresh(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    g_env = env;
    napi_ref refer;
    // Save after creating a reference to prevent release.
    napi_create_reference(env, args[0], 1, &refer);

    g_updateRefresh = refer;
    return nullptr;
}
} // namespace NativeModule