//
// Created on 2025/5/29.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
/**
 * FAQ:如何在Native侧释放ArkTS对象
 */
#include "napi/native_api.h"

void Test(napi_env env, napi_callback_info info) {
    napi_value jsobject;
    void* nativeObject;
    napi_finalize cb;
    // [Start napi_wrap]
    // Usage 1: Napi_wrap does not need to receive the created napi_ref, and the last parameter is passed as nullptr. The created napi_ref is a weak reference, managed by the system, and does not require manual release by the user
    napi_wrap(env, jsobject, nativeObject, cb, nullptr, nullptr);

    // Usage 2: napi_wrap needs to receive the created napi_ref, the last parameter is not null ptr, and the returned napi_ref is a strong reference that needs to be manually released by the user, otherwise it will cause memory leakage
    napi_ref result;
    napi_wrap(env, jsobject, nativeObject, cb, nullptr, &result);
    // When jsobject and result are no longer used in the future, promptly call napi_remove_wrap to release result
    void** result1;
    napi_remove_wrap(env, jsobject, result1);
    // [End napi_wrap]
}