/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

#include <algorithm>
#include <string>
#include "napi/native_api.h"
#include "service_collaboration/service_collaboration_api.h"
#include "uv.h"

static napi_env g_napiEnv = nullptr;
static napi_ref g_onDataCallback = nullptr;
static napi_ref g_onEventCallback = nullptr;
static constexpr int32_t PARAM_ONE = 1;
static constexpr int32_t PARAM_TWO = 2;
static constexpr int32_t PARAM_THIRD = 3;


struct AsyncData {
    uint32_t code;
    uint32_t dataSize;
    std::string data;

    AsyncData(uint32_t size, const char *originalData, uint32_t eventCode) :
        dataSize(size), code(eventCode), data(originalData, size)
    {}
    ~AsyncData() {}
};

struct AsyncEventData {
    ServiceCollaborationEventCode code;
    explicit AsyncEventData(ServiceCollaborationEventCode c) : code(c) {}
};

static ServiceCollaborationCallback g_serviceCollaborationCallback = {.OnEvent = nullptr, .OnDataCallback = nullptr};

static int32_t OnEventProcess(ServiceCollaborationEventCode code, uint32_t extraCode)
{
    uv_loop_s *loop;
    napi_get_uv_event_loop(g_napiEnv, &loop);

    uv_work_t *req = new uv_work_t;
    AsyncEventData *asyncData = new AsyncEventData{code};
    req->data = asyncData;

    uv_queue_work(
        loop, req, [](uv_work_t *) {},
        [](uv_work_t *req, int status) {
            AsyncEventData *asyncData = static_cast<AsyncEventData *>(req->data);

            napi_value callbackFunc = nullptr;
            napi_get_reference_value(g_napiEnv, g_onEventCallback, &callbackFunc);

            napi_value result = nullptr;
            napi_create_object(g_napiEnv, &result);

            napi_value eventCode;
            napi_create_uint32(g_napiEnv, asyncData->code, &eventCode);
            napi_set_named_property(g_napiEnv, result, "code", eventCode);

            napi_value ret;
            napi_call_function(g_napiEnv, nullptr, callbackFunc, 1, &result, &ret);
            delete asyncData;
            delete req;
        });

    return 0;
}

static void AfterCallback(uv_work_t *req, int statusState)
{
    AsyncData *asyncData = static_cast<AsyncData *>(req->data);

    napi_value callbackFunc = nullptr;
    napi_get_reference_value(g_napiEnv, g_onDataCallback, &callbackFunc);

    napi_value dataLength;
    napi_create_uint32(g_napiEnv, asyncData->dataSize, &dataLength);

    napi_value result = nullptr;
    napi_create_object(g_napiEnv, &result);

    napi_value buffer = nullptr;
    napi_create_external_arraybuffer(
        g_napiEnv, static_cast<void*>(const_cast<char*>(asyncData->data.c_str())),
        asyncData->dataSize, [](napi_env, void *data, void *) {}, nullptr, &buffer);

    napi_value eventCode;
    napi_create_uint32(g_napiEnv, asyncData->code, &eventCode);

    napi_set_named_property(g_napiEnv, result, "size", dataLength);
    napi_set_named_property(g_napiEnv, result, "data", buffer);
    napi_set_named_property(g_napiEnv, result, "code", eventCode);
    napi_value ret;
    napi_call_function(g_napiEnv, nullptr, callbackFunc, 1, &result, &ret);
}

static int32_t OnDataCallbackProcess(ServiceCollaborationEventCode code, ServiceCollaborationDataType dataType,
                                     uint32_t dataSize, char *data)
{
    uv_loop_s *loop;
    napi_get_uv_event_loop(g_napiEnv, &loop);
    uv_work_t *req = new uv_work_t;
    AsyncData *asyncData = new AsyncData{dataSize, data, code};
    req->data = asyncData;
    uv_queue_work(
        loop, req, [](uv_work_t *req) {}, AfterCallback);
    return 0;
}

static std::string GetFilterTypeName(ServiceCollaborationFilterType type)
{
    std::string filterTypeName = "";
    switch (type) {
        case TAKE_PHOTO: {
            filterTypeName = "TAKE_PHOTO";
            break;
        }
        case SCAN_DOCUMENT: {
            filterTypeName = "SCAN_DOCUMENT";
            break;
        }
        case IMAGE_PICKER: {
            filterTypeName = "IMAGE_PICKER";
            break;
        }
        default: {
            filterTypeName = "UNKNOWN";
            break;
        }
    }
    return filterTypeName;
}

static napi_value Demo_HMS_ServiceCollaboration_GetCollaborationDeviceInfos(napi_env env, napi_callback_info info)
{
    uint32_t filterNum = 3;
    ServiceCollaborationFilterType serviceFilterTypes[3] = {TAKE_PHOTO, SCAN_DOCUMENT, IMAGE_PICKER};
    ServiceCollaboration_CollaborationDeviceInfoSets *sets =
        HMS_ServiceCollaboration_GetCollaborationDeviceInfos(filterNum, serviceFilterTypes);

    napi_value jsDeviceInfoArray;
    napi_create_array_with_length(env, sets->size, &jsDeviceInfoArray);

    for (uint32_t i = 0; i < sets->size; i++) {
        napi_value jsDeviceInfo;
        napi_create_object(env, &jsDeviceInfo);
        ServiceCollaboration_CollaborationDeviceInfo deviceInfo = sets->deviceInfoSets[i];

        napi_value jsName;
        napi_create_string_utf8(env, deviceInfo.deviceName, NAPI_AUTO_LENGTH, &jsName);
        napi_set_named_property(env, jsDeviceInfo, "deviceName", jsName);

        napi_value jsNetworkId;
        napi_create_string_utf8(env, deviceInfo.deviceNetworkId, NAPI_AUTO_LENGTH, &jsNetworkId);
        napi_set_named_property(env, jsDeviceInfo, "deviceNetworkId", jsNetworkId);

        napi_value jsType;
        napi_create_int32(env, deviceInfo.deviceType, &jsType);
        napi_set_named_property(env, jsDeviceInfo, "deviceType", jsType);

        napi_value jsFilterNum;
        napi_create_int32(env, deviceInfo.filterNum, &jsFilterNum);
        napi_set_named_property(env, jsDeviceInfo, "filterNum", jsFilterNum);

        napi_value jsFiltersArray;
        napi_create_array_with_length(env, deviceInfo.filterNum, &jsFiltersArray);

        for (uint32_t j = 0; j < deviceInfo.filterNum; j++) {
            napi_value jsFilterValue;
            napi_create_int32(env, deviceInfo.serviceFilterTypes[j], &jsFilterValue);
            std::string filterTypeName = GetFilterTypeName(deviceInfo.serviceFilterTypes[j]);
            napi_value jsFilterTypeName;
            napi_create_string_utf8(env, filterTypeName.c_str(), NAPI_AUTO_LENGTH, &jsFilterTypeName);
            napi_set_element(env, jsFiltersArray, j, jsFilterTypeName);
        }
        napi_set_named_property(env, jsDeviceInfo, "serviceCollaborationFilterType", jsFiltersArray);
        napi_set_element(env, jsDeviceInfoArray, i, jsDeviceInfo);
    }
    return jsDeviceInfoArray;
}

static napi_value Demo_HMS_ServiceCollaboration_StartCollaboration(napi_env env, napi_callback_info info)
{
    size_t argc = 4;
    napi_value args[4] = {nullptr, nullptr, nullptr, nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    ServiceCollaboration_SelectInfo taskInfo = {TAKE_PHOTO, {}};
    uint32_t tempValue;
    napi_get_value_uint32(env, args[0], &tempValue);
    taskInfo.serviceFilterType = static_cast<ServiceCollaborationFilterType>(tempValue);

    size_t writtenBytes = 0;
    napi_get_value_string_utf8(env, args[PARAM_ONE], taskInfo.deviceNetworkId,
                               sizeof(taskInfo.deviceNetworkId), &writtenBytes);
    napi_create_reference(env, args[PARAM_TWO], 1, &g_onDataCallback);
    napi_create_reference(env, args[PARAM_THIRD], 1, &g_onEventCallback);

    uint32_t id = HMS_ServiceCollaboration_StartCollaboration(&taskInfo, &g_serviceCollaborationCallback);

    napi_value napi_id;
    napi_create_double(env, id, &napi_id);
    return napi_id;
}

static napi_value Demo_HMS_ServiceCollaboration_StopCollaboration(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    uint32_t id;
    napi_get_value_uint32(env, args[0], &id);
    uint32_t code = HMS_ServiceCollaboration_StopCollaboration(id);
    napi_value code_napi_value;
    napi_create_uint32(env, code, &code_napi_value);
    return code_napi_value;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"Demo_HMS_ServiceCollaboration_GetCollaborationDeviceInfos", nullptr,
         Demo_HMS_ServiceCollaboration_GetCollaborationDeviceInfos, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"Demo_HMS_ServiceCollaboration_StartCollaboration", nullptr, Demo_HMS_ServiceCollaboration_StartCollaboration,
         nullptr, nullptr, nullptr, napi_default, nullptr},
        {"Demo_HMS_ServiceCollaboration_StopCollaboration", nullptr, Demo_HMS_ServiceCollaboration_StopCollaboration,
         nullptr, nullptr, nullptr, napi_default, nullptr}};
    g_napiEnv = env;
    g_serviceCollaborationCallback.OnEvent = &OnEventProcess;
    g_serviceCollaborationCallback.OnDataCallback = &OnDataCallbackProcess;
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
