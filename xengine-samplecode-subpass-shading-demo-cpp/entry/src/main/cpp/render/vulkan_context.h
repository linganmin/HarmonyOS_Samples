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

#ifndef VULKAN_CONTEXT_H
#define VULKAN_CONTEXT_H

#include "vulkan_raii.h"
#include "common/common.h"

#include <vulkan/vulkan.h>
#include <vulkan/vulkan.hpp>

#include <vector>

struct QueueFamilyIndices {
    int graphicsFamily = -1;
    int presentFamily = -1;

    bool isComplete()
    {
        return graphicsFamily >= 0 && presentFamily >= 0;
    }

    static QueueFamilyIndices findQueueFamilies(VkPhysicalDevice device, VkSurfaceKHR surface);
};

struct SwapChainSupportDetails {
    VkSurfaceCapabilitiesKHR capabilities;
    std::vector<VkSurfaceFormatKHR> formats;
    std::vector<VkPresentModeKHR> present_modes;

    static SwapChainSupportDetails querySwapChainSupport(VkPhysicalDevice device, VkSurfaceKHR surface);
};

/**
 * the vulkan context we needed like instance, physical device and logical device
 */
class VulkanContext {
public:
    VulkanContext(OHNativeWindow *window);
    ~VulkanContext();

    VulkanContext(VulkanContext &&) = delete;
    VulkanContext &operator=(VulkanContext &&) = delete;
    VulkanContext(const VulkanContext &) = delete;
    VulkanContext &operator=(const VulkanContext &) = delete;

    std::pair<int, int> getWindowFrameBufferSize() const;

    auto getQueueFamilyIndices() const { return queue_family_indices; }

    vk::PhysicalDevice getPhysicalDevice() const { return physical_device; }

    const vk::PhysicalDeviceProperties &getPhysicalDeviceProperties() const { return physical_device_properties; }

    vk::Device getDevice() const { return graphics_device.get(); }

    vk::Queue getGraphicsQueue() const { return graphics_queue; }

    vk::Queue getPresentQueue() const { return present_queue; }

    vk::Queue getComputeQueue() const { return compute_queue; }

    vk::SurfaceKHR getWindowSurface() const { return window_surface.get(); }

    vk::CommandPool getGraphicsCommandPool() const { return graphics_queue_command_pool.get(); }

    vk::CommandPool getComputeCommandPool() const { return compute_queue_command_pool.get(); }

private:
    OHNativeWindow *window;

    VulkanRaii<vk::Instance> instance;
    VulkanRaii<vk::DebugReportCallbackEXT> callback;
    VulkanRaii<vk::Device> graphics_device; // logical device
    VulkanRaii<vk::SurfaceKHR> window_surface;

    QueueFamilyIndices queue_family_indices;
    VkPhysicalDevice physical_device;
    vk::Queue graphics_queue;
    vk::Queue present_queue;
    vk::Queue compute_queue;

    VulkanRaii<vk::CommandPool> graphics_queue_command_pool;
    VulkanRaii<vk::CommandPool> compute_queue_command_pool;
    vk::PhysicalDeviceProperties physical_device_properties;

    static void DestroyDebugReportCallbackEXT(VkInstance instance, VkDebugReportCallbackEXT callback,
                                              const VkAllocationCallbacks *pAllocator);

    static VkResult CreateDebugReportCallbackEXT(VkInstance instance,
                                                 const VkDebugReportCallbackCreateInfoEXT *pCreateInfo,
                                                 const VkAllocationCallbacks *pAllocator,
                                                 VkDebugReportCallbackEXT *pCallback);

    void createInstance();
    void setupDebugCallback();
    void createWindowSurface();
    void pickPhysicalDevice();
    void findQueueFamilyIndices();
    void createLogicalDevice();
    void getQueue();
    void createCommandPools();

    void initVulkan()
    {
        createInstance();
        createWindowSurface();
        pickPhysicalDevice();
        findQueueFamilyIndices();
        createLogicalDevice();
        getQueue();
        createCommandPools();
    }
};

#endif