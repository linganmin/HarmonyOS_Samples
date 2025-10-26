/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef HELLO_VULKAN_AASSETIMPORTER_H
#define HELLO_VULKAN_AASSETIMPORTER_H

#include <rawfile/raw_file_manager.h>
#include <string>
#include <optional>
#include <vector>
#include <array>
#include <vulkan/vulkan.h>
#include "Singleton.hpp"
#include "glm/vec3.hpp"
#include "glm/vec2.hpp"
#include "glm/vec4.hpp"
#include "glm/mat4x4.hpp"

namespace VulkanFG {
constexpr static uint32_t s_instanceWidth = 10;
constexpr static uint32_t s_instanceLength = 10;
constexpr static uint32_t s_instanceNum = s_instanceWidth * s_instanceLength;
constexpr uint32_t NUMBER_TWO = 2;
constexpr uint32_t NUMBER_THREE = 3;
constexpr uint32_t NUMBER_FOUR = 4;
constexpr uint32_t NUMBER_FIVE = 5;

typedef struct VertexUniformBuffer {
    alignas(16) glm::mat4 modelTransform[s_instanceNum];
    alignas(16) glm::mat4 viewTransform;
    alignas(16) glm::mat4 perspectiveTransform;
    alignas(16) glm::mat4 vpTransform;
    alignas(16) glm::vec4 diffuseColor;
} VertexUniformBuffer;

typedef struct FragmentUniformBuffer {
    alignas(16) glm::vec3 g_AmbientLightColor;
    alignas(16) glm::vec3 g_SpotLightColor;
    alignas(16) glm::vec3 g_SpotLightLocation;
} FragmentUniformBuffer;

#pragma pack(push)
#pragma pack(1)
struct NativeMeshHeader {
    uint32_t vetexNum;
    uint64_t vertexBufferOffset;
};

struct VertexInfo {
    glm::vec3 position;
    glm::vec2 uv;
    glm::vec3 normal;
    glm::vec3 tangent;
    glm::vec3 bitangent;

    static VkVertexInputBindingDescription GetBindingDescription()
    {
        VkVertexInputBindingDescription bindingDescription{};
        bindingDescription.binding = 0;
        bindingDescription.stride = sizeof(VertexInfo);
        bindingDescription.inputRate = VK_VERTEX_INPUT_RATE_VERTEX;

        return bindingDescription;
    }

    static std::array<VkVertexInputAttributeDescription, NUMBER_FIVE> GetAttributeDescriptions()
    {
        std::array<VkVertexInputAttributeDescription, NUMBER_FIVE> attributeDescriptions{};
        attributeDescriptions[0].binding = 0;
        attributeDescriptions[0].location = 0;
        attributeDescriptions[0].format = VK_FORMAT_R32G32B32_SFLOAT;
        attributeDescriptions[0].offset = offsetof(VertexInfo, position);

        attributeDescriptions[1].binding = 0;
        attributeDescriptions[1].location = 1;
        attributeDescriptions[1].format = VK_FORMAT_R32G32_SFLOAT;
        attributeDescriptions[1].offset = offsetof(VertexInfo, uv);

        attributeDescriptions[NUMBER_TWO].binding = 0;
        attributeDescriptions[NUMBER_TWO].location = NUMBER_TWO;
        attributeDescriptions[NUMBER_TWO].format = VK_FORMAT_R32G32B32_SFLOAT;
        attributeDescriptions[NUMBER_TWO].offset = offsetof(VertexInfo, normal);

        attributeDescriptions[NUMBER_THREE].binding = 0;
        attributeDescriptions[NUMBER_THREE].location = NUMBER_THREE;
        attributeDescriptions[NUMBER_THREE].format = VK_FORMAT_R32G32B32_SFLOAT;
        attributeDescriptions[NUMBER_THREE].offset = offsetof(VertexInfo, tangent);

        attributeDescriptions[NUMBER_FOUR].binding = 0;
        attributeDescriptions[NUMBER_FOUR].location = NUMBER_FOUR;
        attributeDescriptions[NUMBER_FOUR].format = VK_FORMAT_R32G32B32_SFLOAT;
        attributeDescriptions[NUMBER_FOUR].offset = offsetof(VertexInfo, bitangent);

        return attributeDescriptions;
    }
};
#pragma pack(pop)

class AAssetImporter : public Singleton<AAssetImporter> {
public:
    enum class AAssetMode {
        AASSET_MODE_UNKNOWN = 0,
        AASSET_MODE_RANDOM = 1,
        AASSET_MODE_STREAMING = 2,
        AASSET_MODE_BUFFER = 3
    };
    typedef struct VertexAttributeAsset {
        uint32_t vertexNum;
        std::vector<VertexInfo> vertexData;
    } VertexAttributeAsset;

    typedef struct ImageAsset {
        enum class Format {
            RGB,
            RGBA
        };
        uint32_t width;
        uint32_t height;
        Format format;
        std::vector<uint8_t> imageData;
    } ImageAsset;

    typedef struct ShaderAsset {
        std::vector<uint8_t> shaderData;
    } ShaderAsset;

    void Init(NativeResourceManager *aAssetMgr);
    std::optional<VertexAttributeAsset> ImportVertexAttributeAsset(const std::string &assetFilePath);
    std::optional<ImageAsset> ImportImageAsset(const std::string &assetFilePath);
    std::optional<ShaderAsset> ImportShaderAsset(const std::string &assetFilePath);

private:
    NativeResourceManager *m_aAssetMgr = nullptr;
};
}


#endif // HELLO_VULKAN_AASSETIMPORTER_H
