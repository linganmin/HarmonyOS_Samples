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

#ifndef KCOMPONENT_PLUGIN_RENDER_H
#define KCOMPONENT_PLUGIN_RENDER_H

#include <unordered_map>
#include <ace/xcomponent/native_interface_xcomponent.h>
#include "camera/ndk_camera.h"
#include "render_thread.h"

namespace NativeXComponentSample {
class PluginRender {
public:
    explicit PluginRender(std::string &id);
    ~PluginRender()
    {
        Release(id_);
    }
    static PluginRender *GetInstance(std::string &id);
    static void Release(std::string &id);
    static void TransformRelease(std::string &id);
    static napi_value StartCamera(napi_env env, napi_callback_info info);
    static napi_value StopCamera(napi_env env, napi_callback_info info);
    static napi_value StartRecorder(napi_env env, napi_callback_info info);
    static napi_value StopRecorder(napi_env env, napi_callback_info info);
    static napi_value StartTransform(napi_env env, napi_callback_info info);
    void OnSurfaceChanged(OH_NativeXComponent *component, void *window);
    void OnTouchEvent(OH_NativeXComponent *component, void *window);
    void OnMouseEvent(OH_NativeXComponent *component, void *window);
    void OnHoverEvent(OH_NativeXComponent *component, bool isHover);
    void OnFocusEvent(OH_NativeXComponent *component, void *window);
    void OnBlurEvent(OH_NativeXComponent *component, void *window);
    void OnKeyEvent(OH_NativeXComponent *component, void *window);
    void RegisterCallback(OH_NativeXComponent *nativeXComponent);

    void UpdateNativeWindow(void *window, uint64_t width, uint64_t height);

public:
    static std::unordered_map<std::string, PluginRender *> instance_;
    std::string id_;
    static int32_t hasDraw_;
    static int32_t hasChangeColor_;
    std::unique_ptr<RenderThread> renderThread_;

private:
    void CreateCamera();
    void StopCamera();
    void StartRecorder();
    void StopRecorder();

    static PluginRender *GetPluginRender(napi_env env, napi_callback_info info);

    OH_NativeXComponent_Callback renderCallback_;
    OH_NativeXComponent_MouseEvent_Callback mouseCallback_;
    std::unique_ptr<OHOS_CAMERA_SAMPLE::NDKCamera> ndkCamera_;
};
}  // namespace NativeXComponentSample
#endif  // KCOMPONENT_PLUGIN_RENDER_H
