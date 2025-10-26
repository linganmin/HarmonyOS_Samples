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

#include "egl_render_context.h"
#include <cstring>
#include "common/common.h"
#include <hilog/log.h>

namespace NativeXComponentSample {
bool CheckEglExtension(const char *extensions, const char *extension)
{
    size_t extLen = strlen(extension);
    const char *end = extensions + strlen(extensions);

    while (extensions < end) {
        size_t n = 0;
        /* Skip whitespaces, if any */
        if (*extensions == ' ') {
            extensions++;
            continue;
        }

        n = strcspn(extensions, " ");
        /* Compare strings */
        if (n == extLen && strncmp(extension, extensions, n) == 0) {
            return true; /* Found */
        }
        extensions += n;
    }
    /* Not found */
    return false;
}

#define CASE_EGL_STR(value) \
    case value:             \
        return #value
const char *GetEglErrorString()
{
    EGLint error = eglGetError();
    switch (error) {
        CASE_EGL_STR(EGL_SUCCESS);
        CASE_EGL_STR(EGL_NOT_INITIALIZED);
        CASE_EGL_STR(EGL_BAD_ACCESS);
        CASE_EGL_STR(EGL_BAD_ALLOC);
        CASE_EGL_STR(EGL_BAD_ATTRIBUTE);
        CASE_EGL_STR(EGL_BAD_CONTEXT);
        CASE_EGL_STR(EGL_BAD_CONFIG);
        CASE_EGL_STR(EGL_BAD_CURRENT_SURFACE);
        CASE_EGL_STR(EGL_BAD_DISPLAY);
        CASE_EGL_STR(EGL_BAD_SURFACE);
        CASE_EGL_STR(EGL_BAD_MATCH);
        CASE_EGL_STR(EGL_BAD_PARAMETER);
        CASE_EGL_STR(EGL_BAD_NATIVE_PIXMAP);
        CASE_EGL_STR(EGL_BAD_NATIVE_WINDOW);
        CASE_EGL_STR(EGL_CONTEXT_LOST);
        default:
            return "Unknow Error";
    }
}
#undef CASE_EGL_STR

constexpr const char EGL_KHR_SURFACELESS_CONTEXT[] = "EGL_KHR_surfaceless_context";

using GetPlatformDisplayExt = PFNEGLGETPLATFORMDISPLAYEXTPROC;
constexpr const char *EGL_GET_PLATFORM_DISPLAY_EXT = "eglGetPlatformDisplayEXT";

static EGLDisplay GetPlatformEglDisplay(
    [[maybe_unused]]EGLenum platform, void *native_display, [[maybe_unused]]const EGLint *attrib_list)
{
    return eglGetDisplay((EGLNativeDisplayType)native_display);
}

EglRenderContext::EglRenderContext() {}

EglRenderContext::~EglRenderContext() noexcept
{
    if (eglDisplay_ == EGL_NO_DISPLAY) {
        return;
    }

    eglDestroyContext(eglDisplay_, eglContext_);
    eglMakeCurrent(eglDisplay_, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
    eglTerminate(eglDisplay_);
    eglReleaseThread();

    eglDisplay_ = EGL_NO_DISPLAY;
    eglContext_ = EGL_NO_CONTEXT;
}

bool EglRenderContext::Init()
{
    if (IsEglContextReady()) {
        return true;
    }

    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "EglRenderContext", "EglRenderContext::Init begin.");
    eglDisplay_ = GetPlatformEglDisplay(EGL_PLATFORM_OHOS_KHR, EGL_DEFAULT_DISPLAY, NULL);
    if (eglDisplay_ == EGL_NO_DISPLAY) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "EglRenderContext",
                     "EglRenderContext::Init: failed to create eglDisplay, error: %{public}s.", GetEglErrorString());
        return false;
    }

    EGLint major;
    EGLint minor;
    if (eglInitialize(eglDisplay_, &major, &minor) == EGL_FALSE) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "EglRenderContext",
                     "EglRenderContext::Init: Failed to initialize EGLDisplay, error: %{public}s.",
                     GetEglErrorString());
    }
    SetupEglExtensions();

    if (eglBindAPI(EGL_OPENGL_ES_API) == EGL_FALSE) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "EglRenderContext",
                     "EglRenderContext::Init: Failed to bind OpenGL ES API, error: %{public}s.", GetEglErrorString());
        return false;
    }
    EGLint count;
    EGLint configAttribs[] = { EGL_SURFACE_TYPE,
                               EGL_WINDOW_BIT,
                               EGL_RED_SIZE,
                               8,
                               EGL_GREEN_SIZE,
                               8,
                               EGL_BLUE_SIZE,
                               8,
                               EGL_ALPHA_SIZE,
                               8,
                               EGL_RENDERABLE_TYPE,
                               EGL_OPENGL_ES3_BIT,
                               EGL_NONE };
    if (eglChooseConfig(eglDisplay_, configAttribs, &config_, 1, &count) == EGL_FALSE) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "EglRenderContext",
                     "EglRenderContext::Init: Failed to bind choose config, error: %{public}s.", GetEglErrorString());
        return false;
    }
    const EGLint contextAttribs[] = { EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE };
    eglContext_ = eglCreateContext(eglDisplay_, config_, EGL_NO_CONTEXT, contextAttribs);
    if (eglContext_ == EGL_NO_CONTEXT) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "EglRenderContext",
                     "EglRenderContext::Init: Failed to bind create context, error: %{public}s.", GetEglErrorString());
        return false;
    }

    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "EglRenderContext", "EglRenderContext::Init end.");
    return true;
}

void EglRenderContext::SetupEglExtensions()
{
    const char *extensions = eglQueryString(eglDisplay_, EGL_EXTENSIONS);
    if (extensions == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "EglRenderContext",
                     "EglRenderContext::SetupEglExtensions: not extensions.");
        return;
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "EglRenderContext", "EglRenderContext extensions: %{public}s.",
                 extensions);
    hasEglSurfacelessContext_ = CheckEglExtension(extensions, EGL_KHR_SURFACELESS_CONTEXT);

    // now WGR product's EGL support these extensions but they are not in the EGL_EXTENSIONS lists.
    hasEglBufferAge_ = true;
    hasEglPartialUpdate_ = true;
    eglSetDamageRegionFunc_ =
        reinterpret_cast<PFNEGLSETDAMAGEREGIONKHRPROC>(eglGetProcAddress("eglSetDamageRegionKHR"));
    eglSwapBuffersWithDamageFunc_ =
        reinterpret_cast<PFNEGLSWAPBUFFERSWITHDAMAGEKHRPROC>(eglGetProcAddress("eglSwapBuffersWithDamageKHR"));

    // for shm optimize
    eglCreateImageFunc_ = reinterpret_cast<PFNEGLCREATEIMAGEKHRPROC>(eglGetProcAddress("eglCreateImageKHR"));
    eglImageTargetTexture2DOESFunc_ =
        reinterpret_cast<PFNGLEGLIMAGETARGETTEXTURE2DOESPROC>(eglGetProcAddress("glEGLImageTargetTexture2DOES"));
}

void EglRenderContext::MakeCurrent(EGLSurface surface) const
{
    EGLSurface currSurface = surface;
    if (!eglMakeCurrent(eglDisplay_, currSurface, currSurface, eglContext_)) {
        EGLint surfaceId = -1;
        eglQuerySurface(eglDisplay_, surface, EGL_CONFIG_ID, &surfaceId);
        OH_LOG_Print(
            LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "EglRenderContext",
            "EglRenderContext::MakeCurrent: Failed to make current on EGLSurface %{public}d, error is %{public}s.",
            surfaceId, GetEglErrorString());
    }
}

void EglRenderContext::SwapBuffers(EGLSurface surface) const
{
    EGLBoolean ret = eglSwapBuffers(eglDisplay_, surface);
    if (ret == EGL_FALSE) {
        EGLint surfaceId = -1;
        eglQuerySurface(eglDisplay_, surface, EGL_CONFIG_ID, &surfaceId);
        OH_LOG_Print(
            LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "EglRenderContext",
            "EglRenderContext::SwapBuffers: Failed to SwapBuffers on EGLSurface %{public}d, error is %{public}s.",
            surfaceId, GetEglErrorString());
    }
}

void EglRenderContext::DestroyEglSurface(EGLSurface surface)
{
    if (!eglDestroySurface(eglDisplay_, surface)) {
        EGLint surfaceId = -1;
        eglQuerySurface(eglDisplay_, surface, EGL_CONFIG_ID, &surfaceId);
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "EglRenderContext",
                     "EglRenderContext::DestroyEglWindowSurface: Failed to DestroySurface on EGLSurface %{public}d, "
                     "error is %{public}s.",
                     surfaceId, GetEglErrorString());
    }
}

EGLSurface EglRenderContext::CreateEglSurface(EGLNativeWindowType eglNativeWindow, const EGLint *attribList)
{
    if (!IsEglContextReady()) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "EglRenderContext",
                     "EglRenderContext::CreateEglWindowSurface: EGL context has not initialized");
        return EGL_NO_SURFACE;
    }

    eglMakeCurrent(eglDisplay_, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);

    EGLSurface surface = eglCreateWindowSurface(eglDisplay_, config_, eglNativeWindow, attribList);
    if (surface == EGL_NO_SURFACE) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "EglRenderContext",
                     "EglRenderContext::CreateEglWindowSurface: Failed to create eglSurface, error is %{public}s.",
                     GetEglErrorString());
        return EGL_NO_SURFACE;
    }

    return surface;
}

bool EglRenderContext::SetPresentationTime([[maybe_unused]]EGLSurface surface, [[maybe_unused]]EGLnsecsANDROID time)
{
//    EGLSurface currSurface = surface;
    EGLBoolean ret = 0;  //eglPresentationTimeANDROID(eglDisplay_, currSurface, time);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "EglRenderContext",
                 "EglRenderContext::eglPresentationTimeANDROID ret : %{public}d", ret);
    return ret;
}
}  // namespace NativeXComponentSample
