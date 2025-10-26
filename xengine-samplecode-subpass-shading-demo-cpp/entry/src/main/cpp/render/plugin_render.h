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

#ifndef PLUGIN_RENDER_H
#define PLUGIN_RENDER_H
#include <thread>
#include <string>
#include <unordered_map>
#include <condition_variable>
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <napi/native_api.h>
#include <native_vsync/native_vsync.h>

#include "vulkan_renderer.h"
#include "scene.h"
#include "util.h"
class PluginRender {
public:
    explicit PluginRender(std::string &id);
    ~PluginRender()
    {
        if (m_vulkanRender != nullptr) {
            delete m_vulkanRender;
            m_vulkanRender = nullptr;
        }
    }
    static PluginRender *GetInstance(std::string &id);
    static void Release(std::string &id);
    void Export(napi_env env, napi_value exports);
    void SetEnv(napi_env env) { m_env = env; }
    OH_NativeVSync *nativeVSync;

public:
    void PrepareDraw(void *window);
    void DrawLoop();
    static std::unordered_map<std::string, PluginRender *> m_instance;
    static OH_NativeXComponent_Callback m_callback;
    std::string m_id;
    OH_NativeXComponent_TouchEvent m_touchEvent;
    uint64_t m_width;
    uint64_t m_height;
    std::chrono::time_point<std::chrono::high_resolution_clock> previous;
    std::thread m_renderThread;
    void *m_window;
    int m_model = 0;
    VulkanRenderer *m_vulkanRender;
    napi_env m_env;
    Camera camera;
    void DealTouchEvent(OH_NativeXComponent *component, void *window);
    static napi_value NapiStopMovingOrRestart(napi_env env, napi_callback_info info);
    bool forwad;
};
#endif