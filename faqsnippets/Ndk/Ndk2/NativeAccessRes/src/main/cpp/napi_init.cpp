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

/**
 * FAQ: 如何在Native侧访问应用包内Rawfile资源
 */

// [Start native_access_cpp]
#include <memory>
#include "string"
#include "napi/native_api.h"
#include <rawfile/raw_file.h>
#include <rawfile/raw_file_manager.h>
#include "hilog/log.h"

const int GLOBAL_RESMGR = 0xFF00;
const char *TAG = "[Sample_rawfile]";

namespace {
    napi_value CreateJsArrayValue(napi_env env, std::unique_ptr<uint8_t[]> &data, long length)
    {
        napi_value buffer;
        napi_status status = napi_create_external_arraybuffer(
            env, data.get(), length,
            [](napi_env env, void *data, void *hint) {
                delete[] static_cast<char *>(data);
            },
            nullptr, &buffer);
        if (status != napi_ok) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "Failed to create external array buffer");
            return nullptr;
        }
        napi_value result = nullptr;
        status = napi_create_typedarray(env, napi_uint8_array, length, buffer, 0, &result);
        if (status != napi_ok) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "Failed to create media typed array");
            return nullptr;
        }
        data.release();
        return result;
    }
}


static napi_value GetRawFileContent(napi_env env, napi_callback_info info)
{
    OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "GetFileContent Begin");
    size_t requireArgc = 3;
    size_t argc = 2;
    napi_value argv[2] = { nullptr };
    // Obtain parameter information
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);

    // Argv [0] is the first parameter of the function, Js resource object, and OH_ ResourceManagerial is converted to a Native object.
    NativeResourceManager *mNativeResMgr = OH_ResourceManager_InitNativeResourceManager(env, argv[0]);
    size_t strSize;
    char strBuf[256];
    napi_get_value_string_utf8(env, argv[1], strBuf, sizeof(strBuf), &strSize);
    std::string filename(strBuf, strSize);

    // Get rawfile pointer object
    RawFile *rawFile = OH_ResourceManager_OpenRawFile(mNativeResMgr, filename.c_str());
    if (rawFile != nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, "OH_ResourceManager_OpenRawFile success");
    }
    // Get rawfile size and request memory
    long len = OH_ResourceManager_GetRawFileSize(rawFile);
    std::unique_ptr<uint8_t[]> data= std::make_unique<uint8_t[]>(len);

    // Read all contents of rawfile at once
    int res = OH_ResourceManager_ReadRawFile(rawFile, data.get(), len);

    // Close open pointer objects
    OH_ResourceManager_CloseRawFile(rawFile);
    OH_ResourceManager_ReleaseNativeResourceManager(mNativeResMgr);
    // Convert to JS object
    return CreateJsArrayValue(env, data, len);
}
// [End native_access_cpp]

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "getRawFileContent", nullptr, GetRawFileContent, nullptr, nullptr, nullptr, napi_default, nullptr }
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
    .nm_modname = "nativeaccessres",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterNativeAccessResModule(void)
{
    napi_module_register(&demoModule);
}
