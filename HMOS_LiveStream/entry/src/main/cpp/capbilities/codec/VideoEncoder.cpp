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
#include "include/VideoEncoder.h"
#include <cstdio> // Used for snprintf
#include "ApiCompatibility.h"

#undef LOG_TAG
#define LOG_TAG "VideoEncoder"

// Destructor: Ensures resources are properly released by calling Release()
VideoEncoder::~VideoEncoder()
{
    Release();
}

// Create and initialize video encoder
int32_t VideoEncoder::Create(const std::string &videoCodecMime)
{
    encoder_ = OH_VideoEncoder_CreateByMime(videoCodecMime.c_str());
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, SAMPLE_ERR_ERROR, "Create failed");
    return SAMPLE_ERR_OK;
}

// Fully configure the encoder: including parameter setup, Surface acquisition,
// callback configuration, and preparation work
int32_t VideoEncoder::Config(SampleInfo &sampleInfo, CodecUserData *codecUserData)
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, SAMPLE_ERR_ERROR, "Encoder is null");
    CHECK_AND_RETURN_RET_LOG(codecUserData != nullptr, SAMPLE_ERR_ERROR, "Invalid param: codecUserData");

    int32_t ret = Configure(sampleInfo);
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, SAMPLE_ERR_ERROR, "Configure failed");

    ret = GetSurface(sampleInfo);
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, SAMPLE_ERR_ERROR, "Get surface failed");

    ret = SetCallback(codecUserData);
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, SAMPLE_ERR_ERROR,
                             "Set callback failed, ret: %{public}d", ret);

    ret = OH_VideoEncoder_Prepare(encoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Prepare failed, ret: %{public}d", ret);

    return SAMPLE_ERR_OK;
}

// Start encoder
int32_t VideoEncoder::Start()
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, SAMPLE_ERR_ERROR, "Encoder is null");

    int ret = OH_VideoEncoder_Start(encoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Start failed, ret: %{public}d", ret);
    return SAMPLE_ERR_OK;
}

// Release output buffer
int32_t VideoEncoder::FreeOutputBuffer(uint32_t bufferIndex)
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, SAMPLE_ERR_ERROR, "Encoder is null");

    int32_t ret = OH_VideoEncoder_FreeOutputBuffer(encoder_, bufferIndex);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Free output data failed, ret: %{public}d",
                             ret);
    return SAMPLE_ERR_OK;
}

// Notify encoder of stream end
int32_t VideoEncoder::NotifyEndOfStream()
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, SAMPLE_ERR_ERROR, "Encoder is null");

    int32_t ret = OH_VideoEncoder_NotifyEndOfStream(encoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Notify end of stream failed, ret: %{public}d",
                             ret);
    return SAMPLE_ERR_OK;
}

// Stop encoder
int32_t VideoEncoder::Stop()
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, SAMPLE_ERR_ERROR, "Encoder is null");

    int ret = OH_VideoEncoder_Flush(encoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Flush failed, ret: %{public}d", ret);

    ret = OH_VideoEncoder_Stop(encoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Stop failed, ret: %{public}d", ret);
    return SAMPLE_ERR_OK;
}

// Release encoder resources
int32_t VideoEncoder::Release()
{
    if (encoder_ != nullptr) {
        OH_VideoEncoder_Destroy(encoder_);
        encoder_ = nullptr;
    }
    return SAMPLE_ERR_OK;
}

// Asynchronously update face information from the camera (thread-safe),
// and convert relative coordinates to absolute coordinates
void VideoEncoder::UpdateFaceInfoFromCamera(const FaceInfo& faceInfo)
{
    std::lock_guard<std::mutex> lock(m_faceMutex);
    if (faceInfo.valid && width_ > 0 && height_ > 0) {
        m_faceInfo = {
            .valid = true,
            .timestamp = faceInfo.timestamp,
            .topLeftX = static_cast<int32_t>(faceInfo.topLeftX * width_),
            .topLeftY = static_cast<int32_t>(faceInfo.topLeftY * height_),
            .width = static_cast<int32_t>(faceInfo.width * width_),
            .height = static_cast<int32_t>(faceInfo.height * height_)
        };
    } else {
        m_faceInfo = {.valid = false};
    }
    m_hasNewFaceInfo = true;
#if ONLY_TEST_ROI_INFO
    if (m_faceInfo.valid && !ApiCompat_OH_MD_KEY_VIDEO_ENCODER_ROI_PARAMS.IsAvailable()) {
        std::string roiInfo;
        int32_t left = m_faceInfo.topLeftX;
        int32_t top = m_faceInfo.topLeftY;
        int32_t right = m_faceInfo.topLeftX + m_faceInfo.width;
        int32_t bottom = m_faceInfo.topLeftY + m_faceInfo.height;

        // Construct ROI information string, lowering the QP value in facial regions to enhance video quality
        char roiBuffer[100];
        int len = snprintf(roiBuffer, sizeof(roiBuffer), "%d,%d-%d,%d=-4", left, top, right, bottom);
        if (len > 0 && len < static_cast<int>(sizeof(roiBuffer))) {
            roiInfo = std::string(roiBuffer, len);
            SAMPLE_LOGI("ROI info updated to: %s", roiInfo.c_str());
        } else {
            SAMPLE_LOGE("Failed to format ROI string, buffer size: %zu", sizeof(roiBuffer));
        }
        SAMPLE_LOGI("HMOS_LiveStream [API %{public}d does not support ROI encoder]: ROI face timestamp: %{public}lld, "
                    "ROI: %{public}s",
                    OH_GetSdkApiVersion(), faceInfo.timestamp, roiBuffer);
    }
#endif
}

// Get the latest face information (for use by callback functions)
FaceIntInfo VideoEncoder::GetLatestFaceInfo()
{
    std::lock_guard<std::mutex> lock(m_faceMutex);
    FaceIntInfo currentFace = m_faceInfo;
    // 2. Clear the stored face information immediately, regardless of validity
    if (m_faceInfo.valid) {
        m_faceInfo.valid = false;
        SAMPLE_LOGI("Face info consumed, resetting.");
    }
    m_hasNewFaceInfo = false; // 3. Reset flag bits
    return currentFace;       // 4. Return the previously saved copy
}

// Check if there is new face information
bool VideoEncoder::HasNewFaceInfo() const
{
    return m_hasNewFaceInfo;
}

// [Start ROI_encode]
// Static callback function: Used to handle encoder requests for input parameters
static void OnNeedInputParameter(OH_AVCodec *codec, uint32_t index, OH_AVFormat *parameter, void *userData)
{
    // Retrieve CodecUserRoi instance from user data
    VideoEncoder::CodecUserRoi* roiUserData = static_cast<VideoEncoder::CodecUserRoi*>(userData);
    if (!roiUserData || !roiUserData->vencoder) {
        SAMPLE_LOGE("Invalid user data in OnNeedInputParameter");
        OH_VideoEncoder_PushInputParameter(codec, index);
        return;
    }

    VideoEncoder* encoder = roiUserData->vencoder;
    FaceIntInfo faceInfo = encoder->GetLatestFaceInfo();
    std::string roiInfo;

    // If valid face information is available, use the face region as the ROI
    if (faceInfo.valid) {
        int32_t left = faceInfo.topLeftX;
        int32_t top = faceInfo.topLeftY;
        int32_t right = faceInfo.topLeftX + faceInfo.width;
        int32_t bottom = faceInfo.topLeftY + faceInfo.height;

        // Construct ROI information string, lowering the QP value in facial regions to enhance image quality
        char roiBuffer[100];
        int len = snprintf(roiBuffer, sizeof(roiBuffer), "%d,%d-%d,%d=-4", left, top, right, bottom);
        if (len > 0 && len < static_cast<int>(sizeof(roiBuffer))) {
            roiInfo = std::string(roiBuffer, len);
        } else {
            SAMPLE_LOGE("Failed to format ROI string, buffer size: %zu", sizeof(roiBuffer));
        }
#if ONLY_TEST_ROI_INFO
        SAMPLE_LOGI("HMOS_LiveStream: ROI face  timestamp: %{public}d, ROI: %{public}s",
            faceInfo.timestamp, roiBuffer);
#endif
    } else {
        // If no face information is available, do not set any ROI, allowing the encoder to use global default
        // parameters
        SAMPLE_LOGI("No valid face info, no ROI set.");
    }

    // Set ROI parameters
    const char* roiKey = ApiCompat_OH_MD_KEY_VIDEO_ENCODER_ROI_PARAMS;
    OH_AVFormat_SetStringValue(parameter, roiKey, roiInfo.c_str());
    OH_VideoEncoder_PushInputParameter(codec, index);
}
// [End ROI_encode]

// Set the encoder's general callback function
int32_t VideoEncoder::SetCallback(CodecUserData *codecUserData)
{
    int32_t ret =
        OH_VideoEncoder_RegisterCallback(encoder_,
                                         {CodecCallback::OnCodecError, CodecCallback::OnCodecFormatChange,
                                          CodecCallback::OnNeedInputBuffer, CodecCallback::OnNewOutputBuffer},
                                         codecUserData);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Set callback failed, ret: %{public}d", ret);
    
    return SAMPLE_ERR_OK;
}

// Configure encoder parameters in detail and register ROI-specific callback
int32_t VideoEncoder::Configure(const SampleInfo &sampleInfo)
{
    OH_AVFormat *format = OH_AVFormat_Create();
    CHECK_AND_RETURN_RET_LOG(format != nullptr, SAMPLE_ERR_ERROR, "AVFormat create failed");

    // Save resolution for subsequent coordinate conversion
    width_ = sampleInfo.videoInfo.videoWidth;
    height_ = sampleInfo.videoInfo.videoHeight;

    // Basic video parameter configuration
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_WIDTH, sampleInfo.videoInfo.videoWidth);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_HEIGHT, sampleInfo.videoInfo.videoHeight);
    OH_AVFormat_SetDoubleValue(format, OH_MD_KEY_FRAME_RATE, sampleInfo.videoInfo.frameRate);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_PIXEL_FORMAT, sampleInfo.videoInfo.pixelFormat);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_VIDEO_ENCODE_BITRATE_MODE, sampleInfo.videoInfo.bitrateMode);
    OH_AVFormat_SetLongValue(format, OH_MD_KEY_BITRATE, sampleInfo.videoInfo.bitrate);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_PROFILE, sampleInfo.videoInfo.hevcProfile);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_I_FRAME_INTERVAL, sampleInfo.videoInfo.iFrameInterval);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_RANGE_FLAG, sampleInfo.videoInfo.rangFlag);
    // HDR Vivid related parameter configuration
    if (sampleInfo.videoInfo.isHDRVivid) {
        OH_AVFormat_SetIntValue(format, OH_MD_KEY_COLOR_PRIMARIES, sampleInfo.videoInfo.primary);
        OH_AVFormat_SetIntValue(format, OH_MD_KEY_TRANSFER_CHARACTERISTICS, sampleInfo.videoInfo.transfer);
        OH_AVFormat_SetIntValue(format, OH_MD_KEY_MATRIX_COEFFICIENTS, sampleInfo.videoInfo.matrix);
    }
    SAMPLE_LOGI("====== VideoEncoder config ======");
    SAMPLE_LOGI("%{public}d*%{public}d, %{public}.1ffps", sampleInfo.videoInfo.videoWidth,
                sampleInfo.videoInfo.videoHeight, sampleInfo.videoInfo.frameRate);
    // 1024: ratio of kbps to bps
    SAMPLE_LOGI("BitRate Mode: %{public}d, BitRate: %{public}" PRId64 "kbps", sampleInfo.videoInfo.bitrateMode,
                        sampleInfo.videoInfo.bitrate / 1024);
    SAMPLE_LOGI("====== VideoEncoder config ======");

    // Print configuration information
    SAMPLE_LOGI("====== VideoEncoder Configure ======");
    SAMPLE_LOGI("Resolution: %dx%d, FrameRate: %.1f fps", sampleInfo.videoInfo.videoWidth,
                sampleInfo.videoInfo.videoHeight, sampleInfo.videoInfo.frameRate);
    SAMPLE_LOGI("BitRate Mode: %d, BitRate: %" PRId64 "kbps",
                        sampleInfo.videoInfo.bitrateMode, sampleInfo.videoInfo.bitrate / 1024);
    SAMPLE_LOGI("====================================");

    // Check and register ROI parameter callback
    if (ApiCompat_OH_MD_KEY_VIDEO_ENCODER_ROI_PARAMS.IsAvailable()) {
        int ret = OH_VideoEncoder_RegisterParameterCallback(encoder_, OnNeedInputParameter, userData_.get());
        CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR,
                                 "HMOS_LiveStream OH_VideoEncoder_RegisterParameterCallback failed, ret: %{public}d",
                                 ret);
        SAMPLE_LOGI("HMOS_LiveStream: ROI feature enabled.");
    } else {
        SAMPLE_LOGW("HMOS_LiveStream: ROI is not supported on this system (requires API >= 20).");
    }
    // Setting the Encoder
    int ret = OH_VideoEncoder_Configure(encoder_, format);
    OH_AVFormat_Destroy(format);
    format = nullptr;
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Config failed, ret: %{public}d", ret);
    return SAMPLE_ERR_OK;
}

// Get the encoder's Surface to receive input data
int32_t VideoEncoder::GetSurface(SampleInfo &sampleInfo)
{
    int32_t ret = OH_VideoEncoder_GetSurface(encoder_, &sampleInfo.videoInfo.window);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK && sampleInfo.videoInfo.window, SAMPLE_ERR_ERROR,
                             "Get surface failed, ret: %{public}d", ret);
    return SAMPLE_ERR_OK;
}