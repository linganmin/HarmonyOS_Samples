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

#ifndef SAMPLE_OPENGL_RENDER_THREAD_H
#define SAMPLE_OPENGL_RENDER_THREAD_H

#include <thread>
#include <vector>
#if defined(__ARM_NEON) || defined(__ARM_NEON__)
#include <arm_neon.h>
#endif
#include <native_image/native_image.h>
#include <native_buffer/native_buffer.h>
#include <native_window/external_window.h>
#include <native_vsync/native_vsync.h>
#include <hilog/log.h>

#include "egl_render_context.h"
#include "shader_program.h"

namespace NativeXComponentSample {
using RenderTask = std::function<void(EglRenderContext &renderContext)>;

class RenderThread {
public:
    RenderThread();
    ~RenderThread() noexcept;
    void UpdateNativeWindow(void *window, uint64_t width, uint64_t height);
    
    void CreateEncoderSurface(void *window, int32_t width, int32_t height);
    void DeleteEncoderSurface(void);
    void AddBW(void);
    
    // disallow copy and move
    RenderThread(const RenderThread &other) = delete;
    void operator=(const RenderThread &other) = delete;
    RenderThread(RenderThread &&other) = delete;
    void operator=(RenderThread &&other) = delete;
    
    void PostTask(const RenderTask &task);
    
    uint64_t GetNativeImageSurfaceId() const
    {
        std::lock_guard<std::mutex> lock(nativeImageSurfaceIdMutex_);
        return nativeImageSurfaceId_;
    }
    
    OHNativeWindow* GetNativeImageWindow() const
    {
        std::lock_guard<std::mutex> lock(nativeImageSurfaceIdMutex_);
        return nativeImageWindow_;
    }
    
    void SetRenderAngle(bool isVertical)
    {
        isVertical_ = isVertical;
    }

    void ImageDraw(OHNativeWindowBuffer *InBuffer, OHNativeWindowBuffer *OutBuffer,
        int32_t imageWidth, int32_t imageHeight, int32_t viewWidth, int32_t viewHeight);
    OH_NativeImage *GetNativeImageEncoder();
    void SetCameraFront(bool isCameraFront);
    void UpdateCameraRotation(int rotation);
private:
    int xcomponentHeight_ = 0;
    int xcomponentWidth_ = 0;
    OHNativeWindow *xcomponentWindows_{nullptr};
    void Start();
    void ThreadMainLoop();
    void DrawScene();
    void UpdateImageResource(void *data, int32_t width, int32_t height, int32_t stride, bool mipmap = true);
    void ConfigSceneMatrix();
    
    std::atomic<bool> running_{false};
    std::thread thread_;
    std::thread::id threadId_;
    
    // Receive Vsync signal from the system to control rendering timing
    bool InitNativeVsync();
    void DestroyNativeVsync();
    OH_NativeVSync *nativeVsync_ = nullptr;
    static void OnVsync(long long timestamp, void *data);
    std::atomic<int> vSyncCnt_{0};
    mutable std::mutex wakeUpMutex_;
    std::condition_variable wakeUpCond_;
    bool wakeUp_ = false;
    mutable std::mutex taskMutex_;
    std::vector<RenderTask> tasks_;
    
    // renderContext initialization and cleanup
    bool InitRenderContext();
    void DestroyRenderContext();
    std::unique_ptr<EglRenderContext> renderContext_;
    
    // Perform resource creation and cleanup on the render thread
    bool CreateGLResources();
    void CleanGLResources();
    
    OHNativeWindow *nativeWindow_ = nullptr;
    EGLSurface eglSurface_ = EGL_NO_SURFACE;
    OHNativeWindow *encoderNativeWindow_ = nullptr;
    
    bool CreateNativeImage();
    void DestroyNativeImage();
    void DrawImage();
    static void OnNativeImageFrameAvailable(void *data);
    OH_OnFrameAvailableListener nativeImageFrameAvailableListener_{};
    OH_NativeImage *nativeImage_ = nullptr;
    GLuint nativeImageTexId_ = 9999U;
    mutable std::mutex nativeImageSurfaceIdMutex_;
    uint64_t nativeImageSurfaceId_ = 0;
    OHNativeWindow *nativeImageWindow_ = nullptr;
    std::atomic<int> availableFrameCnt_{0};
    std::unique_ptr<NativeXComponentSample::ShaderProgram> videoShader_;
    std::unique_ptr<NativeXComponentSample::ShaderProgram> imageShader_;
    std::unique_ptr<NativeXComponentSample::ShaderProgram> frameShader_;
    
    GLuint vertexArrayObject_ = 0;
    GLuint vertexBufferObject_ = 0;
    GLuint vertexFrameObject_ = 0;
    
    EGLSurface encoderSurface_ = EGL_NO_SURFACE;
    int32_t encoderWidth = 0;
    int32_t encoderHeight = 0;
    
    bool isVertical_ = true;
    bool isVertexShader = false;

    // image
    GLuint noiseImageTexId_ = 9999U;
    GLuint inTexId_ = 9999U;
    GLuint outTexId_ = 9999U;
    std::atomic<bool> isCameraFront_ = false;
    std::atomic<int> cameraRotation_{270};
    std::array<float, 16> drawCameraImageMatrix_;
    std::array<float, 16> drawImageMatrix_;
    OH_NativeBuffer *imageBuffer_ = nullptr;
    struct {
        uint32_t *data = nullptr;
        uint32_t width = 0;
        uint32_t height = 0;
        uint32_t stride = 0;
        bool changed = true;
    } noiseImage_;
};
} // namespace NativeXComponentSample

#endif // SAMPLE_OPENGL_RENDER_THREAD_H
