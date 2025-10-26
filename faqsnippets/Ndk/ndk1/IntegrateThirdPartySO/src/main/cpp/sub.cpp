//
// Created on 2025/5/23.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
/**
 * FAQ: 在Native侧如何集成三方SO库
 */

// [Start integrate_sub]
#include "sub.h"

static napi_value Sub(napi_env env, napi_callback_info info)
{
    size_t requireArgc = 2;
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);
    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);
    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);
    double value0;
    napi_get_value_double(env, args[0], &value0);
    double value1;
    napi_get_value_double(env, args[1], &value1);
    napi_value sum;
    napi_create_double(env, sub(value0, value1), &sum);
    return sum;
}
// [End integrate_sub]