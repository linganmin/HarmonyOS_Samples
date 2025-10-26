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
#include <cstdint>
#include <native_window/external_window.h>
#include "Player.h"
#include "Recorder.h"
#include "dfx/error/SampleError.h"
#include "SampleLog.h"
#include "dfx/error/SampleError.h"

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
    Recorder *recorder = nullptr;
};

void DealCallBack(napi_env env, void *data)
{
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

void SurfaceIdCallBack(AsyncCallbackInfo *asyncCallbackInfo, std::string surfaceId)
{
    asyncCallbackInfo->surfaceId = surfaceId;
}

void NativeInit(napi_env env, void *data)
{
    int32_t ret = SAMPLE_ERR_ERROR;
    AsyncCallbackInfo *asyncCallbackInfo = static_cast<AsyncCallbackInfo *>(data);
    if (asyncCallbackInfo->recorder) {
        ret = asyncCallbackInfo->recorder->Init(asyncCallbackInfo->sampleInfo);
    }
    if (ret != SAMPLE_ERR_OK) {
        SetCallBackResult(asyncCallbackInfo, -1);
    }

    uint64_t id = 0;
    ret = OH_NativeWindow_GetSurfaceId(asyncCallbackInfo->sampleInfo.videoInfo.window, &id);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "RenderThread",
                 "ljc nativeImageWindow_:%{public}p, nativeImageSurfaceId_%{public}lu.",
                 asyncCallbackInfo->sampleInfo.videoInfo.window, id);
    if (ret != SAMPLE_ERR_OK) {
        SetCallBackResult(asyncCallbackInfo, -1);
    }
    asyncCallbackInfo->surfaceId = std::to_string(id);
    SurfaceIdCallBack(asyncCallbackInfo, asyncCallbackInfo->surfaceId);
}

napi_value RecorderNative::CreateRecorder(napi_env env, napi_callback_info info)
{
    OH_LOG_INFO(LOG_APP, "enter CreateRecorderObject");

    napi_value result;
    auto recorder = new Recorder();
    int64_t addrValue = (int64_t)recorder;
    napi_create_bigint_int64(env, addrValue, &result);
    OH_LOG_INFO(LOG_APP, "end CreateRecorderObject, addrValue:%{public}ld", addrValue);
    return result;
}

napi_value RecorderNative::ReleaseRecorder(napi_env env, napi_callback_info info)
{
    OH_LOG_INFO(LOG_APP, "enter ReleaseRecorder");

    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int64_t addrValue = 0;
    bool flag = false;
    napi_get_value_bigint_int64(env, args[0], &addrValue, &flag);
    Recorder *recorder = reinterpret_cast<Recorder *>(addrValue);
    if (recorder) {
        delete recorder;
        recorder = nullptr;
    }
    OH_LOG_INFO(LOG_APP, "end ReleaseRecorder");
    return nullptr;
}

napi_value RecorderNative::Init(napi_env env, napi_callback_info info)
{
    SampleInfo sampleInfo;
    size_t argc = 9;
    napi_value args[9] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int64_t addrValue = 0;
    bool flag = false;
    napi_get_value_bigint_int64(env, args[0], &addrValue, &flag);
    OH_LOG_INFO(LOG_APP, " Init, addrValue:%{public}ld", addrValue);
    Recorder *recorder = reinterpret_cast<Recorder *>(addrValue);
    napi_get_value_int32(env, args[1], &sampleInfo.fileInfo.outputFd);
    char videoCodecMime[20] = {0};
    size_t videoCodecMimeStrlen = 0;
    size_t len = 20;
    napi_get_value_string_utf8(env, args[2], videoCodecMime, len, &videoCodecMimeStrlen);
    napi_get_value_int32(env, args[3], &sampleInfo.videoInfo.videoWidth);
    napi_get_value_int32(env, args[4], &sampleInfo.videoInfo.videoHeight);
    napi_get_value_double(env, args[5], &sampleInfo.videoInfo.frameRate);
    napi_get_value_int32(env, args[6], &sampleInfo.videoInfo.isHDRVivid);
    napi_get_value_int64(env, args[7], &sampleInfo.videoInfo.bitrate);
    napi_get_value_int32(env, args[8], &sampleInfo.audioInfo.isOpenEchoCancel);
    sampleInfo.videoInfo.videoCodecMime = videoCodecMime;

    if (sampleInfo.videoInfo.isHDRVivid) {
        sampleInfo.videoInfo.hevcProfile = HEVC_PROFILE_MAIN_10;
    }

    sampleInfo.audioInfo.audioCodecMime = OH_AVCODEC_MIMETYPE_AUDIO_AAC;
    sampleInfo.audioInfo.audioSampleForamt = OH_BitsPerSample::SAMPLE_S16LE;
    sampleInfo.audioInfo.audioSampleRate = 48000;
    sampleInfo.audioInfo.audioChannelCount = 2;
    sampleInfo.audioInfo.audioBitRate = 32000;
    sampleInfo.audioInfo.audioChannelLayout = OH_AudioChannelLayout::CH_LAYOUT_STEREO;
    sampleInfo.audioInfo.audioMaxInputSize = sampleInfo.audioInfo.audioSampleRate * 0.02 *
                                             sampleInfo.audioInfo.audioChannelCount * sizeof(short);

    napi_value promise;
    napi_deferred deferred;
    napi_create_promise(env, &deferred, &promise);

    AsyncCallbackInfo *asyncCallbackInfo = new AsyncCallbackInfo();

    asyncCallbackInfo->env = env;
    asyncCallbackInfo->asyncWork = nullptr;
    asyncCallbackInfo->deferred = deferred;
    asyncCallbackInfo->resultCode = -1;
    asyncCallbackInfo->sampleInfo = sampleInfo;
    asyncCallbackInfo->recorder = recorder;

    napi_value resourceName;
    napi_create_string_latin1(env, "recorder", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_async_work(
        env, nullptr, resourceName, [](napi_env env, void *data) { NativeInit(env, data); },
        [](napi_env env, napi_status status, void *data) { DealCallBack(env, data); }, (void *)asyncCallbackInfo,
        &asyncCallbackInfo->asyncWork);
    napi_queue_async_work(env, asyncCallbackInfo->asyncWork);
    return promise;
}

napi_value RecorderNative::Start(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int64_t addrValue = 0;
    bool flag = false;
    napi_get_value_bigint_int64(env, args[0], &addrValue, &flag);
    Recorder *recorder = reinterpret_cast<Recorder *>(addrValue);
    char previewSurfaceId[20] = {0};
    size_t previewSurfaceIdStrlen = 0;
    size_t len = 20;
    napi_get_value_string_utf8(env, args[1], previewSurfaceId, len, &previewSurfaceIdStrlen);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "Recoder", "previewSurfaceId:%{public}s.", previewSurfaceId);
    std::string id(previewSurfaceId);
    if (recorder) {
        recorder->Start(id);
    }
    return nullptr;
}

napi_value RecorderNative::SetPlayerAsLiveBgm(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int64_t addrValue = 0;
    bool flag = false;
    napi_get_value_bigint_int64(env, args[0], &addrValue, &flag);
    Recorder *recorder = reinterpret_cast<Recorder *>(addrValue);
    napi_get_value_bigint_int64(env, args[1], &addrValue, &flag);
    Player *player = reinterpret_cast<Player *>(addrValue);
    if (recorder && player) {
        auto bgmQueue = recorder->GetBgmQueue();
        player->SetBgmQueue(bgmQueue);
    }
    return nullptr;
}

napi_value RecorderNative::UpdateInfoForCamera(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int64_t addrValue = 0;
    bool flag = false;
    napi_get_value_bigint_int64(env, args[0], &addrValue, &flag);
    Recorder *recorder = reinterpret_cast<Recorder *>(addrValue);
    bool isFront = false;
    napi_get_value_bool(env, args[1], &isFront);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "Recoder", "isFront :%{public}d.", isFront);
    if (recorder) {
        recorder->UpdateInfoForCamera(isFront);
    }
    return nullptr;
}

napi_value RecorderNative::UpdateCameraRotation(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int64_t addrValue = 0;
    bool flag = false;
    napi_get_value_bigint_int64(env, args[0], &addrValue, &flag);
    Recorder *recorder = reinterpret_cast<Recorder *>(addrValue);
    int rotation = 270;
    napi_get_value_int32(env, args[1], &rotation);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "Recoder", "fhmrotation :%{public}d.", rotation);
    if (recorder) {
        recorder->UpdateCameraRotation(rotation);
    }
    return nullptr;
}

void NativeStop(napi_env env, void *data)
{
    int32_t ret = SAMPLE_ERR_ERROR;
    AsyncCallbackInfo *asyncCallbackInfo = static_cast<AsyncCallbackInfo *>(data);
    if (asyncCallbackInfo && asyncCallbackInfo->recorder) {
        ret = asyncCallbackInfo->recorder->Stop();
    }
    if (ret != SAMPLE_ERR_OK) {
        SetCallBackResult(asyncCallbackInfo, -1);
    }
    SetCallBackResult(asyncCallbackInfo, 0);
}

napi_value RecorderNative::Stop(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    napi_value promise;
    napi_deferred deferred;
    napi_create_promise(env, &deferred, &promise);

    int64_t addrValue = 0;
    bool flag = false;
    napi_get_value_bigint_int64(env, args[0], &addrValue, &flag);
    Recorder *recorder = reinterpret_cast<Recorder *>(addrValue);
    AsyncCallbackInfo *asyncCallbackInfo = new AsyncCallbackInfo();

    asyncCallbackInfo->env = env;
    asyncCallbackInfo->asyncWork = nullptr;
    asyncCallbackInfo->deferred = deferred;
    asyncCallbackInfo->recorder = recorder;

    napi_value resourceName;
    napi_create_string_latin1(env, "recorder", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_async_work(
        env, nullptr, resourceName, [](napi_env env, void *data) { NativeStop(env, data); },
        [](napi_env env, napi_status status, void *data) { DealCallBack(env, data); }, (void *)asyncCallbackInfo,
        &asyncCallbackInfo->asyncWork);
    napi_queue_async_work(env, asyncCallbackInfo->asyncWork);
    return promise;
}

napi_value RecorderNative::UpdateFaceInfoFromCamera(napi_env env, napi_callback_info info)
{
    FaceInfo faceInfo;
    size_t argc = 7;
    napi_value args[7] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int64_t addrValue = 0;
    bool flag = false;
    napi_get_value_bigint_int64(env, args[0], &addrValue, &flag);
    Recorder *recorder = reinterpret_cast<Recorder *>(addrValue);
    napi_get_value_bool(env, args[1], &faceInfo.valid);
    napi_get_value_int64(env, args[2], &faceInfo.timestamp);
    napi_get_value_double(env, args[3], &faceInfo.topLeftX);
    napi_get_value_double(env, args[4], &faceInfo.topLeftY);
    napi_get_value_double(env, args[5], &faceInfo.width);
    napi_get_value_double(env, args[6], &faceInfo.height);
    if (recorder) {
        recorder->UpdateFaceInfoFromCamera(faceInfo);
    }
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor classProp[] = {
        {"createRecorder", nullptr, RecorderNative::CreateRecorder, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"releaseRecorder", nullptr, RecorderNative::ReleaseRecorder, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"initNative", nullptr, RecorderNative::Init, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"startNative", nullptr, RecorderNative::Start, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"updateInfoForCamera", nullptr, RecorderNative::UpdateInfoForCamera, nullptr, nullptr, nullptr, napi_default,
         nullptr},
        {"UpdateCameraRotation", nullptr, RecorderNative::UpdateCameraRotation, nullptr, nullptr, nullptr, napi_default,
         nullptr},
        {"stopNative", nullptr, RecorderNative::Stop, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"setPlayerAsLiveBgm", nullptr, RecorderNative::SetPlayerAsLiveBgm, nullptr, nullptr, nullptr, napi_default,
         nullptr},
        {"UpdateFaceInfoFromCamera", nullptr, RecorderNative::UpdateFaceInfoFromCamera, nullptr, nullptr, nullptr,
         napi_default, nullptr},
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