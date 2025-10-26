/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
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

#include <cstring>

#include "napi/native_api.h"
#include "RemoteCommunicationKit/rcp.h"
#include "hilog/log.h"

const int BUFFER_SIZE = 128;

static uint32_t GetCharString(napi_env env, napi_value value, char *opName)
{
    size_t opLen;
    napi_status ret = napi_get_value_string_utf8(env, value, opName, BUFFER_SIZE, &opLen);
    if (ret != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "[GetCharString] nullptr");
        return 0;
    }
    return static_cast<int>(opLen);
}

static napi_value FetchInner(napi_env env, char *url, Rcp_Configuration *cfg, Rcp_TransferRange *range)
{
    napi_value res;
    uint32_t err;
    Rcp_Session *session = nullptr;
    Rcp_Request *request = nullptr;
    Rcp_Response *response = nullptr;
    char msg[BUFFER_SIZE];

    if ((session = HMS_Rcp_CreateSession(nullptr, &err)) == nullptr) {
        goto Exit;
    }
    if ((request = HMS_Rcp_CreateRequest(url)) == nullptr) {
        goto Exit;
    }
    request->configuration = cfg;
    request->transferRange = range;
    response = HMS_Rcp_FetchSync(session, request, &err);
    if (err) {
        sprintf(msg, "Fetch failed, code: %d", err);
        napi_create_string_utf8(env, msg, strlen(msg), &res);
        goto Exit;
    }
    if (response->statusCode == RCP_PARTIAL) {
        sprintf(msg, "Response status code: %d, response body length: %d", response->statusCode, response->body.length);
        napi_create_string_utf8(env, msg, strlen(msg), &res);
        goto Exit;
    }

    napi_create_string_utf8(env, response->body.buffer, response->body.length, &res);

Exit:
    if (response) {
        response->destroyResponse(response);
    }
    if (request) {
        HMS_Rcp_DestroyRequest(request);
    }
    if (session && HMS_Rcp_CloseSession(&session)) {
        printf("close session failed\n");
    }
    return res;
}

static napi_value Get(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    char url[BUFFER_SIZE];
    napi_value res;
    uint32_t err;

    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);
    if (argc != 1) {
        goto Exit;
    }
    if ((err = GetCharString(env, args[0], url)) == 0) {
        goto Exit;
    }
    res = FetchInner(env, url, nullptr, nullptr);

Exit:
    return res;
}

static napi_value GetWithTimeout(napi_env env, napi_callback_info info)
{
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    char url[BUFFER_SIZE];
    napi_value res;
    uint32_t err;
    Rcp_Configuration cfg{};
    
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);
    if (argc != 3) {
        goto Exit;
    }
    if ((err = GetCharString(env, args[0], url)) == 0) {
        goto Exit;
    }
    napi_get_value_uint32(env, args[1], &cfg.transferConfiguration.timeout.connectMs);
    napi_get_value_uint32(env, args[2], &cfg.transferConfiguration.timeout.transferMs);
    res = FetchInner(env, url, &cfg, nullptr);

Exit:
    return res;
}

static napi_value GetWithTransferRange(napi_env env, napi_callback_info info)
{
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    char url[BUFFER_SIZE];
    napi_value res;
    uint32_t err;
    Rcp_TransferRange range = {};
    
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);
    if (argc != 3) {
        goto Exit;
    }
    if ((err = GetCharString(env, args[0], url)) == 0) {
        goto Exit;
    }
    napi_get_value_int64(env, args[1], &range.from);
    napi_get_value_int64(env, args[2], &range.to);
    res = FetchInner(env, url, nullptr, &range);

Exit:
    return res;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "Get", nullptr, Get, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "GetWithTimeout", nullptr, GetWithTimeout, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "GetWithTransferRange", nullptr, GetWithTransferRange, nullptr, nullptr, nullptr, napi_default, nullptr }
    };
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
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
