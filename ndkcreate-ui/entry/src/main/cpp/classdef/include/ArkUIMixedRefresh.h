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

#ifndef NDKCREATEUI_ARKUIMIXEDREFRESH_H
#define NDKCREATEUI_ARKUIMIXEDREFRESH_H

#include <functional>
#include <optional>
#include "ArkUIMixedNode.h"

namespace NativeModule {
// Define the interaction data structure between the Native side and ArkTS side.
struct NativeRefreshAttribute {
    std::optional<bool> isRefreshing;
    std::optional<float> width;
    std::optional<float> height;
    std::optional<uint32_t> backgroundColor;
    std::optional<float> refreshOffset;
    std::optional<bool> pullToRefresh;
    std::function<void()> onRefreshing;
    std::function<void(float)> onOffsetChange;
};

class ArkUIMixedRefresh : public ArkUIMixedNode {
public:
    // Call ArkTS method to create Refresh component.
    static const std::shared_ptr<ArkUIMixedRefresh> Create(const NativeRefreshAttribute &attribute);

    ArkUIMixedRefresh(ArkUI_NodeHandle handle, ArkUI_NodeContentHandle contentHandle, napi_env env,
                      napi_ref componentContent, napi_ref nodeContent)
        : ArkUIMixedNode(handle, env, componentContent), contentHandle_(contentHandle), nodeContent_(nodeContent) {}

    ArkUIMixedRefresh() : ArkUIMixedNode(nullptr, nullptr, nullptr) {}

    ~ArkUIMixedRefresh() override { napi_delete_reference(env_, nodeContent_); }

    void SetRefreshState(bool isRefreshing) { attribute_.isRefreshing = isRefreshing; }

    void SetRefreshCallback(const std::function<void()> &callback) { attribute_.onRefreshing = callback; }

    void SetOnOffsetChange(const std::function<void(float)> &callback) { attribute_.onOffsetChange = callback; }

    // Avoid frequent cross language caching of attribute events on the native side and batch notifications.
    void FlushMixedModeCmd();

    static napi_value RegisterCreateRefresh(napi_env env, napi_callback_info info);
    static napi_value RegisterUpdateRefresh(napi_env env, napi_callback_info info);

protected:
    void OnAddChild(const std::shared_ptr<ArkUIBaseNode> &child) override
    {
        if (!contentHandle_) {
            throw std::runtime_error("contentHandle_ is null, cannot call OH_ArkUI_NodeContent_AddNode");
        }
        // Use NodeContent to mount components.
        OH_ArkUI_NodeContent_AddNode(contentHandle_, child->GetHandle());
    }

    void OnRemoveChild(const std::shared_ptr<ArkUIBaseNode> &child) override
    {
        if (!contentHandle_) {
            throw std::runtime_error("contentHandle_ is null, cannot call OH_ArkUI_NodeContent_RemoveNode");
        }
        // Use NodeContent to uninstall components.
        OH_ArkUI_NodeContent_RemoveNode(contentHandle_, child->GetHandle());
    }

    void OnInsertChild(const std::shared_ptr<ArkUIBaseNode> &child, int32_t index) override
    {
        if (!contentHandle_) {
            throw std::runtime_error("contentHandle_ is null, cannot call OH_ArkUI_NodeContent_InsertNode");
        }
        // Insert components using NodeContent.
        OH_ArkUI_NodeContent_InsertNode(contentHandle_, child->GetHandle(), index);
    }

private:
    // Create data structures on the ArkTS side using the Napi interface.
    static napi_value CreateRefreshAttribute(const NativeRefreshAttribute &attribute, void *userData);
    
    static void SetDoubleValue(napi_env env, napi_property_descriptor &desc, const std::optional<double> &value);
    
    static void SetUint32Value(napi_env env, napi_property_descriptor &desc, const std::optional<uint32_t> &value);
    
    static void SetInt32Value(napi_env env, napi_property_descriptor &desc, const std::optional<int32_t> &value);
    
    static void SetOnRefreshingMethod(napi_env env, napi_property_descriptor &desc, void *userData);
    
    static void SetOnOffsetChangeMethod(napi_env env, napi_property_descriptor &desc, void *userData);
    
    static constexpr int ARGV_COUNT = 3;

    ArkUI_NodeContentHandle contentHandle_;
    napi_ref nodeContent_;
    NativeRefreshAttribute attribute_;
};
} // namespace NativeModule

#endif // NDKCREATEUI_ARKUIMIXEDREFRESH_H