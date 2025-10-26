/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include <core.hpp>

namespace {
[[nodiscard]] napi_value Invoke(napi_env env, napi_value exports)
{
    // This method will be called on:
    //      any 'import' instruction of the ArkUI or ArkTS side.
    //      any 'XComponent' with 'libraryname' "entry"
    napi_value xComponentJS;
    napi_status const check = napi_get_named_property(env, exports, OH_NATIVE_XCOMPONENT_OBJ, &xComponentJS);
    if (!AdaptiveBufferResolution::Core::CheckNAPIResult(check, env, "Invoke", "Can't get JS side XComponent")) {
        return nullptr;
    }

    napi_value const cases[] = {nullptr, exports};
    OH_NativeXComponent *xComponent;

    AdaptiveBufferResolution::Core::GetInstance()->SetEnv(env);
    if (napi_unwrap(env, xComponentJS, reinterpret_cast<void **>(&xComponent)) == napi_ok) {
        // Request from UI.
        return cases[static_cast<size_t>(AdaptiveBufferResolution::Core::InitUI(xComponent))];
    }

    // Request from entry ability ArkTS script or from page ArkUI script.
    return cases[static_cast<size_t>(AdaptiveBufferResolution::Core::InitApp(env, exports))];
}

__attribute__((constructor)) void RegisterAdaptiveBufferResolutionCore() noexcept
{
    napi_module appModule{
        .nm_version = 1,
        .nm_flags = 0U,
        .nm_filename = nullptr,
        .nm_register_func = &Invoke,
        .nm_modname = "entry",
        .nm_priv = nullptr,
        .reserved = {}
    };

    napi_module_register(&appModule);
}
} // end of anonymous namespace
