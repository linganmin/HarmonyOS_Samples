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

#include "plugin_render.h"
#include "file/file_operator.h"
#include "/common/common.h"

#include <native_image/native_image.h>
#include <sstream>
#include <cstdint>
#include <string>
#include <hilog/log.h>

#include <rawfile/raw_file_manager.h>
#include <napi/native_api.h>
#include <unistd.h>

std::unordered_map<std::string, PluginRender *> PluginRender::m_instance;
OH_NativeXComponent_Callback PluginRender::m_callback;
TestSceneConfiguration g_sponzaFull10Lights{
    "sponza_full/sponza.obj",                                              // model_file
    0.01f,                                                                 // scale
    glm::vec3{-15, -5, -5},                                                // min_light_pos
    glm::vec3{15, 20, 5},                                                  // max_light_pos
    5.0f,                                                                  // radius
    10,                                                                    // light num
    glm::vec3{12.7101822f, 1.87933588f, -0.0333303586f},                   // camera position
    glm::quat{0.717312694f, -0.00208670134f, 0.696745396f, 0.00202676491f} // camera rotation
};

TestSceneConfiguration g_sponzaFull30Lights{
    "sponza_full/sponza.obj",                                              // model_file
    0.01f,                                                                 // scale
    glm::vec3{-15, -5, -5},                                                // min_light_pos
    glm::vec3{15, 20, 5},                                                  // max_light_pos
    3.0f,                                                                  // radius
    30,                                                                    // light num
    glm::vec3{12.7101822f, 1.87933588f, -0.0333303586f},                   // camera position
    glm::quat{0.717312694f, -0.00208670134f, 0.696745396f, 0.00202676491f} // camera rotation
};

TestSceneConfiguration g_sponzaFull50LightsSample{
    "sponza_full/sponza.obj",                                              // model_file
    1.20f,                                                                 // scale
    glm::vec3{-15, -5, -5},                                                // min_light_pos
    glm::vec3{15, 20, 5},                                                  // max_light_pos
    5.0f,                                                                  // radius
    50,                                                                    // light num
    glm::vec3{12.8101822f, 1.87933588f, -0.0333303586f},                   // camera position
    glm::quat{0.717312694f, -0.00208670134f, 0.696745396f, 0.00202676491f} // camera rotation
};

TestSceneConfiguration g_sponzaFull50Lights{
    "sponza_full/sponza.obj",                                              // model_file
    0.01f,                                                                 // scale
    glm::vec3{-15, -5, -5},                                                // min_light_pos
    glm::vec3{15, 20, 5},                                                  // max_light_pos
    5.0f,                                                                  // radius
    50,                                                                    // light num
    glm::vec3{10.5f, 2.0f, 0.00f},                                         // camera position
    glm::quat{0.717312694f, -0.00208670134f, 0.696745396f, 0.00202676491f} // camera rotation
};

TestSceneConfiguration g_sponzaFull100Fights{
    "sponza_full/sponza.obj",                                              // model_file
    0.01f,                                                                 // scale
    glm::vec3{-15, -5, -5},                                                // min_light_pos
    glm::vec3{15, 20, 5},                                                  // max_light_pos
    5.0f,                                                                  // radius
    100,                                                                   // light num
    glm::vec3{12.7101822f, 1.87933588f, -0.0333303586f},                   // camera position
    glm::quat{0.717312694f, -0.00208670134f, 0.696745396f, 0.00202676491f} // camera rotation
};

TestSceneConfiguration g_sponzaFull200Lights{
    "sponza_full/sponza.obj",                                              // model_file
    0.01f,                                                                 // scale
    glm::vec3{-15, -5, -5},                                                // min_light_pos
    glm::vec3{15, 20, 5},                                                  // max_light_pos
    5.0f,                                                                  // radius
    200,                                                                   // light num
    glm::vec3{12.7101822f, 1.87933588f, -0.0333303586f},                   // camera position
    glm::quat{0.717312694f, -0.00208670134f, 0.696745396f, 0.00202676491f} // camera rotation
};

TestSceneConfiguration g_sponzaFull1000Lights{
    "sponza_full/sponza.obj",                                              // model_file
    0.01f,                                                                 // scale
    glm::vec3{-15, -5, -5},                                                // min_light_pos
    glm::vec3{15, 20, 5},                                                  // max_light_pos
    5.0f,                                                                  // radius
    1000,                                                                  // light num
    glm::vec3{12.7101822f, 1.87933588f, -0.0333303586f},                   // camera position
    glm::quat{0.717312694f, -0.00208670134f, 0.696745396f, 0.00202676491f} // camera rotation
};

TestSceneConfiguration g_sponzaFull1000SmallLights{
    "sponza_full/sponza.obj",                                              // model_file
    0.01f,                                                                 // scale
    glm::vec3{-15, -5, -5},                                                // min_light_pos
    glm::vec3{15, 20, 5},                                                  // max_light_pos
    2.0f,                                                                  // radius
    1000,                                                                  // light num
    glm::vec3{12.7101822f, 1.87933588f, -0.0333303586f},                   // camera position
    glm::quat{0.717312694f, -0.00208670134f, 0.696745396f, 0.00202676491f} // camera rotation
};

TestSceneConfiguration g_sponzaFull1000LargeLights{
    "sponza_full/sponza.obj",                                              // model_file
    0.01f,                                                                 // scale
    glm::vec3{-15, -5, -5},                                                // min_light_pos
    glm::vec3{15, 20, 5},                                                  // max_light_pos
    10.0f,                                                                 // radius
    1000,                                                                  // light num
    glm::vec3{12.7101822f, 1.87933588f, -0.0333303586f},                   // camera position
    glm::quat{0.717312694f, -0.00208670134f, 0.696745396f, 0.00202676491f} // camera rotation
};

TestSceneConfiguration g_sponzaFull20000SmallLights{
    "sponza_full/sponza.obj",                                              // model_file
    0.01f,                                                                 // scale
    glm::vec3{-15, -5, -5},                                                // min_light_pos
    glm::vec3{15, 20, 5},                                                  // max_light_pos
    2.0f,                                                                  // radius
    20000,                                                                 // light num
    glm::vec3{12.7101822f, 1.87933588f, -0.0333303586f},                   // camera position
    glm::quat{0.717312694f, -0.00208670134f, 0.696745396f, 0.00202676491f} // camera rotation
};

TestSceneConfiguration g_rungholt10Lights{
    "rungholt/rungholt.obj",                                           // model_file
    0.10f,                                                             // scale
    glm::vec3{-20, -5, -20},                                           // min_light_pos
    glm::vec3{20, 20, 20},                                             // max_light_pos
    10.0f,                                                             // radius
    10,                                                                // light num
    glm::vec3{31.8083534f, 27.5098400f, 36.7743378f},                  // camera position
    glm::quat{0.883192122f, -0.292658001f, 0.347898334f, 0.115281112f} // camera rotation
};

TestSceneConfiguration g_rungholt200Lights{
    "rungholt/rungholt.obj",                                           // model_file
    0.10f,                                                             // scale
    glm::vec3{-20, -5, -20},                                           // min_light_pos
    glm::vec3{20, 20, 20},                                             // max_light_pos
    5.0f,                                                              // radius
    200,                                                               // light num
    glm::vec3{31.8083534f, 27.5098400f, 36.7743378f},                  // camera position
    glm::quat{0.883192122f, -0.292658001f, 0.347898334f, 0.115281112f} // camera rotation
};

TestSceneConfiguration g_rungholt1000Lights{
    "rungholt/rungholt.obj",                                           // model_file
    0.10f,                                                             // scale
    glm::vec3{-20, -5, -20},                                           // min_light_pos
    glm::vec3{20, 20, 20},                                             // max_light_pos
    5.0f,                                                              // radius
    1000,                                                              // light num
    glm::vec3{31.8083534f, 27.5098400f, 36.7743378f},                  // camera position
    glm::quat{0.883192122f, -0.292658001f, 0.347898334f, 0.115281112f} // camera rotation
};

TestSceneConfiguration g_rungholt20000Lights{
    "rungholt/rungholt.obj",                                           // model_file
    0.10f,                                                             // scale
    glm::vec3{-20, -5, -20},                                           // min_light_pos
    glm::vec3{20, 20, 20},                                             // max_light_pos
    5.0f,                                                              // radius
    20000,                                                             // light num
    glm::vec3{31.8083534f, 27.5098400f, 36.7743378f},                  // camera position
    glm::quat{0.883192122f, -0.292658001f, 0.347898334f, 0.115281112f} // camera rotation
};

void OnSurfaceCreatedCB(OH_NativeXComponent *component, void *window)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "OnSurface CreatedCB");
    if ((nullptr == component) || (nullptr == window)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "OnSurface CreatedCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(component, idStr, &idSize)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "OnSurface CreatedCB: Unable to get XComponent id");
        return;
    }

    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);

    uint64_t width;
    uint64_t height;
    int32_t xSize = OH_NativeXComponent_GetXComponentSize(component, window, &width, &height);
    if ((OH_NATIVEXCOMPONENT_RESULT_SUCCESS != xSize) && (nullptr == render)) {
        return;
    }
    GetGlobalTestSceneConfiguration() = g_sponzaFull50Lights;

    render->m_window = window;
    render->m_vulkanRender = new VulkanRenderer(static_cast<OHNativeWindow *>(render->m_window));

    char name[] = "hello_vsync";
    render->nativeVSync = OH_NativeVSync_Create(name, 11);
    render->camera.position = GetGlobalTestSceneConfiguration().cameraPosition;
    render->camera.rotation = glm::normalize(GetGlobalTestSceneConfiguration().cameraRotation);
    render->PrepareDraw(window);
}

void OnSurfaceChangedCB(OH_NativeXComponent *component, void *window)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "OnSurfaceChangedCB");
    if ((nullptr == component) || (nullptr == window)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "OnSurfaceChangedCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(component, idStr, &idSize)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "OnSurfaceChangedCB: Unable to get XComponent id");
        return;
    }

    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    if (render != nullptr) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "surface changed");
    }
}

void OnSurfaceDestroyedCB(OH_NativeXComponent *component, void *window)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "OnSurfaceDestroyedCB");
    if ((nullptr == component) || (nullptr == window)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "OnSurfaceDestroyedCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(component, idStr, &idSize)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "OnSurfaceDestroyedCB: Unable to get XComponent id");
        return;
    }

    std::string id(idStr);
    PluginRender::Release(id);
}

void DispatchTouchEventCB(OH_NativeXComponent *component, void *window)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Callback", "DispatchTouchEventCB");
    if ((nullptr == component) || (nullptr == window)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "DispatchTouchEventCB: component or window is null");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NATIVEXCOMPONENT_RESULT_SUCCESS != OH_NativeXComponent_GetXComponentId(component, idStr, &idSize)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback",
                     "DispatchTouchEventCB: Unable to get XComponent id");
        return;
    }
}

void PluginRender::PrepareDraw(void *window)
{
    OH_NativeVSync_RequestFrame(
        nativeVSync,
        [](long long timestamp, void *data) {
            PluginRender *render = (reinterpret_cast<PluginRender *>(data));
            render->previous = std::chrono::high_resolution_clock::now();
            render->DrawLoop();
        },
        (void *)this);
}

void PluginRender::DrawLoop()
{
//     if (forwad) {
//         camera.position.x += 0.2;
//         if (camera.position.x >= 11) {
//             forwad = !forwad;
//         }
//     } else {
//         camera.position.x -= 0.2;
//         if (camera.position.x <= -5) {
//             forwad = !forwad;
//         }
//     }
    m_vulkanRender->setCamera(camera.getViewMatrix(), camera.position);
    auto current = std::chrono::high_resolution_clock::now();
    float deltaTime = std::chrono::duration<float>(current - previous).count();
    m_vulkanRender->requestDraw(deltaTime);
    previous = current;
    OH_NativeVSync_RequestFrame(
        nativeVSync,
        [](long long timestamp, void *data) {
            OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "PluginRender",
                         "OH_NativeVSync_RequestFrame at %{public}lld", timestamp);

            PluginRender *render = (reinterpret_cast<PluginRender *>(data));
            render->DrawLoop();
        },
        (void *)this);
}

PluginRender::PluginRender(std::string &id)
{
    this->m_id = id;
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
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender", "Export: env or exports is null");
        return;
    }

    napi_property_descriptor desc[] = {};
    if (napi_ok != napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginRender", "Export: napi_define_properties failed");
    }
}


void PluginRender::Release(std::string &id)
{
    PluginRender *render = PluginRender::GetInstance(id);
    if (render != nullptr) {
        m_instance.erase(m_instance.find(id));
    }
}