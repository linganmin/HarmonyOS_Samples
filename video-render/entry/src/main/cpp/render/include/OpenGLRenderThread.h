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

#ifndef NATIVEIMAGEDEMO_RENDER_THREAD_H
#define NATIVEIMAGEDEMO_RENDER_THREAD_H

#include <thread>
#include <vector>
#include <native_image/native_image.h>
#include <native_window/external_window.h>
#include <native_vsync/native_vsync.h>
#include "OpenGLRender.h"
#include "ShaderProgram.h"

namespace NativeXComponentSample {
using RenderTask = std::function<void(OpenGLRender &renderContext)>;

class OpenGLRenderThread {
public:
    OpenGLRenderThread();
    ~OpenGLRenderThread() noexcept;
    // disallow copy and move
    OpenGLRenderThread(const OpenGLRenderThread &other) = delete;
    void operator=(const OpenGLRenderThread &other) = delete;
    OpenGLRenderThread(OpenGLRenderThread &&other) = delete;
    void operator=(OpenGLRenderThread &&other) = delete;
    
    void Release();
    void UpdateNativeWindow(void *window, uint64_t width, uint64_t height);
    void CreateEncoderSurface(void *window, int32_t width, int32_t height);
    void DeleteEncoderSurface(void);
    void PostTask(const RenderTask &task);

    uint64_t GetNativeImageSurfaceId() const
    {
        std::lock_guard<std::mutex> lock(nativeImageSurfaceIdMutex_);
        return nativeImageSurfaceId_;
    }
    
    OHNativeWindow* GetNativeImageWindow();
 
private:
    void Start();
    void ThreadMainLoop();

    std::atomic<bool> running_{ false };
    std::thread thread_;
    std::thread::id threadId_;
    
    bool InitNativeVsync();
    void DestroyNativeVsync();
    OH_NativeVSync *nativeVsync_ = nullptr;
    static void OnVsync(long long timestamp, void *data);
    std::atomic<int> vSyncCnt_{ 0 };
    mutable std::mutex wakeUpMutex_;
    std::condition_variable wakeUpCond_;
    bool wakeUp_ = false;
    mutable std::mutex taskMutex_;
    std::vector<RenderTask> tasks_;

    // renderContext 初始化和清理
    bool InitRenderContext();
    void DestroyRenderContext();
    std::unique_ptr<OpenGLRender> renderContext_;

    // 在渲染线程中执行资源的创建与清理
    bool CreateGLResources();
    void CleanGLResources();

    OHNativeWindow *nativeWindow_ = nullptr;
    EGLSurface eglSurface_ = EGL_NO_SURFACE;

    bool CreateNativeImage();
    void DestroyNativeImage();
    void DrawImage();
    void DrawVideoImage();
    static void OnNativeImageFrameAvailable(void *data);
    OH_OnFrameAvailableListener nativeImageFrameAvailableListener_{};
    OH_NativeImage *nativeImage_ = nullptr;
    GLuint nativeImageTexId_ = 9999U;
    mutable std::mutex nativeImageSurfaceIdMutex_;
    uint64_t nativeImageSurfaceId_ = 0;
    OHNativeWindow *nativeImageWindow_ = nullptr;
    std::atomic<int> availableFrameCnt_{ 0 };
    std::unique_ptr<ShaderProgram> shaderProgram_;

    GLuint vertexArrayObject_ = 0;
    GLuint vertexBufferObject_ = 0;

    EGLSurface encoderSurface_ = EGL_NO_SURFACE;
    int32_t encoderWidth_ = 0;
    int32_t encoderHeight_ = 0;
    
    std::atomic<bool> isTranscoding { false };
    float matrix_[16];
};
}  // namespace NativeXComponentSample
#endif  // NATIVEIMAGEDEMO_RENDER_THREAD_H
