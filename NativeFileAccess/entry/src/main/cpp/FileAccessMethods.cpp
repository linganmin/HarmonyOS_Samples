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
 * 最佳实践：Native侧实现文件访问开发实践
 */
#include "napi/native_api.h"
#include "hilog/log.h"
#include <cstdio>
#include <memory>
#include <unistd.h>
#include <string>
#include <rawfile/raw_file_manager.h>

const int DOMAIN = 0xFF00;
const char *TAG = "[FileAccessMethods]";
const int BUFFER_SIZE = 256;
const int READ_SIZE = 1000;
const char *FILE_PATH = "/data/storage/el2/base/haps/entry/files/SplicePath.txt";
// [Start napi_value]
// entry/src/main/cpp/FileAccessMethods.cpp
static napi_value TransferSandboxPath(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value argv[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    //Convert the sandbox path and the contents of the text to be written into C-side variables through the Node-API interface.
    size_t pathSize, contentsSize;
    char pathBuf[BUFFER_SIZE], contentsBuf[BUFFER_SIZE];
    // [Start get_path]
    napi_get_value_string_utf8(env, argv[0], pathBuf, sizeof(pathBuf), &pathSize);
    napi_get_value_string_utf8(env, argv[1], contentsBuf, sizeof(contentsBuf), &contentsSize);
    // [End get_path]
    //Open the file through the specified path.
    snprintf(pathBuf, sizeof(pathBuf), "%s/TransferSandboxPath.txt", pathBuf);
    // [Start fp]
    FILE *fp;
    fp = fopen(pathBuf, "w");
    // [End fp]
    if (fp == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, DOMAIN, TAG, "Open file error!");
        return nullptr;
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, DOMAIN, TAG, "Open file successfully!");
     // [Start contentsBuf]
    //Write a file using the file operation function of the C standard library.
    fprintf(fp, "%s", contentsBuf);
      // [End contentsBuf]
    fclose(fp);
    return nullptr;
}
// [End napi_value]
// [Start splice_path]
static napi_value SplicePath(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value argv[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    //Splice the sandbox path according to the actual file location.
    size_t contentsSize;
    // [Start path_buf] 
    char pathBuf[READ_SIZE] = {0};
    strncpy(pathBuf,FILE_PATH,READ_SIZE);
    // [End path_buf]
    //Convert the contents of the text to be written into C-side variables through the Node-API interface.
    char contentsBuf[BUFFER_SIZE];
    // [Start value_utf8]
    // [Start value_string]
    napi_get_value_string_utf8(env, argv[0], contentsBuf, sizeof(contentsBuf), &contentsSize);
    // [End value_string] 
    // [End value_utf8]
    // [Start fp1]
    //Open the file through the specified path.
    FILE *fp;
    fp = fopen(pathBuf, "w");
    // [End fp1]
    if (fp == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, DOMAIN, TAG, "Open file error!");
        return nullptr;
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, DOMAIN, TAG, "Open file successfully!");
    // [Start fp_buf]
    //Write a file using the file operation function of the C standard library.
    fprintf(fp, "%s", contentsBuf);
    // [End fp_buf]
    fclose(fp);
    return nullptr;
}
// [End splice_path]
// [Start source_mg]
static napi_value TransferResourceMgr(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value argv[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    // [Start native_manage]
    //Convert the incoming resource manager object into a Native object.
    NativeResourceManager *mNativeResMgr = OH_ResourceManager_InitNativeResourceManager(env, argv[0]);
    // [End native_manage]
    size_t fileNameSize;
    char fileNameBuf[BUFFER_SIZE];
    //Convert the passed-in file name into a C-side variable through the Node-API interface.
    napi_get_value_string_utf8(env, argv[1], fileNameBuf, sizeof(fileNameBuf), &fileNameSize);
    // [Start open_raw_file]
    //Open a file through a resource object
    RawFile *rawFile = OH_ResourceManager_OpenRawFile(mNativeResMgr, fileNameBuf);
    // [End open_raw_file]
    if (rawFile != nullptr) {
        OH_LOG_Print(LOG_APP, LOG_INFO, DOMAIN, TAG, "OH_ResourceManager_OpenRawFile success.");
    }
    // [Start long_len]
    //Read the file content through the resource object
    long len = OH_ResourceManager_GetRawFileSize(rawFile);
    std::unique_ptr<char[]> data = std::make_unique<char[]>(len);
    OH_ResourceManager_ReadRawFile(rawFile, data.get(), len);
    // [End long_len]
    OH_ResourceManager_CloseRawFile(rawFile);
    OH_ResourceManager_ReleaseNativeResourceManager(mNativeResMgr);
    napi_value contents;
    napi_create_string_utf8(env, data.get(), len, &contents);
    return contents;
}
// [End source_mg]
// [Start write_pick]
static napi_value WriteFileUsingPickerFd(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value argv[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);

    unsigned int fd = -1;
    size_t contentsSize;
    char contentsBuf[BUFFER_SIZE];
    // [Start uint_get]
    //Convert the incoming file descriptor and the contents to be written into the file into C-side variables.
    napi_get_value_uint32(env, argv[0], &fd);
    napi_get_value_string_utf8(env, argv[1], contentsBuf, sizeof(contentsBuf), &contentsSize);
    // [End uint_get]
    ftruncate(fd, 0);
    // [Start size_buf]
    //Write a file using the file operation function of the C standard library.
    size_t buffSize = write(fd, contentsBuf, contentsSize);
    // [End size_buf]
    // [Start std_res]
    std::string res;
    //According to the return value of the write function, judge whether the operation returns the result successfully. 
    napi_value contents;
    if (buffSize == -1) {
        res = "Write File Failed!";
        OH_LOG_Print(LOG_APP, LOG_ERROR, DOMAIN, TAG, "%s", res.c_str());
    } else {
        res = "Write File Successfully!!!";
        OH_LOG_Print(LOG_APP, LOG_INFO, DOMAIN, TAG, "%s", res.c_str());
    }
    napi_create_string_utf8(env, res.c_str(), sizeof(res), &contents);
    return contents;
    // [End std_res]
}
// [End write_pick]
// [Start read_filepick1]
// entry/src/main/cpp/FileAccessMethods.cpp
static napi_value ReadFileUsingPickerFd(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value argv[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);

    unsigned int fd = -1;
    // [Start uint32_env]
    //Convert the incoming file descriptor into a C-side variable.
    napi_get_value_uint32(env, argv[0], &fd);
    // [End uint32_env]
    // [Start buff_char]
    //Use the file operation function of the C standard library to read the file.
    char buff[READ_SIZE];
    size_t buffSize = read(fd, buff, sizeof(buff));
    // [End buff_char]
    // [Start content_value]
    //Judge whether the reading is successful or not and return the file content.
    napi_value contents;
    if (buffSize == -1) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, DOMAIN, TAG, "Read File Failed!!!");
    } else {
        OH_LOG_Print(LOG_APP, LOG_INFO, DOMAIN, TAG, "Read File Successfully!!!");
        napi_create_string_utf8(env, buff, buffSize, &contents);
    }
    return contents;
    // [End content_value]
}
// [End read_filepick1]

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"transferSandboxPath", nullptr, TransferSandboxPath, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"splicePath", nullptr, SplicePath, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"transferResourceMgr", nullptr, TransferResourceMgr, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"writeFileUsingPickerFd", nullptr, WriteFileUsingPickerFd, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"readFileUsingPickerFd", nullptr, ReadFileUsingPickerFd, nullptr, nullptr, nullptr, napi_default, nullptr}};

    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "file_access",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&demoModule); }