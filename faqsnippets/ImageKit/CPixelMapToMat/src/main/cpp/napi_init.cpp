/*
 *
 *  * Copyright (c) 2024 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */
/**
 * FAQ: 如何将C++侧接收的PixelMap转换成cv::mat格式
 */
// [Start ConvertPixelMapToCvMatFormat_C_One]
#include "napi/native_api.h"
#include <multimedia/image_framework/image_mdk.h>
#include <multimedia/image_framework/image_mdk_common.h>
#include <multimedia/image_framework/image_pixel_map_mdk.h>
#include <multimedia/image_framework/image_pixel_map_napi.h>
#include "hilog/log.h"
#include <opencv2/opencv.hpp>
#include <bits/alltypes.h>

static napi_value ArrayBufferToMat(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_value error;
    napi_create_int32(env, -1, &error);

    // Initialize PixelMap object data 
    NativePixelMap *native = OH_PixelMap_InitNativePixelMap(env, args[0]);
    if (native == nullptr) {
        return error;
    }
    // Obtaining Image Information
    struct OhosPixelMapInfos pixelMapInfos;
    if (OH_PixelMap_GetImageInfo(native, &pixelMapInfos) != IMAGE_RESULT_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "Test", "Pure : -1");
        return error;
    }
    // Obtains the buffer
    napi_value buffer = args[1];
    napi_valuetype valueType;
    napi_typeof(env, buffer, &valueType);
    if (valueType == napi_object) {
        bool isArrayBuffer = false;
        napi_is_arraybuffer(env, buffer, &isArrayBuffer);
        if (!isArrayBuffer) {
            napi_throw_error(env, "EINVAL", "Error");
        }
    }

    void *data = nullptr;
    size_t byteLength = 0;
    napi_get_arraybuffer_info(env, buffer, &data, &byteLength);
    int32_t *saveBuffer = (int32_t *)(data);

    // Convert to Mat
    cv::Mat originMat(pixelMapInfos.height, pixelMapInfos.width, CV_8UC4, saveBuffer);
    if (!originMat.data) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "Read Image", "Pure : -1");
        return error;
    }

    // openCV defaults to BGRA or BGR. If the pixelmap is not created in one of these formats, a format conversion is required
    cv::Mat saveMat;
    cv::cvtColor(originMat, saveMat, cv::COLOR_BGRA2RGBA);
    char pathArray[1024];
    size_t length;
    napi_get_value_string_utf8(env, args[2], pathArray, 1024, &length);
    std::string path(pathArray);
    path += "/buffer.jpg";
    if (!cv::imwrite(path, saveMat)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "Write Image", "Pure : -1");
        return error;
    }

    napi_value res;
    napi_create_int32(env, 1, &res);
    return res;
}
// [End ConvertPixelMapToCvMatFormat_C_One]

// [Start ConvertPixelMapToCvMatFormat_C_Two]
static napi_value AccessToMat(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_value error;
    napi_create_int32(env, -1, &error);

    NativePixelMap *native = OH_PixelMap_InitNativePixelMap(env, args[0]);
    if (native == nullptr) {
        return error;
    }
    struct OhosPixelMapInfos pixelMapInfos;
    if (OH_PixelMap_GetImageInfo(native, &pixelMapInfos) != IMAGE_RESULT_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "Test", "Pure : -1");
        return error;
    }

    void *pixel;
    // Obtain the memory address of the NativePixelMap object and lock the memory
    OH_PixelMap_AccessPixels(native, &pixel);

    // Convert to Mat, pay attention to alignment, so rowSize needs to be passed in
    cv::Mat originMat(pixelMapInfos.height, pixelMapInfos.width, CV_8UC4, pixel, pixelMapInfos.rowSize);
    if (!originMat.data) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "Read Image", "Pure : -1");
        return error;
    }

    // openCV defaults to BGRA or BGR. If the pixelmap is not created in one of these formats, a format conversion is required
    cv::Mat saveMat;
    cv::cvtColor(originMat, saveMat, cv::COLOR_BGRA2RGBA);
    char pathArray[1024];
    size_t length;
    napi_get_value_string_utf8(env, args[1], pathArray, 1024, &length);
    std::string path(pathArray);
    path += "/access.jpg";
    if (!cv::imwrite(path, saveMat)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "Write Image", "Pure : -1");
        return error;
    }

    napi_value res;
    napi_create_int32(env, 1, &res);
    return res;
}
// [End ConvertPixelMapToCvMatFormat_C_Two]

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "arrayBufferToMat", nullptr, ArrayBufferToMat, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "accessToMat", nullptr, AccessToMat, nullptr, nullptr, nullptr, napi_default, nullptr }
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
    .nm_modname = "cpixelmaptomat",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterCPixelMapToMatModule(void)
{
    napi_module_register(&demoModule);
}
