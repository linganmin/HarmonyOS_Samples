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

#include <node_api.h>
#include "AppearDisappearTransitions.h"
#include "BuildingADialogBox.h"
#include "BuildingCustomComponents.h"
#include "CustomGestureJudgment.h"
#include "EmbeddingArkTSComponents.h"
#include "ArkUIMixedRefresh.h"
#include "IntegratingWithArkts.h"
#include "ListeningForComponentEvents.h"
#include "ListItemGroup.h"
#include "ListWithLazyLoading.h"
#include "SequentialRecognition.h"
#include "UsingPropertyAnimations.h"

EXTERN_C_START
// Registration of components related to the encapsulation list.
void RegisterListComponents(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"CreateTextListNativeRoot", nullptr, NativeModule::CreateTextListNativeRoot, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"DestroyTextListNativeRoot", nullptr, NativeModule::DestroyTextListNativeRoot, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"CreateMonitorEventListNativeRoot", nullptr, NativeModule::CreateMonitorEventListNativeRoot, nullptr, nullptr,
         nullptr, napi_default, nullptr},
        {"DestroyMonitorEventListNativeRoot", nullptr, NativeModule::DestroyMonitorEventListNativeRoot, nullptr,
         nullptr, nullptr, napi_default, nullptr},
        {"CreateLazyTextListNativeRoot", nullptr, NativeModule::CreateLazyTextListNativeRoot, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"DestroyLazyTextListNativeRoot", nullptr, NativeModule::DestroyLazyTextListNativeRoot, nullptr, nullptr,
         nullptr, napi_default, nullptr},
        {"CreateTextGroupListNativeRoot", nullptr, NativeModule::CreateTextGroupListNativeRoot, nullptr, nullptr,
         nullptr, napi_default, nullptr},
        {"DestroyTextGroupListNativeRoot", nullptr, NativeModule::DestroyTextGroupListNativeRoot, nullptr, nullptr,
         nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
}

// Encapsulate the registration of mixed refresh related components.
void RegisterCustomContainerComponents(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"CreateCustomContainerNativeRoot", nullptr, NativeModule::CreateCustomContainerNativeRoot, nullptr, nullptr,
         nullptr, napi_default, nullptr},
        {"DestroyCustomContainerNativeRoot", nullptr, NativeModule::DestroyCustomContainerNativeRoot, nullptr, nullptr,
         nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
}

// 封装混合刷新相关组件的注册
void RegisterMixedRefreshComponents(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"CreateMixedRefreshListNativeRoot", nullptr, NativeModule::CreateMixedRefreshListNativeRoot, nullptr, nullptr,
         nullptr, napi_default, nullptr},
        {"registerCreateMixedRefreshNode", nullptr, NativeModule::ArkUIMixedRefresh::RegisterCreateRefresh, nullptr,
         nullptr, nullptr, napi_default, nullptr},
        {"registerUpdateMixedRefreshNode", nullptr, NativeModule::ArkUIMixedRefresh::RegisterUpdateRefresh, nullptr,
         nullptr, nullptr, napi_default, nullptr},
        {"DestroyMixedRefreshListNativeRoot", nullptr, NativeModule::DestroyMixedRefreshListNativeRoot, nullptr,
         nullptr, nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
}

// Registration of components related to encapsulated pop ups.
void RegisterPopupComponents(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"CreatePopupNativeRoot", nullptr, NativeModule::CreatePopupNativeRoot, nullptr, nullptr, nullptr, napi_default,
         nullptr},
        {"DestroyPopupNativeRoot", nullptr, NativeModule::DestroyPopupNativeRoot, nullptr, nullptr, nullptr,
         napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
}

// Registration of encapsulated animation related components.
void RegisterAnimationComponents(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"CreateAnimationViewNativeRoot", nullptr, NativeModule::CreateAnimationViewNativeRoot, nullptr, nullptr,
         nullptr, napi_default, nullptr},
        {"DestroyAnimationViewNativeRoot", nullptr, NativeModule::DestroyAnimationViewNativeRoot, nullptr, nullptr,
         nullptr, napi_default, nullptr},
        {"CreateAttributeAnimationNativeRoot", nullptr, NativeModule::CreateAttributeAnimationNativeRoot, nullptr,
         nullptr, nullptr, napi_default, nullptr},
        {"DestroyAttributeAnimationNativeRoot", nullptr, NativeModule::DestroyAttributeAnimationNativeRoot, nullptr,
         nullptr, nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
}

// Registration of encapsulated gesture related components.
void RegisterGestureComponents(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"CreateGestureViewNativeRoot", nullptr, NativeModule::CreateGestureViewNativeRoot, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"DestroyGestureViewNativeRoot", nullptr, NativeModule::DestroyGestureViewNativeRoot, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"CreateCustomGestureViewNativeRoot", nullptr, NativeModule::CreateCustomGestureViewNativeRoot, nullptr,
         nullptr, nullptr, napi_default, nullptr},
        {"DestroyCustomGestureViewNativeRoot", nullptr, NativeModule::DestroyCustomGestureViewNativeRoot, nullptr,
         nullptr, nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
}

static napi_value Init(napi_env env, napi_value exports)
{
    // Bind the creation and destruction components on the native side.
    RegisterListComponents(env, exports);
    RegisterCustomContainerComponents(env, exports);
    RegisterMixedRefreshComponents(env, exports);
    RegisterPopupComponents(env, exports);
    RegisterAnimationComponents(env, exports);
    RegisterGestureComponents(env, exports);
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