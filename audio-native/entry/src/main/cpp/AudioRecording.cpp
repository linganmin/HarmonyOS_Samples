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

#include <string>
#include <sys/stat.h>
#include "napi/native_api.h"
#include "ohaudio/native_audiocapturer.h"
#include "ohaudio/native_audiorenderer.h"
#include "ohaudio/native_audiostreambuilder.h"
#include "ohaudio/native_audiostream_base.h"

const int GLOBAL_RESMGR = 0xFF00;
const char *TAG = "[Sample_audio]";

namespace AudioTestConstants {
constexpr int32_t FIRST_ARG_IDX = 1;
constexpr int32_t SECOND_ARG_IDX = 2;
constexpr int32_t THIRD_ARG_IDX = 3;
constexpr int32_t RECODER_TIME = 10000;
constexpr int32_t COUNTDOWN_INTERVAL = 1000;
constexpr int32_t CONVERT_RATE = 1000;
constexpr int32_t WAIT_INTERVAL = 1000;
} // namespace AudioTestConstants

static std::string g_filePath = "/data/storage/el2/base/haps/entry/files/oh_test_audio.pcm";

FILE *g_file = nullptr;
bool g_readEnd = false;
bool g_rendererLowLatency = false;
int32_t g_samplingRate = 48000;
int32_t g_channelCount = 2;

static OH_AudioCapturer *audioCapturer;
static OH_AudioRenderer *audioRenderer;
static OH_AudioStreamBuilder *builder;
static OH_AudioStreamBuilder *rendererBuilder;

static napi_value GetRendererState(napi_env env, napi_callback_info info) {
    OH_AudioStreamBuilder *builder;
    OH_AudioStreamBuilder_Create(&builder, AUDIOSTREAM_TYPE_RENDERER);
    
    OH_AudioStream_State state;
    OH_AudioRenderer_GetCurrentState(audioRenderer, &state);
    napi_value sum;
    napi_create_int32(env, state, &sum);

    return sum;
}

static napi_value GetCapturerState(napi_env env, napi_callback_info info) {
    OH_AudioStreamBuilder *builder;
    OH_AudioStreamBuilder_Create(&builder, AUDIOSTREAM_TYPE_CAPTURER);

    OH_AudioStream_State state;
    OH_AudioCapturer_GetCurrentState(audioCapturer, &state);
    napi_value sum;
    napi_create_int32(env, state, &sum);

    return sum;
}

static napi_value GetFileState(napi_env env, napi_callback_info info) {
    napi_value sum;
    napi_create_int32(env, g_readEnd, &sum);

    return sum;
}

static napi_value GetFastState(napi_env env, napi_callback_info info) {
    napi_value sum;
    napi_create_int32(env, g_rendererLowLatency, &sum);

    return sum;
}

static napi_value GetFramesWritten(napi_env env, napi_callback_info info) {
    napi_value sum;
    int64_t frames;
    OH_AudioRenderer_GetFramesWritten(audioRenderer, &frames);
    napi_create_int64(env, frames, &sum);

    return sum;
}

static napi_value GetFileSize(napi_env env, napi_callback_info info) {
    struct stat statbuf;
    stat(g_filePath.c_str(), &statbuf);
    napi_value sum;
    int64_t fileSize = statbuf.st_size;
    napi_create_int64(env, fileSize, &sum);
    return sum;
}

static int32_t AudioCapturerOnReadData(OH_AudioCapturer *capturer, void *userData, void *buffer, int32_t bufferLen) {
    size_t count = 1;
    if (fwrite(buffer, bufferLen, count, g_file) != count) {
        printf("buffer fwrite err");
    }
    return 0;
}

static int32_t AudioRendererOnWriteData(OH_AudioRenderer *renderer, void *userData, void *buffer, int32_t bufferLen) {
    size_t readCount = fread(buffer, bufferLen, 1, g_file);
    if (!readCount) {
        if (feof(g_file)) {
            g_readEnd = true;
        }
    }
    return 0;
}

static napi_value AudioCapturerLowLatencyInit(napi_env env, napi_callback_info info) {
    if (audioCapturer) {
        OH_AudioCapturer_Release(audioCapturer);
        OH_AudioStreamBuilder_Destroy(builder);
        
        audioCapturer = nullptr;
        builder = nullptr;
    }
    if (g_file) {
        fclose(g_file);
        g_file = nullptr;
    }
    g_file = fopen(g_filePath.c_str(), "wb");
    // 1. create builder
    OH_AudioStream_Type type = AUDIOSTREAM_TYPE_CAPTURER;
    OH_AudioStreamBuilder_Create(&builder, type);
    // 2. set params and callbacks
    OH_AudioStreamBuilder_SetSamplingRate(builder, g_samplingRate);
    OH_AudioStreamBuilder_SetChannelCount(builder, g_channelCount);
    OH_AudioStreamBuilder_SetLatencyMode(builder, AUDIOSTREAM_LATENCY_MODE_FAST);

    OH_AudioCapturer_Callbacks callbacks;
    callbacks.OH_AudioCapturer_OnReadData = AudioCapturerOnReadData;
    callbacks.OH_AudioCapturer_OnError = nullptr;
    callbacks.OH_AudioCapturer_OnInterruptEvent = nullptr;
    callbacks.OH_AudioCapturer_OnStreamEvent = nullptr;
    OH_AudioStreamBuilder_SetCapturerCallback(builder, callbacks, nullptr);

    // 3. create OH_AudioCapturer
    OH_AudioStreamBuilder_GenerateCapturer(builder, &audioCapturer);
    return nullptr;
}

static napi_value AudioCapturerInit(napi_env env, napi_callback_info info) {
    if (audioCapturer) {
        OH_AudioCapturer_Release(audioCapturer);
        OH_AudioStreamBuilder_Destroy(builder);
        
        audioCapturer = nullptr;
        builder = nullptr;
    }
    if (g_file) {
        fclose(g_file);
        g_file = nullptr;
    }
    g_file = fopen(g_filePath.c_str(), "wb");
    // 1. create builder
    OH_AudioStream_Type type = AUDIOSTREAM_TYPE_CAPTURER;
    OH_AudioStreamBuilder_Create(&builder, type);
    // 2. set params and callbacks
    OH_AudioStreamBuilder_SetSamplingRate(builder, g_samplingRate);
    OH_AudioStreamBuilder_SetChannelCount(builder, g_channelCount);
    OH_AudioStreamBuilder_SetLatencyMode(builder, AUDIOSTREAM_LATENCY_MODE_NORMAL);

    OH_AudioCapturer_Callbacks callbacks;
    callbacks.OH_AudioCapturer_OnReadData = AudioCapturerOnReadData;
    callbacks.OH_AudioCapturer_OnStreamEvent = nullptr;
    callbacks.OH_AudioCapturer_OnInterruptEvent = nullptr;
    callbacks.OH_AudioCapturer_OnError = nullptr;
    OH_AudioStreamBuilder_SetCapturerCallback(builder, callbacks, nullptr);

    // 3. create OH_AudioCapturer
    OH_AudioStreamBuilder_GenerateCapturer(builder, &audioCapturer);
    return nullptr;
}


static napi_value AudioCapturerStart(napi_env env, napi_callback_info info) {
    // start
    OH_AudioCapturer_Start(audioCapturer);
    return nullptr;
}

static napi_value AudioCapturerPause(napi_env env, napi_callback_info info) {
    OH_AudioCapturer_Pause(audioCapturer);
    return nullptr;
}

static napi_value AudioCapturerStop(napi_env env, napi_callback_info info) {
    OH_AudioCapturer_Stop(audioCapturer);
    return nullptr;
}

static napi_value AudioCapturerRelease(napi_env env, napi_callback_info info) {
    if (audioCapturer) {
        OH_AudioCapturer_Release(audioCapturer);
        OH_AudioStreamBuilder_Destroy(builder);
        audioCapturer = nullptr;
        builder = nullptr;
    }
    if (g_file) {
        fclose(g_file);
        g_file = nullptr;
    }
    return nullptr;
}

static napi_value CloseFile(napi_env env, napi_callback_info info) {
    if (g_file) {
        fclose(g_file);
        g_file = nullptr;
    }
    return nullptr;
}

static napi_value AudioRendererLowLatencyInit(napi_env env, napi_callback_info info) {
    if (audioRenderer) {
        OH_AudioRenderer_Release(audioRenderer);
        OH_AudioStreamBuilder_Destroy(rendererBuilder);
        
        audioRenderer = nullptr;
        rendererBuilder = nullptr;
    }
    if (g_file) {
        fclose(g_file);
        g_file = nullptr;
    }
    g_file = fopen(g_filePath.c_str(), "rb");
    if (g_file == nullptr) {
        return 0;
    }
    // create builder
    OH_AudioStream_Type type = AUDIOSTREAM_TYPE_RENDERER;
    OH_AudioStreamBuilder_Create(&rendererBuilder, type);

    // set params and callbacks
    OH_AudioStreamBuilder_SetSamplingRate(rendererBuilder, g_samplingRate);
    OH_AudioStreamBuilder_SetChannelCount(rendererBuilder, g_channelCount);
    OH_AudioStreamBuilder_SetLatencyMode(rendererBuilder, AUDIOSTREAM_LATENCY_MODE_FAST);

    OH_AudioRenderer_Callbacks rendererCallbacks;
    rendererCallbacks.OH_AudioRenderer_OnWriteData = AudioRendererOnWriteData;
    rendererCallbacks.OH_AudioRenderer_OnError = nullptr;
    rendererCallbacks.OH_AudioRenderer_OnInterruptEvent = nullptr;
    rendererCallbacks.OH_AudioRenderer_OnStreamEvent = nullptr;
    OH_AudioStreamBuilder_SetRendererCallback(rendererBuilder, rendererCallbacks, nullptr);

    // create OH_AudioRenderer
    OH_AudioStreamBuilder_GenerateRenderer(rendererBuilder, &audioRenderer);
    g_readEnd = false;
    g_rendererLowLatency = true;
    return nullptr;
}

static napi_value AudioRendererInit(napi_env env, napi_callback_info info) {
    if (audioRenderer) {
        OH_AudioRenderer_Release(audioRenderer);
        OH_AudioStreamBuilder_Destroy(rendererBuilder);
        
        audioRenderer = nullptr;
        rendererBuilder = nullptr;
    }
    if (g_file) {
        fclose(g_file);
        g_file = nullptr;
    }
    g_file = fopen(g_filePath.c_str(), "rb");
    if (g_file == nullptr) {
        return 0;
    }
    // create builder
    OH_AudioStream_Type type = AUDIOSTREAM_TYPE_RENDERER;
    OH_AudioStreamBuilder_Create(&rendererBuilder, type);

    // set params and callbacks
    OH_AudioStreamBuilder_SetSamplingRate(rendererBuilder, g_samplingRate);
    OH_AudioStreamBuilder_SetChannelCount(rendererBuilder, g_channelCount);
    OH_AudioStreamBuilder_SetLatencyMode(rendererBuilder, AUDIOSTREAM_LATENCY_MODE_NORMAL);
    OH_AudioStreamBuilder_SetFrameSizeInCallback(rendererBuilder, 2500);

    OH_AudioRenderer_Callbacks rendererCallbacks;
    rendererCallbacks.OH_AudioRenderer_OnWriteData = AudioRendererOnWriteData;
    rendererCallbacks.OH_AudioRenderer_OnStreamEvent = nullptr;
    rendererCallbacks.OH_AudioRenderer_OnInterruptEvent = nullptr;
    rendererCallbacks.OH_AudioRenderer_OnError = nullptr;
    OH_AudioStreamBuilder_SetRendererCallback(rendererBuilder, rendererCallbacks, nullptr);

    // create OH_AudioRenderer
    OH_AudioStreamBuilder_GenerateRenderer(rendererBuilder, &audioRenderer);
    g_readEnd = false;
    g_rendererLowLatency = false;
    return nullptr;
}


static napi_value AudioRendererStart(napi_env env, napi_callback_info info) {
    g_readEnd = false;
    // start
    OH_AudioRenderer_Start(audioRenderer);
    return nullptr;
}

static napi_value AudioRendererPause(napi_env env, napi_callback_info info) {
    g_readEnd = false;
    OH_AudioRenderer_Pause(audioRenderer);
    return nullptr;
}

static napi_value AudioRendererStop(napi_env env, napi_callback_info info) {
    g_readEnd = false;
    OH_AudioRenderer_Stop(audioRenderer);
    return nullptr;
}

static napi_value AudioRendererRelease(napi_env env, napi_callback_info info) {
    if (audioRenderer) {
        OH_AudioRenderer_Release(audioRenderer);
        OH_AudioStreamBuilder_Destroy(rendererBuilder);
        audioRenderer = nullptr;
        rendererBuilder = nullptr;
    }
    if (g_file) {
        fclose(g_file);
        g_file = nullptr;
    }
    return nullptr;
}


EXTERN_C_START static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"closeFile", nullptr, CloseFile, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"audioCapturesLowLatencyInit", nullptr, AudioCapturerLowLatencyInit, nullptr, nullptr, nullptr, napi_default,
         nullptr},
        {"audioCapturesInit", nullptr, AudioCapturerInit, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"audioCapturesStart", nullptr, AudioCapturerStart, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"audioCapturesPause", nullptr, AudioCapturerPause, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"audioCapturesRelease", nullptr, AudioCapturerRelease, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"audioCapturesStop", nullptr, AudioCapturerStop, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"audioRendererLowLatencyInit", nullptr, AudioRendererLowLatencyInit, nullptr, nullptr, nullptr, napi_default,
         nullptr},
        {"audioRendererInit", nullptr, AudioRendererInit, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"audioRendererStart", nullptr, AudioRendererStart, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"audioRendererPause", nullptr, AudioRendererPause, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"audioRendererRelease", nullptr, AudioRendererRelease, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getRendererState", nullptr, GetRendererState, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getCapturerState", nullptr, GetCapturerState, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getFileSize", nullptr, GetFileSize, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getFramesWritten", nullptr, GetFramesWritten, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getFileState", nullptr, GetFileState, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getFastState", nullptr, GetFastState, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"audioRendererStop", nullptr, AudioRendererStop, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&demoModule); }
