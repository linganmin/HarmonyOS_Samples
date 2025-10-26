/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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
* FAQ:C侧如何打开文件。
*/

#include "napi/native_api.h"
#include "TestClass.h"
#include <unistd.h>
#include "hilog/log.h"

// [Start c_side_open_file_cpp]
static napi_value OpenFile(unsigned int fd, unsigned int fd2) { 
    OH_LOG_INFO(LOG_APP, "OpenFile"); 
 
    if (fd != -1) { 
        char buffer[4096]; 
        ssize_t bytesRead; 
        // Read the file content into the buffer 
        bytesRead = read(fd, buffer, sizeof(buffer)); 
        if (bytesRead == -1) { 
            OH_LOG_INFO(LOG_APP, "fail to read file"); 
            close(fd); // Close file descriptor 
            return nullptr; 
        } 
        while (bytesRead != 0) { 
            OH_LOG_INFO(LOG_APP, "Read file size %{public}lu", bytesRead); 
            OH_LOG_INFO(LOG_APP, "Read file cg"); 
            char *pData1 = buffer; 
            OH_LOG_INFO(LOG_APP, "file content: \n%{public}s", pData1); 
            ssize_t bytesWrite; 
            bytesWrite = write(fd2, pData1, bytesRead); 
            if (bytesWrite == -1) { 
                OH_LOG_INFO(LOG_APP, "Writing file failed"); 
                close(fd2); // Close file descriptor 
                return nullptr; 
            } 
            bytesRead = read(fd, buffer, sizeof(buffer)); 
        } 
        // Close file descriptor 
        close(fd); 
        close(fd2); // Close file descriptor 
    } 
    return nullptr; 
} 
static napi_value ReadFile(napi_env env, napi_callback_info info) { 
    size_t argc = 2; 
    napi_value args[2] = {nullptr}; 
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr); 
    unsigned int fd = -1; 
    napi_get_value_uint32(env, args[0], &fd); 
    unsigned int fd2 = -1; 
    napi_get_value_uint32(env, args[1], &fd2); 
    OpenFile(fd, fd2); 
    return nullptr; 
}
// [End c_side_open_file_cpp]

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"ReadFile", nullptr, ReadFile, nullptr, nullptr, nullptr, napi_default, nullptr}};
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
