/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
/**
 * FAQ: 如何在Native侧往用户目录写临时文件
 */
// [Start write_file_cpp]
#include "WriteFile.h"
#include "napi/native_api.h"
#include <fstream>
napi_value WriteFile::WriteTemporaryFile(napi_env env, napi_callback_info info) {
    std::ofstream file("data/storage/el2/base/temp/2.txt");
    if (file.is_open()) {        // Determine if the file can be opened normally
        file << "Hello, World!"; // Write content to a file
        file.close();            // close file
    }
    return nullptr;
}
// [End write_file_cpp]
