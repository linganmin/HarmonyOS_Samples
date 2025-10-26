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

#include "PlayerNative.h"
#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0xFF00
#define LOG_TAG "player"

Player *player[2];
SampleInfo *p_sampleInfo[2];
struct CallbackContext {
    napi_env env = nullptr;
    napi_ref callbackRef = nullptr;
};

void Callback(void *asyncContext) {
    uv_loop_s *loop = nullptr;
    CallbackContext *context = (CallbackContext *)asyncContext;
    napi_get_uv_event_loop(context->env, &loop);
    uv_work_t *work = new uv_work_t;
    work->data = context;
    uv_queue_work(
        loop, work, [](uv_work_t *work) {},
        [](uv_work_t *work, int status) {
            CallbackContext *context = (CallbackContext *)work->data;
            napi_handle_scope scope = nullptr;
            // 管理 napi_value 的生命周期，防止内存泄露
            napi_open_handle_scope(context->env, &scope);
            napi_value callback = nullptr;
            napi_get_reference_value(context->env, context->callbackRef, &callback);
            // 回调至UI侧
            napi_call_function(context->env, nullptr, callback, 0, nullptr, nullptr);
            napi_close_handle_scope(context->env, scope);
            NativeXComponentSample::PluginManager::GetInstance()->StopProcessing();
            NativeXComponentSample::PluginManager::GetInstance()->~PluginManager();
            delete context;
            delete work;
        });
}

napi_value StartPlay(napi_env env, napi_callback_info info) {
    size_t argc = 7;
    napi_value args[7] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int32_t color = 0;
    int32_t metadata = 0;
    int32_t needProcess = 0;
    napi_get_value_int32(env, args[3], &needProcess);
    OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "PlayerNative", " PlayerNative::Play %{public}d", needProcess);
    if (!needProcess) {
        delete p_sampleInfo[0];
        p_sampleInfo[0] = nullptr;
        delete p_sampleInfo[1];
        p_sampleInfo[1] = nullptr;
        p_sampleInfo[0] = new SampleInfo();
        p_sampleInfo[1] = new SampleInfo();
        p_sampleInfo[0]->syncIndex = &p_sampleInfo[1]->processedIndex;
    }

    p_sampleInfo[needProcess]->processedIndex = 0;
    p_sampleInfo[needProcess]->needProcess = needProcess;
    napi_get_value_int32(env, args[0], &p_sampleInfo[needProcess]->inputFd);
    napi_get_value_int64(env, args[1], &p_sampleInfo[needProcess]->inputFileOffset);
    napi_get_value_int64(env, args[2], &p_sampleInfo[needProcess]->inputFileSize);
    
    auto asyncContext = new CallbackContext();
    asyncContext->env = env;
    napi_create_reference(env, args[6], 1, &asyncContext->callbackRef);
    p_sampleInfo[needProcess]->playDoneCallback = &Callback;
    p_sampleInfo[needProcess]->playDoneCallbackData = asyncContext;
    if (player[needProcess]) {
        delete player[needProcess];
        player[needProcess] = nullptr;
    }
    if (p_sampleInfo[needProcess]->needProcess) {
        napi_get_value_int32(env, args[4], &color);
        p_sampleInfo[needProcess]->colorSpace = (OH_NativeBuffer_ColorSpace)color;
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "PlayerNative", " PlayerNative::Play color %{public}d", color);
        napi_get_value_int32(env, args[5], &metadata);
        p_sampleInfo[needProcess]->metaData = metadata;
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "PlayerNative", " PlayerNative::Play metadata %{public}d", metadata);
        player[needProcess] = new Player();
        player[needProcess]->Init(*p_sampleInfo[needProcess]);
        player[needProcess]->Start();
        NativeXComponentSample::PluginManager::GetInstance()->SetSampleInfo(p_sampleInfo[needProcess]);
        NativeXComponentSample::PluginManager::GetInstance()->StartProcessing();
    } else {
        player[needProcess] = new Player();
        player[needProcess]->Init(*p_sampleInfo[needProcess]);
        player[needProcess]->Start();
    }
    return nullptr;
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
    auto demuxer = OH_AVDemuxer_CreateWithSource(source);
    auto sourceFormat = OH_AVSource_GetSourceFormat(source);
    int32_t trackCount = 0;
    OH_AVFormat_GetIntValue(sourceFormat, OH_MD_KEY_TRACK_COUNT, &trackCount);
    OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "PlayerNative", " PlayerNative::Play track count %{public}d", trackCount);
    std::string msg = "";
    for (int i = 0; i < trackCount; i++) {
        OH_AVFormat *trackFormat = OH_AVSource_GetTrackFormat(source, i);
        int32_t trackType = -1;
        
        OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_TRACK_TYPE, &trackType);
        if (trackType == OH_MediaType::MEDIA_TYPE_VID) {
            int32_t isVivid = 0;
            int32_t profile = 0;
            int32_t transfunc = 0;
            OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_VIDEO_IS_HDR_VIVID, &isVivid);
            OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "PlayerNative", " PlayerNative::Play is vivid %{public}d", isVivid);
            if (isVivid) {
                msg = "HDRVivid";
            } else {
                OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_PROFILE, &profile);
                OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "PlayerNative", " PlayerNative::Play profile %{public}d", profile);
                if (profile == HEVC_PROFILE_MAIN_10) {
                    msg = "HDR";
                } else {
                    msg = "SDR";
                }
            }
            OH_AVFormat_GetIntValue(trackFormat, OH_MD_KEY_TRANSFER_CHARACTERISTICS, &transfunc);
            switch(transfunc) {
                case TRANSFER_CHARACTERISTIC_PQ:
                msg += " PQ";
                break;
                case TRANSFER_CHARACTERISTIC_HLG:
                msg += " HLG";
                break;
                default:
                OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "PlayerNative", "transfunc %{public}d", transfunc);
                msg += " UNKNOWN";
            }
        }
        OH_AVFormat_Destroy(trackFormat);
    }

    OH_AVFormat_Destroy(sourceFormat);
    OH_AVDemuxer_Destroy(demuxer);
    OH_AVSource_Destroy(source);
    napi_value retVal;
    napi_create_string_utf8(env, msg.c_str(), msg.size(), &retVal);
    return retVal;
}

napi_value Pause(napi_env env, napi_callback_info info) 
{
    OH_VideoProcessing* processor = nullptr;
    while(true) {
        OH_VideoProcessing_InitializeEnvironment();
        VideoProcessing_ErrorCode ret = OH_VideoProcessing_Create(&processor, VIDEO_PROCESSING_TYPE_COLOR_SPACE_CONVERSION);
        ret = OH_VideoProcessing_Destroy(processor);
        OH_VideoProcessing_DeinitializeEnvironment();
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "PlayerNative", "create destroy");
        sleep(1);
    }
    
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor classProp[] = {
        {"playNative", nullptr, StartPlay, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"preload", nullptr, Preload, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"pause", nullptr, Pause, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    NativeXComponentSample::PluginManager::GetInstance()->Export(env, exports);
    napi_define_properties(env, exports, sizeof(classProp) / sizeof(classProp[0]), classProp);
    return exports;
}
EXTERN_C_END

static napi_module PlayerModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "player",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterPlayerModule(void) { napi_module_register(&PlayerModule); }