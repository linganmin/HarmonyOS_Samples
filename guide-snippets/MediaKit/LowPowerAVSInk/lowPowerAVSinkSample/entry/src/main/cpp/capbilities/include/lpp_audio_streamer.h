//
// Created on 2025/2/26.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef AVCODECSAMPLE_MASTER_LPP_AUDIO_STREAMER_H
#define AVCODECSAMPLE_MASTER_LPP_AUDIO_STREAMER_H

#include <multimedia/player_framework/lowpower_avsink_base.h>
#include <multimedia/player_framework/lowpower_video_sink_base.h>
#include <multimedia/player_framework/lowpower_audio_sink_base.h>
// #include "multimedia/player_framework/native_avbuffer_info.h"
#include "dfx/error/av_codec_sample_error.h"
#include "av_codec_sample_log.h"
#include "sample_info.h"

class LppAudioStreamer {
public:
    LppAudioStreamer() = default;
    ~LppAudioStreamer();

    int32_t Create(const std::string &codecMime);
    
    int32_t SetCallback(LppUserData *lppUserData);
    
    int32_t Start();
    
    int32_t SetParameter(const SampleInfo &sampleInfo);
    
    int32_t Prepare();
    
    int32_t Resume();
    
    int32_t Pause();
    
    int32_t Flush();
    
    int32_t Stop();
    
    int32_t Reset();
    
    int32_t Destroy();
    
    int32_t SetVolume(const float volume);
    
    int32_t SetPlayBackSpeed(const float speed);
    
    int32_t Release();
    
    
    
    int32_t returnFrames(LppUserData *lppUserData);
    
    
    int32_t Configure();
    
    bool isAVBufferMode_ = true;
    OH_LowPowerAudioSink *lppAudioStreamer_;
    OH_LowPowerAudioSinkCallback *lppAudioStreamerCallback_;
};

#endif //AVCODECSAMPLE_MASTER_LPP_AUDIO_STREAMER_H
