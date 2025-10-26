/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

#include <iostream>
#include <sstream>
#include <cstdlib>
#include <hilog/log.h>
#include <rawfile/raw_file_manager.h>
#include <mindspore/types.h>
#include <mindspore/model.h>
#include <mindspore/context.h>
#include <mindspore/status.h>
#include <mindspore/tensor.h>
#include "napi/native_api.h"

#define LOG_I(...) ((void)OH_LOG_Print(LOG_APP, LOG_INFO, LOG_DOMAIN, "[MSLiteNapi]", __VA_ARGS__))
#define LOG_D(...) ((void)OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_DOMAIN, "[MSLiteNapi]", __VA_ARGS__))
#define LOG_W(...) ((void)OH_LOG_Print(LOG_APP, LOG_WARN, LOG_DOMAIN, "[MSLiteNapi]", __VA_ARGS__))
#define LOG_E(...) ((void)OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_DOMAIN, "[MSLiteNapi]", __VA_ARGS__))

// read model
void *ReadModelFile(NativeResourceManager *nativeResourceManager, const std::string &modelName, size_t *modelSize)
{
    auto rawFile = OH_ResourceManager_OpenRawFile(nativeResourceManager, modelName.c_str());
    if (rawFile == nullptr) {
        LOG_E("MS_LITE_ERR: Open model file failed");
        return nullptr;
    }
    long fileSize = OH_ResourceManager_GetRawFileSize(rawFile);
    void *modelBuffer = malloc(fileSize);
    if (modelBuffer == nullptr) {
        LOG_E("MS_LITE_ERR: OH_ResourceManager_ReadRawFile failed");
    }
    int ret = OH_ResourceManager_ReadRawFile(rawFile, modelBuffer, fileSize);
    if (ret == 0) {
        LOG_I("MS_LITE_LOG: OH_ResourceManager_ReadRawFile failed");
        OH_ResourceManager_CloseRawFile(rawFile);
        return nullptr;
    }
    OH_ResourceManager_CloseRawFile(rawFile);
    *modelSize = fileSize;
    return modelBuffer;
}

void DestroyModelBuffer(void **buffer)
{
    if (buffer == nullptr) {
        return;
    }
    free(*buffer);
    *buffer = nullptr;
}

OH_AI_ContextHandle CreateMSLiteContext(void *modelBuffer)
{
    // Set executing context for model.
    auto context = OH_AI_ContextCreate();
    if (context == nullptr) {
        DestroyModelBuffer(&modelBuffer);
        LOG_E("MS_LITE_ERR: Create MSLite context failed.\n");
        return nullptr;
    }
    // This sample model does not support configuring OH_AI_DeviceInfoCreate(OH_AI_DEVICETYPE_NNRT).
    auto cpu_device_info = OH_AI_DeviceInfoCreate(OH_AI_DEVICETYPE_CPU);

    OH_AI_DeviceInfoSetEnableFP16(cpu_device_info, true);
    OH_AI_ContextAddDeviceInfo(context, cpu_device_info);
    
    LOG_I("MS_LITE_LOG: Build MSLite context success.\n");
    return context;
}

OH_AI_ModelHandle CreateMSLiteModel(void *modelBuffer, size_t modelSize, OH_AI_ContextHandle context)
{
    // Create model
    auto model = OH_AI_ModelCreate();
    if (model == nullptr) {
        DestroyModelBuffer(&modelBuffer);
        LOG_E("MS_LITE_ERR: Allocate MSLite Model failed.\n");
        return nullptr;
    }

    // Build model object
    auto build_ret = OH_AI_ModelBuild(model, modelBuffer, modelSize, OH_AI_MODELTYPE_MINDIR, context);
    DestroyModelBuffer(&modelBuffer);
    if (build_ret != OH_AI_STATUS_SUCCESS) {
        OH_AI_ModelDestroy(&model);
        LOG_E("MS_LITE_ERR: Build MSLite model failed.\n");
        return nullptr;
    }
    LOG_I("MS_LITE_LOG: Build MSLite model success.\n");
    return model;
}

constexpr int K_NUM_PRINT_OF_OUT_DATA = 20;

// Set model input data
int FillInputTensor(OH_AI_TensorHandle input, std::vector<float> input_data)
{
    if (OH_AI_TensorGetDataType(input) == OH_AI_DATATYPE_NUMBERTYPE_FLOAT32) {
        float *data = (float *)OH_AI_TensorGetMutableData(input);
        for (size_t i = 0; i < OH_AI_TensorGetElementNum(input); i++) {
            data[i] = input_data[i];
        }
        return OH_AI_STATUS_SUCCESS;
    } else {
        return OH_AI_STATUS_LITE_ERROR;
    }
}

// Execute model inference
int RunMSLiteModel(OH_AI_ModelHandle model, std::vector<float> input_data)
{
    // Set input data for model.
    auto inputs = OH_AI_ModelGetInputs(model);

    auto ret = FillInputTensor(inputs.handle_list[0], input_data);
    if (ret != OH_AI_STATUS_SUCCESS) {
        LOG_E("MS_LITE_ERR: RunMSLiteModel set input error.\n");
        return OH_AI_STATUS_LITE_ERROR;
    }
    // Get model output.
    auto outputs = OH_AI_ModelGetOutputs(model);
    // Predict model.
    auto predict_ret = OH_AI_ModelPredict(model, inputs, &outputs, nullptr, nullptr);
    if (predict_ret != OH_AI_STATUS_SUCCESS) {
        LOG_E("MS_LITE_ERR: MSLite Predict error.\n");
        return OH_AI_STATUS_LITE_ERROR;
    }
    LOG_I("MS_LITE_LOG: Run MSLite model Predict success.\n");
    // Print output tensor data.
    LOG_I("MS_LITE_LOG: Get model outputs:\n");
    for (size_t i = 0; i < outputs.handle_num; i++) {
        auto tensor = outputs.handle_list[i];
        LOG_I("MS_LITE_LOG: - Tensor %{public}d name is: %{public}s.\n", static_cast<int>(i),
             OH_AI_TensorGetName(tensor));
        LOG_I("MS_LITE_LOG: - Tensor %{public}d size is: %{public}d.\n", static_cast<int>(i),
             (int)OH_AI_TensorGetDataSize(tensor));
        LOG_I("MS_LITE_LOG: - Tensor data is:\n");
        auto out_data = reinterpret_cast<const float *>(OH_AI_TensorGetData(tensor));
        std::stringstream outStr;
        for (int i = 0; (i < OH_AI_TensorGetElementNum(tensor)) && (i <= K_NUM_PRINT_OF_OUT_DATA); i++) {
            outStr << out_data[i] << " ";
        }
        LOG_I("MS_LITE_LOG: %{public}s", outStr.str().c_str());
    }
    return OH_AI_STATUS_SUCCESS;
}

std::vector<float> ProcessInputData(napi_env env, napi_value argv)
{
    bool isArray = false;
    napi_is_array(env, argv, &isArray);
    uint32_t length = 0;
    napi_get_array_length(env, argv, &length);
    LOG_I("MS_LITE_LOG: argv array length = %{public}d", length);
    std::vector<float> input_data;
    double param = 0;
    for (int i = 0; i < length; i++) {
        napi_value value;
        napi_get_element(env, argv, i, &value);
        napi_get_value_double(env, value, &param);
        input_data.push_back(static_cast<float>(param));
    }
    std::stringstream outStr;
    for (int i = 0; i < K_NUM_PRINT_OF_OUT_DATA; i++) {
        outStr << input_data[i] << " ";
    }
    LOG_I("MS_LITE_LOG: input_data = %{public}s", outStr.str().c_str());
    return input_data;
}

napi_value ProcessOutputData(napi_env env, OH_AI_ModelHandle model)
{
    napi_value out_data;
    napi_create_array(env, &out_data);
    auto outputs = OH_AI_ModelGetOutputs(model);
    OH_AI_TensorHandle output_0 = outputs.handle_list[0];
    float *output0Data = reinterpret_cast<float *>(OH_AI_TensorGetMutableData(output_0));
    for (size_t i = 0; i < OH_AI_TensorGetElementNum(output_0); i++) {
        napi_value element;
        napi_create_double(env, static_cast<double>(output0Data[i]), &element);
        napi_set_element(env, out_data, i, element);
    }
    return out_data;
}

// main function
static napi_value Predict(napi_env env, napi_callback_info info)
{
    LOG_I("MS_LITE_LOG: Enter runDemo()");
    napi_value error_ret;
    napi_create_int32(env, -1, &error_ret);
    // Data Ingestion Processing
    size_t argc = 2;
    napi_value argv[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    std::vector<float> input_data = ProcessInputData(env, argv[0]);
    // Read model file
    const std::string modelName = "resnet18-place365.ms";
    LOG_I("MS_LITE_LOG: Run model: %{public}s", modelName.c_str());
    size_t modelSize;
    auto resourcesManager = OH_ResourceManager_InitNativeResourceManager(env, argv[1]);
    auto modelBuffer = ReadModelFile(resourcesManager, modelName, &modelSize);
    if (modelBuffer == nullptr) {
        LOG_E("MS_LITE_ERR: Read model failed");
        return error_ret;
    }
    LOG_I("MS_LITE_LOG: Read model file success");
    
    auto context = CreateMSLiteContext(modelBuffer);
    if (context == nullptr) {
        LOG_E("MS_LITE_ERR: MSLiteFwk Build context failed.\n");
        return error_ret;
    }
    auto model = CreateMSLiteModel(modelBuffer, modelSize, context);
    if (model == nullptr) {
        OH_AI_ContextDestroy(&context);
        LOG_E("MS_LITE_ERR: MSLiteFwk Build model failed.\n");
        return error_ret;
    }
    int ret = RunMSLiteModel(model, input_data);
    if (ret != OH_AI_STATUS_SUCCESS) {
        OH_AI_ModelDestroy(&model);
        OH_AI_ContextDestroy(&context);
        LOG_E("MS_LITE_ERR: RunMSLiteModel failed.\n");
        return error_ret;
    }
    napi_value out_data = ProcessOutputData(env, model);
    OH_AI_ModelDestroy(&model);
    OH_AI_ContextDestroy(&context);
    LOG_I("MS_LITE_LOG: Exit runDemo()");
    return out_data;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        {"predict", nullptr, Predict, nullptr, nullptr, nullptr, napi_default, nullptr }
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
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
