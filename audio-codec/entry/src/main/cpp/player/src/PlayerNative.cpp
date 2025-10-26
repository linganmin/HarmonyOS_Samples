/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
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

#include <fstream>
#include <fstream>
#include "AudioCapturer.h"
#include "Player.h"
#include "Summary.h"
#include "Transcoding.h"
#include "AVCodecSampleError.h"
#include "PlayerNative.h"

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0xFF00
#define LOG_TAG "player"
namespace {
constexpr int PLAYER_NATIVE_ZERO = 0;
constexpr int PLAYER_NATIVE_ONE = 1;
constexpr int PLAYER_NATIVE_TWO = 2;
constexpr int PLAYER_NATIVE_THREE = 3;
constexpr int PLAYER_NATIVE_FOUR = 4;
constexpr int PLAYER_NATIVE_FIVE = 5;
constexpr int PLAYER_NATIVE_SIX = 6;
constexpr int PLAYER_NATIVE_SEVEN = 7;
constexpr int PLAYER_NATIVE_EIGHT = 8;
constexpr int PLAYER_NATIVE_TWENTY = 1024;
constexpr int PLAYER_NATIVE_FIFTY = 1152;
constexpr int PLAYER_NATIVE_SIXTY = 160;
constexpr int PLAYER_NATIVE_BURDEN_ONE = -1;
} // namespace
struct CallbackContext {
    napi_env env = nullptr;
    napi_ref callbackRef = nullptr;
};
static OH_AudioRenderer *audioRenderer;
bool g_readEnd = false;
bool g_rendererLowLatency = false;
static OH_AudioStreamBuilder *rendererBuilder;

void SetCallBackResult(AsyncCallbackInfo *asyncCallbackInfo, int32_t code) { asyncCallbackInfo->resultCode = code; }

napi_value PlayerNative::Play(napi_env env, napi_callback_info info)
{
    SampleInfo sampleInfo;
    size_t argc = PLAYER_NATIVE_THREE;
    napi_value args[PLAYER_NATIVE_THREE] = {nullptr};
    napi_value sum;
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    napi_get_value_int32(env, args[PLAYER_NATIVE_ZERO], &sampleInfo.inputFd);
    napi_get_value_int64(env, args[PLAYER_NATIVE_ONE], &sampleInfo.inputFileOffset);
    napi_get_value_int64(env, args[PLAYER_NATIVE_TWO], &sampleInfo.inputFileSize);
    
    int32_t ret = Player::GetInstance().Init(sampleInfo);
    if (ret == AVCODEC_SAMPLE_ERR_OK) {
        Player::GetInstance().Start();
        napi_create_int64(env, PLAYER_NATIVE_TWO, &sum);
        return sum;
    }
    napi_create_int64(env, PLAYER_NATIVE_BURDEN_ONE, &sum);
    
    return sum;
}

napi_value PlayerNative::GetFramesWritten(napi_env env, napi_callback_info info)
{
    napi_value sum;
    int64_t frames = Player::GetInstance().GetFramesWritten();
    napi_create_int64(env, frames, &sum);
    return sum;
}
napi_value PlayerNative::GetCurrentSampleRate(napi_env env, napi_callback_info info)
{
    napi_value sum;
    int64_t frames = Player::GetInstance().GetCurrentSampleRate();
    napi_create_int64(env, frames, &sum);
    return sum;
}

napi_value PlayerNative::GetPosition(napi_env env, napi_callback_info info)
{
    napi_value result;
    int64_t position = Player::GetInstance().GetCurrentPosition();
    napi_create_int64(env, position, &result);
    return result;
}

napi_value PlayerNative::Pause(napi_env env, napi_callback_info info)
{
    napi_value sum;
    Player::GetInstance().Pause();
    napi_create_int64(env, PLAYER_NATIVE_FIVE, &sum);
    return sum;
}

napi_value PlayerNative::CapturerStart(napi_env env, napi_callback_info info)
{
    napi_value sum;
    Player::GetInstance().CapturerStart();
    napi_create_int64(env, PLAYER_NATIVE_TWO, &sum);
    return sum;
}

napi_value PlayerNative::Release(napi_env env, napi_callback_info info)
{
    napi_value sum;
    Player::GetInstance().Release();
    napi_create_int64(env, PLAYER_NATIVE_TWO, &sum);
    return sum;
}

napi_value PlayerNative::Init(napi_env env, napi_callback_info info)
{
    SampleInfo sampleInfo;
    size_t argc = PLAYER_NATIVE_SIX;
    napi_value args[PLAYER_NATIVE_SIX] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    napi_get_value_int32(env, args[PLAYER_NATIVE_ZERO], &sampleInfo.inputFd);
    napi_get_value_int64(env, args[PLAYER_NATIVE_ONE], &sampleInfo.inputFileOffset);
    napi_get_value_int64(env, args[PLAYER_NATIVE_TWO], &sampleInfo.inputFileSize);
    
    napi_get_value_int32(env, args[PLAYER_NATIVE_THREE], &sampleInfo.outputFd);
    size_t strLen = PLAYER_NATIVE_ZERO;
    napi_get_value_string_utf8(env, args[PLAYER_NATIVE_FOUR], nullptr, PLAYER_NATIVE_ZERO, &strLen);
    std::string audioCodecMime(strLen, '\0');
    napi_get_value_string_utf8(env, args[PLAYER_NATIVE_FOUR], &audioCodecMime[PLAYER_NATIVE_ZERO],
                               strLen + PLAYER_NATIVE_ONE, &strLen);
    if (audioCodecMime == "AAC") {
        sampleInfo.audioCodecMime_ = OH_AVCODEC_MIMETYPE_AUDIO_AAC;
        sampleInfo.samplingPoints = PLAYER_NATIVE_TWENTY;
    } else if (audioCodecMime == "MP3") {
        sampleInfo.audioCodecMime_ = OH_AVCODEC_MIMETYPE_AUDIO_MPEG;
        sampleInfo.samplingPoints = PLAYER_NATIVE_FIFTY;
    } else if (audioCodecMime == "G711mu") {
        sampleInfo.audioCodecMime_ = OH_AVCODEC_MIMETYPE_AUDIO_G711MU;
    } else if (audioCodecMime == "AMR") {
        sampleInfo.samplingPoints = PLAYER_NATIVE_SIXTY;
    }
    sampleInfo.audioMime = audioCodecMime;
    sampleInfo.audioSampleOutForamt  = OH_BitsPerSample::SAMPLE_S16LE;
    strLen = PLAYER_NATIVE_ZERO;
    napi_get_value_string_utf8(env, args[PLAYER_NATIVE_FIVE], nullptr, PLAYER_NATIVE_ZERO, &strLen);
    std::string audioEncapsulationFormat(strLen, '\0');
    napi_get_value_string_utf8(env, args[PLAYER_NATIVE_FIVE], &audioEncapsulationFormat[PLAYER_NATIVE_ZERO],
                               strLen + PLAYER_NATIVE_ONE, &strLen);
    sampleInfo.audioEncapsulationFormat = audioEncapsulationFormat;
    
    int32_t ret = Summary::GetInstance().Init(sampleInfo);
    if (ret == AVCODEC_SAMPLE_ERR_OK) {
        ret = Summary::GetInstance().Start();
    } else {
        Summary::GetInstance().Stop();
    }
    return nullptr;
}

napi_value PlayerNative::Stop(napi_env env, napi_callback_info info)
{
    Summary::GetInstance().Stop();
    return nullptr;
}

napi_value PlayerNative::TranscodingInit(napi_env env, napi_callback_info info)
{
    SampleInfo sampleInfo;
    size_t argc = PLAYER_NATIVE_THREE;
    napi_value args[PLAYER_NATIVE_THREE] = {nullptr};
    napi_value resultObj;
    napi_value SampleRate;
    napi_value ChannelCount;
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    napi_get_value_int32(env, args[PLAYER_NATIVE_ZERO], &sampleInfo.inputFd);
    napi_get_value_int64(env, args[PLAYER_NATIVE_ONE], &sampleInfo.inputFileOffset);
    napi_get_value_int64(env, args[PLAYER_NATIVE_TWO], &sampleInfo.inputFileSize);
    
    int32_t ret = Transcoding::GetInstance().Init(sampleInfo);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        napi_value sum;
        napi_create_int64(env, PLAYER_NATIVE_ZERO, &sum);
        return sum;
    }
    
    int32_t audioSampleRate = Transcoding::GetInstance().audioSampleRate();
    int32_t audioChannelCount = Transcoding::GetInstance().audioChannelCount();
    
    napi_create_object(env, &resultObj);
    
    napi_create_int64(env, audioSampleRate, &SampleRate);
    napi_create_int64(env, audioChannelCount, &ChannelCount);
    napi_set_named_property(env, resultObj, "sampleRate", SampleRate);
    napi_set_named_property(env, resultObj, "channelCount", ChannelCount);
    
    return resultObj;
}

napi_value PlayerNative::TranscodingStop(napi_env env, napi_callback_info info)
{
    Transcoding::GetInstance().Stop();
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor classProp[] = {
        {"playNative", nullptr, PlayerNative::Play, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"pause", nullptr, PlayerNative::Pause, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"capturerStart", nullptr, PlayerNative::CapturerStart, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getFramesWritten", nullptr, PlayerNative::GetFramesWritten, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getFileSize", nullptr, PlayerNative::GetCurrentSampleRate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCurrentPosition", nullptr, PlayerNative::GetPosition, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"release", nullptr, PlayerNative::Release, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"init", nullptr, PlayerNative::Init, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"stop", nullptr, PlayerNative::Stop, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"transcodingInit", nullptr, PlayerNative::TranscodingInit, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"transcodingStop", nullptr, PlayerNative::TranscodingStop, nullptr, nullptr, nullptr, napi_default, nullptr},
    };

    napi_define_properties(env, exports, sizeof(classProp) / sizeof(classProp[PLAYER_NATIVE_ZERO]), classProp);
    return exports;
}
EXTERN_C_END

static napi_module PlayerModule = {
    .nm_version = PLAYER_NATIVE_ONE,
    .nm_flags = PLAYER_NATIVE_ZERO,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "player",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterPlayerModule(void) { napi_module_register(&PlayerModule); }