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

#include "vulkan_obj_mesh.h"
#include "vulkan_obj_model.h"

vkOBJ::StaticMeshNode::StaticMeshNode(vkOBJ::StaticModel* model, const aiMesh* mesh, vks::VulkanDevice *device)
    : m_model(model), m_materialIndex(mesh->mMaterialIndex), m_device(device)
{
    m_vertexs.resize(mesh->mNumVertices);
    for (unsigned int i = 0; i < mesh->mNumVertices; i++) {
        Vertex vertex;
        glm::vec3 vector;
        vector.x = mesh->mVertices[i].x;
        vector.y = mesh->mVertices[i].y * -1.0f;
        vector.z = mesh->mVertices[i].z;

        vertex.Position = vector;
        if (mesh->HasNormals()) {
            vector.x = mesh->mNormals[i].x;
            vector.y = mesh->mNormals[i].y * -1.0f;
            vector.z = mesh->mNormals[i].z;
            vertex.Normal = vector;
        }
        if (mesh->mTextureCoords[0]) {
            glm::vec2 vec;
            vec.x = mesh->mTextureCoords[0][i].x;
            vec.y = mesh->mTextureCoords[0][i].y;
            vertex.TexCoords = vec;
        }
        if (mesh->mTangents) {
            vector.x = mesh->mTangents[i].x;
            vector.y = mesh->mTangents[i].y;
            vector.z = mesh->mTangents[i].z;
            vertex.Tangent = vector;
        }
        if (mesh->mBitangents) {
            vector.x = mesh->mBitangents[i].x;
            vector.y = mesh->mBitangents[i].y;
            vector.z = mesh->mBitangents[i].z;
            vertex.Bitangent = vector;
        }
        m_vertexs[i] = vertex;
    }
    for (unsigned int i = 0; i < mesh->mNumFaces; i++) {
        aiFace face = mesh->mFaces[i];
        for (unsigned int j = 0; j < face.mNumIndices; j++) {
            m_indices.push_back(face.mIndices[j]);
        }
    }

    vertices.range = sizeof(Vertex) * m_vertexs.size();
    indices.range = sizeof(unsigned int) * m_indices.size();
}

void vkOBJ::StaticMeshNode::InitMeshDescriptors(VkQueue transferQueue)
{
    VK_CHECK_RESULT(m_device->createBuffer(
        VK_BUFFER_USAGE_TRANSFER_SRC_BIT,
        VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
        vertices.range,
        &vertexStaging.buffer,
        &vertexStaging.memory,
        m_vertexs.data()));

    VK_CHECK_RESULT(m_device->createBuffer(
        VK_BUFFER_USAGE_TRANSFER_SRC_BIT,
        VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
        indices.range,
        &indexStaging.buffer,
        &indexStaging.memory,
        m_indices.data()));
    
    VK_CHECK_RESULT(m_device->createBuffer(
        VK_BUFFER_USAGE_VERTEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT | memoryPropertyFlags,
        VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
        vertices.range,
        &vertices.buffer,
        &vertices.memory));
    
    VK_CHECK_RESULT(m_device->createBuffer(
        VK_BUFFER_USAGE_INDEX_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT | memoryPropertyFlags,
        VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT,
        indices.range,
        &indices.buffer,
        &indices.memory));

    VkCommandBuffer copyCmd = m_device->createCommandBuffer(VK_COMMAND_BUFFER_LEVEL_PRIMARY, true);

    VkBufferCopy copyRegion = {};
    copyRegion.size = vertices.range;
    vkCmdCopyBuffer(copyCmd, vertexStaging.buffer, vertices.buffer, 1, &copyRegion);

    copyRegion.size = indices.range;
    vkCmdCopyBuffer(copyCmd, indexStaging.buffer, indices.buffer, 1, &copyRegion);

    m_device->flushCommandBuffer(copyCmd, transferQueue, true);
    
    vkDestroyBuffer(m_device->logicalDevice, vertexStaging.buffer, nullptr);
    vkFreeMemory(m_device->logicalDevice, vertexStaging.memory, nullptr);
    vkDestroyBuffer(m_device->logicalDevice, indexStaging.buffer, nullptr);
    vkFreeMemory(m_device->logicalDevice, indexStaging.memory, nullptr);
    
    if (m_materialIndex >= 0 && m_materialIndex < m_model->m_textures.size() &&
        !m_model->m_textures[m_materialIndex].empty()) {
        auto textures = m_model->m_textures[m_materialIndex];

        VkDescriptorSetAllocateInfo descriptorSetAllocInfo{};
        descriptorSetAllocInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
        descriptorSetAllocInfo.descriptorPool = m_model->m_descriptorPool;
        descriptorSetAllocInfo.pSetLayouts = &m_model->m_descriptorSetLayoutImage;
        descriptorSetAllocInfo.descriptorSetCount = 1;
        VK_CHECK_RESULT(vkAllocateDescriptorSets(m_device->logicalDevice, &descriptorSetAllocInfo, &m_descriptorSet));

        std::vector<VkWriteDescriptorSet> writeDescriptorSets{};
        for (int i = 0; i < textures.size(); i++) {
            VkWriteDescriptorSet writeDescriptorSet{};
            writeDescriptorSet.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
            writeDescriptorSet.descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
            writeDescriptorSet.descriptorCount = 1;
            writeDescriptorSet.dstSet = m_descriptorSet;
            writeDescriptorSet.dstBinding = static_cast<uint32_t>(writeDescriptorSets.size());
            writeDescriptorSet.pImageInfo = &textures[i]->descriptor;
            writeDescriptorSets.push_back(writeDescriptorSet);
        }
        vkUpdateDescriptorSets(m_device->logicalDevice, static_cast<uint32_t>(writeDescriptorSets.size()),
            writeDescriptorSets.data(), 0, nullptr);
    }
}