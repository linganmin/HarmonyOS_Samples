/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "AAssetImporter.h"
#include "log.hpp"
#include <securec.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb/stb_image.h"

namespace VulkanFG {
void AAssetImporter::Init(NativeResourceManager *aAssetMgr)
{
    m_aAssetMgr = aAssetMgr;
}
std::optional<AAssetImporter::VertexAttributeAsset> AAssetImporter::ImportVertexAttributeAsset(
    const std::string &assetFilePath)
{
    std::optional<AAssetImporter::VertexAttributeAsset> asset;
    RawFile *file = OH_ResourceManager_OpenRawFile(m_aAssetMgr, assetFilePath.c_str());
    if (!file) {
        GOLOGE("Open OHOS vertex attribute asset failed!");
        return asset;
    }
    size_t len = static_cast<size_t>(OH_ResourceManager_GetRawFileSize(file));
    if (len < sizeof(NativeMeshHeader)) {
        GOLOGE("OHOS vertex attribute asset len %zu too small!", len);
        return asset;
    }

    asset.emplace();
    VertexAttributeAsset &vertexAsset = asset.value();
    std::vector<uint8_t> rawData(len);
    OH_ResourceManager_ReadRawFile(file, rawData.data(), len);
    OH_ResourceManager_CloseRawFile(file);

    NativeMeshHeader *header = reinterpret_cast<NativeMeshHeader *>(rawData.data());
    vertexAsset.vertexNum = header->vetexNum;
    vertexAsset.vertexData.resize(vertexAsset.vertexNum);
    errno_t rc = memcpy_s(vertexAsset.vertexData.data(), len - header->vertexBufferOffset,
        rawData.data() + header->vertexBufferOffset, len - header->vertexBufferOffset);
    if (rc != EOK) {
        GOLOGI("AAssetImporter memcpy_s failed");
    }
    GOLOGI("OHOS vertex attribute asset %s import Success! Vertex num %u", assetFilePath.c_str(),
        vertexAsset.vertexNum);
    GOLOGI("glm:vec3 size %u, glm:vec2 size %u, vertex info size %u, vertex uniform buffer size %u, fragment uniform "
           "buffer size %u",
        sizeof(glm::vec3), sizeof(glm::vec2), sizeof(VertexInfo), sizeof(VertexUniformBuffer),
        sizeof(FragmentUniformBuffer));
    GOLOGI("f unifor offset1 %u, offset2 %u, offset3 %u", offsetof(FragmentUniformBuffer, g_AmbientLightColor),
        offsetof(FragmentUniformBuffer, g_SpotLightColor), offsetof(FragmentUniformBuffer, g_SpotLightLocation));
    return asset;
}

std::optional<AAssetImporter::ImageAsset> AAssetImporter::ImportImageAsset(const std::string &assetFilePath)
{
    std::optional<AAssetImporter::ImageAsset> asset;
    RawFile *file = OH_ResourceManager_OpenRawFile(m_aAssetMgr, assetFilePath.c_str());
    if (!file) {
        GOLOGE("Open OHOS image asset failed!");
        return asset;
    }

    size_t len = static_cast<size_t>(OH_ResourceManager_GetRawFileSize(file));
    if (len <= 0) {
        GOLOGE("OHOS image asset len %zu too small!", len);
        return asset;
    }

    asset.emplace();
    ImageAsset &imageAsset = asset.value();
    std::vector<uint8_t> rawData(len);
    OH_ResourceManager_ReadRawFile(file, rawData.data(), len);
    OH_ResourceManager_CloseRawFile(file);

    int w = 0;
    int h = 0;
    int comp = 0;
    void *stbiData = stbi_load_from_memory(reinterpret_cast<stbi_uc const *>(rawData.data()), static_cast<int>(len), &w,
        &h, &comp, 0);

    imageAsset.width = w;
    imageAsset.height = h;
    imageAsset.format = comp == NUMBER_THREE ? ImageAsset::Format::RGB : ImageAsset::Format::RGBA;

    size_t imageSizeInBytes = w * h * comp * sizeof(uint8_t);
    imageAsset.imageData.reserve(imageSizeInBytes);
    imageAsset.imageData.resize(imageSizeInBytes);

    errno_t rc = memcpy_s(imageAsset.imageData.data(), imageSizeInBytes, stbiData, imageSizeInBytes);
    if (rc != EOK) {
        GOLOGI("AAssetImporter memcpy_s failed");
    }
    GOLOGI("OHOS image asset %s import Success! w %d h %d comp %d", assetFilePath.c_str(), w, h, comp);
    stbi_image_free(stbiData);
    return asset;
}

std::optional<AAssetImporter::ShaderAsset> AAssetImporter::ImportShaderAsset(const std::string &assetFilePath)
{
    std::optional<AAssetImporter::ShaderAsset> asset;
    RawFile *file = OH_ResourceManager_OpenRawFile(m_aAssetMgr, assetFilePath.c_str());
    if (!file) {
        GOLOGE("Open OHOS shader asset %s failed!", assetFilePath.c_str());
        return asset;
    }
    size_t len = static_cast<size_t>(OH_ResourceManager_GetRawFileSize(file));
    if (len <= 0) {
        GOLOGE("OHOS shader asset %s len %zu too small!", assetFilePath.c_str(), len);
        return asset;
    }

    asset.emplace();
    ShaderAsset &shaderAsset = asset.value();
    shaderAsset.shaderData.resize(len);
    OH_ResourceManager_ReadRawFile(file, shaderAsset.shaderData.data(), len);
    OH_ResourceManager_CloseRawFile(file);

    GOLOGI("OHOS shader asset %s import Success! len %u", assetFilePath.c_str(), len);
    return asset;
}
}