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
#include <uv.h>
#include "dfx/error/SampleError.h"

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0xFF00
#define LOG_TAG "player"

napi_value PlayerNative::CreatePlayer(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "enter CreatePlayer");
    napi_value result;
    auto player = new Player();
    int64_t addrValue = (int64_t)player;
    napi_create_bigint_int64(env, addrValue, &result);
    OH_LOG_INFO(LOG_APP, "end CreatePlayer, addrValue:%{public}ld", addrValue);
    return result;
}

napi_value PlayerNative::ReleasePlayer(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "enter ReleasePlayer");
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int64_t addrValue = 0;
    bool flag = false;
    napi_get_value_bigint_int64(env, args[0], &addrValue, &flag);
    Player *player = reinterpret_cast<Player *>(addrValue);
    if (player) {
        delete player;
        player = nullptr;
    }
    OH_LOG_INFO(LOG_APP, "end ReleasePlayer");
    return nullptr;
}

napi_value PlayerNative::StartPlay(napi_env env, napi_callback_info info) {
    SampleInfo sampleInfo;
    size_t argc = 5;
    napi_value args[5] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    int64_t addrValue = 0;
    bool flag = false;
    int32_t ret = SAMPLE_ERR_ERROR;
    napi_get_value_bigint_int64(env, args[0], &addrValue, &flag);
    Player *player = reinterpret_cast<Player *>(addrValue);
    napi_get_value_int32(env, args[1], &sampleInfo.fileInfo.inputFd);
    napi_get_value_int64(env, args[2], &sampleInfo.fileInfo.inputFileOffset);
    napi_get_value_int64(env, args[3], &sampleInfo.fileInfo.inputFileSize);
    if (player) {
        ret = player->Init(sampleInfo);
        if (ret == SAMPLE_ERR_OK) {
            player->Start();
        }
    }
    return nullptr;
}

napi_value PlayerNative::StopPlay(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int64_t addrValue = 0;
    bool flag = false;
    napi_get_value_bigint_int64(env, args[0], &addrValue, &flag);
    Player *player = reinterpret_cast<Player *>(addrValue);
    if (player) {
        player->WaitForStop();
    }
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor classProp[] = {
        {"createPlayer", nullptr, PlayerNative::CreatePlayer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"releasePlayer", nullptr, PlayerNative::ReleasePlayer, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"startPlay", nullptr, PlayerNative::StartPlay, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"stopPlay", nullptr, PlayerNative::StopPlay, nullptr, nullptr, nullptr, napi_default, nullptr},
    };

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