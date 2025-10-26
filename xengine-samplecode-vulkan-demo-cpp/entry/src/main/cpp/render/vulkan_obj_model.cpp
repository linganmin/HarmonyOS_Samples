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

#include "vulkan_obj_model.h"
#include "stb_image.h"
#include "file/file_operator.h"
#include "common/common.h"
void vkOBJ::StaticModel::LoadFromFile(std::string filename, vks::VulkanDevice *device, VkQueue transferQueue)
{
    m_device = device;
    Assimp::Importer importer;
    const aiScene* scene = importer.ReadFile(filename, aiProcess_Triangulate | aiProcess_GenSmoothNormals |
        aiProcess_FlipUVs | aiProcess_CalcTangentSpace);
    if (!scene || scene->mFlags & AI_SCENE_FLAGS_INCOMPLETE || !scene->mRootNode) {
        LOGE("Model Assimp load model failed: %{public}s", importer.GetErrorString());
        return;
    }
    m_transferQueue = transferQueue;
    m_directory = filename.substr(0, filename.find_last_of('/'));
    LOGI("Model  Load model form dir: %{public}s, name is %{public}s", m_directory.c_str(), filename.c_str());
    m_meshCount = scene->mNumMeshes;
    ProcessMaterialTextures(scene);
    ProcessNode(scene->mRootNode, scene);
    InitVulkanResource(transferQueue);
}

void  vkOBJ::StaticModel::ProcessMaterialTextures(const aiScene* scene)
{
    m_textures.resize(scene->mNumMaterials);
    for (int i = 0; i < (scene->mNumMaterials); i++) {
        aiMaterial* material = scene->mMaterials[i];
        for (auto type : textureTypes) {
            for (int j = 0; j < material->GetTextureCount(type); j++) {
                aiString path;
                material->GetTexture(type, j, &path);
                LOGI("Model assimp get texture path is: %{public}s", path.C_Str());
                auto item = m_texturesMap.find(path.C_Str());
                if (item != m_texturesMap.end()) {
                    m_textures[i].push_back(item->second);
                } else {
                    auto texture = std::shared_ptr<Texture>(new Texture, [this](Texture* texture) {
                        if (texture->image != VK_NULL_HANDLE) {
                            vkDestroyImage(m_device->logicalDevice, texture->image, nullptr);
                        }
                        if (texture->view != VK_NULL_HANDLE) {
                            vkDestroyImageView(m_device->logicalDevice, texture->view, nullptr);
                        }
                        if (texture->deviceMemory != VK_NULL_HANDLE) {
                            vkFreeMemory(m_device->logicalDevice, texture->deviceMemory, nullptr);
                        }
                    });
                    texture->path = path.C_Str();
                    texture->type = type;
                    LOGD("Model texture->path is %{public}s", texture->path.c_str());
                    m_textures[i].push_back(texture);
                    m_texturesMap[path.C_Str()] = texture;
                }
            }
        }
    }
}

void vkOBJ::StaticModel::ProcessNode(const aiNode* node, const aiScene* scene)
{
    for (unsigned int i = 0; i < node->mNumMeshes; i++) {
        aiMesh* mesh = scene->mMeshes[node->mMeshes[i]];
        m_meshes.push_back(std::make_shared<StaticMeshNode>(this, mesh, m_device));
    }
    for (unsigned int i = 0; i < node->mNumChildren; i++) {
        ProcessNode(node->mChildren[i], scene);
    }
}

void vkOBJ::StaticModel::InitVulkanResource(VkQueue transferQueue)
{
    InitVulkanTexture(m_transferQueue);
    InitVulkanDescriptor(m_transferQueue);
}

void vkOBJ::StaticModel::InitVulkanTexture(VkQueue copyQueue)
{
    for (auto& textureIter : m_texturesMap) {
        VkCommandBuffer copyCmd = m_device->createCommandBuffer(VK_COMMAND_BUFFER_LEVEL_PRIMARY, true);
        std::shared_ptr<Texture> texture = textureIter.second;
        std::string name = "Sponza/text" + texture->path;
        std::string texturePath = FileOperator::GetInstance()->GetFileAbsolutePath(name);
        int width, height, nrComponents;
        unsigned char *buffer = stbi_load(texturePath.c_str(), &width, &height, &nrComponents, 0);
        VkDeviceSize bufferSize = width * height * nrComponents;
        VkFormat format = nrComponents == 4 ? VK_FORMAT_R8G8B8A8_UNORM : VK_FORMAT_R8G8B8_UNORM;
        VkFormatProperties formatProperties;
        texture->width = width;
        texture->height = height;
        texture->mipLevels = static_cast<uint32_t>(std::floor(std::log2(std::max(width, height)))) + 1;
        VkBool32 useStaging = true;
        
        VkMemoryAllocateInfo memAllocInfo = vks::initializers::memoryAllocateInfo();
        VkMemoryRequirements memReqs{};

        VkBuffer stagingBuffer;
        VkDeviceMemory stagingMemory;

        VkBufferCreateInfo bufferCreateInfo{};
        bufferCreateInfo.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
        bufferCreateInfo.size = bufferSize;
        bufferCreateInfo.usage = VK_BUFFER_USAGE_TRANSFER_SRC_BIT;
        bufferCreateInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE;
        VK_CHECK_RESULT(vkCreateBuffer(m_device->logicalDevice, &bufferCreateInfo, nullptr, &stagingBuffer));

        vkGetBufferMemoryRequirements(m_device->logicalDevice, stagingBuffer, &memReqs);
        memAllocInfo.allocationSize = memReqs.size;
        memAllocInfo.memoryTypeIndex = m_device->getMemoryType(memReqs.memoryTypeBits,
            VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
        VK_CHECK_RESULT(vkAllocateMemory(m_device->logicalDevice, &memAllocInfo, nullptr, &stagingMemory));
        VK_CHECK_RESULT(vkBindBufferMemory(m_device->logicalDevice, stagingBuffer, stagingMemory, 0));

        uint8_t* data;
        uint64_t size =  memReqs.size;
        VK_CHECK_RESULT(vkMapMemory(m_device->logicalDevice, stagingMemory, 0, memReqs.size, 0, (void**)&data));
        memcpy(data, buffer, bufferSize);
        vkUnmapMemory(m_device->logicalDevice, stagingMemory);
        stbi_image_free(buffer);

        VkImageCreateInfo imageCreateInfo{};
        imageCreateInfo.sType = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO;
        imageCreateInfo.imageType = VK_IMAGE_TYPE_2D;
        imageCreateInfo.format = format;
        imageCreateInfo.mipLevels = texture->mipLevels;
        imageCreateInfo.arrayLayers = 1;
        imageCreateInfo.samples = VK_SAMPLE_COUNT_1_BIT;
        imageCreateInfo.tiling = VK_IMAGE_TILING_OPTIMAL;
        imageCreateInfo.usage = VK_IMAGE_USAGE_SAMPLED_BIT;
        imageCreateInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE;
        imageCreateInfo.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
        imageCreateInfo.extent = { (uint32_t)width, (uint32_t)height, 1 };
        imageCreateInfo.usage = VK_IMAGE_USAGE_TRANSFER_DST_BIT | VK_IMAGE_USAGE_TRANSFER_SRC_BIT |
            VK_IMAGE_USAGE_SAMPLED_BIT;

        VK_CHECK_RESULT(vkCreateImage(m_device->logicalDevice, &imageCreateInfo, nullptr, &texture->image));

        vkGetImageMemoryRequirements(m_device->logicalDevice, texture->image, &memReqs);
        memAllocInfo.allocationSize = memReqs.size;
        memAllocInfo.memoryTypeIndex = m_device->getMemoryType(memReqs.memoryTypeBits,
            VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
        VK_CHECK_RESULT(vkAllocateMemory(m_device->logicalDevice, &memAllocInfo, nullptr, &texture->deviceMemory));
        VK_CHECK_RESULT(vkBindImageMemory(m_device->logicalDevice, texture->image, texture->deviceMemory, 0));

        VkImageMemoryBarrier imageMemoryBarrier{};
        VkImageSubresourceRange subresourceRange = {};
        subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
        subresourceRange.levelCount = 1;
        subresourceRange.layerCount = 1;

        imageMemoryBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        imageMemoryBarrier.oldLayout = VK_IMAGE_LAYOUT_UNDEFINED;
        imageMemoryBarrier.newLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
        imageMemoryBarrier.srcAccessMask = 0;
        imageMemoryBarrier.dstAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        imageMemoryBarrier.image = texture->image;
        imageMemoryBarrier.subresourceRange = subresourceRange;
        vkCmdPipelineBarrier(copyCmd, VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, nullptr,
            0, nullptr, 1, &imageMemoryBarrier);
        
        VkBufferImageCopy bufferCopyRegion = {};
        bufferCopyRegion.imageSubresource.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
        bufferCopyRegion.imageSubresource.mipLevel = 0;
        bufferCopyRegion.imageSubresource.baseArrayLayer = 0;
        bufferCopyRegion.imageSubresource.layerCount = 1;
        bufferCopyRegion.imageExtent.width = width;
        bufferCopyRegion.imageExtent.height = height;
        bufferCopyRegion.imageExtent.depth = 1;

        vkCmdCopyBufferToImage(copyCmd, stagingBuffer, texture->image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1,
            &bufferCopyRegion);

        imageMemoryBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        imageMemoryBarrier.oldLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
        imageMemoryBarrier.newLayout = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
        imageMemoryBarrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        imageMemoryBarrier.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
        imageMemoryBarrier.image = texture->image;
        imageMemoryBarrier.subresourceRange = subresourceRange;
        vkCmdPipelineBarrier(copyCmd, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, nullptr, 0,
                             nullptr, 1, &imageMemoryBarrier);

        m_device->flushCommandBuffer(copyCmd, copyQueue, true);

        vkDestroyBuffer(m_device->logicalDevice, stagingBuffer, nullptr);
        vkFreeMemory(m_device->logicalDevice, stagingMemory, nullptr);

        VkCommandBuffer blitCmd = m_device->createCommandBuffer(VK_COMMAND_BUFFER_LEVEL_PRIMARY, true);
        
        for (uint32_t i = 1; i < texture->mipLevels; i++) {
            VkImageBlit imageBlit{};

            imageBlit.srcOffsets[0] = {0, 0, 0};
            imageBlit.srcOffsets[1].x = int32_t(texture->width >> (i - 1));
            imageBlit.srcOffsets[1].y = int32_t(texture->height >> (i - 1));
            imageBlit.srcOffsets[1].z = 1;
            imageBlit.srcSubresource.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
            imageBlit.srcSubresource.mipLevel = i - 1;
            imageBlit.srcSubresource.baseArrayLayer = 0;
            imageBlit.srcSubresource.layerCount = 1;
            imageBlit.dstOffsets[0] = {0, 0, 0};
            imageBlit.dstOffsets[1].x = int32_t(texture->width >> i);
            imageBlit.dstOffsets[1].y = int32_t(texture->height >> i);
            imageBlit.dstOffsets[1].z = 1;
            imageBlit.dstSubresource.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
            imageBlit.dstSubresource.layerCount = 1;
            imageBlit.dstSubresource.mipLevel = i;
            imageBlit.dstSubresource.baseArrayLayer = 0;

            VkImageSubresourceRange mipSubRange = {};
            mipSubRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
            mipSubRange.baseMipLevel = i;
            mipSubRange.levelCount = 1;
            mipSubRange.layerCount = 1;

            {
                VkImageMemoryBarrier imageMemoryBarrier{};
                imageMemoryBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
                imageMemoryBarrier.oldLayout = VK_IMAGE_LAYOUT_UNDEFINED;
                imageMemoryBarrier.newLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
                imageMemoryBarrier.srcAccessMask = 0;
                imageMemoryBarrier.dstAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
                imageMemoryBarrier.image = texture->image;
                imageMemoryBarrier.subresourceRange = mipSubRange;
                vkCmdPipelineBarrier(blitCmd, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0,
                                     nullptr, 0, nullptr, 1, &imageMemoryBarrier);
            }

            vkCmdBlitImage(blitCmd, texture->image, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, texture->image,
                           VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &imageBlit, VK_FILTER_LINEAR);

            {
                VkImageMemoryBarrier imageMemoryBarrier{};
                imageMemoryBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
                imageMemoryBarrier.oldLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
                imageMemoryBarrier.newLayout = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
                imageMemoryBarrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
                imageMemoryBarrier.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
                imageMemoryBarrier.image = texture->image;
                imageMemoryBarrier.subresourceRange = mipSubRange;
                vkCmdPipelineBarrier(blitCmd, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0,
                                     nullptr, 0, nullptr, 1, &imageMemoryBarrier);
            }
            
            imageMemoryBarrier.oldLayout = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
            imageMemoryBarrier.newLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
            imageMemoryBarrier.srcAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
            imageMemoryBarrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT;

            vkCmdPipelineBarrier(copyCmd, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT,
                                 0, 0, nullptr, 0, nullptr, 1, &imageMemoryBarrier);
        }

        subresourceRange.levelCount = texture->mipLevels;
        texture->imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;

        imageMemoryBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        imageMemoryBarrier.oldLayout = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
        imageMemoryBarrier.newLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
        imageMemoryBarrier.srcAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
        imageMemoryBarrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT;
        imageMemoryBarrier.image = texture->image;
        imageMemoryBarrier.subresourceRange = subresourceRange;
        vkCmdPipelineBarrier(blitCmd, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, 0, 0,
                             nullptr, 0, nullptr, 1, &imageMemoryBarrier);
        m_device->flushCommandBuffer(blitCmd, copyQueue, true);

        VkImageViewCreateInfo viewInfo{};
        viewInfo.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
        viewInfo.image = texture->image;
        viewInfo.viewType = VK_IMAGE_VIEW_TYPE_2D;
        viewInfo.format = format;
        viewInfo.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
        viewInfo.subresourceRange.layerCount = 1;
        viewInfo.subresourceRange.levelCount = texture->mipLevels;
        VK_CHECK_RESULT(vkCreateImageView(m_device->logicalDevice, &viewInfo, nullptr, &texture->view));

        VkSampler sampler;
        VkSamplerCreateInfo samplerInfo{};
        samplerInfo.sType = VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO;
        samplerInfo.magFilter = VK_FILTER_LINEAR;
        samplerInfo.minFilter = VK_FILTER_LINEAR;
        samplerInfo.mipmapMode = VK_SAMPLER_MIPMAP_MODE_LINEAR;
        samplerInfo.mipLodBias = 0;
        samplerInfo.addressModeU = VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT;
        samplerInfo.addressModeV = VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT;
        samplerInfo.addressModeW = VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT;
        samplerInfo.compareOp = VK_COMPARE_OP_NEVER;
        samplerInfo.borderColor = VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE;
        samplerInfo.maxAnisotropy = 8.0f;
        samplerInfo.anisotropyEnable = VK_TRUE;
        samplerInfo.minLod = 1.0f;
        samplerInfo.maxLod = texture->mipLevels;
        VK_CHECK_RESULT(vkCreateSampler(m_device->logicalDevice, &samplerInfo, nullptr, &sampler));
        texture->sampler = sampler;
        texture->descriptor.sampler = sampler;
        texture->descriptor.imageView = texture->view;
        texture->descriptor.imageLayout = texture->imageLayout;
    }
}

void vkOBJ::StaticModel::InitVulkanDescriptor(VkQueue copyQueue)
{
    uint32_t size = m_textures.size() * m_meshCount;

    std::vector<VkDescriptorPoolSize> poolSizes = {
    { VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, size*10 }};

    VkDescriptorPoolCreateInfo descriptorPoolCI{};
    descriptorPoolCI.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO;
    descriptorPoolCI.poolSizeCount = static_cast<uint32_t>(poolSizes.size());
    descriptorPoolCI.pPoolSizes = poolSizes.data();
    descriptorPoolCI.maxSets = m_meshes.size() + m_meshCount;
    VK_CHECK_RESULT(vkCreateDescriptorPool(m_device->logicalDevice, &descriptorPoolCI, nullptr, &m_descriptorPool));
    
    std::vector<VkDescriptorSetLayoutBinding> setLayoutBindings{};
    setLayoutBindings.push_back(vks::initializers::descriptorSetLayoutBinding(
        VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, VK_SHADER_STAGE_FRAGMENT_BIT,
        static_cast<uint32_t>(setLayoutBindings.size())));

    VkDescriptorSetLayoutCreateInfo descriptorLayoutCI{};
    descriptorLayoutCI.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
    descriptorLayoutCI.bindingCount = static_cast<uint32_t>(setLayoutBindings.size());
    descriptorLayoutCI.pBindings = setLayoutBindings.data();
    VK_CHECK_RESULT(vkCreateDescriptorSetLayout(m_device->logicalDevice, &descriptorLayoutCI, nullptr,
        &m_descriptorSetLayoutImage));
    for (auto& mesh : m_meshes) {
        mesh->InitMeshDescriptors(copyQueue);
    }
}

void vkOBJ::StaticModel::Draw(VkCommandBuffer commandBuffer, uint32_t renderFlags, VkPipelineLayout pipelineLayout,
    uint32_t bindImageSet)
{
    for (auto mesh : m_meshes) {
        const VkDeviceSize offsets[1] = { 0 };
        vkCmdBindVertexBuffers(commandBuffer, 0, 1, &mesh->vertices.buffer, offsets);
        vkCmdBindIndexBuffer(commandBuffer, mesh->indices.buffer, 0, VK_INDEX_TYPE_UINT32);
        if (mesh->m_descriptorSet != VK_NULL_HANDLE) {
            vkCmdBindDescriptorSets(commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, pipelineLayout, bindImageSet, 1,
                &mesh->m_descriptorSet, 0, nullptr);
        }
        vkCmdDrawIndexed(commandBuffer, mesh->indices.range / (sizeof(unsigned int)), 1, 0, 0, 0);
    }
}

void vkOBJ::StaticModel::ReleaseVulkanResource()
{
    for (int i = 0; i < m_textures.size(); i++) {
        for (int j = 0; j < m_textures[i].size(); j++) {
            m_textures[i][j]->Destory(m_device->logicalDevice);
        }
    }
    m_texturesMap.clear();
    m_textures.clear();
    m_meshes.clear();
    vkDestroyDescriptorSetLayout(m_device->logicalDevice, m_descriptorSetLayoutImage, nullptr);
    vkDestroyDescriptorPool(m_device->logicalDevice, m_descriptorPool, nullptr);
}