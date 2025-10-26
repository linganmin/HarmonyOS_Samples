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
#include <js_native_api.h>
#include "manager/plugin_manager.h"
#include <js_native_api_types.h>

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    NativeXComponentSample::PluginManager::GetInstance()->RenderConfig(env, exports);
    napi_property_descriptor desc[] = {
        { "StartCamera", nullptr, NativeXComponentSample::PluginRender::StartCamera, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "StopCamera", nullptr, NativeXComponentSample::PluginRender::StopCamera, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "StartRecorder", nullptr, NativeXComponentSample::PluginRender::StartRecorder, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "StopRecorder", nullptr, NativeXComponentSample::PluginRender::StopRecorder, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "startTransform", nullptr, NativeXComponentSample::PluginRender::StartTransform, nullptr, nullptr, nullptr, napi_default, nullptr }
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
    .nm_modname = "nativerender",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
