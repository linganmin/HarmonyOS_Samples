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

#include "ImageProcessing.h"

constexpr uint32_t LOG_PRINT_DOMAIN = 0xFF00;

// [Start CreatePixelMap]
napi_value ImageProcessing::CreatePixelMap(napi_env env, napi_callback_info info)
{
    napi_value udfVar = nullptr;
    napi_value pixelMap = nullptr;
    napi_value thisVar = nullptr;
    napi_value argValue[2] = {0};
    size_t argCount = 2;
    size_t count = 2;
    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < count ||
        argValue[0] == nullptr || argValue[1] == nullptr) {
        return nullptr;
    }
    int32_t width = 0;
    int32_t height = 0;
    napi_get_value_int32(env, argValue[1], &width);
    napi_get_value_int32(env, argValue[0], &height);
    struct OhosPixelMapCreateOps createOps;
    createOps.width = width;
    createOps.height = height;
    int32_t rgba8888 = 3;
    createOps.pixelFormat = rgba8888;
    createOps.alphaType = 0;
    
    size_t bufferSize = createOps.width * createOps.height * 4;
    void *buff = malloc(bufferSize);
    int32_t res = OH_PixelMap_CreatePixelMapWithStride(env, createOps, (uint8_t *)buff, bufferSize, createOps.width * 4,
        &pixelMap);
    free(buff);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "createPixelMap",
        "OH_PixelMap_CreatePixelMapWithStride %{public}d", res);
    if (res != IMAGE_RESULT_SUCCESS || pixelMap == nullptr) {
        return udfVar;
    }
    return pixelMap;
}
// [End CreatePixelMap]
    
int processImage(OH_PixelmapNative *src, OH_PixelmapNative *dst)
{
    // [Start processImageInit]
    ImageProcessing_ErrorCode ret = OH_ImageProcessing_InitializeEnvironment();
    // [End processImageInit]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Create err");
    }
    // [Start processImageSupported]
    // Input format.
    ImageProcessing_ColorSpaceInfo SRC_INFO;
    ImageProcessing_ColorSpaceInfo DST_GAIN_INFO;
    ImageProcessing_ColorSpaceInfo DST_INFO;
    SRC_INFO.colorSpace = DISPLAY_P3;
    SRC_INFO.metadataType = HDR_METADATA_TYPE_NONE;
    SRC_INFO.pixelFormat = PIXEL_FORMAT_RGBA_8888;
    DST_INFO.colorSpace = SRGB;
    DST_INFO.metadataType = HDR_METADATA_TYPE_NONE;
    DST_INFO.pixelFormat = PIXEL_FORMAT_RGBA_8888;
    // Ability inquiry.
    bool flag = OH_ImageProcessing_IsColorSpaceConversionSupported(&SRC_INFO, &DST_INFO);
    // [End processImageSupported]
    if (!flag) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "not supported err");
        return -1;
    }
    // [Start processImageCreate]
    OH_ImageProcessing *instance = nullptr;
    ret = OH_ImageProcessing_Create(&instance, IMAGE_PROCESSING_TYPE_COLOR_SPACE_CONVERSION);
    // [End processImageCreate]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Create err");
    }
    // [Start processImageConvert]
    ret = OH_ImageProcessing_ConvertColorSpace(instance, src, dst);
    // [End processImageConvert]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap",
            "OH_ImageProcessing_ConvertColorSpace err");
    }
    // [Start processImageDestroy]
    ret = OH_ImageProcessing_Destroy(instance);
    // [End processImageDestroy]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Destroy err");
    }
    // [Start processImageEnvironment]
    ret = OH_ImageProcessing_DeinitializeEnvironment();
    // [End processImageEnvironment]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap",
            "OH_ImageProcessing_DeinitializeEnvironment err");
    }
    return ret;
}

napi_value ImageProcessing::getNativeImgFromPixelMap(napi_env env, napi_callback_info info)
{
    napi_value thisVar = nullptr;
    napi_value argValue[4] = {0};
    size_t argCount = 4;
    size_t count = 2;
    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < count ||
        argValue[0] == nullptr || argValue[1] == nullptr) {
        return nullptr;
    }
    // [Start getNativeImg]
    OH_PixelmapNative *srcImg = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[0], &srcImg);
    OH_PixelmapNative *dstImg = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[1], &dstImg);
    // [End getNativeImg]
    napi_value ret;
    int32_t err = processImage(srcImg, dstImg);
    if (err != 0) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "NativePixelMap", "processImage failed ");
    }
    napi_create_int32(env, err, &ret);
    return ret;
}

napi_value ImageProcessing::HdrCompose(napi_env env, napi_callback_info info)
{
    napi_value thisVar = nullptr;
    napi_value argValue[3] = {0};
    size_t argCount = 3;
    size_t count = 3;
    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < count ||
        argValue[0] == nullptr || argValue[1] == nullptr) {
        return nullptr;
    }
    // [Start HdrCompose]
    OH_PixelmapNative *sdr = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[0], &sdr);
    OH_PixelmapNative *gainmap = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[1], &gainmap);
    OH_PixelmapNative *hdr = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[2], &hdr);
    // [End HdrCompose]
    // [Start HdrComposeInitializeEnvironment]
    ImageProcessing_ErrorCode ret = OH_ImageProcessing_InitializeEnvironment();
    // [End HdrComposeInitializeEnvironment]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Create err");
    }
    // [Start HdrComposeSupported]
    // Input format.
    ImageProcessing_ColorSpaceInfo DST_INFO;
    ImageProcessing_ColorSpaceInfo SRC_INFO;
    ImageProcessing_ColorSpaceInfo SRC_GAIN_INFO;
    DST_INFO.colorSpace = BT2020_HLG;
    DST_INFO.metadataType = HDR_METADATA_TYPE_ALTERNATE;
    DST_INFO.pixelFormat = PIXEL_FORMAT_RGBA_1010102;
    SRC_INFO.colorSpace = DCI_P3;
    SRC_INFO.metadataType = HDR_METADATA_TYPE_BASE;
    SRC_INFO.pixelFormat = PIXEL_FORMAT_RGBA_8888;
    SRC_GAIN_INFO.colorSpace = DCI_P3;
    SRC_GAIN_INFO.metadataType = HDR_METADATA_TYPE_GAINMAP;
    SRC_GAIN_INFO.pixelFormat = PIXEL_FORMAT_RGBA_8888;
    // Ability inquiry.
    bool flag = OH_ImageProcessing_IsCompositionSupported(&SRC_INFO, &SRC_GAIN_INFO, &DST_INFO);
    if (!flag) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "not support err");
        napi_value retValErr;
        napi_create_int32(env, -1, &retValErr);
        return retValErr;
    }
    // [End HdrComposeSupported]
    // [Start HdrComposeCreate]
    OH_ImageProcessing *instance = nullptr;
    ret = OH_ImageProcessing_Create(&instance, IMAGE_PROCESSING_TYPE_COMPOSITION);
    // [End HdrComposeCreate]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Create err");
    }
    // [Start HdrComposeCompose]
    ret = OH_ImageProcessing_Compose(instance, sdr, gainmap, hdr);
    // [End HdrComposeCompose]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Compose err");
    }
    // [Start HdrComposeDestroy]
    ret = OH_ImageProcessing_Destroy(instance);
    // [End HdrComposeDestroy]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Compose err");
    }
    // [Start HdrComposeDeinitializeEnvironment]
    ret = OH_ImageProcessing_DeinitializeEnvironment();
    // [End HdrComposeDeinitializeEnvironment]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Compose err");
    }
    napi_value retVal;
    napi_create_int32(env, ret, &retVal);
    return retVal;
}

napi_value ImageProcessing::HdrDecompose(napi_env env, napi_callback_info info)
{
    napi_value thisVar = nullptr;
    napi_value argValue[6] = {0};
    size_t argCount = 6;
    size_t count = 3;
    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < count ||
        argValue[0] == nullptr || argValue[1] == nullptr) {
        return nullptr;
    }
    // [Start HdrDecompose]
    OH_PixelmapNative *sdr = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[0], &sdr);
    OH_PixelmapNative *gainmap = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[1], &gainmap);
    OH_PixelmapNative *hdr = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[2], &hdr);
    // [End HdrDecompose]
    // [Start HdrDecomposeInitializeEnvironment]
    ImageProcessing_ErrorCode ret = OH_ImageProcessing_InitializeEnvironment();
    // [End HdrDecomposeInitializeEnvironment]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap",
            "OH_ImageProcessing_InitializeEnvironment err");
    }
    // [Start HdrDecomposeSupported]
    // Input format.
    ImageProcessing_ColorSpaceInfo SRC_INFO;
    ImageProcessing_ColorSpaceInfo DST_GAIN_INFO;
    ImageProcessing_ColorSpaceInfo DST_INFO;
    SRC_INFO.colorSpace = BT2020_HLG;
    SRC_INFO.metadataType = HDR_METADATA_TYPE_ALTERNATE;
    SRC_INFO.pixelFormat = PIXEL_FORMAT_RGBA_1010102;
    DST_INFO.colorSpace = DISPLAY_P3;
    DST_INFO.metadataType = HDR_METADATA_TYPE_BASE;
    DST_INFO.pixelFormat = PIXEL_FORMAT_RGBA_8888;
    DST_GAIN_INFO.colorSpace = DISPLAY_P3;
    DST_GAIN_INFO.metadataType = HDR_METADATA_TYPE_GAINMAP;
    DST_GAIN_INFO.pixelFormat = PIXEL_FORMAT_RGBA_8888;
    // Ability inquiry.
    bool flag = OH_ImageProcessing_IsDecompositionSupported(&SRC_INFO, &DST_INFO, &DST_GAIN_INFO);
    // [End HdrDecomposeSupported]
    if (!flag) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "not supported err");
        napi_value retValErr;
        napi_create_int32(env, -1, &retValErr);
        return retValErr;
    }
    // [Start HdrDecomposeCreate]
    OH_ImageProcessing *instance = nullptr;
    ret = OH_ImageProcessing_Create(&instance, IMAGE_PROCESSING_TYPE_DECOMPOSITION);
    // [End HdrDecomposeCreate]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Create err");
    }
    // [Start HdrDecomposeDecompose]
    ret = OH_ImageProcessing_Decompose(instance, hdr, sdr, gainmap);
    // [End HdrDecomposeDecompose]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Decompose err");
    }
    // [Start HdrDecomposeDestroy]
    ret = OH_ImageProcessing_Destroy(instance);
    // [End HdrDecomposeDestroy]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Destroy err");
    }
    // [Start HdrDecomposeDeinitializeEnvironment]
    ret = OH_ImageProcessing_DeinitializeEnvironment();
    // [End HdrDecomposeDeinitializeEnvironment]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap",
            "OH_ImageProcessing_DeinitializeEnvironment err");
    }
    napi_value retVal;
    napi_create_int32(env, ret, &retVal);
    return retVal;
}

napi_value ImageProcessing::GenerateMetadata(napi_env env, napi_callback_info info)
{
    napi_value thisVar = nullptr;
    napi_value argValue[1] = {0};
    size_t argCount = 1;
    size_t count = 1;
    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < count ||
        argValue[0] == nullptr) {
        return nullptr;
    }
    // [Start GenerateMetadataConvert]
    OH_PixelmapNative *srcImg = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[0], &srcImg);
    // [End GenerateMetadataConvert]
    OH_Pixelmap_ImageInfo *dstInfo = nullptr;
    OH_PixelmapImageInfo_Create(&dstInfo);
    Image_ErrorCode ret = OH_PixelmapNative_GetImageInfo(srcImg, dstInfo);
    if (ret != IMAGE_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_PixelmapNative_GetImageInfo err");
    }
    uint32_t dstImgWidth = 0;
    uint32_t dstImgHeight = 0;
    ret = OH_PixelmapImageInfo_GetWidth(dstInfo, &dstImgWidth);
    if (ret != IMAGE_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_PixelmapNative_GetImageInfo err");
    }
    ret = OH_PixelmapImageInfo_GetHeight(dstInfo, &dstImgHeight);
    if (ret != IMAGE_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_PixelmapNative_GetImageInfo err");
    }
    // [Start GenerateMetadataInitializeEnvironment]
    ImageProcessing_ErrorCode ret1 = OH_ImageProcessing_InitializeEnvironment();
    // [End GenerateMetadataInitializeEnvironment]
    if (ret1 != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap",
            "OH_ImageProcessing_InitializeEnvironment err");
    }
    // [Start GenerateMetadataSupported]
    // Input format.
    ImageProcessing_ColorSpaceInfo SRC_INFO;
    SRC_INFO.colorSpace = BT2020_HLG;
    SRC_INFO.metadataType = HDR_METADATA_TYPE_ALTERNATE;
    SRC_INFO.pixelFormat = PIXEL_FORMAT_RGBA_1010102;
    // Ability inquiry.
    bool flag = OH_ImageProcessing_IsMetadataGenerationSupported(&SRC_INFO);
    // [End GenerateMetadataSupported]
    if (!flag) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "not supported err");
        napi_value retValErr;
        napi_create_int32(env, -1, &retValErr);
        return retValErr;
    }
    // [Start GenerateMetadataCreate]
    OH_ImageProcessing *instance = nullptr;
    ret1 = OH_ImageProcessing_Create(&instance, IMAGE_PROCESSING_TYPE_METADATA_GENERATION);
    // [End GenerateMetadataCreate]
    if (ret1 != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_PixelmapNative_GetImageInfo err");
    }
    // [Start GenerateMetadata]
    ret1 = OH_ImageProcessing_GenerateMetadata(instance, srcImg);
    // [End GenerateMetadata]
    if (ret1 != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_GenerateMetadata err");
    }
    // [Start GenerateMetadataDestroy]
    ret1 = OH_ImageProcessing_Destroy(instance);
    // [End GenerateMetadataDestroy]
    if (ret1 != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Destroy err");
    }
    // [Start GenerateMetadataDeinitializeEnvironment]
    ret1 = OH_ImageProcessing_DeinitializeEnvironment();
    // [End GenerateMetadataDeinitializeEnvironment]
    napi_value retVal;
    napi_create_int32(env, ret, &retVal);
    return retVal;
}

napi_value ImageProcessing::hdrAIHDR(napi_env env, napi_callback_info info)
{
    napi_value thisVar = nullptr;
    napi_value argValue[2] = {0};
    size_t argCount = 2;
    size_t count = 2;
    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < count ||
        argValue[0] == nullptr || argValue[1] == nullptr) {
        return nullptr;
    }
    OH_PixelmapNative *sdr = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[0], &sdr);
    OH_PixelmapNative *hdr = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[1], &hdr);
    OH_ImageProcessing_InitializeEnvironment();
    OH_ImageProcessing *instance = nullptr;
    ImageProcessing_ErrorCode ret = OH_ImageProcessing_Create(&instance, IMAGE_PROCESSING_TYPE_COLOR_SPACE_CONVERSION);
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Create err");
    }
    ret = OH_ImageProcessing_ConvertColorSpace(instance, sdr, hdr);
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap",
            "OH_ImageProcessing_ConvertColorSpace err");
    }
    OH_ImageProcessing_Destroy(instance);
    OH_ImageProcessing_DeinitializeEnvironment();
    napi_value retVal;
    napi_create_int32(env, ret, &retVal);
    return retVal;
}

ImageProcessing_ErrorCode processImageQuality(OH_PixelmapNative *src, OH_PixelmapNative *dst, int level)
{
    OH_ImageProcessing *instance = nullptr;
    // [Start processImageQualityInitializeEnvironment]
    ImageProcessing_ErrorCode ret = OH_ImageProcessing_InitializeEnvironment();
    // [End processImageQualityInitializeEnvironment]
    // [Start processImageQualityCreate]
    ret = OH_ImageProcessing_Create(&instance, IMAGE_PROCESSING_TYPE_DETAIL_ENHANCER);
    // [End processImageQualityCreate]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Create err");
    }
    // [Start processImageQualitySetIntValue]
    OH_AVFormat *parameter = OH_AVFormat_Create();
    if (level == 0) {
        OH_AVFormat_SetIntValue(parameter, IMAGE_DETAIL_ENHANCER_PARAMETER_KEY_QUALITY_LEVEL,
            IMAGE_DETAIL_ENHANCER_QUALITY_LEVEL_NONE);
    }
    if (level == 1) {
        OH_AVFormat_SetIntValue(parameter, IMAGE_DETAIL_ENHANCER_PARAMETER_KEY_QUALITY_LEVEL,
            IMAGE_DETAIL_ENHANCER_QUALITY_LEVEL_LOW);
    }
    if (level == 2) {
        OH_AVFormat_SetIntValue(parameter, IMAGE_DETAIL_ENHANCER_PARAMETER_KEY_QUALITY_LEVEL,
            IMAGE_DETAIL_ENHANCER_QUALITY_LEVEL_MEDIUM);
    }
    if (level == 3) {
        OH_AVFormat_SetIntValue(parameter, IMAGE_DETAIL_ENHANCER_PARAMETER_KEY_QUALITY_LEVEL,
            IMAGE_DETAIL_ENHANCER_QUALITY_LEVEL_HIGH);
    }
    ret = OH_ImageProcessing_SetParameter(instance, parameter);
    // [End processImageQualitySetIntValue]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_SetParameter err");
    }
    // [Start processImageQualityEnhanceDetail]
    ret = OH_ImageProcessing_EnhanceDetail(instance, src, dst);
    // [End processImageQualityEnhanceDetail]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_EnhanceDetail err");
    }
    // [Start processImageQualityDestroy]
    ret = OH_ImageProcessing_Destroy(instance);
    // [End processImageQualityDestroy]
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Destroy err");
    }
    // [Start processImageQualityDeinitializeEnvironment]
    OH_ImageProcessing_DeinitializeEnvironment();
    // [End processImageQualityDeinitializeEnvironment]
    return IMAGE_PROCESSING_SUCCESS;
}

napi_value ImageProcessing::DetailEnhance(napi_env env, napi_callback_info info)
{
    napi_value thisVar = nullptr;
    napi_value argValue[5] = {0};
    size_t argCount = 5;
    size_t count = 2;
    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < count ||
        argValue[0] == nullptr) {
        return nullptr;
    }
    OH_PixelmapNative *srcImg = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[0], &srcImg);
    OH_PixelmapNative *dstImg = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[1], &dstImg);
    int level = 0;
    napi_get_value_int32(env, argValue[4], &level);
    if (processImageQuality(srcImg, dstImg, level) != IMAGE_PROCESSING_SUCCESS) {
        return nullptr;
    }
    napi_value pixelmapNapi = nullptr;
    if (OH_PixelmapNative_ConvertPixelmapNativeToNapi(env, dstImg, &pixelmapNapi) != IMAGE_SUCCESS) {
        return nullptr;
    }
    return pixelmapNapi;
}