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
 * FAQ: 如何获取Native侧printf等方法打印的信息
 */
// [Start log_redirect_cpp]
#include "napi/native_api.h" 
#include <hilog/log.h> 
#include <string> 
#include "iostream" 
#include "fstream" 
#define LOG_TAG "Pure" 
 
static napi_value Redirect(napi_env env, napi_callback_info info) { 
    // Get the JS parameters of the function 
    size_t argc = 1; 
    napi_value argv[1] = {nullptr}; 
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr); 
    // Resolve parameter 1, the destination directory for saving the file
    size_t targetDirectoryNameSize; 
    char targetDirectoryNameBuf[512]; 
    napi_get_value_string_utf8(env, argv[0], targetDirectoryNameBuf, sizeof(targetDirectoryNameBuf), 
                               &targetDirectoryNameSize); 
    std::string targetDirectoryName(targetDirectoryNameBuf, targetDirectoryNameSize); // target directory 
    OH_LOG_INFO(LOG_APP, "C++Received target path on the side === %{public}s", targetDirectoryNameBuf); 
    std::string targetSandboxPath = targetDirectoryName + "/Log.log"; // Saved file path 
     
    // Use the freopen function to associate files with standard output 
    FILE *stdoutFile = NULL; 
    FILE *stderrFile = NULL; 
    stdoutFile = freopen(targetSandboxPath.c_str(), "a", stdout); 
    stderrFile = freopen(targetSandboxPath.c_str(), "a", stderr); 
    if (NULL == stdoutFile || NULL == stderrFile) { 
        OH_LOG_INFO(LOG_APP, "Recreate！"); 
        // Opening the file output stream of the sandbox file will create a file
        std::ofstream outputFile(targetSandboxPath, std::ios::binary); 
        if (!outputFile) { 
            OH_LOG_ERROR(LOG_APP, "Unable to create target file!"); 
            return nullptr; 
        } 
        stdoutFile = freopen(targetSandboxPath.c_str(), "a", stdout); 
        stderrFile = freopen(targetSandboxPath.c_str(), "a", stderr); 
        if (NULL == stdoutFile || NULL == stderrFile) { 
            OH_LOG_ERROR(LOG_APP, "fail!"); 
            return nullptr; 
        } 
    } 
    OH_LOG_WARN(LOG_APP, "redirect!"); 
    printf("\n*****************Redirect dividing line*****************\n"); 
    return 0; 
}
// [End log_redirect_cpp]

static napi_value PrintByCPP(napi_env env, napi_callback_info info) {
    OH_LOG_WARN(LOG_APP, "Print!");

    // 方式1
    printf("out test\n");
    perror("error test\n");

    // 方式2
    using namespace std;
    cout << "hello out!" << endl;
    cerr << "hello err!" << endl;

    // 方式3
    fprintf(stdout, "fprintf out Test\n");
    fprintf(stderr, "fprintf err Test\n");

    // 方式4
    FILE *pd = NULL;
    pd = fopen("/data/storage/el2/base/files/Log2.log", "w+");
    if (pd == NULL) {
        return nullptr;
    }
    fprintf(pd, "fprintf Test\n");
    fclose(pd);

    return 0;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "redirect", nullptr, Redirect, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "printByCPP", nullptr, PrintByCPP, nullptr, nullptr, nullptr, napi_default, nullptr }
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
    .nm_modname = "logredirect",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterLogRedirectModule(void)
{
    napi_module_register(&demoModule);
}
