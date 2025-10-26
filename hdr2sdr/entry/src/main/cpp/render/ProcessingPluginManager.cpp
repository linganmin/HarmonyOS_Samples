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

#include "AVCodecSampleLog.h"
#include "PluginManager.h"
#include "SampleInfo.h"
#include "multimedia/video_processing_engine/video_processing.h"
#include "multimedia/video_processing_engine/video_processing_types.h"

#include <ace/xcomponent/native_interface_xcomponent.h>
#include <cerrno>
#include <cstdint>
#include <hilog/log.h>
#include <mutex>
#include <native_buffer/buffer_common.h>
#include <string>

#include <sys/mman.h>
#include <sys/poll.h>
#include <unistd.h>

#undef LOG_TAG
#define LOG_TAG "PluginManager"

namespace NativeXComponentSample {
constexpr uint32_t LOG_PRINT_DOMAIN = 0xFF00;
PluginManager PluginManager::pluginManager_;
std::condition_variable g_SyncCond;
std::mutex g_SyncLock;
uint32_t g_FrameCount = 0;
uint32_t g_Index = -1;

void OnError(OH_VideoProcessing *videoProcessor, VideoProcessing_ErrorCode error, void *userData) {
    (void)videoProcessor;
    (void)error;
    (void)userData;
    OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, LOG_TAG, "OnError: %{public}d", error);
    if ((error == VIDEO_PROCESSING_ERROR_UNSUPPORTED_PROCESSING) &&
        (PluginManager::GetInstance()->sampleInfo_->vpErrorCode == 0)) {
        PluginManager::GetInstance()->ResetVP(5, 1);
    }
}

void OnState(OH_VideoProcessing *videoProcessor, VideoProcessing_State state, void *userData) {
    (void)videoProcessor;
    (void)state;
    (void)userData;
}

void OnNewOutputBuffer(OH_VideoProcessing *videoProcessor, uint32_t index, void *userData) {
    if (g_Index != index) {
        g_Index = index;
        g_FrameCount++;
    }
    OH_VideoProcessing_RenderOutputBuffer(videoProcessor, index);
    (void)userData;
}

PluginManager::~PluginManager() {
    for (auto iter = nativeXComponentMap_.begin(); iter != nativeXComponentMap_.end(); ++iter) {
        if (iter->second != nullptr) {
            delete iter->second;
            iter->second = nullptr;
        }
    }
    nativeXComponentMap_.clear();

    for (auto iter = pluginRenderMap_.begin(); iter != pluginRenderMap_.end(); ++iter) {
        if (iter->second != nullptr) {
            delete iter->second;
            iter->second = nullptr;
        }
    }
    pluginRenderMap_.clear();
}

void PluginManager::SetNativeXComponent(std::string &id, OH_NativeXComponent *nativeXComponent) {
    if (nativeXComponent == nullptr) {
        return;
    }
    if (nativeXComponentMap_.find(id) == nativeXComponentMap_.end()) {
        nativeXComponentMap_[id] = nativeXComponent;
        return;
    }
    if (nativeXComponentMap_[id] != nativeXComponent) {
        OH_NativeXComponent *tmp = nativeXComponentMap_[id];
        tmp = nullptr;
        nativeXComponentMap_[id] = nativeXComponent;
    }
}

PluginRender *PluginManager::GetRender(std::string &id) {
    if (pluginRenderMap_.find(id) == pluginRenderMap_.end()) {
        PluginRender *instance = PluginRender::GetInstance(id);
        pluginRenderMap_[id] = instance;
        return instance;
    }
    return pluginRenderMap_[id];
}

void PluginManager::Export(napi_env env, napi_value exports) {
    if ((env == nullptr) || (exports == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, LOG_TAG, "Export: env or exports is null");
        return;
    }
    napi_value exportInstance = nullptr;
    if (napi_get_named_property(env, exports, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance) != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, LOG_TAG, "Export: napi_get_named_property fail");
        return;
    }
    OH_NativeXComponent *nativeXComponent = nullptr;
    if (napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent)) != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "Export: napi_unwrap fail");
        return;
    }
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, LOG_TAG, "Export unable to get XComponent id");
        return;
    }
    std::string id(idStr);
    auto context = PluginManager::GetInstance();
    if ((context != nullptr) && (nativeXComponent != nullptr)) {
        context->SetNativeXComponent(id, nativeXComponent);
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "SetNativeXComponent: %{public}s", id.c_str());
        auto render = context->GetRender(id);
        if (render != nullptr) {
            render->RegisterCallback(nativeXComponent);
            render->Export(env, exports);
            OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "SetNativeXComponent123");
            
        }
    }
}

// [Start PluginManagerInitProcessing]
void PluginManager::InitProcessing(SampleInfo &sampleInfo) {
    VideoProcessing_ErrorCode ret = VIDEO_PROCESSING_ERROR_INVALID_VALUE;
    int32_t processType = sampleInfo.processType;

    if (processType) {
        int32_t err = 0;
        if (sampleInfo.colorSpace == OH_COLORSPACE_BT709_LIMIT) {
            err = OH_NativeWindow_NativeWindowHandleOpt(PluginManager::GetInstance()->windowOut, SET_FORMAT,
                                                        NATIVEBUFFER_PIXEL_FMT_YCBCR_420_SP);
            int8_t metaData = OH_VIDEO_NONE;
            err = OH_NativeWindow_SetMetadataValue(PluginManager::GetInstance()->windowOut, OH_HDR_METADATA_TYPE,
                                                   sizeof(uint8_t), (uint8_t *)&metaData);
            CHECK_AND_RETURN_LOG(err == 0, "NativeWindowHandleOpt BT709_LIMIT failed");
        } else if (sampleInfo.colorSpace == OH_COLORSPACE_BT2020_HLG_LIMIT) {
            err = OH_NativeWindow_SetMetadataValue(PluginManager::GetInstance()->windowOut, OH_HDR_METADATA_TYPE,
                                                   sizeof(uint8_t), (uint8_t *)&sampleInfo.metaData);
            CHECK_AND_RETURN_LOG(err == 0, "SetMetadataValue BT2020_HLG_LIMIT failed");
            err = OH_NativeWindow_NativeWindowHandleOpt(PluginManager::GetInstance()->windowOut, SET_FORMAT,
                                                        NATIVEBUFFER_PIXEL_FMT_RGBA_1010102);
            CHECK_AND_RETURN_LOG(err == 0, "NativeWindowHandleOpt BT2020_HLG_LIMIT failed");
        } else if (sampleInfo.colorSpace == OH_COLORSPACE_BT2020_PQ_LIMIT) {
            err = OH_NativeWindow_SetMetadataValue(PluginManager::GetInstance()->windowOut, OH_HDR_METADATA_TYPE,
                                                   sizeof(uint8_t), (uint8_t *)&sampleInfo.metaData);
            CHECK_AND_RETURN_LOG(err == 0, "SetMetadataValue BT2020_PQ_LIMIT failed");
            err = OH_NativeWindow_NativeWindowHandleOpt(PluginManager::GetInstance()->windowOut, SET_FORMAT,
                                                        NATIVEBUFFER_PIXEL_FMT_RGBA_1010102);
            CHECK_AND_RETURN_LOG(err == 0, "NativeWindowHandleOpt BT2020_PQ_LIMIT failed");
        }
        err = OH_NativeWindow_SetColorSpace(PluginManager::GetInstance()->windowOut, sampleInfo.colorSpace);
        CHECK_AND_RETURN_LOG(err == 0, "SetColorSpace failed");
    }
    if (sampleInfo.window != nullptr) {
        ret = OH_VideoProcessing_SetSurface(processor, sampleInfo.window);
    } else {
        ret = OH_VideoProcessing_SetSurface(processor, PluginManager::GetInstance()->windowOut);
    }
    CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "SetSurface failed");
    // [Start VideoProcessingRegisterCallback]
    ret = OH_VideoProcessingCallback_Create(&callback);
    CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessingCallback_Create failed");
    ret = OH_VideoProcessingCallback_BindOnError(callback, OnError);
    CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessingCallback_BindOnError failed");
    ret = OH_VideoProcessingCallback_BindOnState(callback, OnState);
    CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessingCallback_BindOnState failed");
    ret = OH_VideoProcessingCallback_BindOnNewOutputBuffer(callback, OnNewOutputBuffer);
    CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessingCallback_BindOnNewOutputBuffer failed");
    ret = OH_VideoProcessing_RegisterCallback(processor, callback, nullptr);
    CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessing_RegisterCallback failed");
    // [End VideoProcessingRegisterCallback]
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "InitProcessing succeed");
}
// [End PluginManagerInitProcessing]

// [Start PluginManagerPrepareSurface]
void PluginManager::PrepareSurface(SampleInfo &sampleInfo) {
    VideoProcessing_ErrorCode ret = VIDEO_PROCESSING_ERROR_INVALID_VALUE;
    if (!isEnvironmentInited) {
        ret = OH_VideoProcessing_InitializeEnvironment();
        CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessing_InitializeEnvironment failed");
        isEnvironmentInited = true;
    }
    if (isVPRunning) {
        StopProcessing();
    }
    int32_t metaData = sampleInfo.metaData;
    if (metaData == 2) { //  metadata only supports generating OH_VIDEO_HDR_VIVID format
        ret = OH_VideoProcessing_Create(&processor, VIDEO_PROCESSING_TYPE_METADATA_GENERATION);
    } else {
        ret = OH_VideoProcessing_Create(&processor, VIDEO_PROCESSING_TYPE_COLOR_SPACE_CONVERSION);
    }
    CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessing_Create failed");
    ret = OH_VideoProcessing_GetSurface(processor, &PluginManager::GetInstance()->pluginWindow_);
    CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessing_GetSurface failed");
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "PrepareSurface succeed");
}
// [End PluginManagerPrepareSurface]

// [Start PluginManagerStartProcessing]
void PluginManager::StartProcessing() {
    PluginManager::GetInstance()->sampleInfo_->vpErrorCode = 0;
    VideoProcessing_ErrorCode ret = OH_VideoProcessing_Start(processor);
    if (ret != VIDEO_PROCESSING_SUCCESS) {
        // [StartExclude PluginManagerStartProcessing]
        ResetVP(5, 0);
        // [EndExclude PluginManagerStartProcessing]
    }
    CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessing_Start failed， ret: %{public}d", ret);
    // [StartExclude PluginManagerStartProcessing]
    isVPRunning = true;
    // [EndExclude PluginManagerStartProcessing]
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "StartProcessing succeed");
    
}
// [End PluginManagerStartProcessing]

void PluginManager::SetSampleInfo(SampleInfo *sampleInfo) { sampleInfo_ = sampleInfo; }

// [Start PluginManagerStopProcessing]
void PluginManager::StopProcessing() {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "StartProcessing stop :%{public}d, %{public}d",
                 g_FrameCount, PluginManager::GetInstance()->frameCount);
    if (isVPRunning) {
        VideoProcessing_ErrorCode ret = OH_VideoProcessing_Stop(processor);
        CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessing_Stop failed");
        isVPRunning = false;
    }
    g_FrameCount = 0;
    PluginManager::GetInstance()->frameCount = 0;
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "StartProcessing Stop succeed");
    DestroyProcessing();
}
// [End PluginManagerStopProcessing]

// [Start PluginManagerDestroyProcessing]
void PluginManager::DestroyProcessing() {
    CHECK_AND_RETURN_LOG(processor != nullptr, "processor is nullptr");
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "start DestroyProcessing");
    VideoProcessing_ErrorCode ret = OH_VideoProcessing_Destroy(processor);
    CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessing_Destroy failed");
    processor = nullptr;
    CHECK_AND_RETURN_LOG(callback != nullptr, "callback is nullptr");
    ret = OH_VideoProcessingCallback_Destroy(callback);
    CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessingCallback_Destroy failed");
    callback = nullptr;
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "Destroy And Callback_Destroy succeed");

    if (OnErrorThread_ && OnErrorThread_->joinable()) {
        OnErrorThread_->detach();
        OnErrorThread_.reset();
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "Release OnError Thread succeed");
    }
}
// [End PluginManagerDestroyProcessing]

// [Start PluginManagerRelease]
void PluginManager::Release() {
    if (isVPRunning) {
        StopProcessing();
        DestroyProcessing();
    }
    if (isEnvironmentInited) {
        VideoProcessing_ErrorCode ret = OH_VideoProcessing_DeinitializeEnvironment();
        CHECK_AND_RETURN_LOG(ret == VIDEO_PROCESSING_SUCCESS, "OH_VideoProcessing_DeinitializeEnvironment failed");
        isEnvironmentInited = false;
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "DeinitializeEnvironment Succeed");
    }
}
// [End PluginManagerRelease]

void PluginManager::ResetVP(int32_t ret, int8_t from) {
    PluginManager::GetInstance()->sampleInfo_->vpErrorCode = ret;
    CallbackContext *context = (CallbackContext *)PluginManager::GetInstance()->sampleInfo_->playDoneCallbackData;
    context->code = ret;
    PluginManager::GetInstance()->sampleInfo_->playDoneCallback(
        PluginManager::GetInstance()->sampleInfo_->playDoneCallbackData);
    errorCode = ret;
    if (from == 0) {
        StopProcessing();
    } else {
        OnErrorThread_ = std::make_unique<std::thread>(&PluginManager::VPOnErrorThread, this);
    }
}

void PluginManager::VPOnErrorThread() { StopProcessing(); }

int32_t PluginManager::BlackLastFrame() {
    int32_t format = 0;
    int32_t ret = OH_NativeWindow_NativeWindowHandleOpt(windowOut, GET_FORMAT, &format);
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "StartProcessing succeed");
    }
    if (format != NATIVEBUFFER_PIXEL_FMT_RGBA_8888) {
        ret = OH_NativeWindow_NativeWindowHandleOpt(windowOut, SET_FORMAT, NATIVEBUFFER_PIXEL_FMT_RGBA_8888);
        if (ret != 0) {
            OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "StartProcessing succeed");
        }
    }
    OHNativeWindowBuffer *buffer = nullptr;
    int releaseFenceFd = -1;
    ret = OH_NativeWindow_NativeWindowRequestBuffer(windowOut, &buffer, &releaseFenceFd);
    if (ret != 0 || buffer == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "StartProcessing succeed");
        return -1;
    }
    BufferHandle *bufferHandle = OH_NativeWindow_GetBufferHandleFromNative(buffer);
    void *mappedAddr =
        mmap(bufferHandle->virAddr, bufferHandle->size, PROT_READ | PROT_WRITE, MAP_SHARED, bufferHandle->fd, 0);
    if (mappedAddr == MAP_FAILED) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "StartProcessing succeed");
        return -1;
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "StartProcessing succeed");
    int retCode = -1;
    uint32_t timeout = 3000;
    if (releaseFenceFd != -1) {
        struct pollfd pollfds = {0};
        pollfds.fd = releaseFenceFd;
        pollfds.events = POLL_IN;
        do {
            retCode = poll(&pollfds, 1, timeout);
        } while (retCode == -1 && (errno == EINTR || errno == EAGAIN));
        close(releaseFenceFd);
    }
//    memset_s(mappedAddr, bufferHandle->stride * bufferHandle->height, 0, bufferHandle->stride *
    //    bufferHandle->height);
    static uint32_t value = 0x00;
    value++;
    uint32_t *pixel = static_cast<uint32_t *>(mappedAddr);
    for (uint32_t x = 0; x < bufferHandle->width; x++) {
        for (uint32_t y = 0; y < bufferHandle->height; y++) {
            *pixel++ = value;
        }
    }
    Region region{nullptr, 0};
    int acquireFenceFd = -1;
    ret = OH_NativeWindow_NativeWindowFlushBuffer(windowOut, buffer, acquireFenceFd, region);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "StartProcessing succeed");
    int result = munmap(mappedAddr, bufferHandle->size);
    if (result == -1) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, LOG_TAG, "StartProcessing succeed");
        return -1;
    }
    return 0;
}
} // namespace NativeXComponentSample
