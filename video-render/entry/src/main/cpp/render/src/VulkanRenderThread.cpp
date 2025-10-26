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

#include "VulkanRenderThread.h"
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>
#include <array>
#include <hilog/log.h>
#include <iostream>
#include <native_buffer/native_buffer.h>

namespace NativeXComponentSample {
const unsigned int LOG_PRINT_DOMAIN = 0XFF00;

constexpr char DEMO_NAME[] = "NativeImage";

VulkanRenderThread::VulkanRenderThread() { Start(); }

VulkanRenderThread::~VulkanRenderThread() noexcept {
    PostTask([this](VulkanRender &renderContext) {
        DestroyNativeImage();
        UpdateNativeWindow(nullptr, 0, 0);
        DestroyNativeVsync();
    });

    running_ = false;
    if (thread_.joinable()) {
        thread_.join();
    }
}

bool VulkanRenderThread::InitRenderContext() {
    vulkanRenderContext_ = std::make_unique<NativeXComponentSample::VulkanRender>();
    return true;
}

OHNativeWindow *VulkanRenderThread::GetNativeImageWindow() {
    if (nativeImageWindow_ != nullptr) {
        return nativeImageWindow_;
    }
    while (nativeImageWindow_ == nullptr) {
        std::unique_lock<std::mutex> lock(nativeImageSurfaceIdMutex_);
        wakeUpCond_.wait(lock);
    }
    return nativeImageWindow_;
}

// [Start update_native_window]
void VulkanRenderThread::UpdateNativeWindow(void *window, uint64_t width, uint64_t height) {
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "UpdateNativeWindow.");
    auto nativeWindow = reinterpret_cast<OHNativeWindow *>(window);
    PostTask([this, nativeWindow, width, height](VulkanRender &renderContext) {
        if (nativeWindow_ != nativeWindow) {
            if (nativeWindow_ != nullptr) {
                (void)OH_NativeWindow_NativeObjectUnreference(nativeWindow_);
            }
            nativeWindow_ = nativeWindow;
            if (nativeWindow_ != nullptr) {
                (void)OH_NativeWindow_NativeObjectReference(nativeWindow_);
            }
        }
        if (nativeWindow_ != nullptr) {
            vulkanRenderContext_->SetupWindow(nativeWindow_);
        }
    });
}
// [End update_native_window]

void VulkanRenderThread::Start() {
    if (running_) {
        return;
    }

    running_ = true;
    thread_ = std::thread([this]() {
        ThreadMainLoop();
        // Ensure that the creation and destruction of renderContext are executed within the rendering thread
        DestroyNativeImage();
        UpdateNativeWindow(nullptr, 0, 0);
        DestroyNativeVsync();
        running_ = false;
    });
}

void VulkanRenderThread::OnVsync(long long timestamp, void *data) {
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "OnVsync %{public}llu", timestamp);
    auto renderThread = reinterpret_cast<VulkanRenderThread *>(data);
    if (renderThread == nullptr) {
        return;
    }

    renderThread->vSyncCnt_++;
    renderThread->wakeUpCond_.notify_one();
}

bool VulkanRenderThread::InitNativeVsync() {
    nativeVsync_ = OH_NativeVSync_Create(DEMO_NAME, strlen(DEMO_NAME));
    if (nativeVsync_ == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "Create NativeVSync failed.");
        return false;
    }
    (void)OH_NativeVSync_RequestFrame(nativeVsync_, &VulkanRenderThread::OnVsync, this);
    return true;
}

void VulkanRenderThread::DestroyNativeVsync() {
    if (nativeVsync_ != nullptr) {
        OH_NativeVSync_Destroy(nativeVsync_);
        nativeVsync_ = nullptr;
    }
}

void VulkanRenderThread::OnNativeImageFrameAvailable(void *data) {
    OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "OnNativeImageFrameAvailable.");
    auto renderThread = reinterpret_cast<VulkanRenderThread *>(data);
    if (renderThread == nullptr) {
        return;
    }
    renderThread->availableFrameCnt_++;
    renderThread->wakeUpCond_.notify_one();
}

// [Start create_native_image]
bool VulkanRenderThread::CreateNativeImage() {
    nativeImage_ = OH_NativeImage_Create(-1, GL_TEXTURE_EXTERNAL_OES);
    if (nativeImage_ == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "OH_NativeImage_Create failed.");
        return false;
    }
    int ret = 0;
    {
        std::lock_guard<std::mutex> Lock(nativeImageSurfaceIdMutex_);
        nativeImageWindow_ = OH_NativeImage_AcquireNativeWindow(nativeImage_);
        ret = OH_NativeImage_GetSurfaceId(nativeImage_, &nativeImageSurfaceId_);
    }
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeImage_GetSurfaceId failed, ret is %{public}d.", ret);
        return false;
    }

    nativeImageFrameAvailableListener_.context = this;
    nativeImageFrameAvailableListener_.onFrameAvailable = &VulkanRenderThread::OnNativeImageFrameAvailable;
    ret = OH_NativeImage_SetOnFrameAvailableListener(nativeImage_, nativeImageFrameAvailableListener_);
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeImage_SetonFrameAvailableListener failed, ret is %{public}d.", ret);
        return false;
    }
    return true;
}
// [End create_native_image]

void VulkanRenderThread::DestroyNativeImage() {
    if (nativeImage_ != nullptr) {
        (void)OH_NativeImage_UnsetOnFrameAvailableListener(nativeImage_);
        OH_NativeImage_Destroy(&nativeImage_);
        nativeImage_ = nullptr;
    }
}

// [Start vulkan_render_thread]
void VulkanRenderThread::ThreadMainLoop() {
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
            OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "Waiting for Vsync.");
            std::unique_lock<std::mutex> Lock(wakeUpMutex_);
            wakeUpCond_.wait(Lock, [this]() { return wakeup_ || vSyncCnt_ > 0 || availableFrameCnt_ > 0; });
            wakeup_ = false;
            vSyncCnt_--;
            (void)OH_NativeVSync_RequestFrame(nativeVsync_, &VulkanRenderThread::OnVsync, this);
        }

        std::vector<VulkanRenderTask> tasks;
        {
            std::lock_guard<std::mutex> lock(taskMutex_);
            tasks.swap(tasks_);
        }
        for (const auto &task : tasks) {
            task(*vulkanRenderContext_);
        }
        if (availableFrameCnt_ <= 0) {
            continue;
        }
        DrawImage();
        availableFrameCnt_--;
    }
}
// [End vulkan_render_thread]

void VulkanRenderThread::PostTask(const VulkanRenderTask &task) {
    if (!running_) {
        OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, "RenderThread",
                     "PostTask failed: RenderThread is not running");
        return;
    }

    std::lock_guard<std::mutex> lock(taskMutex_);
    tasks_.push_back(task);

    if (std::this_thread::get_id() != threadId_) {
        std::lock_guard<std::mutex> lock(wakeUpMutex_);
        wakeup_ = true;
        wakeUpCond_.notify_one();
    }
}

void ComputeTransform(int32_t &transform, float transformMatrix[16]) {
    float transformMatrixR0[16] = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixR90[16] = {0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixR180[16] = {-1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixR270[16] = {0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipH[16] = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipV[16] = {1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipHR90[16] = {0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipVR90[16] = {0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipHR180[16] = {1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipVR180[16] = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipHR270[16] = {1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    float transformMatrixFlipVR270[16] = {0, -1, 0, 0, -1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    switch (transform) {
    case 0:
        memcpy(transformMatrix, transformMatrixR0, sizeof(float) * 16);
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

// [Start draw_image]
void VulkanRenderThread::DrawImage() {
    OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "VulkanRenderThread", "DrawImage.");
    int ret;
    OHNativeWindowBuffer *inBuffer = nullptr;
    OH_NativeBuffer *nativeBuffer = nullptr;
    int32_t fenceFd1 = -1;
    ret = OH_NativeImage_AcquireNativeWindowBuffer(nativeImage_, &inBuffer, &fenceFd1);
    ret = OH_NativeWindow_NativeObjectReference(inBuffer);
    ret = OH_NativeBuffer_FromNativeWindowBuffer(inBuffer, &nativeBuffer);
    if (nativeBuffer == nullptr) {
        OH_NativeWindow_NativeObjectUnreference(inBuffer);
        OH_NativeImage_ReleaseNativeWindowBuffer(nativeImage_, inBuffer, -1);
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "VulkanRenderThread", "nativeBuffer is null.");
        return;
    }
    ret = OH_NativeImage_GetTransformMatrix(nativeImage_, matrix_);
    int32_t transformTmp = 0;
    ComputeTransform(transformTmp, matrix_);
    vulkanRenderContext_->hwBufferToTexture(nativeBuffer, matrix_);
    vulkanRenderContext_->render();
    if (lastInBuffer_ != nullptr) {
        OH_NativeWindow_NativeObjectUnreference(lastInBuffer_);
        OH_NativeImage_ReleaseNativeWindowBuffer(nativeImage_, lastInBuffer_, -1);
    }
    lastInBuffer_ = inBuffer;
}
// [End draw_image]
} // namespace NativeXComponentSample
