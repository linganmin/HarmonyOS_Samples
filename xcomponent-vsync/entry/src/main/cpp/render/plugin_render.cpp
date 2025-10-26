/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

#include <cstdint>
#include <hilog/log.h>
#include "common/plugin_common.h"
#include "manager/plugin_manager.h"
#include "native_common.h"
#include "render/plugin_render.h"

std::unordered_map<std::string, PluginRender *> PluginRender::instance_;

OH_NativeXComponent_Callback PluginRender::callback_;

// Create EGL surface based on surfaceID.
void OnSurfaceCreatedCB(OH_NativeXComponent *component, void *window) {
    LOGD("OnSurfaceCreatedCB");
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }
    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    render->OnSurfaceCreated(component, window);
}

// Monitor surfaceID changes and transform EGL surface.
void OnSurfaceChangedCB(OH_NativeXComponent *component, void *window) {
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }
    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    render->OnSurfaceChanged(component, window);
}

// Monitor surfaceID destruction and destroy EGL surface.
void OnSurfaceDestroyedCB(OH_NativeXComponent *component, void *window) {
    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return;
    }
    std::string id(idStr);
    auto render = PluginRender::GetInstance(id);
    render->OnSurfaceDestroyed(component, window);
}

PluginRender::PluginRender(std::string &id) : id_(id) {
    eglCore_ = new EGLCore(id);
    auto renderCallback = PluginRender::GetNXComponentCallback();
    renderCallback->OnSurfaceCreated = OnSurfaceCreatedCB;
    renderCallback->OnSurfaceChanged = OnSurfaceChangedCB;
    renderCallback->OnSurfaceDestroyed = OnSurfaceDestroyedCB;
}

PluginRender *PluginRender::GetInstance(std::string &id) {
    if (instance_.find(id) == instance_.end()) {
        PluginRender *instance = new PluginRender(id);
        instance_[id] = instance;
        return instance;
    } else {
        return instance_[id];
    }
}

OH_NativeXComponent_Callback *PluginRender::GetNXComponentCallback() { return &PluginRender::callback_; }

void PluginRender::SetNativeXComponent(OH_NativeXComponent *component) {
    OH_NativeXComponent_RegisterCallback(component, &PluginRender::callback_);
}

void PluginRender::OnSurfaceCreated(OH_NativeXComponent *component, void *window) {
    LOGD("PluginRender::OnSurfaceCreated");
    int32_t ret = OH_NativeXComponent_GetXComponentSize(component, window, &width_, &height_);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS && nullptr != eglCore_) {
        eglCore_->OnSurfaceCreated(window, width_, height_);
    }
}

void PluginRender::OnSurfaceChanged(OH_NativeXComponent *component, void *window) {
    LOGD("PluginRender::OnSurfaceChanged");
    int32_t ret = OH_NativeXComponent_GetXComponentSize(component, window, &width_, &height_);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS && nullptr != eglCore_) {
        eglCore_->OnSurfaceChanged(window, width_, height_);
    }
}

void PluginRender::OnSurfaceDestroyed(OH_NativeXComponent *component, void *window) {
    LOGD("PluginRender::OnSurfaceDestroyed");
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    int32_t ret = OH_NativeXComponent_GetXComponentId(component, idStr, &idSize);
    if (ret == OH_NATIVEXCOMPONENT_RESULT_SUCCESS && nullptr != eglCore_) {
        eglCore_->OnSurfaceDestroyed();
    }
    if (nullptr != eglCore_) {
        delete eglCore_;
        eglCore_ = nullptr;
    }
    if (nullptr != instance_[id_]) {
        delete instance_[id_];
        instance_[id_] = nullptr;
        instance_.erase(id_);
    }
}

// Register JS API
napi_value PluginRender::Export(napi_env env, napi_value exports) {
    LOGI("PluginRender::Export");
    napi_property_descriptor desc[] = {
        DECLARE_NAPI_FUNCTION("switchAmbient", PluginRender::NapiSwitchAmbient),
        DECLARE_NAPI_FUNCTION("switchDiffuse", PluginRender::NapiSwitchDiffuse),
        DECLARE_NAPI_FUNCTION("switchSpecular", PluginRender::NapiSwitchSpecular),
    };
    NAPI_CALL(env, napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc));
    return exports;
}

// NAPI bridging layer, JS calls EGL to achieve diffuse reflection effect.
napi_value PluginRender::NapiSwitchAmbient(napi_env env, napi_callback_info info) {
    LOGD("NapiSwitchAmbient");
    napi_value exportInstance;
    napi_value thisArg;
    napi_status status;
    OH_NativeXComponent *nativeXComponent = nullptr;

    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;

    NAPI_CALL(env, napi_get_cb_info(env, info, NULL, NULL, &thisArg, NULL));

    status = napi_get_named_property(env, thisArg, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance);
    if (status != napi_ok) {
        return nullptr;
    };

    status = napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent));
    if (status != napi_ok) {
        return nullptr;
    }

    ret = OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return nullptr;
    }

    std::string id(idStr);
    PluginRender *instance = PluginRender::GetInstance(id);
    if (instance) {
        instance->eglCore_->switchAmbient();
    }
    return nullptr;
}

// NAPI bridging layer, JS calls EGL to achieve ambient light effects.
napi_value PluginRender::NapiSwitchDiffuse(napi_env env, napi_callback_info info) {
    LOGD("NapiSwitchDiffuse");
    napi_value exportInstance;
    napi_value thisArg;
    napi_status status;
    OH_NativeXComponent *nativeXComponent = nullptr;

    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;

    NAPI_CALL(env, napi_get_cb_info(env, info, NULL, NULL, &thisArg, NULL));

    status = napi_get_named_property(env, thisArg, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance);
    if (status != napi_ok) {
        return nullptr;
    };

    status = napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent));
    if (status != napi_ok) {
        return nullptr;
    }

    ret = OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return nullptr;
    }

    std::string id(idStr);
    PluginRender *instance = PluginRender::GetInstance(id);
    if (instance) {
        instance->eglCore_->switchDiffuse();
    }
    return nullptr;
}

// NAPI bridging layer, JS calls EGL to achieve specular lighting effect.
napi_value PluginRender::NapiSwitchSpecular(napi_env env, napi_callback_info info) {
    LOGD("NapiSwitchSpecular");
    napi_value exportInstance;
    napi_value thisArg;
    napi_status status;
    OH_NativeXComponent *nativeXComponent = nullptr;

    int32_t ret;
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;

    NAPI_CALL(env, napi_get_cb_info(env, info, NULL, NULL, &thisArg, NULL));

    status = napi_get_named_property(env, thisArg, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance);
    if (status != napi_ok) {
        return nullptr;
    }

    status = napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent));
    if (status != napi_ok) {
        return nullptr;
    }

    ret = OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize);
    if (ret != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return nullptr;
    }

    std::string id(idStr);
    PluginRender *instance = PluginRender::GetInstance(id);
    if (instance) {
        instance->eglCore_->switchSpecular();
    }
    return nullptr;
}