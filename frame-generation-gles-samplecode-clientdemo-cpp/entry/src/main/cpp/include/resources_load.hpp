/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef RESOURCES_LOAD_H
#define RESOURCES_LOAD_H
#define SHARED_PTR std::shared_ptr
#include <js_native_api.h>
#include <multimedia/image_framework/image_source_mdk.h>
#include <multimedia/image_framework/image_pixel_map_mdk.h>
#include <GLES3/gl3.h>
#include <rawfile/raw_file_manager.h>
#include "core.hpp"

#include "log.hpp"

namespace FrameGeneration {
using ImageParam = struct ImageParam {
    napi_env env;
    int32_t fd;
    ImageSourceNative *imageSource = nullptr;
    NativePixelMap *pixelMap = nullptr;
    uint8_t *buffer;
};

struct PicInfo {
    uint32_t width;
    uint32_t height;
    uint32_t stride;
    GLubyte *imageBuffer;
    int32_t pixelFormZat;
};

using Image = PicInfo;
NativeResourceManager *mgr;
int64_t buffer_length;

char *ReadRawFile(const std::string &rawPath)
{
    mgr = Core::GetInstance()->GetResourceManager();

    char *buffer;
    auto srcFile = OH_ResourceManager_OpenRawFile(mgr, rawPath.c_str());
    if (srcFile == nullptr) {
        GOLOGE("OH_ResourceManager_OpenRawFile(%s) failed.", rawPath.c_str());
        return nullptr;
    }

    int srcFileSize = OH_ResourceManager_GetRawFileSize(srcFile);
    buffer_length = srcFileSize;
    int realReadBytes = 0;
    GOLOGI("ReadRawFile rawfile(%{public}s)  file size: %d.", rawPath.c_str(), srcFileSize);
    do {
        buffer = new char[srcFileSize];
        if (buffer == nullptr) {
            GOLOGE("alloc mem for read rawfile(%{public}s) failed, file size: %d.", rawPath.c_str(), srcFileSize);
            break;
        }

        realReadBytes = OH_ResourceManager_ReadRawFile(srcFile, buffer, srcFileSize);

        GOLOGI("ReadRawFile rawfile(%{public}s)  realReadBytes: %d.", rawPath.c_str(), realReadBytes);

        if (srcFileSize != realReadBytes) {
            GOLOGE("OH_ResourceManager_ReadRawFile(%s) failed, file size: %d, real read: %d.", rawPath.c_str(),
                srcFileSize, realReadBytes);
            break;
        }
    } while (false);

    OH_ResourceManager_CloseRawFile(srcFile);

    return buffer;
}

void DecodeJepg(ImageParam *data)
{
    struct OhosImageSource source = {
        .buffer = data->buffer,
        .bufferSize = static_cast<size_t>(buffer_length)
    };
    napi_value imageSource = nullptr;
    GOLOGI("before Image decoder create");
    auto ret = OH_ImageSource_Create(data->env, &source, nullptr, &imageSource);
    GOLOGI("end Image decoder create");
    if (ret != 0) {
        GOLOGE("Image decoder create image source failed. %d.", ret);
        return;
    }
    data->imageSource = OH_ImageSource_InitNative(data->env, imageSource);
    if (data->imageSource == nullptr) {
        GOLOGE("Image decoder failed. image source is null");
        return;
    }
    struct OhosImageDecodingOps decodeOps = {};
    napi_value pixelMap = nullptr;
    ret = OH_ImageSource_CreatePixelMap(data->imageSource, &decodeOps, &pixelMap);
    if (ret != 0 || pixelMap == nullptr) {
        GOLOGE("Image decoder create pixel map failed. %d.", ret);
        return;
    }

    data->pixelMap = OH_PixelMap_InitNativePixelMap(data->env, pixelMap);
    if (data->pixelMap == nullptr) {
        GOLOGE("Image decoder init pixel map failed.");
        return;
    }
}

ImageParam *GetParam(uint8_t *buffer)
{
    if (!Core::GetInstance()->GetEnv()) {
        GOLOGE("Image decoder env is null");
        return nullptr;
    }

    GOLOGI("data buffer:%s", buffer);
    ImageParam *param = new (std::nothrow) ImageParam{
        .env = Core::GetInstance()->GetEnv(),
        .buffer = buffer
    };
    if (param == nullptr) {
        return nullptr;
    }

    return param;
}

const uint32_t PIXEL_LENGTH_RGBA8888 = 3;
SHARED_PTR<Image> Decode(uint8_t *buffer)
{
    ImageParam *param = GetParam(buffer);
    DecodeJepg(param);

    GOLOGI("Image decoder wait sucess");
    //    delete work;
    if (param->pixelMap == nullptr) {
        GOLOGE("Image decoder pixelMap is null.");
        return nullptr;
    }

    OhosPixelMapInfos pixelmapInfo;
    auto ret = OH_PixelMap_GetImageInfo(param->pixelMap, &pixelmapInfo);
    if (ret != 0) {
        GOLOGE("Image decoder get image info failed. %d.", ret);
        delete param;
        return nullptr;
    }

    void *addrPtr = nullptr;
    ret = OH_PixelMap_AccessPixels(param->pixelMap, &addrPtr);
    if (ret != 0 || addrPtr == nullptr) {
        GOLOGE("Image decoder access pixel failed. %d.", ret);
        delete param;
        return nullptr;
    }

    OH_ImageSource_Release(param->imageSource);
    auto image = new (std::nothrow) Image();
    if (!image) {
        GOLOGE("Image decoder failed, image is null");
        delete param;
        return nullptr;
    }
    image->width = pixelmapInfo.width;
    image->height = pixelmapInfo.height;
    image->imageBuffer = (GLubyte *)addrPtr;
    image->stride = pixelmapInfo.rowSize / PIXEL_LENGTH_RGBA8888;
    image->pixelFormZat = pixelmapInfo.pixelFormat;
    auto pixelMap = param->pixelMap;
    delete param;

    ret = OH_PixelMap_UnAccessPixels(pixelMap);
    if (ret != IMAGE_RESULT_SUCCESS) {
        GOLOGE("UnAccessPixels Failed");
    }

    GOLOGI("Image decoder finish w=%{public}d,h = %d,fmt: %d.", pixelmapInfo.width, pixelmapInfo.height,
        pixelmapInfo.pixelFormat);
    return SHARED_PTR<Image>(image);
}
} // namespace FrameGeneration
#endif // RESOURCES_LOAD_H