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

#include "include/Demuxer.h"

#undef LOG_TAG
#define LOG_TAG "Demuxer"

Demuxer::~Demuxer() { Release(); }

int32_t Demuxer::Create(SampleInfo &info)
{
    source_ =
        OH_AVSource_CreateWithFD(info.fileInfo.inputFd, info.fileInfo.inputFileOffset, info.fileInfo.inputFileSize);
    CHECK_AND_RETURN_RET_LOG(source_ != nullptr, SAMPLE_ERR_ERROR,
                             "Create demuxer source failed, fd: %{public}d, offset: %{public}" PRId64
                             ", file size: %{public}" PRId64,
                             info.fileInfo.inputFd, info.fileInfo.inputFileOffset, info.fileInfo.inputFileSize);
    demuxer_ = OH_AVDemuxer_CreateWithSource(source_);
    CHECK_AND_RETURN_RET_LOG(demuxer_ != nullptr, SAMPLE_ERR_ERROR, "Create demuxer failed");

    auto sourceFormat = std::shared_ptr<OH_AVFormat>(OH_AVSource_GetSourceFormat(source_), OH_AVFormat_Destroy);
    CHECK_AND_RETURN_RET_LOG(sourceFormat != nullptr, SAMPLE_ERR_ERROR, "Get source format failed");

    int32_t ret = GetTrackInfo(sourceFormat, info);
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, SAMPLE_ERR_ERROR, "Get track info failed");

    return SAMPLE_ERR_OK;
}

int32_t Demuxer::ReadSample(int32_t trackId, OH_AVBuffer *buffer, OH_AVCodecBufferAttr &attr)
{
    CHECK_AND_RETURN_RET_LOG(demuxer_ != nullptr, SAMPLE_ERR_ERROR, "Demuxer is null");
    int32_t ret = OH_AVDemuxer_ReadSampleBuffer(demuxer_, trackId, buffer);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Read sample failed");
    ret = OH_AVBuffer_GetBufferAttr(buffer, &attr);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "GetBufferAttr failed");
    return SAMPLE_ERR_OK;
}

int32_t Demuxer::Release()
{
    if (demuxer_ != nullptr) {
        OH_AVDemuxer_Destroy(demuxer_);
        demuxer_ = nullptr;
    }
    if (source_ != nullptr) {
        OH_AVSource_Destroy(source_);
        source_ = nullptr;
    }
    return SAMPLE_ERR_OK;
}

int32_t Demuxer::GetTrackInfo(std::shared_ptr<OH_AVFormat> sourceFormat, SampleInfo &info)
{
    int32_t trackCount = 0;
    OH_AVFormat_GetIntValue(sourceFormat.get(), OH_MD_KEY_TRACK_COUNT, &trackCount);
    for (int32_t index = 0; index < trackCount; index++) {
        int trackType = -1;
        auto trackFormat =
            std::shared_ptr<OH_AVFormat>(OH_AVSource_GetTrackFormat(source_, index), OH_AVFormat_Destroy);
        OH_AVFormat_GetIntValue(trackFormat.get(), OH_MD_KEY_TRACK_TYPE, &trackType);
        if (trackType == MEDIA_TYPE_VID) {
        } else if (trackType == MEDIA_TYPE_AUD) {
            OH_AVDemuxer_SelectTrackByID(demuxer_, index);
            OH_AVFormat_GetIntValue(trackFormat.get(), OH_MD_KEY_AUDIO_SAMPLE_FORMAT,
                                    &info.audioInfo.audioSampleForamt);
            OH_AVFormat_GetIntValue(trackFormat.get(), OH_MD_KEY_AUD_CHANNEL_COUNT, &info.audioInfo.audioChannelCount);
            OH_AVFormat_GetLongValue(trackFormat.get(), OH_MD_KEY_CHANNEL_LAYOUT, &info.audioInfo.audioChannelLayout);
            OH_AVFormat_GetIntValue(trackFormat.get(), OH_MD_KEY_AUD_SAMPLE_RATE, &info.audioInfo.audioSampleRate);
            char *audioCodecMime;
            OH_AVFormat_GetStringValue(trackFormat.get(), OH_MD_KEY_CODEC_MIME,
                                       const_cast<char const **>(&audioCodecMime));
            uint8_t *codecConfig = nullptr;
            OH_AVFormat_GetBuffer(trackFormat.get(), OH_MD_KEY_CODEC_CONFIG, &codecConfig,
                                  &info.audioInfo.codecConfigLen);
            if (info.audioInfo.codecConfigLen > 0 &&
                info.audioInfo.codecConfigLen < sizeof(info.audioInfo.codecConfig)) {
                memcpy(info.audioInfo.codecConfig, codecConfig, info.audioInfo.codecConfigLen);
                SAMPLE_LOGI(
                    "codecConfig:%{public}p, len:%{public}i, 0:0x%{public}02x 1:0x:%{public}02x, bufLen:%{public}u",
                    info.audioInfo.codecConfig, (int)info.audioInfo.codecConfigLen, info.audioInfo.codecConfig[0],
                    info.audioInfo.codecConfig[1], sizeof(info.audioInfo.codecConfig));
            }
            OH_AVFormat_GetIntValue(trackFormat.get(), OH_MD_KEY_AAC_IS_ADTS, &info.audioInfo.aacAdts);

            info.audioInfo.audioCodecMime = audioCodecMime;
            audioTrackId_ = index;

            SAMPLE_LOGI("====== Demuxer Audio config ======");
            SAMPLE_LOGI("audioMime:%{public}s sampleForamt:%{public}d "
                        "sampleRate:%{public}d channelCount:%{public}d channelLayout:%{public}d adts:%{public}i",
                        info.audioInfo.audioCodecMime.c_str(), info.audioInfo.audioSampleForamt,
                        info.audioInfo.audioSampleRate, info.audioInfo.audioChannelCount,
                        info.audioInfo.audioChannelLayout, info.audioInfo.aacAdts);
            SAMPLE_LOGI("====== Demuxer Audio config ======");
        }
    }

    return SAMPLE_ERR_OK;
}

int32_t Demuxer::GetAudioTrackId() { return audioTrackId_; }