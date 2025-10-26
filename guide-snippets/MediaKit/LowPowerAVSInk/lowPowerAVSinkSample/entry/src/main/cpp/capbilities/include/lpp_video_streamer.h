//
// Created on 2025/2/26.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef AVCODECSAMPLE_MASTER_LPP_VIDEO_STREAMER_H
#define AVCODECSAMPLE_MASTER_LPP_VIDEO_STREAMER_H

// #include "multimedia/player_framework/native_avbuffer_info.h"
#include "dfx/error/av_codec_sample_error.h"
#include "av_codec_sample_log.h"
#include <multimedia/player_framework/lowpower_avsink_base.h>
#include <multimedia/player_framework/lowpower_video_sink_base.h>
#include <multimedia/player_framework/lowpower_audio_sink_base.h>
#include "sample_info.h"

class LppVideoStreamer {
public:
    LppVideoStreamer() = default;
    ~LppVideoStreamer();

    int32_t Create(const std::string &codecMime);

    int32_t Configure(const SampleInfo &sampleInfo);

    int32_t SetParameter(const SampleInfo &sampleInfo);

    int32_t SetVideoSurface(const SampleInfo &sampleInfo);

    int32_t Prepare();

    int32_t StartDecode(bool flag);

    int32_t StartRender();

    int32_t Pause();

    int32_t Resume();

    int32_t Flush();

    int32_t Stop();

    int32_t Reset();

    int32_t Destroy();

    int32_t Release();

    int32_t SetSyncAudioStreamer(OH_LowPowerAudioSink *audioStreamer);

    int32_t SetTargetStartFrame(const long framePts, OH_LowPowerVideoSink_OnTargetArrived OnTargetArrived, const long timeoutMs, LppUserData *lppUserData);

    int32_t SetPlaybackSpeed(const float speed);

    int32_t returnFrames(LppUserData *lppUserData);

    int32_t SetCallback(LppUserData *lppUserData);
    
    int32_t RenderFirstFrame();
    
    bool isAVBufferMode_ = true;
    OH_LowPowerVideoSink *lppVideoStreamer_;
    OH_LowPowerVideoSinkCallback *lppVideoStreamerCallback_;
};

#endif //AVCODECSAMPLE_MASTER_LPP_AUDIO_STREAMER_H
