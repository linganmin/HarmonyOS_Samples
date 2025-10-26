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

#include <fstream>
#include <dlfcn.h>
#include "napi/native_api.h"
#include "hilog/log.h"
#include "rawfile/raw_file_manager.h"
#include "rawfile/raw_file.h"

const int CHAR_BUF_SIZE = 512;
const int GLOBAL_RES_MGR = 0xFF00;
const char *TAG = "[pic2sandbox]";
const char libCurlDownload[CHAR_BUF_SIZE] = "libcurlDownload.so"; // 下载so文件

struct CallbackRawFileContext {
    napi_async_work asyncWork = nullptr;     // Work asynchronously.
    napi_ref callbackRef = nullptr;          // callback function reference.
    NativeResourceManager *resMgr = nullptr; // resource.
    std::string rawFileName = "";            // file name in rawfile.
    std::string sandboxDir = "";             // Sandbox directory to save to.
    std::string result = "";                 // Return results.
};

struct CallbackInternetContext {
    napi_async_work asyncWork = nullptr; // Work asynchronously.
    napi_ref callbackRef = nullptr;      // callback function reference.
    std::string internetPicUrl = "";     // Internet picture address.
    std::string sandboxDir = "";         // Sandbox directory to save to.
    std::string FileName = "";           // Saved file name.
    std::string result = "";             // Return results.
};

/*
 * Business logic processing functions perform time-consuming tasks and are scheduled and executed by the worker thread
 * pool.
*/

static void InternetCallbackExecuteCB(napi_env env, void *data) {
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RES_MGR, TAG, "saveImageOfInternet load libcurlDownload.so begin");
    // Use dlopen to dynamically load the so library and return the handle of the so library.
    void *handler = dlopen(libCurlDownload, RTLD_LAZY);
    if (handler == nullptr) {
        dlerror();
        return;
    }

    typedef std::string (*DownloadInternetFileFunc)(char *, char *);
    DownloadInternetFileFunc downloadInternetWrapper =
        reinterpret_cast<DownloadInternetFileFunc>(dlsym(handler, "DownloadInternetFileWrapper"));
    if (downloadInternetWrapper) {
        // Call the downloadInternetWrapper function of so to save Internet images to the sandbox.
        CallbackInternetContext *internetContext = (CallbackInternetContext *)data;
        if (internetContext == nullptr) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RES_MGR, TAG, "saveImageOfInternet internetContext is null");
            return;
        }
        // Image sandbox full path.
        std::string targetSandboxPath = internetContext->sandboxDir + internetContext->FileName;

        internetContext->result =
            downloadInternetWrapper((char *)internetContext->internetPicUrl.c_str(), (char *)targetSandboxPath.c_str());
        OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RES_MGR, TAG, "saveImageOfInternet download finish");
        dlclose(handler);
    } else {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RES_MGR, TAG, "saveImageOfInternet download function is null");
        dlclose(handler);
    }
}

/*
 * The business logic processing completion callback function is triggered after the execution of the business logic
 * processing function is completed or canceled, and is executed in the EventLoop thread.
 */
static void InternetCallbackCompleteCB(napi_env env, napi_status status, void *data) {
    CallbackInternetContext *internetContext = (CallbackInternetContext *)data;
    if (internetContext == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RES_MGR, TAG, "saveImageOfInternet internetContext is null");
        return;
    }
    napi_value callback = nullptr;
    napi_get_reference_value(env, internetContext->callbackRef, &callback);
    napi_value undefined = nullptr;
    napi_get_undefined(env, &undefined);
    napi_value callbackResult = nullptr;
    napi_value result;
    napi_create_string_utf8(env, internetContext->result.c_str(), NAPI_AUTO_LENGTH, &result);
    // Execute callback function.
    napi_call_function(env, undefined, callback, 1, &result, &callbackResult);
    // Delete napi_ref object.
    if (internetContext->callbackRef != nullptr) {
        napi_delete_reference(env, internetContext->callbackRef);
    }
    // Delete an asynchronous work item.
    napi_delete_async_work(env, internetContext->asyncWork);
    delete internetContext;
}

// Save network images to sandbox path.
static napi_value SaveImageOfInternet(napi_env env, napi_callback_info info) {
    // Asynchronous work item context user data is passed to execute and complete of the asynchronous work item.
    auto internetContext = new CallbackInternetContext{.asyncWork = nullptr};
    if (internetContext == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RES_MGR, TAG, "saveImageOfInternet new internetContext fail!");
        return nullptr;
    }

    size_t argc = 4;
    napi_value args[4] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    size_t internetPicSize;
    char internetPicBuf[CHAR_BUF_SIZE];
    napi_get_value_string_utf8(env, args[0], internetPicBuf, sizeof(internetPicBuf), &internetPicSize);
    std::string internetPicUrl(internetPicBuf, internetPicSize);
    internetContext->internetPicUrl = internetPicUrl;

    size_t targetDirectorSize;
    char targetDirectoryBuf[CHAR_BUF_SIZE];
    napi_get_value_string_utf8(env, args[1], targetDirectoryBuf, sizeof(targetDirectoryBuf), &targetDirectorSize);
    std::string targetDirectory(targetDirectoryBuf, targetDirectorSize);

    internetContext->sandboxDir = targetDirectory;

    size_t fileNameSize;
    char fileNameBuf[CHAR_BUF_SIZE];
    napi_get_value_string_utf8(env, args[2], fileNameBuf, sizeof(fileNameBuf), &fileNameSize);
    std::string fileName(fileNameBuf, fileNameSize);
    internetContext->FileName = fileName;

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[3], &valueType);
    if (valueType != napi_function) {
        OH_LOG_ERROR(LOG_APP, "saveImageOfInternet param[3] is not function");
        return nullptr;
    }
    uint32_t initial_refcount = 1;
    napi_create_reference(env, args[3], initial_refcount, &internetContext->callbackRef);

    napi_value resourceName = nullptr;
    napi_create_string_utf8(env, "InternetCallback", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_async_work(env, nullptr, resourceName, InternetCallbackExecuteCB, InternetCallbackCompleteCB,
                           (void *)internetContext, &internetContext->asyncWork);

    napi_queue_async_work(env, internetContext->asyncWork);

    napi_value result = 0;
    napi_get_null(env, &result);
    return result;
}

/*
 * Business logic processing functions perform time-consuming tasks and are scheduled and executed by the worker thread
 * pool.
 */
static void RawFileCallbackExecuteCB(napi_env env, void *data) {
    CallbackRawFileContext *rawFileContext = (CallbackRawFileContext *)data;
    if (rawFileContext == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RES_MGR, TAG, "saveImageOfRawfile rawFileContext is null");
        return;
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RES_MGR, TAG, "saveImageOfRawfile Begin");

    // Open Rawfile.
    RawFile *rawFile = OH_ResourceManager_OpenRawFile(rawFileContext->resMgr, rawFileContext->rawFileName.c_str());
    if (rawFile == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RES_MGR, TAG, "saveImageOfRawfile OpenRawFile fail!");
        // Release resources.
        OH_ResourceManager_ReleaseNativeResourceManager(rawFileContext->resMgr);
        return;
    }
    // Get file size.
    long imageDataSize = OH_ResourceManager_GetRawFileSize(rawFile);
    // Apply for memory.
    std::unique_ptr<char[]> imageData = std::make_unique<char[]>(imageDataSize);
    // Read Rawfile files through the Rawfile API interface.
    OH_ResourceManager_ReadRawFile(rawFile, imageData.get(), imageDataSize);
    // The sandbox path to save the target network image.
    std::string targetSandboxPath = rawFileContext->sandboxDir + rawFileContext->rawFileName;
    // Write the read data to the sandbox file through std::ofstream.
    std::ofstream outputFile(targetSandboxPath, std::ios::binary);
    if (!outputFile) {
        // Release resources.
        OH_ResourceManager_CloseRawFile(rawFile);
        OH_ResourceManager_ReleaseNativeResourceManager(rawFileContext->resMgr);
        return;
    }
    // write file.
    outputFile.write(imageData.get(), imageDataSize);

    // close file.
    outputFile.close();
    // Release resources.
    OH_ResourceManager_CloseRawFile(rawFile);
    OH_ResourceManager_ReleaseNativeResourceManager(rawFileContext->resMgr);
    // Return sandbox path.
    rawFileContext->result = targetSandboxPath;
}

/*
 * The business logic processing completion callback function is triggered after the execution of the business logic
 * processing function is completed or canceled, and is executed in the EventLoop thread.
 */
static void RawFileCallbackCompleteCB(napi_env env, napi_status status, void *data) {
    CallbackRawFileContext *rawFileContext = (CallbackRawFileContext *)data;
    if (rawFileContext == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RES_MGR, TAG, "saveImageOfRawfile rawFileContext is null");
        return;
    }
    napi_value callback = nullptr;
    napi_get_reference_value(env, rawFileContext->callbackRef, &callback);
    napi_value undefined = nullptr;
    napi_get_undefined(env, &undefined);
    napi_value callbackResult = nullptr;
    napi_value result;
    napi_create_string_utf8(env, rawFileContext->result.c_str(), NAPI_AUTO_LENGTH, &result);
    // Execute callback function.
    uint32_t param_count = 1;
    napi_call_function(env, undefined, callback, param_count, &result, &callbackResult);

    if (rawFileContext->callbackRef != nullptr) {
        napi_delete_reference(env, rawFileContext->callbackRef);
    }

    napi_delete_async_work(env, rawFileContext->asyncWork);
    delete rawFileContext;
}

// Rawfile file is saved to the sandbox path.
static napi_value SaveImageOfRawfile(napi_env env, napi_callback_info info) {
    // Asynchronous work item context user data is passed to execute and complete of the asynchronous work item..
    auto rawFileContext = new CallbackRawFileContext{.asyncWork = nullptr};
    if (rawFileContext == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RES_MGR, TAG, "saveImageOfRawfile new rawFileContext fail!");
        return nullptr;
    }

    size_t argc = 4;
    napi_value args[4];
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // Initialize native resource manager.
    rawFileContext->resMgr = OH_ResourceManager_InitNativeResourceManager(env, args[0]);

    size_t rawFileNameSize;
    char rawFileNameBuf[CHAR_BUF_SIZE];
    napi_get_value_string_utf8(env, args[1], rawFileNameBuf, sizeof(rawFileNameBuf), &rawFileNameSize);
    std::string rawFileName(rawFileNameBuf, rawFileNameSize);
    rawFileContext->rawFileName = rawFileName;
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RES_MGR, TAG, "saveImageOfRawfile rawfileName :%{public}s",
                 rawFileName.c_str());

    size_t targetDirectorSize;
    char targetDirectoryBuf[CHAR_BUF_SIZE];
    napi_get_value_string_utf8(env, args[2], targetDirectoryBuf, sizeof(targetDirectoryBuf), &targetDirectorSize);
    std::string targetDirectory(targetDirectoryBuf, targetDirectorSize);
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RES_MGR, TAG, "saveImageOfRawfile targetPath:%{public}s",
                 targetDirectoryBuf);
    rawFileContext->sandboxDir = targetDirectory;

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, args[3], &valueType);
    if (valueType != napi_function) {
        OH_LOG_ERROR(LOG_APP, "saveImageOfRawfile param[3] is not function");
        return nullptr;
    }
    uint32_t initial_refcount = 1;
    napi_create_reference(env, args[3], initial_refcount, &rawFileContext->callbackRef);

    napi_value resourceName = nullptr;
    napi_create_string_utf8(env, "rawFileCallback", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_async_work(env, nullptr, resourceName, RawFileCallbackExecuteCB, RawFileCallbackCompleteCB,
                           (void *)rawFileContext, &rawFileContext->asyncWork);

    napi_queue_async_work(env, rawFileContext->asyncWork);

    napi_value result = 0;
    napi_get_null(env, &result);
    return result;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {{"saveImageOfInternet", nullptr, SaveImageOfInternet, nullptr,
                                        nullptr, nullptr, napi_default, nullptr},
                                       {"saveImageOfRawfile", nullptr, SaveImageOfRawfile, nullptr,
                                        nullptr, nullptr, napi_default, nullptr}};
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
