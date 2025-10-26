/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <cstdint>
#include <string>
#include "common/common.h"
#include "file/file_operator.h"
#include "plugin_render.h"

std::mutex PluginRender::m_mutex;
std::condition_variable PluginRender::m_con;
bool PluginRender::stop = false;
std::unordered_map<std::string, PluginRender *> PluginRender::m_instance;
OH_NativeXComponent_Callback PluginRender::m_callback;

template<typename T>
void OnSurfaceCreatedCB(OH_NativeXComponent *component, T *window)
{
    LOGI("PluginRender OnSurfaceCrateCB");
    if ((nullptr == component) || (nullptr == window)) {
        LOGE("PluginRender OnSurfaceCreatedCB failed: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = { '\0' };
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(component, idStr, &idSize)) {
        LOGE("PluginRender OnSurfaceCreatedCB failed: Unable to get XComponent id");
        return;
    }

    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    render->RenderCreated(component, window);
}

template<typename T>
void PluginRender::RenderCreated(OH_NativeXComponent *component, T *window)
{
    uint64_t width;
    uint64_t height;
    int32_t ret = OH_NativeXComponent_GetXComponentSize(component, window, &width, &height);
    LOGD("PluginRender OnSurfaceCreated ret is %{public}d, w:%{public}lu, d:%{public}lu", ret, width, height);
    if (!m_vulkanexample->initVulkan()) {
        LOGE("PluginRender OnSurfaceCreated vulkanExample initVulkan FALSE");
        return;
    }
    m_vulkanexample->setupWindow(static_cast<OHNativeWindow *>(window));

    m_renderThread = std::thread(std::bind(&PluginRender::RenderThread, this));
}

void PluginRender::RenderThread()
{
    while (true) {
        std::unique_lock<std::mutex> locker(m_mutex);
        if (!stop) {
            bool prepared = m_vulkanexample->Prepare();
            if (!prepared) {
                LOGE("vulkan example is not prepared");
                break;
            }
            m_vulkanexample->SetMethod(m_mode);
            m_vulkanexample->renderLoop();
        } else {
            LOGI("PluginRender Render Thread stop ");
            break;
        }
    }
}

template<typename T>
void OnSurfaceChangedCB(OH_NativeXComponent *component, T *window) {}

template<typename T>
void OnSurfaceDestroyedCB(OH_NativeXComponent *component, T *window)
{
    LOGI("PluginRender OnSurfaceDestroyedCB");
    if ((nullptr == component) || (nullptr == window)) {
        LOGE("PluginRender OnSurfaceDestroyedCB : component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = { '\0' };
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(component, idStr, &idSize)) {
        LOGE("PluginRender OnSurfaceDestroyedCB : Unable to get XComponent id");
        return;
    }

    std::string id(idStr);
    PluginRender::Release(id);
}

template<typename T>
void DispatchTouchEventCB(OH_NativeXComponent *component, T *window) {}

void PluginRender::SetMode(int mode)
{
    m_mode = mode;
}

napi_value PluginRender::SetUpscaleMethod(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int upscaleMode;
    napi_get_value_int32(env, args[0], &upscaleMode);
    LOGI("PluginRender::Add get params is %{public}d", upscaleMode);

    if ((nullptr == env) || (nullptr == info)) {
        LOGE("PluginRender SetUpscaleMethod : env or info is null");
        return nullptr;
    }

    napi_value thisArg;
    if (napi_ok != napi_get_cb_info(env, info, nullptr, nullptr, &thisArg, nullptr)) {
        LOGE("PluginRender SetUpscaleMethod : napi_get_cb_info fail");
        return nullptr;
    }

    napi_value exportInstance;
    if (napi_ok != napi_get_named_property(env, thisArg, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance)) {
        LOGE("PluginRender SetUpscaleMethod : napi_get_named_property fail");
        return nullptr;
    }

    OH_NativeXComponent *nativeXComponent = nullptr;
    if (napi_ok != napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent))) {
        LOGE("PluginRender SetUpscaleMethod : napi_unwrap fail");
        return nullptr;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize)) {
        LOGE("PluginRender SetUpscaleMethod : Unable to get XComponent id");
        return nullptr;
    }
    std::string id(idStr);
    PluginRender *render = PluginRender::GetInstance(id);
    if (render) {
        render->SetMode(upscaleMode);
    }
    return nullptr;
}

napi_value PluginRender::SetVRSUsed(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    bool useVRS;
    napi_get_value_bool(env, args[0], &useVRS);
    LOGI("PluginRender::SetVRSUsed get params is %{public}d", useVRS);

    if ((nullptr == env) || (nullptr == info)) {
        LOGE("PluginRender SetVRSUsed : env or info is null");
        return nullptr;
    }

    napi_value thisArg;
    if (napi_ok != napi_get_cb_info(env, info, nullptr, nullptr, &thisArg, nullptr)) {
        LOGE("PluginRender SetVRSUsed : napi_get_cb_info fail");
        return nullptr;
    }

    napi_value exportInstance;
    if (napi_ok != napi_get_named_property(env, thisArg, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance)) {
        LOGE("PluginRender SetVRSUsed : napi_get_named_property fail");
        return nullptr;
    }

    OH_NativeXComponent *nativeXComponent = nullptr;
    if (napi_ok != napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent))) {
        LOGE("PluginRender SetVRSUsed : napi_unwrap fail");
        return nullptr;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize)) {
        LOGE("PluginRender SetVRSUsed : Unable to get XComponent id");
        return nullptr;
    }
    std::string id(idStr);
    PluginRender *render = PluginRender::GetInstance(id);
    if (render) {
        render->m_vulkanexample->UseVRS(useVRS);
    }
    return nullptr;
}

PluginRender::PluginRender(std::string &id) : m_id(id), m_vulkanexample(new VulkanExample())
{
    OH_NativeXComponent_Callback *renderCallback = &PluginRender::m_callback;
    renderCallback->OnSurfaceCreated = OnSurfaceCreatedCB;
    renderCallback->OnSurfaceChanged = OnSurfaceChangedCB;
    renderCallback->OnSurfaceDestroyed = OnSurfaceDestroyedCB;
    renderCallback->DispatchTouchEvent = DispatchTouchEventCB;
}

PluginRender *PluginRender::GetInstance(std::string &id)
{
    if (m_instance.find(id) == m_instance.end()) {
        PluginRender *instance = new PluginRender(id);
        m_instance[id] = instance;
        return instance;
    } else {
        return m_instance[id];
    }
}

void PluginRender::Export(napi_env env, napi_value exports)
{
    if ((nullptr == env) || (nullptr == exports)) {
        LOGE("PluginRender Export: env or exports is null");
        return;
    }

    napi_property_descriptor desc[] = {
        {"setUpscaleMethod", nullptr, PluginRender::SetUpscaleMethod, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setVRSUsed", nullptr, PluginRender::SetVRSUsed, nullptr, nullptr, nullptr, napi_default, nullptr}};

    if (napi_ok != napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc)) {
        LOGE("PluginRender Export: napi_define_properties failed");
    }
}

void PluginRender::Release(std::string &id)
{
    LOGE("PluginRender start release");
    PluginRender *render = PluginRender::GetInstance(id);
    if (render != nullptr) {
        std::unique_lock<std::mutex> locker(m_mutex);
        stop = true;
        m_con.notify_all();
        m_instance.erase(m_instance.find(id));
        delete render->m_vulkanexample;
    }
}