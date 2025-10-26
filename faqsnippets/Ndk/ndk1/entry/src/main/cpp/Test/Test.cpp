//
// Created on 2024/3/7.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
/**
 * FAQ: 在Native侧如何处理ArkTS侧传入的字符串被截断的异常场景
 */
#include "Test.h"
#include "hilog/log.h"
#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200 
#define LOG_TAG "MY_TAG"
// [Start test_func]
napi_value Test::TestFunc(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    size_t len = 0;
    napi_get_value_string_utf8(env, args[0], nullptr, 0, &len);   // Get string length to len
    char *buf = new char[len + 1];                                // Allocate a char array of appropriate size
    napi_get_value_string_utf8(env, args[0], buf, len + 1, &len); // get string
    OH_LOG_ERROR(LOG_APP, "result is:  b:%{public}s.", buf);
    return nullptr;
}
// [End test_func]