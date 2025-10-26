/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
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

#ifndef RENDER_VULKAN_OBJ_MESH_H
#define RENDER_VULKAN_OBJ_MESH_H

#include <vector>

#define GLM_FORCE_RADIANS
#define GLM_FORCE_DEPTH_ZERO_TO_ONE
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include "assimp/scene.h"
#include "vulkan/vulkan.h"
#include "VulkanDevice.h"

namespace vkOBJ {
    class StaticModel;

    struct Vertex {
        glm::vec3 Position;
        glm::vec3 Normal;
        glm::vec2 TexCoords;
        glm::vec3 Bitangent;
        glm::vec3 Tangent;
    };

    class StaticMeshNode {
    public:
        StaticMeshNode(StaticModel* model, const aiMesh* mesh, vks::VulkanDevice *device);
        ~StaticMeshNode()
        {
            if (m_device) {
                vkDestroyBuffer(m_device->logicalDevice, vertices.buffer, nullptr);
                vkFreeMemory(m_device->logicalDevice, vertices.memory, nullptr);
                vkDestroyBuffer(m_device->logicalDevice, indices.buffer, nullptr);
                vkFreeMemory(m_device->logicalDevice, indices.memory, nullptr);
            }
            m_vertexs.clear();
            m_indices.clear();
        }
        void CheckResult();
        void InitMeshDescriptors(VkQueue transferQueue);

        struct Vertices {
            int count;
            VkBuffer buffer;
            VkDeviceMemory memory;
            VkDeviceSize    offset;
            VkDeviceSize    range;
        } vertices;

        struct Indices {
            int count;
            VkBuffer buffer;
            VkDeviceMemory memory;
            VkDeviceSize    offset;
            VkDeviceSize    range;
        } indices;

        VkDescriptorSet m_descriptorSet = VK_NULL_HANDLE;

    private:
        VkMemoryPropertyFlags memoryPropertyFlags = 0;
        StaticModel* m_model;
        vks::VulkanDevice *m_device;
        std::vector<Vertex> m_vertexs;
        std::vector<unsigned int> m_indices;
        unsigned int m_materialIndex;
        struct StagingBuffer {
            VkBuffer buffer;
            VkDeviceMemory memory;
        } vertexStaging, indexStaging;
    };
}
#endif // RENDER_VULKAN_OBJ_MESH_H