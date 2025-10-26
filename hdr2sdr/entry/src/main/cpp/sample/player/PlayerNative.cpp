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

#include "PlayerNative.h"
#include "AVCodecSampleLog.h"
#include <cstdint>
#include <hilog/log.h>
#include <native_buffer/buffer_common.h>
#include <uv.h>
#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0xFF00
#define LOG_TAG "Player"

Player *player[2];
SampleInfo *p_sampleInfo[2];

void Callback(void *asyncContext) {
    uv_loop_s *loop = nullptr;
    CallbackContext *context = (CallbackContext *)asyncContext;
    napi_get_uv_event_loop(context->env, &loop);
    if (loop == nullptr) {
        delete context;
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "playerNative", "callback::loop is nullptr");
        return;
    }
    uv_work_t *work = new uv_work_t;
    work->data = context;
    uv_queue_work(
        loop, work, [](uv_work_t *work) {},
        [](uv_work_t *work, int status) {
            CallbackContext *context = (CallbackContext *)work->data;
            napi_handle_scope scope = nullptr;
            napi_open_handle_scope(context->env, &scope);
            napi_value callbck = nullptr;
            napi_get_reference_value(context->env, context->callbackRef, &callbck);
            size_t argc = 1;
            napi_value arg;
            napi_create_int32(context->env, context->code, &arg);
            napi_value *argv = &arg;
            napi_call_function(context->env, nullptr, callbck, argc, argv, nullptr);
            napi_close_handle_scope(context->env, scope);
            delete context;
            delete work;
        });
}

napi_value Preload(napi_env env, napi_callback_info info) {

    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t inputFD = 0;
    int64_t offset = 0;
    int64_t size = 0;
    napi_get_value_int32(env, args[0], &inputFD);
    napi_get_value_int64(env, args[1], &size);

    auto source = OH_AVSource_CreateWithFD(inputFD, offset, size);
    auto sourceFormat = OH_AVSource_GetSourceFormat(source);
    if (sourceFormat == nullptr || source == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "playerNative", "source is nullptr");
        return nullptr;
    }
    int32_t trackCount = 0;
    OH_AVFormat_GetIntValue(sourceFormat, OH_MD_KEY_TRACK_COUNT, &trackCount);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "playerNative", "playerNative::Preload track count: %{public}d",
                 trackCount);
    std::string msg = "";
    for (int i = 0; i < trackCount; i++) {
        OH_AVFormat *trackFormat = OH_AVSource_GetTrackFormat(source, i);
        CHECK_AND_BREAK_LOG(trackFormat != nullptr, "GetTrackFormat failed for track %d", i);
        int32_t trackType = -1;
        OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_TRACK_TYPE, &trackType);
        if (trackType == OH_MediaType::MEDIA_TYPE_VID) {
            int32_t isVivid = 0;
            int32_t profile = 0;
            int32_t transfer = 0;
            OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_VIDEO_IS_HDR_VIVID, &isVivid);

            if (isVivid) {
                msg = "HDRVivid";
            } else {
                OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_PROFILE, &profile);
                if (profile == HEVC_PROFILE_MAIN_10) {
                    msg = "HDR";
                } else {
                    msg = "SDR";
                }
            }
            OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_TRANSFER_CHARACTERISTICS, &transfer);
            switch (transfer) {
            case TRANSFER_CHARACTERISTIC_PQ:
                msg += " PQ";
                break;
            case TRANSFER_CHARACTERISTIC_HLG:
                msg += " HLG";
                break;
            default:
                msg += " UNKNOWN";
            }
            int32_t width = 0;
            int32_t height = 0;
            OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_WIDTH, &width);
            OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_HEIGHT, &height);

            int32_t pixelFormat = 0;
            OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_PIXEL_FORMAT, &pixelFormat);
            msg += "@" + std::to_string(width) + "x" + std::to_string(height) + "@" + std::to_string(pixelFormat);
        }
        OH_AVFormat_Destroy(trackFormat);
    }
    OH_AVFormat_Destroy(sourceFormat);
    OH_AVSource_Destroy(source);
    napi_value retVal;
    napi_create_string_utf8(env, msg.c_str(), msg.size(), &retVal);
    return retVal;
}

napi_value StartPlay(napi_env env, napi_callback_info info) {
    size_t argc = 9;
    napi_value args[9] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t outputFd = -1;
    int32_t color = 0;
    int32_t metaData = 0;
    int32_t videoIndex = 0;
    int32_t processType = 0;
    napi_get_value_int32(env, args[7], &processType);
    napi_get_value_int32(env, args[3], &videoIndex);
    if (p_sampleInfo[videoIndex] == nullptr) {
        p_sampleInfo[videoIndex] = new SampleInfo();
    }
    p_sampleInfo[videoIndex]->videoIndex = videoIndex;
    p_sampleInfo[videoIndex]->processType = processType;
    napi_get_value_int32(env, args[0], &p_sampleInfo[videoIndex]->inputFd);
    napi_get_value_int64(env, args[1], &p_sampleInfo[videoIndex]->inputFileOffset);
    napi_get_value_int64(env, args[2], &p_sampleInfo[videoIndex]->inputFileSize);

    auto asyncContext = new CallbackContext();
    asyncContext->env = env;
    napi_create_reference(env, args[8], 1, &asyncContext->callbackRef);
    p_sampleInfo[videoIndex]->playDoneCallback = &Callback;
    p_sampleInfo[videoIndex]->playDoneCallbackData = asyncContext;
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "playerNative", "StartPlay: index:%{public}d, type:%{public}d",
                 videoIndex, processType);
    if (p_sampleInfo[videoIndex]->processType == 1) {
        napi_get_value_int32(env, args[4], &outputFd);
        p_sampleInfo[videoIndex]->outputFd = outputFd;
        napi_get_value_int32(env, args[5], &color);
        p_sampleInfo[videoIndex]->colorSpace = (OH_NativeBuffer_ColorSpace)color;
        napi_get_value_int32(env, args[6], &metaData);
        p_sampleInfo[videoIndex]->metaData = metaData;
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "playerNative",
                     "StartPlay: fd:%{public}d, color:%{public}d,metadata:%{public}d", outputFd, color, metaData);
        player[videoIndex] = new Player();
        player[videoIndex]->Init(*p_sampleInfo[videoIndex]);
        player[videoIndex]->Start();
        NativeXComponentSample::PluginManager::GetInstance()->SetSampleInfo(p_sampleInfo[videoIndex]);
        NativeXComponentSample::PluginManager::GetInstance()->StartProcessing();
    } else if (p_sampleInfo[videoIndex]->processType == 2) {
        // AVcodec Transcoding is only supported for HDR Vivid.
        auto source =
            OH_AVSource_CreateWithFD(p_sampleInfo[videoIndex]->inputFd, p_sampleInfo[videoIndex]->inputFileOffset,
                                     p_sampleInfo[videoIndex]->inputFileSize);
        auto sourceFormat = OH_AVSource_GetSourceFormat(source);
        if (sourceFormat == nullptr || source == nullptr) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "playerNative", "source is nullptr");
            return nullptr;
        }
        int32_t trackCount = 0;
        OH_AVFormat_GetIntValue(sourceFormat, OH_MD_KEY_TRACK_COUNT, &trackCount);
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "playerNative", "playerNative::Preload track count: %{public}d",
                     trackCount);
        for (int i = 0; i < trackCount; i++) {
            OH_AVFormat *trackFormat = OH_AVSource_GetTrackFormat(source, i);
            CHECK_AND_BREAK_LOG(trackFormat != nullptr, "GetTrackFormat failed for track %d", i);
            int32_t trackType = -1;
            OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_TRACK_TYPE, &trackType);
            if (trackType == OH_MediaType::MEDIA_TYPE_VID) {
                int32_t isHDRVivid = 0;
                bool getHDRRet = OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_VIDEO_IS_HDR_VIVID, &isHDRVivid);

                OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "playerNative", "getHDRRet status:  %{public}d", getHDRRet);
                if (getHDRRet == false || isHDRVivid == 0) {
                    OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "playerNative", "is not HDRVivid");
                    OH_AVFormat_Destroy(trackFormat);
                    return 0;
                }
            }
        }
        player[videoIndex] = new Player();
        player[videoIndex]->Init(*p_sampleInfo[videoIndex]);
        player[videoIndex]->Start();
    } else {
        player[videoIndex] = new Player();
        player[videoIndex]->Init(*p_sampleInfo[videoIndex]);
        player[videoIndex]->Start();
    }
    return nullptr;
}

napi_value Destroy(napi_env env, napi_callback_info info) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "playerNative", "playerNative::Destroy");
    if (p_sampleInfo[0] != nullptr) {
        delete p_sampleInfo[0];
        p_sampleInfo[0] = nullptr;
    }
    if (p_sampleInfo[1] != nullptr) {
        delete p_sampleInfo[1];
        p_sampleInfo[1] = nullptr;
    }
    NativeXComponentSample::PluginManager::GetInstance()->Release();
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor classProp[] = {
        {"preload", nullptr, Preload, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"playNative", nullptr, StartPlay, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"destroy", nullptr, Destroy, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_define_properties(env, exports, sizeof(classProp) / sizeof(classProp[0]), classProp);
    NativeXComponentSample::PluginManager::GetInstance()->Export(env, exports);
    return exports;
}
EXTERN_C_END

static napi_module PlayerModule = {.nm_version = 1,
                                   .nm_flags = 0,
                                   .nm_filename = nullptr,
                                   .nm_register_func = Init,
                                   .nm_modname = "player",
                                   .nm_priv = ((void *)0),
                                   .reserved = {0}};

extern "C" __attribute__((constructor)) void RegisterPlayerModule(void) { napi_module_register(&PlayerModule); }