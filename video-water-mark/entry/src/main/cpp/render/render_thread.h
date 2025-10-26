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
#include "egl_render_context.h"
#include "shader_program.h"
#include <drawing/sample_bitmap.h>

namespace NativeXComponentSample {
using RenderTask = std::function<void(EglRenderContext &renderContext)>;

class RenderThread {
public:
    RenderThread();
    ~RenderThread() noexcept;
    // disallow copy and move
    RenderThread(const RenderThread &other) = delete;
    void operator=(const RenderThread &other) = delete;
    RenderThread(RenderThread &&other) = delete;
    void operator=(RenderThread &&other) = delete;
    
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

    void SetCameraRotation(bool isEnabled)
    {
        isCameraRotated_ = isEnabled;
    }
 
private:
    void Start();
    void ThreadMainLoop();

    std::atomic<bool> running_{ false };
    std::thread thread_;
    std::thread::id threadId_;

    // 接收系统发送的Vsync信号，用于控制渲染节奏
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
    std::unique_ptr<EglRenderContext> renderContext_;

    // 在渲染线程中执行资源的创建与清理
    bool CreateGLResources();
    void CleanGLResources();

    OHNativeWindow *nativeWindow_ = nullptr;
    EGLSurface eglSurface_ = EGL_NO_SURFACE;

    bool CreateNativeImage();
    void DestroyNativeImage();
    void DrawImage();
    void DrawPreviewImage();
    void DrawEncoderImage();
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

    bool isCameraRotated_ = false;
    std::atomic<bool> isTranscoding { false };
    float matrix_[16];
    
    void* CreateTextImage(int32_t width, int32_t height);
    void CreateTextTexture(int32_t width, int32_t height);
    void DeleteTextTexture(void);
    std::unique_ptr<SampleBitMap> textImage_;
    GLuint textTexId_ = 9999U;
    
    bool videoStatus = true;
};
}  // namespace NativeXComponentSample
#endif  // NATIVEIMAGEDEMO_RENDER_THREAD_H
