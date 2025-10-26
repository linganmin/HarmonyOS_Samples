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

#ifndef VULKAN_EGLRENDERCONTEXT_H
#define VULKAN_EGLRENDERCONTEXT_H

#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl3.h>
#include <GLES2/gl2ext.h>

namespace NativeXComponentSample {
class OpenGLRender {
public:
    OpenGLRender();
    ~OpenGLRender() noexcept;

    bool Init();
    bool IsEglContextReady() const
    {
        return eglContext_ != EGL_NO_CONTEXT;
    }
    
    EGLSurface CreateEglSurface(EGLNativeWindowType surface, const EGLint *attribList = nullptr);
    void DestroyEglSurface(EGLSurface surface);
    void MakeCurrent(EGLSurface surface) const;
    void SwapBuffers(EGLSurface surface) const;

protected:
    EGLDisplay eglDisplay_ = EGL_NO_DISPLAY;
    EGLContext eglContext_ = EGL_NO_CONTEXT;
    EGLConfig config_ = nullptr;

    bool hasEglSurfacelessContext_ = false;
    bool hasEglBufferAge_ = false;
    bool hasEglPartialUpdate_ = false;
    PFNEGLSETDAMAGEREGIONKHRPROC eglSetDamageRegionFunc_ = nullptr;
    PFNEGLSWAPBUFFERSWITHDAMAGEKHRPROC eglSwapBuffersWithDamageFunc_ = nullptr;
    PFNEGLCREATEIMAGEKHRPROC eglCreateImageFunc_ = nullptr;
    PFNGLEGLIMAGETARGETTEXTURE2DOESPROC eglImageTargetTexture2DOESFunc_ = nullptr;

private:
    void SetupEglExtensions();
};
}

#endif //VULKAN_EGLRENDERCONTEXT_H
