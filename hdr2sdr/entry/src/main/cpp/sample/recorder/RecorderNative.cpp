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

#include "RecorderNative.h"
#include "dfx/error/AVCodecSampleError.h"
#include <hilog/log.h>

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0xFF00
#define LOG_TAG "recorder"

struct AsyncCallbackInfo {
    napi_env env;
    napi_async_work asyncWork;
    napi_deferred deferred;
    int32_t resultCode = 0;
    std::string surfaceId = "";
    SampleInfo sampleInfo;
};

void DealCallBack(napi_env env, void *data) {
    if (data == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "RecorderNative", "Async callback data is null");
        return;
    }
    AsyncCallbackInfo *asyncCallbackInfo = static_cast<AsyncCallbackInfo *>(data);
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

void SetCallBackResult(AsyncCallbackInfo *asyncCallbackInfo, int32_t code) { asyncCallbackInfo->resultCode = code; }

void SurfaceIdCallBack(AsyncCallbackInfo *asyncCallbackInfo, std::string surfaceId) {
    asyncCallbackInfo->surfaceId = surfaceId;
}

void NativeInit(napi_env env, void *data) {
    AsyncCallbackInfo *asyncCallbackInfo = static_cast<AsyncCallbackInfo *>(data);
    int32_t ret = Recorder::GetInstance().Init(asyncCallbackInfo->sampleInfo);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        SetCallBackResult(asyncCallbackInfo, -1);
    }

    uint64_t id = 0;
    ret = OH_NativeWindow_GetSurfaceId(asyncCallbackInfo->sampleInfo.window, &id);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        SetCallBackResult(asyncCallbackInfo, -1);
    }
    asyncCallbackInfo->surfaceId = std::to_string(id);
    SurfaceIdCallBack(asyncCallbackInfo, asyncCallbackInfo->surfaceId);
}

napi_value RecorderNative::Init(napi_env env, napi_callback_info info) {
    SampleInfo sampleInfo;
    size_t argc = 7;
    napi_value args[7] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_get_value_int32(env, args[0], &sampleInfo.outputFd);
    char videoCodecMime[20] = {0};
    size_t videoCodecMimeStrlen = 0;
    size_t len = 20;
    napi_get_value_string_utf8(env, args[1], videoCodecMime, len, &videoCodecMimeStrlen);
    napi_get_value_int32(env, args[2], &sampleInfo.videoWidth);
    napi_get_value_int32(env, args[3], &sampleInfo.videoHeight);
    napi_get_value_double(env, args[4], &sampleInfo.frameRate);
    napi_get_value_int32(env, args[5], &sampleInfo.isHDRVivid);
    napi_get_value_int64(env, args[6], &sampleInfo.bitrate);
    sampleInfo.videoCodecMime = videoCodecMime;

    if (sampleInfo.isHDRVivid) {
        sampleInfo.hevcProfile = HEVC_PROFILE_MAIN_10;
    }

    sampleInfo.audioCodecMime = OH_AVCODEC_MIMETYPE_AUDIO_AAC;
    sampleInfo.audioSampleForamt = OH_BitsPerSample::SAMPLE_S16LE;
    sampleInfo.audioSampleRate = 48000;
    sampleInfo.audioChannelCount = 2;
    sampleInfo.audioBitRate = 32000;
    sampleInfo.audioChannelLayout = OH_AudioChannelLayout::CH_LAYOUT_STEREO;
    sampleInfo.audioMaxInputSize = sampleInfo.audioSampleRate * 0.02 * sampleInfo.audioChannelCount * sizeof(short);


    napi_value promise;
    napi_deferred deferred;
    napi_create_promise(env, &deferred, &promise);

    AsyncCallbackInfo *asyncCallbackInfo = new AsyncCallbackInfo();

    asyncCallbackInfo->env = env;
    asyncCallbackInfo->asyncWork = nullptr;
    asyncCallbackInfo->deferred = deferred;
    asyncCallbackInfo->resultCode = -1;
    asyncCallbackInfo->sampleInfo = sampleInfo;

    napi_value resourceName;
    napi_create_string_latin1(env, "recorder", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_async_work(
        env, nullptr, resourceName, [](napi_env env, void *data) { NativeInit(env, data); },
        [](napi_env env, napi_status status, void *data) { DealCallBack(env, data); }, (void *)asyncCallbackInfo,
        &asyncCallbackInfo->asyncWork);
    napi_queue_async_work(env, asyncCallbackInfo->asyncWork);
    return promise;
}

napi_value RecorderNative::Start(napi_env env, napi_callback_info info) {
    Recorder::GetInstance().Start();
    return nullptr;
}

void NativeStop(napi_env env, void *data) {
    AsyncCallbackInfo *asyncCallbackInfo = static_cast<AsyncCallbackInfo *>(data);
    int32_t ret = Recorder::GetInstance().Stop();
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        SetCallBackResult(asyncCallbackInfo, -1);
    }
    SetCallBackResult(asyncCallbackInfo, 0);
}

napi_value RecorderNative::Stop(napi_env env, napi_callback_info info) {
    napi_value promise;
    napi_deferred deferred;
    napi_create_promise(env, &deferred, &promise);

    AsyncCallbackInfo *asyncCallbackInfo = new AsyncCallbackInfo();

    asyncCallbackInfo->env = env;
    asyncCallbackInfo->asyncWork = nullptr;
    asyncCallbackInfo->deferred = deferred;

    NativeStop(env, asyncCallbackInfo);
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor classProp[] = {
        {"initNative", nullptr, RecorderNative::Init, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"startNative", nullptr, RecorderNative::Start, nullptr, nullptr, nullptr, napi_default, nullptr},
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
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "recorder",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterRecorderModule(void) { napi_module_register(&RecorderModule); }