#include "CustomObject.h"
napi_value CustomObject::Test(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    napi_value obj = args[0];

    napi_value testNum;
    napi_value testString;

    napi_create_int32(env, 3, &testNum);
    napi_set_named_property(env, obj, "testNum", testNum);

    napi_create_string_utf8(env, "hello world", NAPI_AUTO_LENGTH, &testString);
    napi_set_named_property(env, obj, "testString", testString);

    return obj;
}

napi_value CustomObject::Test1(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    napi_value obj = args[0];

    napi_value testNum;
    napi_value testString;

    napi_create_int32(env, 3, &testNum);
    napi_set_named_property(env, obj, "testNum", testNum);

    napi_create_string_utf8(env, "hello world", NAPI_AUTO_LENGTH, &testString);
    napi_set_named_property(env, obj, "testString", testString);

    return obj;
}