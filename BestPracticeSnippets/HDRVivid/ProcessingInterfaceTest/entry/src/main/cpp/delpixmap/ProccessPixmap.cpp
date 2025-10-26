#include "napi/native_api.h"
#include <cstddef>
#include <multimedia/image_framework/image_mdk_common.h>
#include <multimedia/image_framework/image_pixel_map_mdk.h>
#include <multimedia/image_framework/image/pixelmap_native.h>
#include "multimedia/video_processing_engine/image_processing.h"
#include "multimedia/video_processing_engine/image_processing_types.h"
#include <stdlib.h>
#include <hilog/log.h>
#include <chrono>
#include <string>
#undef LOG_TAG
#define LOG_TAG "PixelMapTest"
constexpr uint32_t LOG_PRINT_DOMAIN = 0xFF00;
void *buff = nullptr;

napi_value CreateAlphaPixelMap(napi_env env, napi_callback_info info) {
    napi_value udfVar = nullptr;
    napi_value thisVar = nullptr;
    napi_value argValue[1] = {0};
    size_t argCount = 1;

    napi_value alphaPixelMap = nullptr;

    napi_get_undefined(env, &udfVar);

    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < 1 ||
        argValue[0] == nullptr) {
        return udfVar;
    }
    int32_t res = OH_PixelMap_CreateAlphaPixelMap(env, argValue[0], &alphaPixelMap);
    if (res != IMAGE_RESULT_SUCCESS || alphaPixelMap == nullptr) {
        return udfVar;
    }
    return alphaPixelMap;
}

napi_value CreatePixelMapTest(napi_env env, napi_callback_info info) {
    napi_value udfVar = nullptr;
    napi_value pixelMap = nullptr;
    napi_value thisVar = nullptr;
    napi_value argValue[2] = {0};
    size_t argCount = 2;
    
    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < 2 ||
        argValue[0] == nullptr || argValue[1] == nullptr  ) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "CreatePixelMapTest", "CreatePixelMapTest start %{public}u,%{public}u", argValue[0], argValue[1]);
        return nullptr;
    }
    int32_t width = 0;
    int32_t height = 0;
    napi_get_value_int32(env, argValue[1], &width);
    napi_get_value_int32(env, argValue[0], &height);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "CreatePixelMapTest", "CreatePixelMapTest start %{public}d,%{public}d", width, height);
    struct OhosPixelMapCreateOps createOps;
    createOps.width = width;
    createOps.height = height;
    createOps.pixelFormat = 3;
    createOps.alphaType = 0;
    size_t bufferSize = createOps.width * createOps.height * 4;
    static bool isFirst = true;
    if (isFirst) {
        buff = malloc(bufferSize);
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "CreatePixelMapTest", "aaaaaa");
        isFirst = false;
    }
    
    char *cc = (char *)buff;
    for (int i = 0; i < 96; i++) {
        *(cc++) = (char)i;
    }
   
    int32_t res = OH_PixelMap_CreatePixelMapWithStride(env, createOps, (uint8_t *)buff, bufferSize,createOps.width *4, &pixelMap);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "CreatePixelMapTest","OH_PixelMap_CreatePixelMapWithStride %{public}d",res);
    if (res != IMAGE_RESULT_SUCCESS || pixelMap == nullptr) {
        return udfVar;
    }
    return pixelMap;
}

void CreatePixmap(OH_PixelmapNative** pixelMap,uint8_t *data, int32_t width, int32_t height, int format){
    
    OH_Pixelmap_InitializationOptions* options = nullptr;
    OH_PixelmapInitializationOptions_Create(&options);
    OH_PixelmapInitializationOptions_SetWidth(options, width);
    OH_PixelmapInitializationOptions_SetHeight(options, height);
    OH_PixelmapInitializationOptions_SetPixelFormat(options, format);
    OH_PixelmapInitializationOptions_SetAlphaType(options, PIXELMAP_ALPHA_TYPE_UNKNOWN);
    OH_PixelmapNative_CreatePixelmap(data, width * height * 4, options, pixelMap);
    
    OH_PixelmapNative_Scale(*pixelMap, 1, 1);
    OH_Pixelmap_ImageInfo* dstInfo = nullptr;
    OH_PixelmapImageInfo_Create(&dstInfo);
    Image_ErrorCode ret = OH_PixelmapNative_GetImageInfo(*pixelMap, dstInfo);
    uint32_t dstImgWidth = 0;
    uint32_t dstImgHeight = 0;
    ret = OH_PixelmapImageInfo_GetWidth(dstInfo,&dstImgWidth);
    
}
void CreatePixmapEmpty(OH_PixelmapNative** pixelMap,int32_t width, int32_t height, int format){
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "NativePixelMap", "NativePixelMap create dst img %d %d",width , height);
    OH_Pixelmap_InitializationOptions* options = nullptr;
    Image_ErrorCode ret =  OH_PixelmapInitializationOptions_Create(&options);
    ret = OH_PixelmapInitializationOptions_SetWidth(options, width);
    ret = OH_PixelmapInitializationOptions_SetHeight(options, height);
    ret = OH_PixelmapInitializationOptions_SetPixelFormat(options, format);
    ret = OH_PixelmapNative_CreateEmptyPixelmap(options, pixelMap);
    ret = OH_PixelmapInitializationOptions_SetAlphaType(options, PIXELMAP_ALPHA_TYPE_UNKNOWN);
    if (ret != IMAGE_SUCCESS) {
         OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "CreatePixmapEmpty err");
    }
}

int processImage(OH_PixelmapNative* src, OH_PixelmapNative* dst){
    OH_ImageProcessing* instance = nullptr;
    ImageProcessing_ErrorCode ret =  OH_ImageProcessing_InitializeEnvironment();
    ret = OH_ImageProcessing_Create(&instance, IMAGE_PROCESSING_TYPE_COLOR_SPACE_CONVERSION);
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Create err");
    }
    auto start = clock();
    ret = OH_ImageProcessing_ConvertColorSpace(instance, src, dst);
    auto end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_ConvertColorSpace %{public}f ms", double(end - start) / 1000);
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_ConvertColorSpace err");
    }
    OH_ImageProcessing_Destroy(instance);
    return ret;
}

napi_value NativeImgToPixmap(napi_env env, napi_callback_info info) {
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "NativePixelMap", "NativeImgToPixmap begin");
    OH_PixelmapNative* srcImg = nullptr;
    CreatePixmapEmpty(&srcImg, 1024, 720, 3);
    napi_value udfVar = nullptr;
    OH_PixelmapNative* dstImg = nullptr;
    CreatePixmapEmpty(&dstImg, 1024, 720, 3);
    processImage(srcImg, dstImg);
    
    OH_PixelmapNative_ConvertPixelmapNativeToNapi(env,srcImg,&udfVar);
    
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "NativePixelMap", "NativeImgToPixmap end");
    return udfVar;
}

napi_value GetNativeImgFromPixmap(napi_env env, napi_callback_info info) {
    
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "NativePixelMap", "GetNativeImgFromPixmap begin");
    napi_value thisVar = nullptr;
    napi_value argValue[4] = {0};
    size_t argCount = 4;
    
    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < 2 ||
        argValue[0] == nullptr || argValue[1] == nullptr  ) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "NativePixelMap", "GetNativeImgFromPixmap start");
        return nullptr;
    }
    OH_PixelmapNative* srcImg = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[0], &srcImg);
    OH_PixelmapNative* dstImg = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[1], &dstImg);
    napi_value ret;
    
    int32_t err = processImage(srcImg, dstImg);
    if (err != 0) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "NativePixelMap", "processImage failed ");
    }
    napi_create_int32(env,err, &ret);
    return ret;
}

napi_value HdrCompose(napi_env env, napi_callback_info info) {
    
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "NativePixelMap", "HdrCompose begin");
    napi_value thisVar = nullptr;
    napi_value argValue[3] = {0};
    size_t argCount = 3;
    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < 3 ||
        argValue[0] == nullptr || argValue[1] == nullptr  ) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "HdrCompose", "HdrCompose start");
        return nullptr;
    }
    OH_PixelmapNative* sdr = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[0], &sdr);
    OH_PixelmapNative* gainmap = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[1], &gainmap);
    OH_PixelmapNative* hdr = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[2], &hdr);
    auto start = clock();
    OH_ImageProcessing_InitializeEnvironment();
    auto end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_InitializeEnvironment %{public}f ms", double(end - start) / 1000);
    OH_ImageProcessing* instance = nullptr;
    start = clock();
    ImageProcessing_ErrorCode ret = OH_ImageProcessing_Create(&instance, IMAGE_PROCESSING_TYPE_COMPOSITION);
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_Create compose %{public}f ms", double(end - start) / 1000);
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Create err");
    }
    start = clock();
    ret = OH_ImageProcessing_Compose(instance, sdr, gainmap, hdr);
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_Compose %{public}f ms", double(end - start) / 1000);
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Compose err %{public}d", ret);
    }
    start = clock();
    OH_ImageProcessing_Destroy(instance);
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_Destroy %{public}f ms", double(end - start) / 1000);
    start = clock();
    OH_ImageProcessing_DeinitializeEnvironment();
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_DeinitializeEnvironment %{public}f ms", double(end - start) / 1000);
    napi_value retVal;
    napi_create_int32(env, ret, &retVal);
    return retVal;
}

napi_value HdrDecompose(napi_env env, napi_callback_info info) {
    
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "NativePixelMap", "HdrDecompose begin");
    napi_value thisVar = nullptr;
    napi_value argValue[6] = {0};
    size_t argCount = 6;
    
    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < 3 ||
        argValue[0] == nullptr || argValue[1] == nullptr  ) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Decompose start");
        return nullptr;
    }

    OH_PixelmapNative* sdr = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[0], &sdr);
    OH_PixelmapNative* gainmap = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[1], &gainmap);
    OH_PixelmapNative* hdr = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[2], &hdr);
    
    OH_ImageProcessing* instance = nullptr;
    auto start = clock();
    ImageProcessing_ErrorCode ret =  OH_ImageProcessing_InitializeEnvironment();
    auto end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_InitializeEnvironment %{public}f ms", double(end - start) / 1000);
    start = clock();
    ret = OH_ImageProcessing_Create(&instance, IMAGE_PROCESSING_TYPE_DECOMPOSITION);
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_Create decompose %{public}f ms", double(end - start) / 1000);
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "HdrDecompose err");
    }
    start = clock();
    ret = OH_ImageProcessing_Decompose(instance, hdr, sdr, gainmap);
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_DeCompose %{public}f ms", double(end - start) / 1000);
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "HdrDecompose err %{public}d", ret);
    }
    start = clock();
    OH_ImageProcessing_Destroy(instance);
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_Destroy %{public}f ms", double(end - start) / 1000);
    start = clock();
    OH_ImageProcessing_DeinitializeEnvironment();
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_DeinitializeEnvironment %{public}f ms", double(end - start) / 1000);
    napi_value retVal;
    napi_create_int32(env, ret, &retVal);
    return retVal;
}

napi_value GenerateMetadata(napi_env env, napi_callback_info info) {
    
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "NativePixelMap", "MetadataGeneration begin");
    napi_value thisVar = nullptr;
    napi_value argValue[1] = {0};
    size_t argCount = 1;
    
    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < 1 ||
        argValue[0] == nullptr ) {
        return nullptr;
    }
    OH_PixelmapNative* srcImg = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env,argValue[0], &srcImg);
    OH_Pixelmap_ImageInfo* dstInfo = nullptr;
    OH_PixelmapImageInfo_Create(&dstInfo);
    Image_ErrorCode ret = OH_PixelmapNative_GetImageInfo(srcImg, dstInfo);
    if (ret != IMAGE_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "NativePixelMap  OH_PixelmapNative_GetImageInfo err");
    }
    uint32_t dstImgWidth = 0;
    uint32_t dstImgHeight = 0;
    ret = OH_PixelmapImageInfo_GetWidth(dstInfo, &dstImgWidth);
    if (ret != IMAGE_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_PixelmapImageInfo_GetWidth err");
    }
    ret = OH_PixelmapImageInfo_GetHeight(dstInfo, &dstImgHeight);
    if (ret != IMAGE_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_PixelmapImageInfo_GetHeight err");
    }
    OH_ImageProcessing* instance = nullptr;
    auto start = clock();
    ImageProcessing_ErrorCode ret1 =  OH_ImageProcessing_InitializeEnvironment();
    auto end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_InitializeEnvironment %{public}f ms", double(end - start) / 1000);
    start = clock();
    ret1 = OH_ImageProcessing_Create(&instance, IMAGE_PROCESSING_TYPE_METADATA_GENERATION);
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_Create metadatagen %{public}f ms", double(end - start) / 1000);
    if (ret1 != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Create err");
    }
    start = clock();
    ret1 = OH_ImageProcessing_GenerateMetadata(instance, srcImg);
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_GenerateMetadata %{public}f ms", double(end - start) / 1000);
    if (ret1 != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_GenerateMetadata err %{public}d", ret1);
    }
    start = clock();
    OH_ImageProcessing_Destroy(instance);
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_Destroy %{public}f ms", double(end - start) / 1000);
    start = clock();
    OH_ImageProcessing_DeinitializeEnvironment();
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_DeinitializeEnvironment %{public}f ms", double(end - start) / 1000);
    napi_value retVal;
    napi_create_int32(env, ret1, &retVal);
    return retVal;
}

napi_value hdrAIHDR(napi_env env, napi_callback_info info) {
    
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "NativePixelMap", "hdrAIHDR hdrAIHDR begin");
    napi_value thisVar = nullptr;
    napi_value argValue[2] = {0};
    size_t argCount = 2;
    
    if (napi_get_cb_info(env, info, &argCount, argValue, &thisVar, nullptr) != napi_ok || argCount < 2 ||
        argValue[0] == nullptr || argValue[1] == nullptr  ) {
        OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Decompose start");
        return nullptr;
    }
    OH_PixelmapNative* sdr = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[0], &sdr);
    OH_PixelmapNative* hdr = nullptr;
    OH_PixelmapNative_ConvertPixelmapNativeFromNapi(env, argValue[1], &hdr);
    ImageProcessing_ErrorCode ret =  OH_ImageProcessing_InitializeEnvironment();
    
    OH_ImageProcessing* instance1 = nullptr;
    auto start = clock();
    ret = OH_ImageProcessing_Create(&instance1, IMAGE_PROCESSING_TYPE_COLOR_SPACE_CONVERSION);
    auto end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_Create colorsapce conversion  %{public}f ms", double(end - start) / 1000);
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_Create err");
    }
    start = clock();
    ret = OH_ImageProcessing_ConvertColorSpace(instance1, sdr, hdr);
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_ConvertColorSpace aihdr  %{public}f ms", double(end - start) / 1000);
    if (ret != IMAGE_PROCESSING_SUCCESS) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "NativePixelMap", "OH_ImageProcessing_ConvertColorSpace err %{public}d", ret);
    }
    start = clock();
    OH_ImageProcessing_Destroy(instance1);
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_Destroy  %{public}f ms", double(end - start) / 1000);
    start = clock();
    OH_ImageProcessing_DeinitializeEnvironment();
    end = clock();
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "api time", "OH_ImageProcessing_DeinitializeEnvironment  %{public}f ms", double(end - start) / 1000);
    return nullptr;
}


EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "createPixelMapTest", nullptr, CreatePixelMapTest, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "createAlphaPixelMap", nullptr, CreateAlphaPixelMap, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "nativeImgToPixmap", nullptr, NativeImgToPixmap, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "getNativeImgFromPixmap", nullptr, GetNativeImgFromPixmap, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "GenerateMetadata", nullptr, GenerateMetadata, nullptr, nullptr, nullptr, napi_default, nullptr},
        { "hdrCompose", nullptr, HdrCompose, nullptr, nullptr, nullptr, napi_default, nullptr},
        { "hdrDecompose", nullptr, HdrDecompose, nullptr, nullptr, nullptr, napi_default, nullptr},
        { "hdrAIHDR", nullptr, hdrAIHDR, nullptr, nullptr, nullptr, napi_default, nullptr},
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
    .nm_modname = "delpixmap",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
