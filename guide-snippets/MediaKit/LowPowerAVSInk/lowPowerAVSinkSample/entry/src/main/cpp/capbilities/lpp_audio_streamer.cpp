/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2020-2020. All rights reserved.
 */
/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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

#include "lpp_audio_streamer.h"
#include "lppCallback.h"
#include "multimedia/player_framework/lowpower_audio_sink_base.h"
#include "multimedia/player_framework/lowpower_audio_sink.h"

#undef LOG_TAG
#define LOG_TAG "LppAudioStreamer"

LppAudioStreamer::~LppAudioStreamer()
{
    if(lppAudioStreamer_!=nullptr){
        Release();
    }
}

int32_t LppAudioStreamer::Create(const std::string &codecMime)
{
    lppAudioStreamer_ = OH_LowPowerAudioSink_CreateByMime(codecMime.c_str());
    AVCODEC_SAMPLE_LOGI("codecMime.c_str()  %{public}s", codecMime.c_str());
    CHECK_AND_RETURN_RET_LOG(lppAudioStreamer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Create failed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t LppAudioStreamer::SetCallback(LppUserData *lppUserData)
{
    int32_t ret = AV_ERR_OK;
    lppAudioStreamerCallback_ = OH_LowPowerAudioSinkCallback_Create();
    OH_LowPowerAudioSinkCallback_SetDataNeededListener(lppAudioStreamerCallback_, LppCallback::OnDataNeeded, lppUserData);
    OH_LowPowerAudioSinkCallback_SetErrorListener(lppAudioStreamerCallback_, LppCallback::OnError, lppUserData);
    OH_LowPowerAudioSinkCallback_SetPositionUpdateListener(lppAudioStreamerCallback_, LppCallback::OnPositionUpdated, lppUserData);
    OH_LowPowerAudioSinkCallback_SetInterruptListener(lppAudioStreamerCallback_, LppCallback::OnInterrupted, lppUserData);
    ret = OH_LowPowerAudioSink_RegisterCallback(lppAudioStreamer_, lppAudioStreamerCallback_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Set callback failed, ret: %{public}d", ret);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t LppAudioStreamer::Configure()
{
    OH_AVFormat *format = OH_AVFormat_Create();
    int ret = OH_LowPowerAudioSink_Configure(lppAudioStreamer_, format);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Configure failed, ret: %{public}d", ret);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t LppAudioStreamer::SetVolume(const float volume)
{
    int ret = OH_LowPowerAudioSink_SetVolume(lppAudioStreamer_, volume);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "SetVolume failed, ret: %{public}d", ret);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t LppAudioStreamer::SetPlayBackSpeed(const float speed)
{
    int ret = OH_LowPowerAudioSink_SetPlaybackSpeed(lppAudioStreamer_, speed);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "SetSpeed failed, ret: %{public}d", ret);
    return AVCODEC_SAMPLE_ERR_OK;
}


int32_t LppAudioStreamer::Start()
{
    int ret = OH_LowPowerAudioSink_Start(lppAudioStreamer_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Start failed, ret: %{public}d", ret);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t LppAudioStreamer::returnFrames(LppUserData *lppUserData)
{
    OH_LowPowerAudioSink_ReturnSamples(lppAudioStreamer_, lppUserData->framePacket_);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t LppAudioStreamer::SetParameter(const SampleInfo &sampleInfo)
{
    OH_AVFormat *format = OH_AVFormat_Create();
    if (sampleInfo.audioCodecConfig != nullptr) {
        OH_AVFormat_SetBuffer(format, "codec_config", sampleInfo.audioCodecConfig, sampleInfo.audioCodecSize);
    }
//         OH_AudioStreamBuilder_SetLatencyMode(builder_, AUDIOSTREAM_LATENCY_MODE_NORMAL);
//         // 设置音频采样率
//         OH_AudioStreamBuilder_SetSamplingRate(builder_, sampleInfo_.audioSampleRate);
//         // 设置音频声道
//         OH_AudioStreamBuilder_SetChannelCount(builder_, sampleInfo_.audioChannelCount);
//         // 设置音频采样格式
//         OH_AudioStreamBuilder_SetSampleFormat(builder_, AUDIOSTREAM_SAMPLE_S16LE);
//         // 设置音频流的编码类型
//         OH_AudioStreamBuilder_SetEncodingType(builder_, AUDIOSTREAM_ENCODING_TYPE_RAW);
//         // 设置输出音频流的工作场景
//         OH_AudioStreamBuilder_SetRendererInfo(builder_, AUDIOSTREAM_USAGE_MUSIC);
    
//     Format format;
//     (void)format.PutIntValue(PlayerKeys::STREAM_USAGE, streamUsage);
//     (void)format.PutIntValue(PlayerKeys::CONTENT_TYPE, 0);
//     (void)format.PutIntValue(PlayerKeys::RENDERER_FLAG, 0);
//     音频送显
//     OH_AVFormat_SetIntValue(format, "CONTENT_TYPE", 0);
    //         STREAM_USAGE_MOVIE = 10,
//     OH_AVFormat_SetIntValue(format, "STREAM_USAGE", 10);
//     OH_AVFormat_SetIntValue(format, "SAMPLE_RATE", sampleInfo.audioSampleRate);
//     AVCODEC_SAMPLE_LOGI("audioSampleRate  %{public}d", sampleInfo.audioSampleRate);
//     OH_AVFormat_SetIntValue(format, "RENDERER_FLAG", 5);
// //     ENCODING_PCM = 0,
//     OH_AVFormat_SetIntValue(format, "ENCODING", 0);
// //     SAMPLE_S16LE = 1,
//     OH_AVFormat_SetIntValue(format, "SAMPLE_FORMAT", SAMPLE_S16LE);
// //     CHANNEL_6 = 6,
//     OH_AVFormat_SetIntValue(format, "CHANNEL", sampleInfo.audioChannelCount);
    
//     音频解码
//     const char *OH_MD_KEY_AUDIO_SAMPLE_FORMAT = "audio_sample_format";
    OH_AVFormat_SetIntValue(format, "audio_sample_format", SAMPLE_S16LE);
    OH_AVFormat_SetIntValue(format, "audio.raw.sample.format", 24);
//     OH_AVFormat_SetIntValue(format, "audio_sample_format", sampleInfo.audioSampleForamt);
//     const char *OH_MD_KEY_AUD_CHANNEL_COUNT = "channel_count";
    OH_AVFormat_SetIntValue(format, "channel_count", sampleInfo.audioChannelCount);
    AVCODEC_SAMPLE_LOGI("audioChannelCount  %{public}d", sampleInfo.audioChannelCount);
//     const char *OH_MD_KEY_AUD_SAMPLE_RATE = "sample_rate";
    OH_AVFormat_SetIntValue(format, "sample_rate", sampleInfo.audioSampleRate);
//     const char *OH_MD_KEY_CHANNEL_LAYOUT = "channel_layout";
    OH_AVFormat_SetLongValue(format, "channel_layout", sampleInfo.audioChannelLayout);
    OH_LowPowerAudioSink_Configure(lppAudioStreamer_, format);
//     OH_LowPowerAudioSink_SetParameter(lppAudioStreamer_, format);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t LppAudioStreamer::Prepare()
{
    auto ret = OH_LowPowerAudioSink_Prepare(lppAudioStreamer_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Prepare failed.");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t LppAudioStreamer::Pause()
{
    auto ret = OH_LowPowerAudioSink_Pause(lppAudioStreamer_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Pause failed.");
    return AVCODEC_SAMPLE_ERR_OK;
}
    
int32_t LppAudioStreamer::Resume()
{
    auto ret = OH_LowPowerAudioSink_Resume(lppAudioStreamer_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Resume failed.");
    return AVCODEC_SAMPLE_ERR_OK;
}
    
int32_t LppAudioStreamer::Flush()
{
    auto ret = OH_LowPowerAudioSink_Flush(lppAudioStreamer_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Flush failed.");
    return AVCODEC_SAMPLE_ERR_OK;
}
    
int32_t LppAudioStreamer::Stop()
{
    auto ret = OH_LowPowerAudioSink_Stop(lppAudioStreamer_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Stop failed.");
    return AVCODEC_SAMPLE_ERR_OK;
}
    
int32_t LppAudioStreamer::Reset()
{
    AVCODEC_SAMPLE_LOGI("reset in3");
    auto ret = OH_LowPowerAudioSink_Reset(lppAudioStreamer_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Reset failed.");
    AVCODEC_SAMPLE_LOGI("reset in6");
    return AVCODEC_SAMPLE_ERR_OK;
}
    
int32_t LppAudioStreamer::Destroy()
{
    AVCODEC_SAMPLE_LOGI("====== LppAudioStreamer Destroy ======");
    auto ret = OH_LowPowerAudioSink_Destroy(lppAudioStreamer_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Destroy failed.");
    lppAudioStreamer_ = nullptr;
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t LppAudioStreamer::Release()
{
    Stop();
    Destroy();
    return AVCODEC_SAMPLE_ERR_OK;
}

