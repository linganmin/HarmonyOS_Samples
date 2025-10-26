/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef HELLO_VULKAN_DEVICE_H
#define HELLO_VULKAN_DEVICE_H
#include "Singleton.hpp"
#include <vulkan/vulkan.h>
#include <string>
#include <vector>

namespace VulkanFG {
class Device : public Singleton<Device> {
public:
    typedef struct DeviceDescriptor {
        std::string name;
        VkInstance instance;
        VkPhysicalDevice physicalDevice;
        VkDevice device;
        uint32_t queueFamilyIndex;
        VkQueue queue;

        DeviceDescriptor &Name(const std::string &s)
        {
            name = s;
            return *this;
        }
        DeviceDescriptor &Instance(VkInstance ins)
        {
            instance = ins;
            return *this;
        }
        DeviceDescriptor &PhysicalDevice(VkPhysicalDevice phyDev)
        {
            physicalDevice = phyDev;
            return *this;
        }
        DeviceDescriptor &LogicalDevice(VkDevice dev)
        {
            device = dev;
            return *this;
        }
        DeviceDescriptor &QueueFamilyIndex(uint32_t idx)
        {
            queueFamilyIndex = idx;
            return *this;
        }
        DeviceDescriptor &Queue(VkQueue q)
        {
            queue = q;
            return *this;
        }
    } DeviceDescriptor;
    void Init(const DeviceDescriptor &descriptor);
    VkDevice GetNativeDevice();
    VkPhysicalDevice GetNativePhysicalDevice();
    VkInstance GetNativeInstance();
    VkQueue GetNativeQueue();
    uint32_t GetQueueFamilyIndex();
    VkPhysicalDeviceProperties GetPhysicalDeviceProperties();
    VkFormat FindSupportedFormat(const std::vector<VkFormat> &candidates, VkImageTiling tiling,
        VkFormatFeatureFlags features);
    VkFormat FindDepthFormat();
    uint32_t FindMemoryType(uint32_t typeFilter, VkMemoryPropertyFlags properties);
    constexpr static uint32_t InvalidMemoryType = static_cast<uint32_t>(-1);

private:
    VkInstance m_instance;
    VkPhysicalDevice m_physicalDevice;
    VkDevice m_device;
    uint32_t m_queueFamilyIndex;
    VkQueue m_queue;
    VkPhysicalDeviceProperties m_physicalDevicePorperties;
};
} // namespace VulkanFG

#endif // HELLO_VULKAN_DEVICE_H
