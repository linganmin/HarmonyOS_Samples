/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef HELLO_VULKAN_DESCRIPTORPOOL_H
#define HELLO_VULKAN_DESCRIPTORPOOL_H
#include "Singleton.hpp"
#include <vulkan/vulkan.h>
namespace VulkanFG {
class DescriptorPool : public Singleton<DescriptorPool> {
public:
    void Init();
    VkDescriptorPool GetNativeDescriptorPool();

private:
    VkDescriptorPool m_descriptorPool;
};
} // namespace VulkanFG

#endif // HELLO_VULKAN_DESCRIPTORPOOL_H
