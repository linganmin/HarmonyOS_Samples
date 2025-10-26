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

#include "render_thread.h"
#include "common/common.h"
#include "transform/transform.h"
#include <hilog/log.h>

namespace NativeXComponentSample {
using namespace std::chrono_literals;
namespace Detail {
std::string vertexShader = R"delimiter(
attribute vec3 position;
attribute vec2 texCoord;

varying vec2 vTexCoord;

uniform mat4 matTransform;

void main()
{
    gl_Position = matTransform * vec4(position, 1.0);
    vTexCoord = texCoord;
}
)delimiter";

std::string fragmentShader = R"delimiter(
#extension GL_OES_EGL_image_external : require
precision highp float;
varying vec2 vTexCoord;
uniform samplerExternalOES texture;
uniform sampler2D textTexture;

void main()
{
    vec2 uv = vTexCoord.xy;
    uv.y = vTexCoord.x;
    uv.x = 1.0 - vTexCoord.y;
    vec4 image = texture2D(texture, vTexCoord);
    vec4 text = texture2D(textTexture, uv);
    float r = text.r + (1.0 - text.a) * image.r;
    float g = text.r + (1.0 - text.a) * image.g;
    float b = text.r + (1.0 - text.a) * image.b;
    gl_FragColor = vec4(r, g, b, 1.0);
}
)delimiter";

std::string fragmentShaderBW = R"delimiter(
#extension GL_OES_EGL_image_external : require
precision mediump float;
varying vec2 vTexCoord;
uniform samplerExternalOES texture;
void main()
{
    vec4 tc = texture2D(texture, vTexCoord);
    float color = tc.r * 0.3 + tc.g * 0.59 + tc.b * 0.11;
    gl_FragColor = vec4(color, color, color, 1.0);
}
)delimiter";

GLfloat vertices[] = {
    -1.0f, 1.0f,  0.0f, 1.0f, 1.0f,  // top left
    -1.0f, -1.0f, 0.0f, 1.0f, 0.0f,  // bottom left
    1.0f,  -1.0f, 0.0f, 0.0f, 0.0f,  // bottom right
    1.0f,  1.0f,  0.0f, 0.0f, 1.0f,  // top right
};
GLuint indices[] = {
    0, 1, 2,  // first triangle
    0, 2, 3   // second triangle
};
}  // namespace Detail

RenderThread::RenderThread()
{
    if (videoStatus) {
        Start();
    }
    
}

RenderThread::~RenderThread() noexcept { Release(); }

void RenderThread::Release() {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "RenderThread", "~RenderThread.");
    PostTask([this](EglRenderContext &renderContext) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "RenderThread", "~RenderThread PostTask.");
        CleanGLResources();
        DestroyNativeImage();
        UpdateNativeWindow(nullptr, 0, 0);
        DestroyNativeVsync();
        DestroyRenderContext();
    });

    running_ = false;
    if (thread_.joinable()) {
        thread_.join();
    }
}

bool RenderThread::InitRenderContext()
{
    renderContext_ = std::make_unique<EglRenderContext>();
    return renderContext_->Init();
}

void RenderThread::DestroyRenderContext()
{
    renderContext_.reset();
}

void RenderThread::CleanGLResources()
{
    glDeleteVertexArrays(1, &vertexArrayObject_);
    glDeleteBuffers(1, &vertexBufferObject_);
    shaderProgram_.reset();

    DeleteTextTexture();
}

bool RenderThread::CreateGLResources()
{
    shaderProgram_ = std::make_unique<ShaderProgram>(Detail::vertexShader, Detail::fragmentShader);
    if (!shaderProgram_->Valid()) {
        return false;
    }

    glGenVertexArrays(1, &vertexArrayObject_);
    glGenBuffers(1, &vertexBufferObject_);

    glBindVertexArray(vertexArrayObject_);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObject_);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Detail::vertices), Detail::vertices, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    return true;
}

void RenderThread::UpdateNativeWindow(void *window, uint64_t width, uint64_t height)
{
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "UpdateNativeWindow.");
    auto nativeWindow = reinterpret_cast<OHNativeWindow *>(window);
    PostTask([this, nativeWindow, width, height](EglRenderContext &renderContext) {
        if (nativeWindow_ != nativeWindow) {
            if (nativeWindow_ != nullptr) {
                (void)OH_NativeWindow_NativeObjectUnreference(nativeWindow_);
            }
            nativeWindow_ = nativeWindow;
            if (nativeWindow_ != nullptr) {
                (void)OH_NativeWindow_NativeObjectReference(nativeWindow_);
            }

            if (eglSurface_ != EGL_NO_SURFACE) {
                renderContext_->DestroyEglSurface(eglSurface_);
                eglSurface_ = EGL_NO_SURFACE;
                CleanGLResources();
            }
        }
        if (nativeWindow_ != nullptr) {
            (void)OH_NativeWindow_NativeWindowHandleOpt(nativeWindow_, SET_BUFFER_GEOMETRY, static_cast<int>(width),
                                                        static_cast<int>(height));
            if (eglSurface_ == EGL_NO_SURFACE) {
                eglSurface_ = renderContext_->CreateEglSurface(static_cast<EGLNativeWindowType>(nativeWindow_));
            }
            if (eglSurface_ == EGL_NO_SURFACE) {
                OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "xfl CreateEglSurface failed.");
                return;
            }
            renderContext_->MakeCurrent(eglSurface_);
            CreateGLResources();
        }
    });
}

void RenderThread::CreateEncoderSurface(void *window, int32_t width, int32_t height)
{
    if (encoderSurface_ != EGL_NO_SURFACE) {
        renderContext_->DestroyEglSurface(encoderSurface_);
        encoderSurface_ = EGL_NO_SURFACE;
    }

    encoderSurface_ = renderContext_->CreateEglSurface(static_cast<EGLNativeWindowType>(window));
    if (encoderSurface_ == EGL_NO_SURFACE) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "CreateEncoderSurface failed.");
    }

    encoderWidth_ = width;
    encoderHeight_ = height;
}

void RenderThread::DeleteEncoderSurface(void)
{
    if (encoderSurface_ != EGL_NO_SURFACE) {
        renderContext_->DestroyEglSurface(encoderSurface_);
        encoderSurface_ = EGL_NO_SURFACE;
    }
}

void* RenderThread::CreateTextImage(int32_t width, int32_t height)
{
    textImage_ = std::make_unique<SampleBitMap>();
    textImage_->SetWidth(width);
    textImage_->SetHeight(height);
    textImage_->Create();
    textImage_->DrawText();
    return textImage_->GetText();
}

void RenderThread::CreateTextTexture(int32_t width, int32_t height)
{
    if (textTexId_ == 9999) {
        glGenTextures(1, &textTexId_);
        glBindTexture(GL_TEXTURE_2D, textTexId_);
        // set the texture wrapping parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        // set texture filtering parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    }
    
    glBindTexture(GL_TEXTURE_2D, textTexId_);
     void *data = CreateTextImage(width, height);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    glBindTexture(GL_TEXTURE_2D, 0);
}

void RenderThread::DeleteTextTexture(void)
{
    if (textTexId_ != 0U) {
        glDeleteTextures(1, &textTexId_);
        textTexId_ = 0U;
    }
    textImage_.reset();
}

void RenderThread::Start()
{
    if (running_) {
        return;
    }

    running_ = true;
    thread_ = std::thread([this]() {
        ThreadMainLoop();
        // Ensure that the creation and destruction of renderContext are executed within the rendering thread
        CleanGLResources();
        DestroyNativeImage();
        UpdateNativeWindow(nullptr, 0, 0);
        DestroyNativeVsync();
        DestroyRenderContext();
        running_ = false;
    });
}

void RenderThread::OnVsync(long long timestamp, void *data)
{
    auto renderThread = reinterpret_cast<RenderThread *>(data);
    if (renderThread == nullptr) {
        return;
    }

    renderThread->vSyncCnt_++;
    renderThread->wakeUpCond_.notify_one();
}

bool RenderThread::InitNativeVsync()
{
    nativeVsync_ = OH_NativeVSync_Create(DEMO_NAME, strlen(DEMO_NAME));
    if (nativeVsync_ == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "Create NativeVSync failed.");
        return false;
    }
    (void)OH_NativeVSync_RequestFrame(nativeVsync_, &RenderThread::OnVsync, this);
    return true;
}

void RenderThread::DestroyNativeVsync()
{
    if (nativeVsync_ != nullptr) {
        OH_NativeVSync_Destroy(nativeVsync_);
        nativeVsync_ = nullptr;
    }
}

OHNativeWindow *RenderThread::GetNativeImageWindow() {
    if (nativeImageWindow_ != nullptr) {
        return nativeImageWindow_;
    }

    while (nativeImageWindow_ == nullptr) {
        std::unique_lock<std::mutex> lock(nativeImageSurfaceIdMutex_);
        wakeUpCond_.wait(lock);
    }
    
    return nativeImageWindow_;
}

void RenderThread::OnNativeImageFrameAvailable(void *data)
{
    auto renderThread = reinterpret_cast<RenderThread *>(data);
    if (renderThread == nullptr) {
        return;
    }
    renderThread->availableFrameCnt_++; 
    renderThread->wakeUpCond_.notify_one();
}

bool RenderThread::CreateNativeImage()
{
    nativeImage_ = OH_NativeImage_Create(-1, GL_TEXTURE_EXTERNAL_OES);
    if (nativeImage_ == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "OH_NativeImage_Create failed.");
        return false;
    }
    int ret = 0;
    {
        std::lock_guard<std::mutex> lock(nativeImageSurfaceIdMutex_);
        nativeImageWindow_ = OH_NativeImage_AcquireNativeWindow(nativeImage_);
        ret = OH_NativeImage_GetSurfaceId(nativeImage_, &nativeImageSurfaceId_);
    }
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeImage_GetSurfaceId failed, ret is %{public}d.", ret);
        return false;
    }

    nativeImageFrameAvailableListener_.context = this;
    nativeImageFrameAvailableListener_.onFrameAvailable = &RenderThread::OnNativeImageFrameAvailable;
    ret = OH_NativeImage_SetOnFrameAvailableListener(nativeImage_, nativeImageFrameAvailableListener_);
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeImage_SetOnFrameAvailableListener failed, ret is %{public}d.", ret);
        return false;
    }

    return true;
}

void RenderThread::DestroyNativeImage()
{
    if (nativeImageTexId_ != 0U) {
        glDeleteTextures(1, &nativeImageTexId_);
        nativeImageTexId_ = 0U;
    }

    if (nativeImage_ != nullptr) {
        OH_NativeWindow_DestroyNativeWindow(nativeImageWindow_);
        nativeImageWindow_ = nullptr;
        (void)OH_NativeImage_UnsetOnFrameAvailableListener(nativeImage_);
        OH_NativeImage_Destroy(&nativeImage_);
        nativeImage_ = nullptr;
    }
}

void RenderThread::ThreadMainLoop()
{
    threadId_ = std::this_thread::get_id();
    if (!InitRenderContext()) {
        return;
    }
    if (!InitNativeVsync()) {
        return;
    }
    if (!CreateNativeImage()) {
        return;
    }
    while (running_) {
        {
            std::unique_lock<std::mutex> lock(wakeUpMutex_);
            wakeUpCond_.wait(lock, [this]() { return wakeUp_ || vSyncCnt_ > 0 || availableFrameCnt_ > 0; });
            wakeUp_ = false;
            vSyncCnt_--;
            (void)OH_NativeVSync_RequestFrame(nativeVsync_, &RenderThread::OnVsync, this);
        }
        
        std::vector<RenderTask> tasks;
        {
            std::unique_lock<std::mutex> lock(taskMutex_);
            tasks.swap(tasks_);
        }
        for (const auto &task : tasks) {
            task(*renderContext_);
        }

        if (availableFrameCnt_ <= 0) {
            continue;
        }
        DrawImage();
        availableFrameCnt_--;
        if (availableFrameCnt_ == 0) {
            if (!Transform::GetInstance().GetIsDecStarted() && Transform::GetInstance().GetIsEncStarted()) {
                Transform::GetInstance().NotifyEndOfStream();
                break;
            }
            continue;
        }
    }
}

void RenderThread::PostTask(const RenderTask &task)
{
    if (!running_) {
        OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, "RenderThread",
                     "PostTask failed: RenderThread is not running");
        return;
    }

    {
        std::lock_guard<std::mutex> lock(taskMutex_);
        tasks_.push_back(task);
    }

    if (std::this_thread::get_id() != threadId_) {
        std::lock_guard<std::mutex> lock(wakeUpMutex_);
        wakeUp_ = true;
        wakeUpCond_.notify_one();
    }
}

void ComputeTransformByMatrix(int32_t &transform, float transformMatrix[16])
{
    float transformMatrixR90[16] = { 0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    float transformMatrixR180[16] = { -1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    float transformMatrixR270[16] = { 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    float transformMatrixFlipH[16] = { -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    float transformMatrixFlipV[16] = { 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    float transformMatrixFlipHR90[16] = { 0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    float transformMatrixFlipVR90[16] = { 0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    float transformMatrixFlipHR180[16] = { 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    float transformMatrixFlipVR180[16] = { -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    float transformMatrixFlipHR270[16] = { 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    float transformMatrixFlipVR270[16] = { 0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    switch (transform) {
        case 0:
            break;
        case 1:
            memcpy(transformMatrix, transformMatrixR90, sizeof(float) * 16);
            break;
        case 2:
            memcpy(transformMatrix, transformMatrixR180, sizeof(float) * 16);
            break;
        case 3:
            memcpy(transformMatrix, transformMatrixR270, sizeof(float) * 16);
            break;
        case 4:
            memcpy(transformMatrix, transformMatrixFlipH, sizeof(float) * 16);
            break;
        case 5:
            memcpy(transformMatrix, transformMatrixFlipV, sizeof(float) * 16);
            break;
        case 6:
            memcpy(transformMatrix, transformMatrixFlipHR90, sizeof(float) * 16);
            break;
        case 7:
            memcpy(transformMatrix, transformMatrixFlipVR90, sizeof(float) * 16);
            break;
        case 8:
            memcpy(transformMatrix, transformMatrixFlipHR180, sizeof(float) * 16);
            break;
        case 9:
            memcpy(transformMatrix, transformMatrixFlipVR180, sizeof(float) * 16);
            break;
        case 10:
            memcpy(transformMatrix, transformMatrixFlipHR270, sizeof(float) * 16);
            break;
        case 11:
            memcpy(transformMatrix, transformMatrixFlipVR270, sizeof(float) * 16);
            break;
        default:
            break;
    }
}

void RenderThread::DrawImage()
{
    if (nativeImageTexId_ == 9999) {
        glGenTextures(1, &nativeImageTexId_);
        glBindTexture(GL_TEXTURE_EXTERNAL_OES, nativeImageTexId_);
        // set the texture wrapping parameters
        glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_WRAP_T, GL_REPEAT);
        // set texture filtering parameters
        glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_EXTERNAL_OES, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    }
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "DrawImage.");

    if (eglSurface_ == EGL_NO_SURFACE) {
        OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, "RenderThread", "eglSurface_ is EGL_NO_SURFACE");
        return;
    }

    OH_NativeImage_AttachContext(nativeImage_, nativeImageTexId_);

    int32_t ret = OH_NativeImage_UpdateSurfaceImage(nativeImage_);
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeImage_UpdateSurfaceImage failed, ret: %{public}d, texId: %{public}d", ret,
                     nativeImageTexId_);
        return;
    }
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "OH_NativeImage_UpdateSurfaceImage succeed.");

    OHNativeWindow *nativeWindow = OH_NativeImage_AcquireNativeWindow(nativeImage_);
    int32_t transformTmp = 0;
    int code = NativeWindowOperation::GET_TRANSFORM;
    OH_NativeWindow_NativeWindowHandleOpt(nativeWindow, code, &transformTmp);

    ret = OH_NativeImage_GetTransformMatrix(nativeImage_, matrix_);
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeImage_GetTransformMatrix failed, ret: %{public}d", ret);
        return;
    }

    if (isCameraRotated_) {
        transformTmp = 3;
        ComputeTransformByMatrix(transformTmp, matrix_);
    } else {
        transformTmp = 2;
        ComputeTransformByMatrix(transformTmp, matrix_);
    }

    DrawPreviewImage();

    if (encoderSurface_ != EGL_NO_SURFACE) {
        DrawEncoderImage();
    }
}

void RenderThread::DrawPreviewImage()
{
    renderContext_->MakeCurrent(eglSurface_);

    int viewWidth = 0;
    int viewHeight = 0;
    OH_NativeWindow_NativeWindowHandleOpt(nativeWindow_, GET_BUFFER_GEOMETRY, &viewHeight, &viewWidth);
    
    glViewport(0, 0, viewWidth, viewHeight);

    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    shaderProgram_->Use();
    shaderProgram_->SetInt("texture", 0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, nativeImageTexId_);
    if (isTranscoding) {
        int32_t transformTmp = 1;
        ComputeTransformByMatrix(transformTmp, matrix_);
    }
    shaderProgram_->SetMatrix4v("matTransform", matrix_, 16, false);
    
    CreateTextTexture(viewWidth, viewHeight);
    shaderProgram_->SetInt("textTexture", 1);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textTexId_);

    glBindVertexArray(vertexArrayObject_);
    glEnable(GL_DEPTH_TEST);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, Detail::indices);

    renderContext_->SwapBuffers(eglSurface_);
}

void RenderThread::DrawEncoderImage()
{
    renderContext_->MakeCurrent(encoderSurface_);

    int64_t timestamp = OH_NativeImage_GetTimestamp(nativeImage_);
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "OH_NativeImage_GetTimestamp: %{public}ld",
                 timestamp);

    renderContext_->SetPresentationTime(encoderSurface_, static_cast<EGLnsecsANDROID>(timestamp));

    glViewport(0, 0, encoderWidth_, encoderHeight_);

    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    shaderProgram_->Use();
    shaderProgram_->SetInt("texture", 0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, nativeImageTexId_);
    shaderProgram_->SetMatrix4v("matTransform", matrix_, 16, false);

    CreateTextTexture(encoderWidth_, encoderHeight_);
    shaderProgram_->SetInt("textTexture", 1);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textTexId_);

    glBindVertexArray(vertexArrayObject_);
    glEnable(GL_DEPTH_TEST);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, Detail::indices);
    renderContext_->SwapBuffers(encoderSurface_);
}

}  // namespace NativeXComponentSample
