/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
#ifndef RENDER_PLUGIN_RENDER_H
#define RENDER_PLUGIN_RENDER_H
#include <string>
#include <unordered_map>
#include <condition_variable>
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <thread>
#include <condition_variable>
#include "model_3d_sponza.h"

class PluginRender {
public:
    explicit PluginRender(std::string &id);
    ~PluginRender() {}
    
    static PluginRender *GetInstance(std::string &id);
    static void Release(std::string &id);
    static napi_value SetUpscaleMethod(napi_env env, napi_callback_info info);
    static napi_value SetVRSUsed(napi_env env, napi_callback_info info);
    static std::unordered_map<std::string, PluginRender *> m_instance;
    static OH_NativeXComponent_Callback m_callback;
    static std::mutex m_mutex;
    static std::condition_variable m_con;
    static bool stop;
    
    void Export(napi_env env, napi_value exports);
    void SetMode(int mode);
    void RenderThread();
    void RenderCreated(OH_NativeXComponent *component, void *window);
    
    std::string m_id;
    void *m_window;
    int m_mode = 0;
    VulkanExample *m_vulkanexample;
    std::thread m_renderThread;
};
#endif // RENDER_PLUGIN_RENDER_H