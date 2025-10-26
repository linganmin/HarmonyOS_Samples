/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

#include "PluginManager.h"
#include "SampleInfo.h"
#include "multimedia/video_processing_engine/video_processing.h"
#include "multimedia/video_processing_engine/video_processing_types.h"

#include <ace/xcomponent/native_interface_xcomponent.h>
#include <cstdint>
#include <hilog/log.h>
#include <string>
#include <mutex>

#undef LOG_TAG
#define LOG_TAG "PLUGINMANAGER"
namespace NativeXComponentSample {
constexpr uint32_t LOG_PRINT_DOMAIN = 0xFF00;
PluginManager PluginManager::pluginManager_;
std::condition_variable g_SyncCond;
std::mutex g_SyncLock;

PluginManager::~PluginManager() {
    OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "Callback", "~PluginManager");
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

void  OnError(OH_VideoProcessing* videoProcessor,VideoProcessing_ErrorCode error, void* userData){
    (void ) videoProcessor;
    (void ) error;
    (void ) userData;
}

void OnState(OH_VideoProcessing* videoProcessor, VideoProcessing_State state,void* userData){
    (void ) videoProcessor;
    (void ) state;
    (void ) userData;
}

void OnNewOutputBuffer(OH_VideoProcessing* videoProcessor, uint32_t index, void* userData){
    std::unique_lock<std::mutex> lock(g_SyncLock);
    PluginManager::GetInstance()->sampleInfo_->processedIndex++;
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "PluginManager","play sync %{public}d", PluginManager::GetInstance()->sampleInfo_->processedIndex);
    OH_VideoProcessing_RenderOutputBuffer(videoProcessor, index);
    (void ) userData;
}

// [Start create_space]
void PluginManager::PrepareSurface(){
    VideoProcessing_ErrorCode ret = OH_VideoProcessing_InitializeEnvironment();
    if (ret != VIDEO_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_VideoProcessing_InitializeEnvironment %d",ret);
        return;
    }
    
    // Creating a color space conversion module
    ret = OH_VideoProcessing_Create(&processor, VIDEO_PROCESSING_TYPE_COLOR_SPACE_CONVERSION);
    if (ret != VIDEO_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_VideoProcessing_Create %d",ret);
        return;
    }
    
    // [StartExclude create_space]
    ret = OH_VideoProcessing_GetSurface(processor, &PluginManager::GetInstance()->pluginWindow_);
    if (ret != VIDEO_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_VideoProcessing_GetSurface %d",ret);
        return;
    }
   // [EndExclude create_space]
}
// [End create_space]

// [Start segment]
void PluginManager::InitProcessing(SampleInfo &sampleInfo){
    int32_t err = 0;
    OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","target colorspace %{public}d",sampleInfo.colorSpace);
    // Set the metadata property value, width, height, and content format for OHNativeWindow
    if (sampleInfo.colorSpace == OH_COLORSPACE_BT709_LIMIT) {
        err = OH_NativeWindow_NativeWindowHandleOpt(PluginManager::GetInstance()->windowOut, SET_FORMAT, NATIVEBUFFER_PIXEL_FMT_YCBCR_420_SP);
        // [StartExclude segment]
        if (err != 0) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","set format %d", err);
            return;
        }
       // [EndExclude segment]
    } else if (sampleInfo.colorSpace == OH_COLORSPACE_BT2020_HLG_LIMIT) {
        err = OH_NativeWindow_SetMetadataValue(PluginManager::GetInstance()->windowOut, 
            OH_HDR_METADATA_TYPE, sizeof(uint8_t), (uint8_t *)&sampleInfo.metaData);
         // [StartExclude segment]
        if (err != 0) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_NativeWindow_SetMetadataValue %d", err);
            return;
        }
           // [EndExclude segment]
        err = OH_NativeWindow_NativeWindowHandleOpt(PluginManager::GetInstance()->windowOut, SET_FORMAT, NATIVEBUFFER_PIXEL_FMT_RGBA_1010102);
          // [StartExclude segment]
        if (err != 0) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","set format %d", err);
            return;
        }
           // [EndExclude segment]
    } else if (sampleInfo.colorSpace == OH_COLORSPACE_BT2020_PQ_LIMIT) {
        err = OH_NativeWindow_SetMetadataValue(PluginManager::GetInstance()->windowOut, 
            OH_HDR_METADATA_TYPE, sizeof(uint8_t), (uint8_t *)&sampleInfo.metaData);
         // [StartExclude segment]
        if (err != 0) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_NativeWindow_SetMetadataValue %d", err);
            return;
        }
           // [EndExclude segment]
        err = OH_NativeWindow_NativeWindowHandleOpt(PluginManager::GetInstance()->windowOut, SET_FORMAT, NATIVEBUFFER_PIXEL_FMT_RGBA_1010102);
         // [StartExclude segment]
        if (err != 0) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","set format %d", err);
            return;
        }
      // [EndExclude segment]
    }
    
    // Set color space properties for OHNativeWindow
    err = OH_NativeWindow_SetColorSpace(PluginManager::GetInstance()->windowOut, sampleInfo.colorSpace);
      // [StartExclude segment]
    if (err != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","set colorspace %d", err);
        return;
    }
        // [EndExclude segment]
    // Setting the output surface
    VideoProcessing_ErrorCode ret = OH_VideoProcessing_SetSurface(processor, PluginManager::GetInstance()->windowOut);
     // [StartExclude segment]
    if (ret != VIDEO_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_VideoProcessing_SetSurface %d",ret);
        return;
    }
    // [Start segment2]
    // Create and bind a callback function
    ret = OH_VideoProcessingCallback_Create(&callback);
    if (ret != VIDEO_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_VideoProcessingCallback_Create %d",ret);
        return;
    }
    
    ret = OH_VideoProcessingCallback_BindOnError(callback, OnError);
    if (ret != VIDEO_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_VideoProcessingCallback_BindOnError %d",ret);
        return;
    }
    ret = OH_VideoProcessingCallback_BindOnState(callback, OnState);
    if (ret != VIDEO_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_VideoProcessingCallback_BindOnState %d",ret);
        return;
    }
    ret = OH_VideoProcessingCallback_BindOnNewOutputBuffer(callback, OnNewOutputBuffer);
    if (ret != VIDEO_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_VideoProcessingCallback_BindOnNewOutputBuffer %d",ret);
        return;
    }
    OH_VideoProcessing_RegisterCallback(processor, callback, nullptr);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "PluginManager","InitProcessing end");
    // [End segment2]
    // [EndExclude segment]
}
// [End segment]

void PluginManager::SetSampleInfo(SampleInfo *sampleInfo) 
{
    sampleInfo_ = sampleInfo;
}

// [Start segment3]
// Start color space conversion processing
void PluginManager::StartProcessing(){
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "PluginManager","StartProcessing ");
    VideoProcessing_ErrorCode ret = OH_VideoProcessing_Start(processor);
    if (ret != VIDEO_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","StartProcessing %d",ret);
        return;
    }
}
// [End segment3]

// [Start segment4]
// Stop color space conversion processing
void PluginManager::StopProcessing(){
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "PluginManager","StopProcessing ");
    VideoProcessing_ErrorCode ret = OH_VideoProcessing_Stop(processor);
    if (ret != VIDEO_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_VideoProcessing_Stop %d",ret);
        return;
    }
}
// [End segment4]
    
// [Start segment5]
// Release processing instances and resources
void PluginManager::DestroyProcessing(){
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "PluginManager","DestroyProcessing ");
    VideoProcessing_ErrorCode ret = OH_VideoProcessing_Destroy(processor);
    if (ret != VIDEO_PROCESSING_SUCCESS) {
       OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_VideoProcessing_Destroy %d",ret);
       return;
    }
    ret = OH_VideoProcessingCallback_Destroy(callback);
    if (ret != VIDEO_PROCESSING_SUCCESS) {
       OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_VideoProcessingCallback_Destroy %d",ret);
       return;
    }
    ret = OH_VideoProcessing_DeinitializeEnvironment();
    if (ret != VIDEO_PROCESSING_SUCCESS) {
       OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","OH_VideoProcessing_DeinitializeEnvironment %d",ret);
       return;
    }
}
// [End segment5]

void PluginManager::Export(napi_env env, napi_value exports) {
    if ((env == nullptr) || (exports == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager", "Export: env or exports is null");
        return;
    }

    napi_value exportInstance = nullptr;
    if (napi_get_named_property(env, exports, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance) != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager", "Export: napi_get_named_property fail");
        return;
    }

    OH_NativeXComponent *nativeXComponent = nullptr;
    if (napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent)) != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager", "Export: napi_unwrap fail");
        return;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager",
                     "Export: OH_NativeXComponent_GetXComponentId fail");
        return;
    }
    
    std::string id(idStr);
    
    auto context = PluginManager::GetInstance();
    if ((context != nullptr) && (nativeXComponent != nullptr)) {
        context->SetNativeXComponent(id, nativeXComponent);
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "PluginManager","111 %s",id.c_str());
        auto render = context->GetRender(id);
        if (render != nullptr) {
            render->RegisterCallback(nativeXComponent);
            render->Export(env, exports);
        }
    }
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

} // namespace NativeXComponentSample