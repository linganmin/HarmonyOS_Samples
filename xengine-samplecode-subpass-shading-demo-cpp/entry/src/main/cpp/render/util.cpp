/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
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

#include "util.h"

#include <fstream>
#include <unordered_map>
#include <tuple>
#include <array>


std::vector<char> util::readFile(const std::string &fileName)
{
    std::ifstream fileStream(fileName, std::ios::ate | std::ios::binary);

    if (!fileStream.is_open()) {
        auto eee = strerror(errno);
        throw std::runtime_error("failed to open file!");
    }

    // starts reading at the end of file to determine file size (ate)
    size_t fileSize = static_cast<size_t>(fileStream.tellg());
    std::vector<char> buffer(fileSize);
    fileStream.seekg(0);
    fileStream.read(buffer.data(), fileSize);

    fileStream.close();
    return buffer;
}
