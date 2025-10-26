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

#include "HIAIModelManager.h"

#include <hilog/log.h>
#include <string>

#include "hiai_foundation/hiai_options.h"
#include "hiai_foundation/hiai_helper.h"
#include "hiai_foundation/hiai_aipp_param.h"
#include "hiai_foundation/hiai_tensor.h"

HIAIModelManager &HIAIModelManager::GetInstance()
{
    static HIAIModelManager instance;
    return instance;
}

namespace {
    size_t GetDeviceID()
    {
        size_t deviceID = 0;
        const size_t *allDevicesID = nullptr;
        uint32_t deviceCount = 0;
        OH_NN_ReturnCode ret = OH_NNDevice_GetAllDevicesID(&allDevicesID, &deviceCount);
        if (ret != OH_NN_SUCCESS || allDevicesID == nullptr) {
            OH_LOG_ERROR(LOG_APP, "OH_NNDevice_GetAllDevicesID failed");
            return deviceID;
        }

        for (uint32_t i = 0; i < deviceCount; i++) {
            const char *name = nullptr;
            ret = OH_NNDevice_GetName(allDevicesID[i], &name);
            if (ret != OH_NN_SUCCESS || name == nullptr) {
                OH_LOG_ERROR(LOG_APP, "OH_NNDevice_GetName failed");
                return deviceID;
            }
            if (std::string(name) == "HIAI_F") {
                deviceID = allDevicesID[i];
                break;
            }
        }
        return deviceID;
    }

    OH_NN_ReturnCode SetInputTensorData(std::vector<NN_Tensor *> inputTensors,
                                        std::vector<std::pair<float *, size_t>> inputData) {
        for (size_t i = 0; i < inputTensors.size(); ++i) {
            // Obtain the address of the input memory and write the input data.
            void *data = OH_NNTensor_GetDataBuffer(inputTensors[i]);
            size_t dataSize = 0;
            OH_NNTensor_GetSize(inputTensors[i], &dataSize);
            if (data == nullptr || dataSize != inputData[i].second * sizeof(float)) {
                OH_LOG_ERROR(LOG_APP, "invalid data or dataSize");
                return OH_NN_FAILED;
            }

            memcpy(data, inputData[i].first, dataSize);
        }
        return OH_NN_SUCCESS;
    }

    void DestroyTensors(std::vector<NN_Tensor *> &tensors) {
        for (auto tensor : tensors) {
            OH_NNTensor_Destroy(&tensor);
        }
        tensors.clear();
    }

    OH_NN_ReturnCode SetModelBuildOptions(OH_NNCompilation* &compilation)
    {
        // set bandmode
        OH_NN_ReturnCode ret = HMS_HiAIOptions_SetBandMode(compilation, HiAI_BandMode::HIAI_BANDMODE_NORMAL);
        if (ret != OH_NN_SUCCESS) {
            OH_LOG_ERROR(LOG_APP, "HMS_HiAIOptions_SetBandMode failed");
            return ret;
        }
        HiAI_BandMode bandMode = HMS_HiAIOptions_GetBandMode(compilation);

        // set model execute device
        std::vector<HiAI_ExecuteDevice> executeDevices {HiAI_ExecuteDevice::HIAI_EXECUTE_DEVICE_NPU};
        ret = HMS_HiAIOptions_SetModelDeviceOrder(compilation, executeDevices.data(), executeDevices.size());
        if (ret != OH_NN_SUCCESS) {
            OH_LOG_ERROR(LOG_APP, "HMS_HiAIOptions_SetModelDeviceOrder failed");
            return ret;
        }
        return OH_NN_SUCCESS;
    }
}

OH_NN_ReturnCode HIAIModelManager::LoadModelFromBuffer(uint8_t *modelData, size_t modelSize)
{
    if (executor_ != nullptr) {
        OH_LOG_ERROR(LOG_APP, "executor has already been initialized");
        return OH_NN_FAILED;
    }
    // check model compility
    HiAI_Compatibility compibility = HMS_HiAICompatibility_CheckFromBuffer(modelData, modelSize);
    OH_LOG_INFO(LOG_APP, "model compibility is %{public}d", compibility);

    // Create a compilation based on the model buffer.
    OH_NNCompilation *compilation = OH_NNCompilation_ConstructWithOfflineModelBuffer(modelData, modelSize);
    if (compilation == nullptr) {
        OH_LOG_ERROR(LOG_APP, "OH_NNCompilation_ConstructWithOfflineModelBuffer failed");
        return OH_NN_FAILED;
    }

    size_t deviceID = GetDeviceID();
    if (deviceID == 0) {
        OH_LOG_ERROR(LOG_APP, "GetDeviceID failed");
        OH_NNCompilation_Destroy(&compilation);
        return OH_NN_FAILED;
    }

    OH_NN_ReturnCode ret = OH_NNCompilation_SetDevice(compilation, deviceID);
    if (ret != OH_NN_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "OH_NNCompilation_SetDevice failed");
        OH_NNCompilation_Destroy(&compilation);
        return OH_NN_FAILED;
    }
    deviceID_ = deviceID;

    ret = SetModelBuildOptions(compilation);
    if (ret != OH_NN_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "SetModelBuildOptions failed");
        OH_NNCompilation_Destroy(&compilation);
        return OH_NN_FAILED;
    }

    // Compiling a Model
    ret = OH_NNCompilation_Build(compilation);
    if (ret != OH_NN_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "OH_NNCompilation_Build failed");
        OH_NNCompilation_Destroy(&compilation);
        return OH_NN_FAILED;
    }

    // Create an executor and load a model.
    executor_ = OH_NNExecutor_Construct(compilation);
    if (executor_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "OH_NNExecutor_Construct failed");
        OH_NNCompilation_Destroy(&compilation);
        return OH_NN_FAILED;
    }
    OH_NNCompilation_Destroy(&compilation);
    OH_LOG_INFO(LOG_APP, "LoadModelFromBuffer success");
    return OH_NN_SUCCESS;
}

OH_NN_ReturnCode HIAIModelManager::InitLabels(const char *labelData, size_t labelLength)
{
    std::string values = std::string(labelData, labelLength) + '\n';
    std::string label = "";
    for (size_t i = 0; i < values.size(); ++i) {
        if (values[i] != '\n') {
            label += values[i];
            continue;
        }
        labels.push_back(label);
        label = "";
    }
    
    return OH_NN_SUCCESS;
}

OH_NN_ReturnCode HIAIModelManager::InitIOTensors(std::vector<std::pair<float *, size_t>> inputData)
{
    if (executor_ == nullptr || inputData.empty()) {
        OH_LOG_ERROR(LOG_APP, "executor is not initialized or inputData is empty");
        return OH_NN_FAILED;
    }
    
    if (!inputTensors_.empty()) {
        DestroyTensors(inputTensors_);
        inputTensors_.clear();
    }

    if (!outputTensors_.empty()) {
        DestroyTensors(outputTensors_);
        outputTensors_.clear();
    }

    // Preparing to Input Tensor
    size_t inputCount = 0;
    OH_NN_ReturnCode ret = OH_NNExecutor_GetInputCount(executor_, &inputCount);
    if (ret != OH_NN_SUCCESS || inputCount != inputData.size()) {
        OH_LOG_ERROR(LOG_APP, "OH_NNExecutor_GetInputCount failed, size mismatch");
        return OH_NN_FAILED;
    }
    for (size_t i = 0; i < inputCount; ++i) {
        NN_TensorDesc *tensorDesc = OH_NNExecutor_CreateInputTensorDesc(executor_, i);
        NN_Tensor *tensor = OH_NNTensor_Create(deviceID_, tensorDesc);
        if (tensor != nullptr) {
            inputTensors_.push_back(tensor);
        }
        OH_NNTensorDesc_Destroy(&tensorDesc);
    }
    if (inputTensors_.size() != inputCount) {
        OH_LOG_ERROR(LOG_APP, "input size mismatch.");
        DestroyTensors(inputTensors_);
        return OH_NN_FAILED;
    }
    
    // Write input data
    ret = SetInputTensorData(inputTensors_, inputData);
    if (ret != OH_NN_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "SetInputTensorData failed");
        DestroyTensors(inputTensors_);
        return OH_NN_FAILED;
    }

    // Preparing to Output Tensor
    size_t outputCount = 0;
    ret = OH_NNExecutor_GetOutputCount(executor_, &outputCount);
    if (ret != OH_NN_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "OH_NNExecutor_GetOutputCount failed");
        DestroyTensors(inputTensors_);
        return OH_NN_FAILED;
    }
    for (size_t i = 0; i < outputCount; i++) {
        NN_TensorDesc *tensorDesc = OH_NNExecutor_CreateOutputTensorDesc(executor_, i);
        NN_Tensor *tensor = OH_NNTensor_Create(deviceID_, tensorDesc);
        if (tensor != nullptr) {
            outputTensors_.push_back(tensor);
        }
        OH_NNTensorDesc_Destroy(&tensorDesc);
    }
    if (outputTensors_.size() != outputCount) {
        DestroyTensors(inputTensors_);
        DestroyTensors(outputTensors_);
        OH_LOG_ERROR(LOG_APP, "output size mismatch.");
        return OH_NN_FAILED;
    }
    
    OH_LOG_INFO(LOG_APP, "InitIOTensors success");
    return OH_NN_SUCCESS;
}

OH_NN_ReturnCode HIAIModelManager::RunModel()
{
    if (executor_ == nullptr || inputTensors_.empty() || outputTensors_.empty()) {
        OH_LOG_ERROR(LOG_APP, "model is not initialized or input is empty or output is empty.");
        return OH_NN_FAILED;
    }
    OH_NN_ReturnCode ret = OH_NNExecutor_RunSync(executor_, inputTensors_.data(), inputTensors_.size(),
                                                 outputTensors_.data(), outputTensors_.size());
    if (ret != OH_NN_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "OH_NNExecutor_RunSync failed");
        return ret;
    }
    OH_LOG_INFO(LOG_APP, "OH_NNExecutor_RunSync success");
    return OH_NN_SUCCESS;
}

std::vector<std::vector<float>> HIAIModelManager::GetResult()
{
    std::vector<std::vector<float>> outputs;
    for (auto tensor : outputTensors_) {
        void *tensorData = OH_NNTensor_GetDataBuffer(tensor);
        if (tensorData == nullptr) {
            OH_LOG_ERROR(LOG_APP, "OH_NNTensor_GetDataBuffer failed");
            break;
        }
        size_t size = 0;
        OH_NN_ReturnCode ret = OH_NNTensor_GetSize(tensor, &size);
        if (ret != OH_NN_SUCCESS || size == 0) {
            OH_LOG_ERROR(LOG_APP, "OH_NNTensor_GetSize failed");
            break;
        }
        
        float *outputResult = static_cast<float *>(tensorData);
        std::vector<float> output(size / 4, 0.0);
        for (size_t i = 0; i < size / 4; ++i) {
            output[i] = outputResult[i];
        }
        outputs.push_back(output);
    }

    if (outputs.size() != outputTensors_.size()) {
        OH_LOG_ERROR(LOG_APP, "The output tensor size does not match");
        outputs.clear();
    }
    OH_LOG_INFO(LOG_APP, "GetResult success");
    return outputs;
}

OH_NN_ReturnCode HIAIModelManager::UnloadModel()
{
    DestroyTensors(inputTensors_);
    inputTensors_.clear();
    
    DestroyTensors(outputTensors_);
    outputTensors_.clear();
    
    OH_NNExecutor_Destroy(&executor_);
    return OH_NN_SUCCESS;
}