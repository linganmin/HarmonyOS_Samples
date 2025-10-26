/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:如何在Native侧集成三方库Curl，并进行HTTP数据请求
*/

// [Start curl_request_cpp]
#include "curl/curl.h"

// [StartExclude curl_request_cpp]
#include "napi/native_api.h"
#include "hilog/log.h"
#include <string>
using namespace std;
// [EndExclude curl_request_cpp]

// Get request and post request data response functions
size_t ReqReply(void *ptr, size_t size, size_t nmemb, void *userdata) {
    string *str = reinterpret_cast<string *>(userdata);
    (*str).append((char *)ptr, size * nmemb);
    return size * nmemb;
}

// http GET Request configuration
CURLcode CurlGetReq(const std::string &url, std::string &response) {
    // Curl initialization
    CURL *curl = curl_easy_init();
    // Curl return value
    CURLcode res;
    if (curl) {
        // Set the request header for Curl
        struct curl_slist *headers = NULL;
        headers = curl_slist_append(headers, "Content-Type:application/json");
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);

        // Set the URL address for the request
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());

        // Receive response header data, 0 represents not receiving, 1 represents receiving
        curl_easy_setopt(curl, CURLOPT_HEADER, 1);

        // Set data receiving function
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, ReqReply);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&response);

        // Set to not use any signal/alarm handlers
        curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1);

        // Set timeout period
        curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10);

        // Open request
        res = curl_easy_perform(curl);
    }
    // Release curl
    curl_easy_cleanup(curl);
    return res;
}


static napi_value NatReq(napi_env env, napi_callback_info info) {
    string getUrlStr = "http://app.huawei.com";
    string getResponseStr;
    auto res = CurlGetReq(getUrlStr, getResponseStr);
    if (res == CURLE_OK) {
        OH_LOG_Print(LOG_APP, LOG_INFO, 0xFF00, "pure", "response: \n%{public}s", getResponseStr.c_str());
    }

    // [StartExclude curl_request_cpp]
    size_t requireArgc = 2;
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

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
    // [EndExclude curl_request_cpp]
}
// [End curl_request_cpp]

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {{"add", nullptr, NatReq, nullptr, nullptr, nullptr, napi_default, nullptr}};
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
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&demoModule); }
