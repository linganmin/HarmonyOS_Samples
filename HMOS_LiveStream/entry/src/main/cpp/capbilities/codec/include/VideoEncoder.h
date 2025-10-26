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

#ifndef VIDEOENCODER_H
#define VIDEOENCODER_H

#include <mutex>
#include <atomic>
#include <memory>
#include <string> // Ensure inclusion of std::string
#include "SampleInfo.h"
#include "multimedia/player_framework/native_avcodec_videoencoder.h"
#include "multimedia/player_framework/native_avbuffer_info.h"
#include "SampleInfo.h"
#include "native_window/external_window.h"
#include "native_window/buffer_handle.h"
#include "CodecCallback.h"
#include "dfx/error/SampleError.h"
#include "SampleLog.h"

class VideoEncoder {
public:
    // User data structure for ROI parameter callback
    struct CodecUserRoi {
        VideoEncoder* vencoder = nullptr; // Pointer to the current encoder instance
    };

    // Constructor: Creates a CodecUserRoi object managed by a smart pointer
    VideoEncoder() : userData_(std::make_unique<CodecUserRoi>()) 
    {
        if (userData_) {
            userData_->vencoder = this;
        }
    }

    ~VideoEncoder();

    // Core control interface
    int32_t Create(const std::string &videoCodecMime);
    int32_t Config(SampleInfo &sampleInfo, CodecUserData *codecUserData);
    int32_t Start();
    int32_t FreeOutputBuffer(uint32_t bufferIndex);
    int32_t NotifyEndOfStream();
    int32_t Stop();
    int32_t Release();

    // Interface for updating and retrieving face information
    void UpdateFaceInfoFromCamera(const FaceInfo& faceInfo);
    FaceIntInfo GetLatestFaceInfo();
    bool HasNewFaceInfo() const;

    // Get ROI callback user data pointer
    CodecUserRoi* GetUserData() const 
    {
        return userData_.get();
    }

private:
    // Internal helper methods
    int32_t SetCallback(CodecUserData *codecUserData);
    int32_t Configure(const SampleInfo &sampleInfo);
    int32_t GetSurface(SampleInfo &sampleInfo);

    // Encoder status and resources
    OH_AVCodec *encoder_ = nullptr;
    std::unique_ptr<CodecUserRoi> userData_;

    // Video resolution, used for coordinate conversion
    int width_ = 0;
    int height_ = 0;

    // Thread-safe face information storage
    FaceIntInfo m_faceInfo;
    mutable std::mutex m_faceMutex;
    std::atomic<bool> m_hasNewFaceInfo{false};
};

#endif // VIDEOENCODER_H