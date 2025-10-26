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

#include <cstdint>
#include <fstream>
#include <map>
#include "Recorder.h"
#include "AVCodecSampleError.h"
#include "RecorderNative.h"
#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0xFF00
#define LOG_TAG "recorder"

namespace {
constexpr double RECORDERNATIVE_DOUBLE_TWO = 0.02;
constexpr int RECORDERNATIVE_ZERO = 0;
constexpr int RECORDERNATIVE_ONE = 1;
constexpr int RECORDERNATIVE_TWO = 2;
constexpr int RECORDERNATIVE_THREE = 3;
constexpr int RECORDERNATIVE_FOUR = 4;
constexpr int RECORDERNATIVE_FIVE = 5;
constexpr int RECORDERNATIVE_AMR_SAMPLING_1 = 8000;
constexpr int RECORDERNATIVE_AMR_CODERATE_1 = 10200;
constexpr int RECORDERNATIVE_AMR_SAMPLING_2 = 16000;
constexpr int RECORDERNATIVE_AMR_CODERATE_2 = 23050;
constexpr int RECORDERNATIVE_MP3_SAMPLING_1 = 16000;
constexpr int RECORDERNATIVE_MP3_CODERATE_1 = 48000;
constexpr int RECORDERNATIVE_MP3_CODERATE_2 = 80000;
constexpr int RECORDERNATIVE_MP3_SAMPLING_2 = 22050;
constexpr int RECORDERNATIVE_MP3_CODERATE_3 = 64000;
constexpr int RECORDERNATIVE_MP3_SAMPLING_3 = 24000;
constexpr int RECORDERNATIVE_MP3_CODERATE_4 = 96000;
constexpr int RECORDERNATIVE_MP3_SAMPLING_4 = 32000;
constexpr int RECORDERNATIVE_MP3_SAMPLING_5 = 44100;
constexpr int RECORDERNATIVE_MP3_CODERATE_5 = 128000;
constexpr int RECORDERNATIVE_MP3_SAMPLING_6 = 48000;
constexpr int RECORDERNATIVE_MP3_CODERATE_6 = 160000;
constexpr int RECORDERNATIVE_G711MU_CODERATE_1 = 64000;
constexpr int RECORDERNATIVE_AAC_SAMPLING_1 = 8000;
constexpr int RECORDERNATIVE_AAC_CODERATE_1 = 24000;
constexpr int RECORDERNATIVE_AAC_CODERATE_2 = 32000;
constexpr int RECORDERNATIVE_AAC_SAMPLING_2 = 12000;
constexpr int RECORDERNATIVE_AAC_CODERATE_3 = 48000;
constexpr int RECORDERNATIVE_AAC_SAMPLING_3 = 16000;
constexpr int RECORDERNATIVE_AAC_CODERATE_4 = 96000;
constexpr int RECORDERNATIVE_AAC_SAMPLING_4 = 22050;
constexpr int RECORDERNATIVE_AAC_CODERATE_5 = 128000;
constexpr int RECORDERNATIVE_AAC_SAMPLING_5 = 24000;
constexpr int RECORDERNATIVE_AAC_CODERATE_6 = 48000;
constexpr int RECORDERNATIVE_AAC_CODERATE_7 = 80000;
constexpr int RECORDERNATIVE_AAC_SAMPLING_6 = 32000;
constexpr int RECORDERNATIVE_AAC_CODERATE_8 = 56000;
constexpr int RECORDERNATIVE_AAC_SAMPLING_7 = 44100;
constexpr int RECORDERNATIVE_AAC_SAMPLING_8 = 48000;
constexpr int RECORDERNATIVE_AAC_CODERATE_9 = 256000;
constexpr int RECORDERNATIVE_AAC_SAMPLING_9 = 64000;
constexpr int RECORDERNATIVE_AAC_CODERATE_10 = 128000;
constexpr int RECORDERNATIVE_AAC_CODERATE_11 = 160000;
constexpr int RECORDERNATIVE_AAC_CODERATE_12 = 192000;
constexpr int RECORDERNATIVE_AAC_SAMPLING_10 = 88200;
constexpr int RECORDERNATIVE_AAC_SAMPLING_11 = 96000;
constexpr int RECORDERNATIVE_AAC_SAMPLING_12 = 11025;
}
struct AsyncCallbackInfo {
    napi_env env;
    napi_async_work asyncWork;
    napi_deferred deferred;
    int32_t resultCode = 0;
    std::string surfaceId = "";
    SampleInfo sampleInfo;
};

void DealCallBackImpl(napi_env env, napi_status status, AsyncCallbackInfo* asyncCallbackInfo)
{
    napi_value code;
    napi_create_int32(env, asyncCallbackInfo->resultCode, &code);
    napi_value surfaceId;
    napi_create_string_utf8(env, asyncCallbackInfo->surfaceId.data(), NAPI_AUTO_LENGTH, &surfaceId);
    napi_value obj;
    napi_create_object(env, &obj);

    napi_set_named_property(env, obj, "code", code);
    napi_set_named_property(env, obj, "surfaceId", surfaceId);
    napi_resolve_deferred(asyncCallbackInfo->env, asyncCallbackInfo->deferred, obj);
    napi_delete_async_work(env, asyncCallbackInfo->asyncWork);
    delete asyncCallbackInfo;
}

void DealCallBack(napi_env env, napi_status status, void* data)
{
    DealCallBackImpl(env, status, static_cast<AsyncCallbackInfo*>(data));
}

int32_t SetAmrBitRate(SampleInfo sampleInfo)
{
    if (sampleInfo.audioCodecMime == "AMR" && sampleInfo.audioSampleOutRate == RECORDERNATIVE_AMR_SAMPLING_1) {
        sampleInfo.audioCodecMime_ = OH_AVCODEC_MIMETYPE_AUDIO_AMR_NB;
        sampleInfo.audioBitRate = RECORDERNATIVE_AMR_CODERATE_1;
    } else if (sampleInfo.audioCodecMime == "AMR" && sampleInfo.audioSampleOutRate == RECORDERNATIVE_AMR_SAMPLING_2) {
        sampleInfo.audioCodecMime_ = OH_AVCODEC_MIMETYPE_AUDIO_AMR_WB;
        sampleInfo.audioBitRate = RECORDERNATIVE_AMR_CODERATE_2;
    }
    return sampleInfo.audioBitRate;
}

std::string AmrCodecMime(SampleInfo sampleInfo)
{
    if (sampleInfo.audioCodecMime == "AMR" && sampleInfo.audioSampleOutRate == RECORDERNATIVE_AMR_SAMPLING_1) {
        sampleInfo.audioCodecMime_ = OH_AVCODEC_MIMETYPE_AUDIO_AMR_NB;
    } else if (sampleInfo.audioCodecMime == "AMR" && sampleInfo.audioSampleOutRate == RECORDERNATIVE_AMR_SAMPLING_2) {
        sampleInfo.audioCodecMime_ = OH_AVCODEC_MIMETYPE_AUDIO_AMR_WB;
    }
    return sampleInfo.audioCodecMime_;
}

int32_t SetAudioBitRate(SampleInfo sampleInfo)
{
    if (sampleInfo.audioCodecMime == "MP3" && sampleInfo.audioSampleOutRate == RECORDERNATIVE_MP3_SAMPLING_1 &&
                sampleInfo.audioChannelOutCount  == RECORDERNATIVE_ONE) {
        sampleInfo.audioBitRate = RECORDERNATIVE_MP3_CODERATE_1;
    } else if (sampleInfo.audioCodecMime == "MP3" && sampleInfo.audioSampleOutRate == RECORDERNATIVE_MP3_SAMPLING_1 &&
                sampleInfo.audioChannelOutCount  == RECORDERNATIVE_TWO) {
        sampleInfo.audioBitRate = RECORDERNATIVE_MP3_CODERATE_2;
    } else if (sampleInfo.audioCodecMime == "MP3" && sampleInfo.audioSampleOutRate == RECORDERNATIVE_MP3_SAMPLING_2) {
        sampleInfo.audioBitRate = RECORDERNATIVE_MP3_CODERATE_3;
    } else if (sampleInfo.audioCodecMime == "MP3" &&  sampleInfo.audioSampleOutRate == RECORDERNATIVE_MP3_SAMPLING_3) {
        sampleInfo.audioBitRate = RECORDERNATIVE_MP3_CODERATE_4;
    } else if (sampleInfo.audioCodecMime == "MP3" && (sampleInfo.audioSampleOutRate == RECORDERNATIVE_MP3_SAMPLING_4 ||
                sampleInfo.audioSampleOutRate == RECORDERNATIVE_MP3_SAMPLING_5)) {
        sampleInfo.audioBitRate = RECORDERNATIVE_MP3_CODERATE_5;
    } else if (sampleInfo.audioCodecMime == "MP3" && sampleInfo.audioSampleOutRate == RECORDERNATIVE_MP3_SAMPLING_6) {
        sampleInfo.audioBitRate = RECORDERNATIVE_MP3_CODERATE_6;
    } else if (sampleInfo.audioCodecMime == "G711mu") {
        sampleInfo.audioBitRate = RECORDERNATIVE_G711MU_CODERATE_1;
    }
    return sampleInfo.audioBitRate;
}

int32_t CodeAacSampleInfo(SampleInfo sampleInfo)
{
    const std::map<int, int> bitRates = {
        {RECORDERNATIVE_AAC_SAMPLING_1, RECORDERNATIVE_AAC_CODERATE_1},
        {RECORDERNATIVE_AAC_SAMPLING_2, RECORDERNATIVE_AAC_CODERATE_2},
        {RECORDERNATIVE_AAC_SAMPLING_3, RECORDERNATIVE_AAC_CODERATE_4},
        {RECORDERNATIVE_AAC_SAMPLING_4, RECORDERNATIVE_AAC_CODERATE_5},
        {RECORDERNATIVE_AAC_SAMPLING_5, RECORDERNATIVE_AAC_CODERATE_6},
        {RECORDERNATIVE_AAC_SAMPLING_6, RECORDERNATIVE_AAC_CODERATE_8},
        {RECORDERNATIVE_AAC_SAMPLING_7, RECORDERNATIVE_AAC_CODERATE_6},
        {RECORDERNATIVE_AAC_SAMPLING_8, RECORDERNATIVE_AAC_CODERATE_9},
        {RECORDERNATIVE_AAC_SAMPLING_9, RECORDERNATIVE_AAC_CODERATE_10},
        {RECORDERNATIVE_AAC_SAMPLING_10, RECORDERNATIVE_AAC_CODERATE_11},
        {RECORDERNATIVE_AAC_SAMPLING_11, RECORDERNATIVE_AAC_CODERATE_12}
    };
    if (sampleInfo.audioCodecMime == "AAC") {
        auto it = bitRates.find(sampleInfo.audioSampleOutRate);
        if (it != bitRates.end()) {
            switch (sampleInfo.audioChannelOutCount) {
                case RECORDERNATIVE_ONE: sampleInfo.audioBitRate = it->second; break;
                case RECORDERNATIVE_TWO: sampleInfo.audioBitRate = it->second; break;
                default:
                    break;
            }
        }
    }
    return sampleInfo.audioBitRate;
}

std::string CodeCodecMime(SampleInfo sampleInfo)
{
    if (sampleInfo.audioCodecMime == "AAC") {
        sampleInfo.audioCodecMime_ = OH_AVCODEC_MIMETYPE_AUDIO_AAC;
    } else if (sampleInfo.audioCodecMime == "MP3") {
        sampleInfo.audioCodecMime_ = OH_AVCODEC_MIMETYPE_AUDIO_MPEG;
    } else if (sampleInfo.audioCodecMime == "G711mu") {
        sampleInfo.audioCodecMime_ = OH_AVCODEC_MIMETYPE_AUDIO_G711MU;
    }
    return sampleInfo.audioCodecMime_;
}

int64_t CodeOutLayout(SampleInfo sampleInfo)
{
    if (sampleInfo.audioChannelOutCount  == RECORDERNATIVE_ONE) {
        sampleInfo.audioChannelOutLayout = OH_AudioChannelLayout::CH_LAYOUT_MONO;
    } else if (sampleInfo.audioChannelOutCount  == RECORDERNATIVE_TWO) {
        sampleInfo.audioChannelOutLayout = OH_AudioChannelLayout::CH_LAYOUT_STEREO;
    }
    return sampleInfo.audioChannelOutLayout;
}

int32_t MaxInputOutSize(SampleInfo sampleInfo)
{
    sampleInfo.audioMaxInputOutSize = sampleInfo.audioSampleOutRate * RECORDERNATIVE_DOUBLE_TWO *
                                        sampleInfo.audioChannelOutCount  * sizeof(short);
    return sampleInfo.audioMaxInputOutSize;
}

void SetCallBackResult(AsyncCallbackInfo *asyncCallbackInfo, int32_t code) { asyncCallbackInfo->resultCode = code; }

napi_value RecorderNative::Init(napi_env env, napi_callback_info info)
{
    SampleInfo sampleInfo;
    size_t argc = RECORDERNATIVE_FIVE;
    napi_value args[RECORDERNATIVE_FIVE] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    napi_get_value_int32(env, args[RECORDERNATIVE_ZERO], &sampleInfo.outputFd);
    size_t strLen = RECORDERNATIVE_ZERO;
    napi_get_value_string_utf8(env, args[RECORDERNATIVE_ONE], nullptr, RECORDERNATIVE_ZERO, &strLen);
    std::string audioCodecMime(strLen, '\0');
    napi_get_value_string_utf8(env, args[RECORDERNATIVE_ONE], &audioCodecMime[RECORDERNATIVE_ZERO],
                               strLen + RECORDERNATIVE_ONE, &strLen);
    sampleInfo.audioCodecMime = audioCodecMime;
    sampleInfo.audioSampleOutForamt  = OH_BitsPerSample::SAMPLE_S16LE;
    sampleInfo.audioCodecMime_ = CodeCodecMime(sampleInfo);
    strLen = RECORDERNATIVE_ZERO;
    napi_get_value_string_utf8(env, args[RECORDERNATIVE_TWO], nullptr, 0, &strLen);
    std::string audioEncapsulationFormat(strLen, '\0');
    napi_get_value_string_utf8(env, args[RECORDERNATIVE_TWO], &audioEncapsulationFormat[RECORDERNATIVE_ZERO],
                               strLen + RECORDERNATIVE_ONE, &strLen);
    sampleInfo.audioEncapsulationFormat = audioEncapsulationFormat;
    strLen = RECORDERNATIVE_ZERO;
    napi_get_value_string_utf8(env, args[RECORDERNATIVE_THREE], nullptr, RECORDERNATIVE_ZERO, &strLen);
    std::string audioSampleRate(strLen, '\0');
    napi_get_value_string_utf8(env, args[RECORDERNATIVE_THREE], &audioSampleRate[RECORDERNATIVE_ZERO],
                               strLen + RECORDERNATIVE_ONE, &strLen);
    sampleInfo.audioSampleOutRate  = std::stol(audioSampleRate);
    strLen = RECORDERNATIVE_ZERO;
    napi_get_value_string_utf8(env, args[RECORDERNATIVE_FOUR], nullptr, RECORDERNATIVE_ZERO, &strLen);
    std::string audioChannelCount(strLen, '\0');
    napi_get_value_string_utf8(env, args[RECORDERNATIVE_FOUR], &audioChannelCount[RECORDERNATIVE_ZERO],
                               strLen + RECORDERNATIVE_ONE, &strLen);
    sampleInfo.audioChannelOutCount  = std::stol(audioChannelCount);
    sampleInfo.audioChannelOutLayout = CodeOutLayout(sampleInfo);
    sampleInfo.audioMaxInputOutSize = MaxInputOutSize(sampleInfo);
    if (sampleInfo.audioCodecMime == "AAC") {
        sampleInfo.audioBitRate = CodeAacSampleInfo(sampleInfo);
    } else if (sampleInfo.audioCodecMime == "AMR") {
        sampleInfo.audioBitRate = SetAmrBitRate(sampleInfo);
        sampleInfo.audioCodecMime_ = AmrCodecMime(sampleInfo);
    } else {
        sampleInfo.audioBitRate = SetAudioBitRate(sampleInfo);
    }
    Recorder::GetInstance().Init(sampleInfo);
    napi_value promise;
    napi_create_int64(env, RECORDERNATIVE_ONE, &promise);
    return promise;
}

napi_value RecorderNative::Start(napi_env env, napi_callback_info info)
{
    Recorder::GetInstance().Start();
    return nullptr;
}

napi_value RecorderNative::Pause(napi_env env, napi_callback_info info)
{
    Recorder::GetInstance().Pause();
    return nullptr;
}
napi_value RecorderNative::Resume(napi_env env, napi_callback_info info)
{
    Recorder::GetInstance().Resume();
    return nullptr;
}

void NativeStop(napi_env env, AsyncCallbackInfo *asyncCallbackInfo)
{
    int32_t ret = Recorder::GetInstance().Stop();
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        SetCallBackResult(asyncCallbackInfo, -1);
    }
    SetCallBackResult(asyncCallbackInfo, 0);
}

void NativeStopWrapper(napi_env env, void *data)
{
    NativeStop(env, static_cast<AsyncCallbackInfo*>(data));
}

napi_value RecorderNative::Stop(napi_env env, napi_callback_info info)
{
    napi_value promise;
    napi_deferred deferred;
    napi_create_promise(env, &deferred, &promise);

    AsyncCallbackInfo *asyncCallbackInfo = new AsyncCallbackInfo();

    asyncCallbackInfo->env = env;
    asyncCallbackInfo->asyncWork = nullptr;
    asyncCallbackInfo->deferred = deferred;

    napi_value resourceName;
    napi_create_string_latin1(env, "recorder", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_async_work(
        env, nullptr, resourceName,
        NativeStopWrapper,
        DealCallBack,
        asyncCallbackInfo,
        &asyncCallbackInfo->asyncWork);
    napi_queue_async_work(env, asyncCallbackInfo->asyncWork);
    return promise;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor classProp[] = {
        {"initNative", nullptr, RecorderNative::Init, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"startNative", nullptr, RecorderNative::Start, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"pauseNative", nullptr, RecorderNative::Pause, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"resumeNative", nullptr, RecorderNative::Resume, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"stopNative", nullptr, RecorderNative::Stop, nullptr, nullptr, nullptr, napi_default, nullptr},
    };

    napi_value RecorderNative = nullptr;
    const char *classBindName = "recorderNative";
    napi_define_class(env, classBindName, strlen(classBindName), nullptr, nullptr, 1, classProp, &RecorderNative);
    napi_define_properties(env, exports, sizeof(classProp) / sizeof(classProp[0]), classProp);
    return exports;
}
EXTERN_C_END

static napi_module RecorderModule = {
    .nm_version = RECORDERNATIVE_ONE,
    .nm_flags = RECORDERNATIVE_ZERO,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "recorder",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterRecorderModule(void) { napi_module_register(&RecorderModule); }