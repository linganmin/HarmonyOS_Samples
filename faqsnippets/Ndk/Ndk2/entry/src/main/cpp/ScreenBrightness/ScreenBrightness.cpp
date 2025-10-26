// DocsCode 1
#include "ScreenBrightness.h"
#include "napi/native_api.h"
#include "hilog/log.h"
#include <string>

#define LOG_TAG "Pure"

napi_value ScreenBrightness::Success(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_value obj = args[0];
    napi_value key;
    napi_value rv;
    std::string x = "value";
    napi_create_string_utf8(env, x.c_str(), 5, &key);
    napi_get_property(env, obj, key, &rv);

    uint32_t result;
    napi_get_value_uint32(env, rv, &result);
    OH_LOG_INFO(LOG_APP, "napi get brightness %{public}d", result);
    return nullptr;
}
napi_value ScreenBrightness::Fail(napi_env env, napi_callback_info info) { return nullptr; }

napi_value ScreenBrightness::Complete(napi_env env, napi_callback_info info) { return nullptr; }

napi_value ScreenBrightness::NapiLoadModule(napi_env env, napi_callback_info info) {
    napi_value result;

    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_status get = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    char path[64] = {0};
    size_t typeLen = 0;
    napi_get_value_string_utf8(env, args[0], path, sizeof(path), &typeLen);

    napi_status status = napi_load_module(env, path, &result);
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "napi_load_module failed");
        return nullptr;
    }

    napi_value outputObject;
    napi_get_named_property(env, result, "getValue", &outputObject);

    napi_value arg;
    napi_create_object(env, &arg);
    napi_property_descriptor desc[] = {
        {"success", nullptr, Success, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"fail", nullptr, Fail, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"complete", nullptr, Complete, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_define_properties(env, arg, sizeof(desc) / sizeof(desc[0]), desc);

    napi_call_function(env, result, outputObject, 1, &arg, nullptr);

    return result;
}
// DocsCode 1