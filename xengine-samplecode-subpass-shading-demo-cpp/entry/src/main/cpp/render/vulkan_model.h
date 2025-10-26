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

#ifndef VULKAN_MODEL_H
#define VULKAN_MODEL_H

#include "vulkan_raii.h"
#include "vulkan_context.h"

#include <vulkan/vulkan.hpp>
#include <vector>

/**
 * A structure that points to a part of a buffer
 */
struct VBufferSection {
    vk::Buffer buffer = {}; // just a handle, no ownership for this buffer
    vk::DeviceSize offset = 0;
    vk::DeviceSize size = 0;

    VBufferSection() = default;

    VBufferSection(vk::Buffer buffer, vk::DeviceSize offset, vk::DeviceSize size)
        : buffer(buffer), offset(offset), size(size) {}
};

struct VMeshPart {
    VBufferSection vertex_buffer_section = {};
    VBufferSection index_buffer_section = {};
    VBufferSection material_uniform_buffer_section = {};
    size_t index_count = 0;
    vk::DescriptorSet material_descriptor_set = {};

    // handles for images (no ownership or so)
    vk::ImageView albedo_map = {};
    vk::ImageView normal_map = {};

    VMeshPart(const VBufferSection &vertex_buffer_section, const VBufferSection &index_buffer_section,
              size_t index_count)
        : vertex_buffer_section(vertex_buffer_section), index_buffer_section(index_buffer_section),
          index_count(index_count) {}
};

/**
 * A class to manage resources of a static mesh.
 * Must be destructed before the vk::Device used to construct it
 */
class VulkanModel {
public:
    VulkanModel() = default;
    ~VulkanModel() = default;
    VulkanModel(VulkanModel &&) = default;
    VulkanModel &operator=(VulkanModel &&) = default;

    const std::vector<VMeshPart> &getMeshParts() const { return mesh_parts; }

    static VulkanModel loadModelFromFile(const VulkanContext &vulkan_context, const std::string &path,
                                    const vk::Sampler &texture_sampler, const vk::DescriptorPool &descriptor_pool,
                                    const vk::DescriptorSetLayout &material_descriptor_set_layout);

    VulkanModel(const VulkanModel &) = delete;
    VulkanModel &operator=(const VulkanModel &) = delete;

private:
    VulkanRaii<VkBuffer> buffer;
    VulkanRaii<VkDeviceMemory> buffer_memory;
    std::vector<VulkanRaii<VkImage>> images;
    std::vector<VulkanRaii<VkImageView>> imageviews;
    std::vector<VulkanRaii<VkDeviceMemory>> image_memories;
    VulkanRaii<VkBuffer> uniform_buffer;
    VulkanRaii<VkDeviceMemory> uniform_buffer_memory;

    std::vector<VMeshPart> mesh_parts;
};

#endif