/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */
#include "napi/native_api.h"
#include "hcts/include/fido2_test.h"
#include "OnlineAuthenticationKit/fido2_api.h"
#include <cstdio>
#include <string>
#include "log.h"


static bool GetParamsFromNapiValue(napi_env env, napi_callback_info info, std::string &reqParams)
{
    size_t argc = 1;
    napi_value argv[1] = { nullptr };
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);

    size_t length = 0;
    napi_valuetype reqParamsType;
    napi_typeof(env, argv[0], &reqParamsType);
    if (reqParamsType == napi_null) {
        LOGE("osAccountId or reqParams is null");
        return false;
    }
    if (reqParamsType != napi_string) {
        LOGE("osAccountId is not number or reqParams is not string");
        return false;
    }
    if (napi_get_value_string_utf8(env, argv[0], nullptr, 0, &length) != napi_ok) {
        LOGE("can not get length of reqParams");
        return false;
    }
    reqParams.reserve(length + 1);
    reqParams.resize(length);
    if (napi_get_value_string_utf8(env, argv[0], reqParams.data(), length + 1, &length) != napi_ok) {
        LOGE("can not get reqParams");
        return false;
    }
    return true;
}

static napi_value HCTS_ConnectService_Reg(napi_env env, napi_callback_info info)
{                                                
    napi_value retVal = nullptr;
    std::string requestParams;
    if (!GetParamsFromNapiValue(env, info,requestParams)) {
        LOGE("get params failed");
        return nullptr;
    }
    std::string out = OHOS::OnlineAuthenticationKit::HCTS_ConnectService_Reg(requestParams);
    napi_create_string_utf8(env, out.c_str(), NAPI_AUTO_LENGTH, &retVal);
//    napi_create_int32(env, ret, &retVal);                                                                          
    return retVal;                                                                                                 
}

static napi_value HCTS_ConnectService_Auth(napi_env env, napi_callback_info info)
{                                                
    napi_value retVal = nullptr;
    std::string requestParams;
    if (!GetParamsFromNapiValue(env, info,requestParams)) {
        LOGE("get params failed");
        return nullptr;
    }
    std::string out = OHOS::OnlineAuthenticationKit::HCTS_ConnectService_Auth(requestParams);
    napi_create_string_utf8(env, out.c_str(), NAPI_AUTO_LENGTH, &retVal);
    return retVal;
}

static napi_value Add(napi_env env, napi_callback_info info)
{
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
    napi_create_double(env, value0 + value1, &sum);

    return sum;

}

static napi_value napi_connect_service(napi_env env, napi_callback_info info)
{
    FIDO2_AuthenticatorMetadataArray *authenticators;
    FIDO2_ErrorCode ret = HMS_FIDO2_getPlatformAuthenticator(&authenticators);

    napi_value value;
    napi_create_double(env, ret, &value);

    return value;
}

static napi_value NAPI_Global_HCTS_ConnectService_getClientCapability(napi_env env, napi_callback_info info) {
    napi_value retVal = nullptr;
    std::int64_t ret = OHOS::OnlineAuthenticationKit::HCTS_ConnectService_getClientCapability();
    napi_create_int64(env, ret, &retVal);                                                                          
    return retVal;   
}

static napi_value NAPI_Global_HCTS_ConnectService_getPlatformAuthenticator(napi_env env, napi_callback_info info) {
    napi_value retVal = nullptr;
    std::int64_t ret = OHOS::OnlineAuthenticationKit::HCTS_ConnectService_getPlatformAuthenticator();
    napi_create_int64(env, ret, &retVal);                                                                          
    return retVal;   
}
EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"HCTS_ConnectService_Reg", nullptr, HCTS_ConnectService_Reg, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"HCTS_ConnectService_Auth", nullptr, HCTS_ConnectService_Auth, nullptr, nullptr, nullptr, napi_default,
         nullptr},
        {"add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"napi_connect_service", nullptr, napi_connect_service, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"HCTS_ConnectService_getClientCapability", nullptr, NAPI_Global_HCTS_ConnectService_getClientCapability,
         nullptr, nullptr, nullptr, napi_default, nullptr},
        {"HCTS_ConnectService_getPlatformAuthenticator", nullptr,
         NAPI_Global_HCTS_ConnectService_getPlatformAuthenticator, nullptr, nullptr, nullptr, napi_default, nullptr },
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
    .nm_modname = "entry",
    .nm_priv = nullptr,
    .reserved = {0},
};

// 加载so时，该函数会自动被调用，将上述demoModule模块注册到系统中。
extern "C" __attribute__((constructor)) void RegisterDemoModule() { 
    napi_module_register(&demoModule);
 }