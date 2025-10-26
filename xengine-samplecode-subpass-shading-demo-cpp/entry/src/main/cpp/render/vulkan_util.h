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

#ifndef VULKAN_UTIL_H
#define VULKAN_UTIL_H

#include "vulkan_raii.h"
#include "vulkan_context.h"

#include <vulkan/vulkan.h>
#include <vulkan/vulkan.hpp>

#include <array>
#include <string>

const int VERTEX_INPUT_ATTR_DESC_NUMS = 4;

namespace vulkan_util {
    VkVertexInputBindingDescription getVertexBindingDesciption();
    std::array<VkVertexInputAttributeDescription, VERTEX_INPUT_ATTR_DESC_NUMS> getVertexAttributeDescriptions();

    void checkResult(VkResult result, const char *what = "Runtime error from vulkan_util::checkResult!");

} // namespace vulkan_util

/**
 * a utility module for vulkan context
 */
class VulkanUtil {
public:
    VulkanUtil(const VulkanContext &context);
    ~VulkanUtil() = default;

    VulkanUtil(VulkanUtil &&) = delete;
    VulkanUtil &operator=(VulkanUtil &&) = delete;
    VulkanUtil(const VulkanUtil &) = delete;
    VulkanUtil &operator=(const VulkanUtil &) = delete;

    VkSurfaceFormatKHR chooseSwapSurfaceFormat(const std::vector<VkSurfaceFormatKHR> &available_formats);
    VkPresentModeKHR chooseSwapPresentMode(const std::vector<VkPresentModeKHR> &available_present_modes);
    VkExtent2D chooseSwapExtent(const VkSurfaceCapabilitiesKHR &capabilities);
    VkFormat findSupportedFormat(const std::vector<VkFormat> &candidates, VkImageTiling tiling,
                                 VkFormatFeatureFlags features);
    inline VkFormat findDepthFormat()
    {
        return findSupportedFormat({VK_FORMAT_D24_UNORM_S8_UINT, VK_FORMAT_D32_SFLOAT, VK_FORMAT_D32_SFLOAT_S8_UINT},
                                   VK_IMAGE_TILING_OPTIMAL, VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT);
    }

    std::tuple<VulkanRaii<VkBuffer>, VulkanRaii<VkDeviceMemory>> createBuffer(VkDeviceSize size,
                                                                              VkBufferUsageFlags usage,
                                                                              VkMemoryPropertyFlags property_bits,
                                                                              int sharing_queue_family_index_a = -1,
                                                                              int sharing_queue_family_index_b = -1);
    void copyBuffer(VkBuffer src_buffer, VkBuffer dst_buffer, VkDeviceSize size, VkDeviceSize src_offset = 0,
                    VkDeviceSize dst_offset = 0);

    std::tuple<VulkanRaii<VkImage>, VulkanRaii<VkDeviceMemory>> createImage(uint32_t image_width, uint32_t image_height,
                                                                  VkFormat format, VkImageTiling tiling,
                                                                  VkImageUsageFlags usage,
                                                                  VkMemoryPropertyFlags memory_properties);

    void copyImage(VkImage src_image, VkImage dst_image, uint32_t width, uint32_t height);
    void transitImageLayout(VkImage image, VkImageLayout old_layout, VkImageLayout new_layout);

    void createImageView(VkImage image, VkFormat format, VkImageAspectFlags aspect_mask, VkImageView *p_image_view);
    VulkanRaii<VkImageView> createImageView(VkImage image, VkFormat format, VkImageAspectFlags aspect_mask);

    std::tuple<VulkanRaii<VkImage>, VulkanRaii<VkDeviceMemory>, VulkanRaii<VkImageView>> loadImageFromFile(
        std::string path);

    VkCommandBuffer beginSingleTimeCommands();
    void endSingleTimeCommands(VkCommandBuffer commandBuffer);

    // Called on vulcan command buffer recording
    void recordCopyBuffer(VkCommandBuffer command_buffer, VkBuffer src_buffer, VkBuffer dst_buffer, VkDeviceSize size,
                          VkDeviceSize src_offset = 0, VkDeviceSize dst_offset = 0);
    void recordCopyImage(VkCommandBuffer command_buffer, VkImage src_image, VkImage dst_image, uint32_t width,
                         uint32_t height);
    void recordTransitImageLayout(VkCommandBuffer command_buffer, VkImage image, VkImageLayout old_layout,
                                  VkImageLayout new_layout);

private:
    std::tuple<VkBuffer, VkDeviceMemory> createBufferImpl(VkDeviceSize size, VkBufferUsageFlags usage,
                                                          VkMemoryPropertyFlags property_bits,
                                                          int sharing_queue_family_index_a = -1,
                                                          int sharing_queue_family_index_b = -1);
                                                          
    const VulkanContext *context;
    vk::PhysicalDevice physical_device;
    VkDevice graphics_device; // for previously written code using C api
    vk::Device device;
    vk::Queue graphics_queue;
    vk::Queue compute_queue;
    vk::Queue present_queue;
    vk::CommandPool graphics_queue_command_pool;
    vk::CommandPool compute_queue_command_pool;
};
#endif
