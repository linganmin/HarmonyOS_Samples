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

#include "napi/native_api.h"
#include "bundle/native_interface_bundle.h"
#include <cstdlib>

static napi_value GetCurrentAppInfo(napi_env env, napi_callback_info info) {
    // Call the Native interface to obtain application information.
    OH_NativeBundle_ApplicationInfo nativeApplicationInfo = OH_NativeBundle_GetCurrentApplicationInfo();
    napi_value result = nullptr;
    napi_create_object(env, &result);
    // Convert the application info obtained through the Native interface into the attribute in the ArkTS object.
    napi_value bundleName;
    napi_create_string_utf8(env, nativeApplicationInfo.bundleName, NAPI_AUTO_LENGTH, &bundleName);
    napi_set_named_property(env, result, "bundleName", bundleName);
    napi_value fingerprint;
    napi_create_string_utf8(env, nativeApplicationInfo.fingerprint, NAPI_AUTO_LENGTH, &fingerprint);
    napi_set_named_property(env, result, "fingerprint", fingerprint);

    // Obtain the AppId.
    char *appId = OH_NativeBundle_GetAppId();
    napi_value napi_appId;
    napi_create_string_utf8(env, appId, NAPI_AUTO_LENGTH, &napi_appId);
    napi_set_named_property(env, result, "appId", napi_appId);

    // Get the AppIdentifier.
    char *appIdentifier = OH_NativeBundle_GetAppIdentifier();
    napi_value napi_appIdentifier;
    napi_create_string_utf8(env, appIdentifier, NAPI_AUTO_LENGTH, &napi_appIdentifier);
    napi_set_named_property(env, result, "appIdentifier", napi_appIdentifier);

    // For the purpose of preventing memory leaks, release manually.
    if (nativeApplicationInfo.bundleName && nativeApplicationInfo.fingerprint) {
        free(nativeApplicationInfo.bundleName);
        free(nativeApplicationInfo.fingerprint);
    }
    free(appId);
    free(appIdentifier);
    return result;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"getCurrentAppInfo", nullptr, GetCurrentAppInfo, nullptr, nullptr, nullptr, napi_default, nullptr}};
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
