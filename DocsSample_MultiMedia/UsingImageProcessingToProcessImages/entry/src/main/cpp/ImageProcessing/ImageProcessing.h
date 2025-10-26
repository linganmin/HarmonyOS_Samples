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

#ifndef USINGIMAGEPROCESSINGTOPROCESSIMAGES_IMAGEPROCESSING_H
#define USINGIMAGEPROCESSINGTOPROCESSIMAGES_IMAGEPROCESSING_H

// [Start import]
// [Start MetadataImport]
#include <hilog/log.h>
#include <multimedia/image_framework/image_pixel_map_mdk.h>
#include <multimedia/image_framework/image/pixelmap_native.h>
#include <multimedia/video_processing_engine/image_processing.h>
#include <multimedia/video_processing_engine/image_processing_types.h>
#include <multimedia/player_framework/native_avformat.h>
#include <napi/native_api.h>
// [End import]
#include <multimedia/image_framework/image_mdk_common.h>
#include <native_color_space_manager/native_color_space_manager.h>
// [End MetadataImport]
#include <cstdint>
#include <cstring>
#include <ctime>
#include <multimedia/image_framework/image/pixelmap_native.h>
#include <cstddef>
#include <stdlib.h>
#undef LOG_TAG
#define LOG_TAG "UsingImageProcessingToProcessImages"

class ImageProcessing {
public:
    static napi_value CreatePixelMap(napi_env env, napi_callback_info info);
    static napi_value getNativeImgFromPixelMap(napi_env env, napi_callback_info info);
    static napi_value HdrCompose(napi_env env, napi_callback_info info);
    static napi_value HdrDecompose(napi_env env, napi_callback_info info);
    static napi_value GenerateMetadata(napi_env env, napi_callback_info info);
    static napi_value hdrAIHDR(napi_env env, napi_callback_info info);
    static napi_value DetailEnhance(napi_env env, napi_callback_info info);
};

#endif // USINGIMAGEPROCESSINGTOPROCESSIMAGES_IMAGEPROCESSING_H
