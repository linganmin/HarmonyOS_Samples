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

#ifndef TEXTURE_H
#define TEXTURE_H

#include "vulkan_context.h"

#include <vulkan/vulkan.h>


class Texture {
public:
    VkImage image;
    VkImageLayout imageLayout;
    VkDeviceMemory deviceMemory;
    VkImageView view;
    uint32_t layerCount;
    VkDescriptorImageInfo descriptor;
    VkSampler sampler;
    static Texture createDeviceImage(VkDevice vulkanDevice, VkPhysicalDevice physical_device, uint32_t width,
                                     uint32_t height, uint32_t mipLevels, VkFormat format, VkImageUsageFlags usage,
                                     VkFilter filter = VK_FILTER_LINEAR);

    static void createImage(VkDevice vulkanDevice, VkPhysicalDevice physical_device, uint32_t width, uint32_t height,
                            uint32_t mipLevels, VkFormat format, VkImageTiling tiling, VkImageUsageFlags usage,
                            VkMemoryPropertyFlags properties, VkImage &image, VkDeviceMemory &imageMemory);

    static VkImageView createImageView(VkDevice logicDevice, VkImage image, VkFormat format,
                                       VkImageAspectFlags aspectFlags, uint32_t mipLevels);

    static VkSampler createImageSampler(VkDevice logicDevice, uint32_t mipLevels, VkFilter filter = VK_FILTER_LINEAR);

    static uint32_t getMemoryType(uint32_t typeBits, VkMemoryPropertyFlags properties, VkPhysicalDevice physical_device,
                                  VkBool32 *memTypeFound = nullptr);
};
#endif