
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

#ifndef HIAI_MODEL_MANAGER_H
#define HIAI_MODEL_MANAGER_H

#include "neural_network_runtime/neural_network_core.h"
#include "hiai_foundation/hiai_options.h"
#include <string>
#include <vector>

#undef LOG_DOMAIN
#define LOG_DOMAIN 0x0000

#undef LOG_TAG
#define LOG_TAG "HiAIFoundationDemo"

class HIAIModelManager {
public:
    HIAIModelManager() = default;

    static HIAIModelManager &GetInstance();

    HIAIModelManager(const HIAIModelManager &) = delete;

    HIAIModelManager &operator=(const HIAIModelManager &) = delete;

    OH_NN_ReturnCode LoadModelFromBuffer(uint8_t *modelData, size_t modelSize);

    OH_NN_ReturnCode InitLabels(const char *labelData, size_t labelLength);

    std::vector<std::string> GetLabels() const { return labels; }

    OH_NN_ReturnCode InitIOTensors(std::vector<std::pair<float *, size_t>> inputData);
    
    OH_NN_ReturnCode RunModel();

    std::vector<std::vector<float>> GetResult();
    
    OH_NN_ReturnCode UnloadModel();
    
private:
    size_t deviceID_ {0};
    
    std::vector<NN_Tensor*> inputTensors_;
    std::vector<NN_Tensor*> outputTensors_;

    OH_NNExecutor *executor_ {nullptr};

    std::vector<std::string> labels;
};

#endif // HIAI_MODEL_MANAGER_H
