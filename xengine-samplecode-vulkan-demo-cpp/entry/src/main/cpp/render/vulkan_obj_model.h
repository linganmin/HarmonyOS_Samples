/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef RENDER_VULKAN_OBJ_MODEL_H
#define RENDER_VULKAN_OBJ_MODEL_H

#include <stdlib.h>
#include <string>
#include <fstream>
#include <vector>
#include <sstream>
#include <map>
#include <array>
#define GLM_FORCE_RADIANS
#define GLM_FORCE_DEPTH_ZERO_TO_ONE
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <iostream>
#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include "vulkan/vulkan.h"
#include "VulkanDevice.h"
#include "vulkan_obj_mesh.h"

namespace vkOBJ {
    enum class VertexComponent {Position, Normal, UV};
    static std::vector<aiTextureType> textureTypes = {aiTextureType_DIFFUSE};
    struct Texture {
        vks::VulkanDevice* device = nullptr;
        VkImage image;
        VkImageLayout imageLayout;
        VkDeviceMemory deviceMemory;
        VkImageView view;
        uint32_t width, height;
        uint32_t mipLevels;
        uint32_t layerCount;
        VkDescriptorImageInfo descriptor;
        VkSampler sampler;
        VkDescriptorSet descriptorSet;
        std::string path;
        std::string type;
        void Destory(VkDevice logicalDevice)
        {
            if (logicalDevice) {
                vkDestroyImageView(logicalDevice, view, nullptr);
                vkDestroyImage(logicalDevice, image, nullptr);
                vkFreeMemory(logicalDevice, deviceMemory, nullptr);
                vkDestroySampler(logicalDevice, sampler, nullptr);
                view = VK_NULL_HANDLE;
                image = VK_NULL_HANDLE;
                deviceMemory = VK_NULL_HANDLE;
                sampler = VK_NULL_HANDLE;
            }
        }
    };

    class StaticModel {
        friend class StaticMeshNode;
    public:
        StaticModel() = default;
        StaticModel(vks::VulkanDevice *device):m_device(device) {}
        ~StaticModel()
        {

        }
        void LoadFromFile(std::string filename, vks::VulkanDevice *device, VkQueue transferQueue);
        void Draw(VkCommandBuffer commandBuffer, uint32_t renderFlags, VkPipelineLayout pipelineLayout,
            uint32_t bindImageSet);
        VkDescriptorSetLayout m_descriptorSetLayoutImage;
        void Destory() { ReleaseVulkanResource(); }

    protected:
        void InitVulkanResource(VkQueue transferQueue);
        void InitVulkanTexture(VkQueue copyQueue);
        void GenerateMipmaps(VkImage image, VkFormat imageFormat, int32_t texWidth, int32_t texHeight,
            uint32_t mipLevels);
        void InitVulkanDescriptor(VkQueue copyQueue);
        void ReleaseVulkanResource();

    private:
        void ProcessNode(const aiNode* node, const aiScene* scene);
        void ProcessMaterialTextures(const aiScene* scene);
        VkMemoryPropertyFlags m_memoryPropertyFlags;
        vks::VulkanDevice* m_device;
        VkDescriptorPool m_descriptorPool;
        VkQueue m_transferQueue;
        std::string m_directory;
        std::vector<std::shared_ptr<StaticMeshNode>> m_meshes;
        std::vector<std::vector<std::shared_ptr<Texture>>> m_textures;
        std::map<std::string, std::shared_ptr<Texture>> m_texturesMap;
        uint32_t m_meshCount;
        uint32_t m_maxMipLevels = 8;
    };
}
#endif // RENDER_VULKAN_OBJ_MODEL_H