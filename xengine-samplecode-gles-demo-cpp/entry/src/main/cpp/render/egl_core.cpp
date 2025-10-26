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

#include "egl_core.h"

void EGLCore::EglContextInit(void *window, int width, int height)
{
    if (m_eglInited) {
        LOGD("EGLCore m_eglInited is true");
        return;
    }
    LOGI("EGLCore start init eglcontext");
    if ((nullptr == window) || (0 >= width) || (0 >= height)) {
        LOGE("EGLCore init failed: error params");
        return;
    }
    m_eglWindow = static_cast<EGLNativeWindowType>(window);
    m_eglDisplay = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (EGL_NO_DISPLAY == m_eglDisplay) {
        LOGE("EGLCore init failed: unable to get EGL display");
        return;
    }
    
    EGLint majorVersion;
    EGLint minorVersion;
    if (!eglInitialize(m_eglDisplay, &majorVersion, &minorVersion)) {
        LOGE("EGLCore init failed: unable to get initialize EGL display");
        return;
    }

    const EGLint maxConfigSize = 1;
    EGLint numConfigs;
    if (!eglChooseConfig(m_eglDisplay, ATTRIB_LIST, &m_eglConfig, maxConfigSize, &numConfigs)) {
        LOGE("EGLCore init failed: eglChooseConfig unable to choose configs");
        return;
    }

    if (nullptr == m_eglWindow) {
        LOGE("EGLCore init failed: eglWindow is null");
        return;
    }

    m_eglSurface = eglCreateWindowSurface(m_eglDisplay, m_eglConfig, m_eglWindow, NULL);
    if (nullptr == m_eglSurface) {
        LOGE("EGLCore init failed: eglCreateWindowSurface unable to create surface");
        return;
    }
    
    m_eglContext = eglCreateContext(m_eglDisplay, m_eglConfig, EGL_NO_CONTEXT, CONTEXT_ATTRIBS);
    if (!eglMakeCurrent(m_eglDisplay, m_eglSurface, m_eglSurface, m_eglContext)) {
        LOGE("EGLCore init failed: eglMakeCurrent failed");
        return;
    }
    m_eglInited = true;
}

void EGLCore::ExampleInit(int width, int height)
{
    if (m_exampleInited) {
        LOGD("EGLCore m_exampleInited is true");
        return;
    }
    LOGI("EGLCore start init model3dsponza");
    m_model3dSponza = new Model3DSponza();
    if (!m_model3dSponza->Init(width, height)) {
        m_exampleInited = false;
        return;
    }
    m_exampleInited = true;
}

void EGLCore::Init(void *window, int width, int height)
{
    m_window = window;
    EglContextInit(m_window, width, height);
    ExampleInit(width, height);
    m_width = width;
    m_height = height;
}

void EGLCore::DrawLoop()
{
    m_model3dSponza->Draw(m_width, m_height);
    eglSwapBuffers(m_eglDisplay, m_eglSurface);
}

void EGLCore::SetMode(int mode, bool useVRS)
{
    LOGD("EGLCore set upscale mode: %{public}d, use vrs: %{public}d", mode, useVRS);
    m_model3dSponza->SetUpscaleMode(mode);
    m_model3dSponza->SetUseVRS(useVRS);
}

void EGLCore::Release()
{
    if (m_model3dSponza) {
        delete m_model3dSponza;
    }
    
    LOGI("EGLCore release");
    if ((nullptr == m_eglDisplay) || (nullptr == m_eglSurface) || (!eglDestroySurface(m_eglDisplay, m_eglSurface))) {
        LOGE("EGLCore release eglDestroySurface failed");
    }

    if ((nullptr == m_eglDisplay) || (nullptr == m_eglContext) || (!eglDestroyContext(m_eglDisplay, m_eglContext))) {
        LOGE("EGLCore release eglDestroyContext failed");
    }

    if ((nullptr == m_eglDisplay) || (!eglTerminate(m_eglDisplay))) {
        LOGE("EGLCore release eglTerminate failed");
    }
}
