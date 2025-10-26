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
 * FAQ: Native侧如何获取ArkTS侧的应用包名
 */
// [Start c_get_app_package_name_cpp]
#include "CGetAppPackageName.h" 
#include "napi/native_api.h" 
#include <bundle/native_interface_bundle.h> 
#include <cstdlib> 
#include "hilog/log.h" 
#define LOG_TAG "Pure" 
 
napi_value CGetAppPackageName::GetCurrentApplicationPackageName(napi_env env, napi_callback_info info) 
{ 
    // Call the Native interface to obtain application information 
    OH_NativeBundle_ApplicationInfo nativeApplicationInfo = OH_NativeBundle_GetCurrentApplicationInfo(); 
    // Convert the application package name obtained by the Native interface to the bundleName property in the JS object 
    napi_value bundleName; 
    napi_create_string_utf8(env, nativeApplicationInfo.bundleName, NAPI_AUTO_LENGTH, &bundleName); 
    OH_LOG_INFO(LOG_APP, "napi get application package name： %{public}s", nativeApplicationInfo.bundleName); 
    // Finally, to prevent memory leaks, manually release
    free(nativeApplicationInfo.bundleName); 
    return nullptr; 
}
// [End c_get_app_package_name_cpp]