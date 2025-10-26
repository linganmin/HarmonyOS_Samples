//
// Created on 2025/5/21.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
//FAQ:Native侧如何使用hilog打印出日志信息
#include <js_native_api_types.h>
// [Start napi_hilog1]
#include "hilog/log.h"
#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200 // Global domain macro, identifying the business domain
#define LOG_TAG "MY_TAG"  // Global tag macro, identifying module log tags
// [End napi_hilog1]

static napi_value NAPI_Global_SayHello(napi_env env, napi_callback_info info) {
    // [Start napi_hilog2]
    int a = 5, b = 10;
    OH_LOG_ERROR(LOG_APP, "Pure a:%{public}d b:%{private}d.", a, b);
    // [Start napi_hilog2]
}
