/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef HELLO_VULKAN_COMMANDPOOL_H
#define HELLO_VULKAN_COMMANDPOOL_H
#include "Singleton.hpp"
#include <vulkan/vulkan.h>
#include <string>
namespace VulkanFG {
class CommandPool : public Singleton<CommandPool> {
public:
    typedef struct CommandPoolDescriptor {
        std::string name = "Default Command Pool";
        VkDevice device = VK_NULL_HANDLE;
        VkCommandPoolCreateFlags flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
        uint32_t queueFamilyIndex = 0;
        VkQueue queue = VK_NULL_HANDLE;

        CommandPoolDescriptor &Name(const std::string &s)
        {
            name = s;
            return *this;
        }
        CommandPoolDescriptor &Device(VkDevice dev)
        {
            device = dev;
            return *this;
        }
        CommandPoolDescriptor &Flags(VkCommandPoolCreateFlags f)
        {
            flags = f;
            return *this;
        }
        CommandPoolDescriptor &QueueFamilyIndex(uint32_t idx)
        {
            queueFamilyIndex = idx;
            return *this;
        }
        CommandPoolDescriptor &Queue(VkQueue q)
        {
            queue = q;
            return *this;
        }
    } CommandPoolDescriptor;
    bool Init(const CommandPoolDescriptor &descriptor);
    VkQueue GetQueue();
    uint32_t GetQueueIndex();
    VkCommandBuffer AllocateSingleTimeCommandBuffer();
    void DeallocateSingleTimeCommandBuffer(VkCommandBuffer commandBuffer);
    void AllocateCommandBuffers(VkCommandBuffer *cmdBuffers, uint32_t num);
    void DeaocateCommandBuffers(VkCommandBuffer *cmdBuffers, uint32_t num);
    void Destroy();
    ~CommandPool();

private:
    CommandPoolDescriptor m_descriptor;
    VkCommandPool m_commandPool = VK_NULL_HANDLE;
    VkDevice m_device = VK_NULL_HANDLE;
    VkQueue m_queue = VK_NULL_HANDLE;
};
} // namespace VulkanFG
#endif // HELLO_VULKAN_COMMANDPOOL_H
