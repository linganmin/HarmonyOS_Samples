/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

#ifndef RENDER_EGL_CORE_H
#define RENDER_EGL_CORE_H
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <EGL/eglplatform.h>
#include <GLES3/gl3.h>
#include <napi/native_api.h>
#include <native_vsync/native_vsync.h>
#include "common/common.h"
#include "model_3d_sponza.h"

class EGLCore {
public:
    explicit EGLCore(){};
    ~EGLCore() {
    }
    void Init(void *window, int width, int height);
    void DrawLoop();
    void SetMode(int mode, bool useVRS);
    void Release();

private:
    void EglContextInit(void *window, int width, int height);
    void ExampleInit(int width, int height);
    EGLNativeWindowType m_eglWindow;
    EGLDisplay m_eglDisplay = EGL_NO_DISPLAY;
    EGLConfig m_eglConfig = EGL_NO_CONFIG_KHR;
    EGLSurface m_eglSurface = EGL_NO_SURFACE;
    EGLContext m_eglContext = EGL_NO_CONTEXT;
    int m_width, m_height;
    void *m_window;
    Model3DSponza *m_model3dSponza;
    bool m_exampleInited = false;
    bool m_eglInited = false;
};
#endif // RENDER_EGL_CORE_H
