/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License")
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

#include <hilog/log.h>
#include "manager.h"

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Init", "Init begins");
    if ((env == nullptr) || (exports == nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Init", "env or exports is null");
        return nullptr;
    }
    
    napi_property_descriptor desc[] = {
        {"createNativeNaviNode", nullptr, Manager::CreateNativeNaviNode, nullptr, nullptr, nullptr, napi_default,
         nullptr},
        {"createNativeRootAnimation1", nullptr, createNativeRootAnimation1,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootAnimation2", nullptr, createNativeRootAnimation2,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootAnimation3", nullptr, createNativeRootAnimation3,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootAnimation4", nullptr, createNativeRootAnimation4,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootAnimation5", nullptr, createNativeRootAnimation5,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootVisualEffects1", nullptr, createNativeRootVisualEffects1,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootVisualEffects2", nullptr, createNativeRootVisualEffects2,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootVisualEffects3", nullptr, createNativeRootVisualEffects3,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootVisualEffects4", nullptr, createNativeRootVisualEffects4,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootVisualEffects5", nullptr, createNativeRootVisualEffects5,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootVisualEffects6", nullptr, createNativeRootVisualEffects6,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootVisualEffects7", nullptr, createNativeRootVisualEffects7,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootVisualEffects8", nullptr, createNativeRootVisualEffects8,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootVisualEffects9", nullptr, createNativeRootVisualEffects9,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createNativeRootVisualEffects10", nullptr, createNativeRootVisualEffects10,
            nullptr, nullptr, nullptr, napi_default, nullptr},
        {"destroyNativeRoot", nullptr, DestroyNativeRoot, nullptr, nullptr, nullptr, napi_default, nullptr},
        { "processDrawable", nullptr, Manager::ProcessDrawable, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "processDrawable2", nullptr, Manager::ProcessDrawable2, nullptr, nullptr, nullptr, napi_default, nullptr },
    };
    
    if (napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc) != napi_ok) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "Init", "napi_define_properties failed");
        return nullptr;
    }
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

extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&demoModule); }
