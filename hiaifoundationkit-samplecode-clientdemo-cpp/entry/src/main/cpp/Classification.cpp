/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "napi/native_api.h"
#include <hilog/log.h>
#include <rawfile/raw_file_manager.h>
#include "HIAIModelManager.h"
#include <sstream>
#include <iomanip>

using namespace std;

static napi_value LoadModel(napi_env env, napi_callback_info info) {
    napi_value errorCode;
    napi_create_int32(env, 1, &errorCode);
    napi_value successCode;
    napi_create_int32(env, 0, &successCode);
    size_t argc = 2;
    napi_value argv[2] = {nullptr, nullptr};
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    
    // Obtain model file resources and create a model buffer.
    NativeResourceManager *resourceMgr = OH_ResourceManager_InitNativeResourceManager(env, argv[0]);
    if (resourceMgr == nullptr) {
        OH_LOG_ERROR(LOG_APP, "OH_ResourceManager_InitNativeResourceManager failed");
        return errorCode;
    }

    const char* modelPath = "hiai.om";
    RawFile *rawFile = OH_ResourceManager_OpenRawFile(resourceMgr, modelPath);
    if (rawFile == nullptr) {
        OH_LOG_ERROR(LOG_APP, "OH_ResourceManager_OpenRawFile failed");
        return errorCode;
    }
    long modelSize = OH_ResourceManager_GetRawFileSize(rawFile);
    std::unique_ptr<uint8_t[]> modelData = std::make_unique<uint8_t[]>(modelSize);
    int res = OH_ResourceManager_ReadRawFile(rawFile, modelData.get(), modelSize);
    if (res == 0) {
        OH_LOG_ERROR(LOG_APP, "OH_ResourceManager_ReadRawFile failed");
        return errorCode;
    }

    OH_NN_ReturnCode ret = HIAIModelManager::GetInstance().LoadModelFromBuffer(modelData.get(), modelSize);
    if (ret != OH_NN_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "LoadModelFromBuffer failed");
        return errorCode;
    }
    OH_LOG_INFO(LOG_APP, "LoadModelFromBuffer success");
    return successCode;
}

static napi_value InitLabels(napi_env env, napi_callback_info info) {
    napi_value errorCode;
    napi_create_int32(env, 1, &errorCode);
    napi_value successCode;
    napi_create_int32(env, 0, &successCode);
    size_t argc = 2;
    napi_value argv[2] = {nullptr, nullptr};
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    
    // Obtain model file resources and create a model buffer.
    NativeResourceManager *resourceMgr = OH_ResourceManager_InitNativeResourceManager(env, argv[0]);
    if (resourceMgr == nullptr) {
        OH_LOG_ERROR(LOG_APP, "OH_ResourceManager_InitNativeResourceManager failed");
        return errorCode;
    }

    const char* labelFilePath = "labels_caffe.txt";
    RawFile *rawFile = OH_ResourceManager_OpenRawFile(resourceMgr, labelFilePath);
    if (rawFile == nullptr) {
        OH_LOG_ERROR(LOG_APP, "OH_ResourceManager_OpenRawFile failed");
        return errorCode;
    }
    long labelLength = OH_ResourceManager_GetRawFileSize(rawFile);
    std::unique_ptr<char[]> labelData = std::make_unique<char[]>(labelLength);
    int res = OH_ResourceManager_ReadRawFile(rawFile, labelData.get(), labelLength);
    if (res == 0) {
        OH_LOG_ERROR(LOG_APP, "OH_ResourceManager_ReadRawFile failed");
        return errorCode;
    }

    OH_NN_ReturnCode ret = HIAIModelManager::GetInstance().InitLabels(labelData.get(), labelLength);
    if (ret != OH_NN_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "InitLabels failed");
        return errorCode;
    }
    OH_LOG_INFO(LOG_APP, "InitLabels success");
    return successCode;
}

static napi_value InitIOTensors(napi_env env, napi_callback_info info) {
    napi_value errorCode;
    napi_create_int32(env, 1, &errorCode);
    napi_value successCode;
    napi_create_int32(env, 0, &successCode);
    napi_status status;
    size_t argc = 1;
    napi_value argv[1];
    status = napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    if (status != napi_ok) {
        napi_throw_error(env, nullptr, "Failed to parse arguments");
        return errorCode;
    }

    napi_typedarray_type type;
    size_t length = 0;
    void *data = nullptr;
    napi_value arraybuffer;
    size_t byte_offset;
    status = napi_get_typedarray_info(env, argv[0], &type, &length, &data, &arraybuffer, &byte_offset);
    if (status != napi_ok) {
        napi_throw_error(env, nullptr, "Failed to get typedarray info");
        return errorCode;
    }
    if (type != napi_uint8_array) {
        napi_throw_error(env, nullptr, "Invalid typedarray type");
        return errorCode;
    }

    uint8_t *bgrData = static_cast<uint8_t*>(data);
    float *floatData = new float[length];
    for (size_t i = 0; i < length; ++i) {
        floatData[i] = static_cast<float>(bgrData[i]);
    }
    std::vector<std::pair<float *, size_t>> inputData{ {floatData, length} };
    OH_NN_ReturnCode ret = HIAIModelManager::GetInstance().InitIOTensors(inputData);
    delete[] floatData;

    if (ret != OH_NN_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "InitIOTensors failed");
        return errorCode;
    }
    OH_LOG_INFO(LOG_APP, "InitIOTensors success");
    return successCode;
}

static napi_value RunModel(napi_env env, napi_callback_info info) {
    napi_value errorCode;
    napi_create_int32(env, 1, &errorCode);
    napi_value successCode;
    napi_create_int32(env, 0, &successCode);
    
    OH_NN_ReturnCode ret = HIAIModelManager::GetInstance().RunModel();
    if (ret != OH_NN_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "RunModel failed");
        return errorCode;
    }
    
    OH_LOG_INFO(LOG_APP, "RunModel success");
    return successCode;
}

namespace {
std::vector<std::pair<std::string, float>> GetTopThreeResult(std::vector<float> output) {
    std::vector<std::pair<std::string, float>> topThree;
    size_t topCount = 3;    // Obtain the maximum three values.
    if (output.size() < topCount) {
        OH_LOG_ERROR(LOG_APP, "size of output < 3");
        return topThree;
    }

    std::vector<std::string> labels = HIAIModelManager::GetInstance().GetLabels();
    for (size_t n = 0; n < topCount; ++n) {
        size_t index = 0;
        float maxResult = output[index];
        for (size_t i = 0; i < output.size(); ++i) {
            if (maxResult < output[i]) {
                index = i;
                maxResult = output[index];
            }
        }
        topThree.push_back({labels[index], maxResult});
        output[index] = 0;
    }
    return topThree;
}
}

static napi_value GetResult(napi_env env, napi_callback_info info) {
    napi_value resList;
    napi_create_array_with_length(env, 3, &resList);
    
    std::vector<std::vector<float>> result = HIAIModelManager::GetInstance().GetResult();
    if (result.empty()) {
        OH_LOG_ERROR(LOG_APP, "GetResult failed");
        return resList;
    }
    std::vector<std::pair<std::string, float>> topThree = GetTopThreeResult(result[0]);
    if (topThree.size() != 3) {
        OH_LOG_ERROR(LOG_APP, "GetTopThreeResult failed");
        return resList;
    }
    
    for (size_t i = 0; i < 3; ++i) {
        stringstream ss;
        ss << fixed << setprecision(2) << topThree[i].second * 100;
        string classifyRes = topThree[i].first + "  (" + ss.str() + "%)";

        napi_value res;
        napi_create_string_utf8(env, classifyRes.c_str(), classifyRes.size(), &res);
        napi_set_element(env, resList, i, res);
    }
    
    OH_LOG_INFO(LOG_APP, "GetResult success.");
    return resList;
}

static napi_value UnloadModel(napi_env env, napi_callback_info info) {
    napi_value errorCode;
    napi_create_int32(env, 1, &errorCode);
    napi_value successCode;
    napi_create_int32(env, 0, &successCode);

    OH_NN_ReturnCode ret = HIAIModelManager::GetInstance().UnloadModel();
    if (ret != OH_NN_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "UnloadModel failed");
        return errorCode;
    }
    OH_LOG_INFO(LOG_APP, "UnloadModel success.");
    return successCode;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"LoadModel", nullptr, LoadModel, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"InitLabels", nullptr, InitLabels, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"InitIOTensors", nullptr, InitIOTensors, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"RunModel", nullptr, RunModel, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"GetResult", nullptr, GetResult, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"UnloadModel", nullptr, UnloadModel, nullptr, nullptr, nullptr, napi_default, nullptr}
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version =1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterHiaiModule(void)
{
    napi_module_register(&demoModule);
}
