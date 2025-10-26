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

#include "vulkan_context.h"
#include "util.h"

#include <native_window/external_window.h>
#include <unordered_set>
#include <iostream>
#include <cstring>
#include <set>


#define NDEBUG

#ifdef NDEBUG
// if not debugging
const bool ENABLE_VALIDATION_LAYERS = false;
#else
const bool ENABLE_VALIDATION_LAYERS = true;
#endif

#define ONE_QUEUE // Force one queue for everything

#define VK_USE_PLATFORM_OHOS_KHR

const std::vector<const char *> VALIDATION_LAYERS = {"VK_LAYER_KHRONOS_validation"};

const std::vector<const char *> DEVICE_EXTENSIONS = {
    VK_KHR_SWAPCHAIN_EXTENSION_NAME, VK_HUAWEI_SUBPASS_SHADING_EXTENSION_NAME, VK_KHR_SYNCHRONIZATION_2_EXTENSION_NAME,
    VK_KHR_CREATE_RENDERPASS_2_EXTENSION_NAME};

VulkanContext::VulkanContext(OHNativeWindow *window)
{
    if (!window) {
        throw std::runtime_error("invalid window");
    }

    this->window = window;

    initVulkan();
}

VulkanContext::~VulkanContext() = default;

std::pair<int, int> VulkanContext::getWindowFrameBufferSize() const
{
    int frameBufferWidth;
    int frameBufferHeight;

    OH_NativeWindow_NativeWindowHandleOpt(window, GET_BUFFER_GEOMETRY, &frameBufferHeight, &frameBufferWidth);
    // LOGE("Window Frame BufferSize width is  %{public}d, height is %{public}d", frameBufferWidth, frameBufferHeight);
    return std::make_pair(frameBufferWidth, frameBufferHeight);
}

// the debug callback function that Vulkan runs
static VKAPI_ATTR VkBool32 debugCallback(VkDebugReportFlagsEXT flags, VkDebugReportObjectTypeEXT objType, uint64_t obj,
                                         size_t location, int32_t messageCode, const char *pLayerPrefix,
                                         const char *pMessage, void *userData) {
    std::string type = "";
    if (flags & VK_DEBUG_REPORT_INFORMATION_BIT_EXT) {
        type = "INFO";
    } else if (flags & VK_DEBUG_REPORT_WARNING_BIT_EXT) {
        type = "WARNING";
    } else if (flags & VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT) {
        type = "PERFORMANCE";
    } else if (flags & VK_DEBUG_REPORT_ERROR_BIT_EXT) {
        type = "ERROR";
    } else if (flags & VK_DEBUG_REPORT_DEBUG_BIT_EXT) {
        type = "DEBUG";
    } else {
        type = "UNKNOWN";
    }

    // LOGE("ValidationLayer: TYPE=%s, messageCode=%d, pLayerPrefix=%s, message=%s.", type.c_str(), messageCode,
    //      pLayerPrefix, pMessage);

    return VK_TRUE;
}

QueueFamilyIndices QueueFamilyIndices::findQueueFamilies(VkPhysicalDevice device, VkSurfaceKHR surface)
{
    QueueFamilyIndices indices;

    uint32_t queuefamily_count = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(device, &queuefamily_count, nullptr);

    std::vector<VkQueueFamilyProperties> queuefamilies(queuefamily_count);
    vkGetPhysicalDeviceQueueFamilyProperties(device, &queuefamily_count, queuefamilies.data());

    int i = 0;
    for (const auto &queuefamily : queuefamilies) {
#ifdef ONE_QUEUE
        if (queuefamily.queueCount > 0 && (queuefamily.queueFlags & VK_QUEUE_GRAPHICS_BIT) &&
            (queuefamily.queueFlags & VK_QUEUE_COMPUTE_BIT)) {
            VkBool32 presentSupport = false;
            vkGetPhysicalDeviceSurfaceSupportKHR(device, i, surface, &presentSupport);
            if (queuefamily.queueCount > 0 && presentSupport) {
                indices.graphicsFamily = i;
                indices.presentFamily = i;
            }
        }
#else
        if (queuefamily.queueCount > 0 && (queuefamily.queueFlags & VK_QUEUE_GRAPHICS_BIT)) {
            auto support_compute = static_cast<bool>(queuefamily.queueFlags & VK_QUEUE_COMPUTE_BIT);
            auto enough_size = (queuefamily.queueCount >= 2);

            if (!support_compute) {
                std::cout << "Found a graphics queue family, but it doesn't support compute." << std::endl;
            }
            if (!enough_size) {
                std::cout << "Found a graphics queue family, but it doesn't enough queue count" << std::endl;
            }
            if (support_compute && enough_size) {
                indices.graphicsFamily = i;
            }
        }

        VkBool32 presentSupport = false;
        vkGetPhysicalDeviceSurfaceSupportKHR(device, i, surface, &presentSupport);
        if (queuefamily.queueCount > 0 && presentSupport) {
            indices.presentFamily = i;
        }
#endif // ONE_QUEUE
        if (indices.isComplete()) {
            break;
        }

        i++;
    }

    return indices;
}


VkResult VulkanContext::CreateDebugReportCallbackEXT(VkInstance instance,
                                                     const VkDebugReportCallbackCreateInfoEXT *pCreateInfo,
                                                     const VkAllocationCallbacks *pAllocator,
                                                     VkDebugReportCallbackEXT *pCallback)
{
    auto func = (PFN_vkCreateDebugReportCallbackEXT)vkGetInstanceProcAddr(instance, "vkCreateDebugReportCallbackEXT");
    if (func != nullptr) {
        VkResult result = func(instance, pCreateInfo, pAllocator, pCallback);
        return result;
    } else {
        return VK_ERROR_EXTENSION_NOT_PRESENT;
    }
}

void VulkanContext::DestroyDebugReportCallbackEXT(VkInstance instance, VkDebugReportCallbackEXT callback,
                                                  const VkAllocationCallbacks *pAllocator)
{
    auto func = (PFN_vkDestroyDebugReportCallbackEXT)vkGetInstanceProcAddr(instance, "vkDestroyDebugReportCallbackEXT");
    if (func != nullptr) {
        func(instance, callback, pAllocator);
    }
}

bool checkValidationLayerSupport()
{
    uint32_t layerCount;
    vkEnumerateInstanceLayerProperties(&layerCount, nullptr);

    std::vector<VkLayerProperties> availableLayers(layerCount);
    LOGI("layerCount %d: ", layerCount);
    vkEnumerateInstanceLayerProperties(&layerCount, availableLayers.data());
    LOGI("zzg layerCount is %d", layerCount);

    if (availableLayers.size() == 0) {
        LOGI("availableLayers size is 0");
        return true;
    }

    for (const char *layerName : VALIDATION_LAYERS) {
        bool layerFound = false;
        for (const auto &layerProperties : availableLayers) {
            if (strcmp(layerName, layerProperties.layerName) == 0) {
                layerFound = true;
                break;
            }
        }
        if (!layerFound) {
            // LOGE("layerFound not %s", layerName);
            return false;
        }
    }
    return true;
}

void VulkanContext::createInstance()
{
    if (ENABLE_VALIDATION_LAYERS && !checkValidationLayerSupport()) {
        throw std::runtime_error("validation layers requested, but not available!");
    }

    VkApplicationInfo app_info = {}; // optional
    app_info.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    app_info.pApplicationName = "Vulkan Hello World";
    app_info.applicationVersion = VK_MAKE_VERSION(1, 1, 0);
    app_info.pEngineName = "No Engine";
    app_info.engineVersion = VK_MAKE_VERSION(1, 1, 0);
    app_info.apiVersion = VK_API_VERSION_1_0;
    app_info.apiVersion = VK_API_VERSION_1_1;

    VkInstanceCreateInfo instance_info = {}; // not optional
    instance_info.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    instance_info.pApplicationInfo = &app_info;

    // Getting Vulkan supported extensions
    uint32_t extensionCount = 0;
    vkEnumerateInstanceExtensionProperties(nullptr, &extensionCount, nullptr);
    std::vector<VkExtensionProperties> extensions(extensionCount);
    vkEnumerateInstanceExtensionProperties(nullptr, &extensionCount, extensions.data());
    std::unordered_set<std::string> supportedExtensionNames;
    for (const auto &extension : extensions) {
        supportedExtensionNames.insert(std::string(extension.extensionName));
    }

    std::vector<const char *> instanceExtensions = {VK_KHR_SURFACE_EXTENSION_NAME};
    // Enable surface extensions depending on os
#if defined(_WIN32)
    instanceExtensions.push_back("VK_KHR_win32_surface");
#elif defined(VK_USE_PLATFORM_OHOS_KHR)
    instanceExtensions.push_back(VK_OHOS_SURFACE_EXTENSION_NAME);
#ifdef NDEBUG
    instanceExtensions.push_back(VK_EXT_DEBUG_REPORT_EXTENSION_NAME);
#endif
#elif defined(VK_LINUX_CMODEL)
    instanceExtensions.clear();
#endif

    if (instanceExtensions.size() > 0) {
        // Enable required extensions
        instance_info.enabledExtensionCount = (uint32_t)instanceExtensions.size();
        instance_info.ppEnabledExtensionNames = instanceExtensions.data();
    }

    if (ENABLE_VALIDATION_LAYERS) {
        instance_info.enabledLayerCount = static_cast<uint32_t>(VALIDATION_LAYERS.size());
        instance_info.ppEnabledLayerNames = VALIDATION_LAYERS.data();
    } else {
        instance_info.enabledLayerCount = 0;
    }

    instance =
        VulkanRaii<vk::Instance>{vk::createInstance(instance_info, nullptr), [](vk::Instance &obj) { obj.destroy(); }};

    if (ENABLE_VALIDATION_LAYERS) {
        setupDebugCallback();
    }
    LOGI("------------------createInstance success-----------------");
}

void VulkanContext::setupDebugCallback()
{
    if (!ENABLE_VALIDATION_LAYERS)
        return;

    VkDebugReportCallbackCreateInfoEXT createInfo = {};
    createInfo.sType = VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT;
    createInfo.flags = VK_DEBUG_REPORT_INFORMATION_BIT_EXT | VK_DEBUG_REPORT_WARNING_BIT_EXT |
                       VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT | VK_DEBUG_REPORT_ERROR_BIT_EXT |
                       VK_DEBUG_REPORT_DEBUG_BIT_EXT;
    createInfo.pfnCallback = debugCallback;

    VkDebugReportCallbackEXT temp_callback;
    if (CreateDebugReportCallbackEXT(instance.get(), &createInfo, nullptr, &temp_callback) != VK_SUCCESS) {
        throw std::runtime_error("failed to set up debug callback!");
    }

    callback = VulkanRaii<vk::DebugReportCallbackEXT>{temp_callback, [instance = this->instance.get()](auto &obj) {
        DestroyDebugReportCallbackEXT(instance, obj, nullptr);}};
}

bool checkDeviceExtensionSupport(VkPhysicalDevice device)
{
    uint32_t extension_count;
    vkEnumerateDeviceExtensionProperties(device, nullptr, &extension_count, nullptr);

    std::vector<VkExtensionProperties> available_extensions(extension_count);
    vkEnumerateDeviceExtensionProperties(device, nullptr, &extension_count, available_extensions.data());

    std::set<std::string> required_extensions(DEVICE_EXTENSIONS.begin(), DEVICE_EXTENSIONS.end());

    for (const auto &extension : available_extensions) {
        required_extensions.erase(extension.extensionName);
    }
    return required_extensions.empty();
}


bool isDeviceSuitable(VkPhysicalDevice device, VkSurfaceKHR window_surface)
{
    QueueFamilyIndices indices =
        QueueFamilyIndices::findQueueFamilies(device, static_cast<VkSurfaceKHR>(window_surface));

    bool extensions_supported = checkDeviceExtensionSupport(device);

    bool swap_chain_adequate = false;
    if (extensions_supported) {
        auto swap_chain_support =
            SwapChainSupportDetails::querySwapChainSupport(device, static_cast<VkSurfaceKHR>(window_surface));
        swap_chain_adequate = !swap_chain_support.formats.empty() && !swap_chain_support.present_modes.empty();
    }

    return indices.isComplete() && extensions_supported && swap_chain_adequate;
}

// Pick up a graphics card to use
void VulkanContext::pickPhysicalDevice()
{
    // This object will be implicitly destroyed when the VkInstance is destroyed, so we don't need to add a delete
    // wrapper.
    VkPhysicalDevice physial_device = VK_NULL_HANDLE;
    uint32_t device_count = 0;
    vkEnumeratePhysicalDevices(instance.get(), &device_count, nullptr);

    if (device_count == 0) {
        throw std::runtime_error("Failed to find GPUs with Vulkan support!");
    }

    std::vector<VkPhysicalDevice> devices(device_count);
    vkEnumeratePhysicalDevices(instance.get(), &device_count, devices.data());

    for (const auto &device : devices) {
        if (isDeviceSuitable(device, window_surface.get())) {
            physial_device = device;
            break;
        }
    }

    if (physial_device == VK_NULL_HANDLE) {
        throw std::runtime_error("Failed to find a suitable GPU!");
    } else {
        VkPhysicalDeviceProperties properties;
        vkGetPhysicalDeviceProperties(physial_device, &properties);
    }

    this->physical_device = physial_device;
    this->physical_device_properties = static_cast<vk::PhysicalDevice>(physical_device).getProperties();
    LOGI("------------------pickPhysicalDevice success-----------------");
}

void VulkanContext::findQueueFamilyIndices()
{
    queue_family_indices = QueueFamilyIndices::findQueueFamilies(physical_device, window_surface.get());
    if (!queue_family_indices.isComplete()) {
        // throw std::runtime_error("Queue family indices not complete!");
    }
    LOGI("------------------findQueueFamilyIndices success-----------------");
}

// Needs to be called right after instance creation because it may influence device selection
void VulkanContext::createWindowSurface()
{
    VkSurfaceKHR temp_surface;
    VkSurfaceCreateInfoOHOS createInfo;
    createInfo.sType = VK_STRUCTURE_TYPE_SURFACE_CREATE_INFO_OHOS;
    createInfo.pNext = nullptr;
    createInfo.flags = 0;
    createInfo.window = static_cast<NativeWindow *>(window);
    auto result = vkCreateSurfaceOHOS(instance.get(), &createInfo, nullptr, &temp_surface);
    if (result != VK_SUCCESS) {
        throw std::runtime_error("Failed to create window surface!");
    }

    window_surface = VulkanRaii<vk::SurfaceKHR>{
        temp_surface, [instance = this->instance.get()](auto &surface) { instance.destroySurfaceKHR(surface); }};
    LOGI("------------------createWindowSurface success-----------------");
}

void VulkanContext::createLogicalDevice()
{
    QueueFamilyIndices indices =
        QueueFamilyIndices::findQueueFamilies(physical_device, static_cast<VkSurfaceKHR>(window_surface.get()));

    std::vector<VkDeviceQueueCreateInfo> queue_create_infos;
    std::vector<int> queue_families; // = { indices.graphics_family, indices.present_family };
    // 2 queues in graphics family, 1 used for light cullingf
    std::vector<std::vector<float>>queue_priorties; // = { { 1.0f, 1.0f },{ 1.0f } };
#ifdef ONE_QUEUE
    queue_families = {indices.graphicsFamily};
    queue_priorties = {{1.0f}}; // 2 queues in graphics family, 1 used for light cullingf
#else
    if (indices.graphicsFamily != indices.presentFamily) {
        queue_families = {indices.graphicsFamily, indices.presentFamily};
        queue_priorties = {{1.0f, 1.0f}, {1.0f}}; // 2 queues in graphics family, 1 used for light cullingf
    } else {
        queue_families = {indices.graphicsFamily};
        queue_priorties = {{1.0f, 1.0f, 1.0f}};
    }
#endif // ONE_QUEUE

    float queue_priority = 1.0f;
    for (int i = 0; i < queue_families.size(); i++) {
        auto family = queue_families[i];
        // Create a graphics queue
        VkDeviceQueueCreateInfo queue_create_info = {};
        queue_create_info.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
        queue_create_info.queueFamilyIndex = indices.graphicsFamily;
        queue_create_info.queueCount = static_cast<uint32_t>(queue_priorties[i].size());
        queue_create_info.pQueuePriorities = queue_priorties[i].data();
        queue_create_infos.push_back(queue_create_info);
    }

    // Specify used device features
    VkPhysicalDeviceFeatures device_features = {}; // Everything is by default VK_FALSE

    // Create the logical device
    VkDeviceCreateInfo device_create_info = {};
    device_create_info.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
    device_create_info.pQueueCreateInfos = queue_create_infos.data();
    device_create_info.queueCreateInfoCount = static_cast<uint32_t>(queue_create_infos.size());

    device_create_info.pEnabledFeatures = &device_features;

    if (ENABLE_VALIDATION_LAYERS) {
        device_create_info.enabledLayerCount = static_cast<uint32_t>(VALIDATION_LAYERS.size());
        device_create_info.ppEnabledLayerNames = VALIDATION_LAYERS.data();
    } else {
        device_create_info.enabledLayerCount = 0;
    }

    device_create_info.enabledExtensionCount = static_cast<uint32_t>(DEVICE_EXTENSIONS.size());
    device_create_info.ppEnabledExtensionNames = DEVICE_EXTENSIONS.data();
    VkPhysicalDeviceSubpassShadingFeaturesHUAWEI physicalDeviceSubpassShadingFeatures;
    physicalDeviceSubpassShadingFeatures.subpassShading = VK_TRUE;
    physicalDeviceSubpassShadingFeatures.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBPASS_SHADING_FEATURES_HUAWEI;
    physicalDeviceSubpassShadingFeatures.pNext = nullptr;
    device_create_info.pNext = &physicalDeviceSubpassShadingFeatures;

    VkDevice temp_device;
    auto result = vkCreateDevice(physical_device, &device_create_info, nullptr, &temp_device);
    if (result != VK_SUCCESS) {
        throw std::runtime_error("Failed to create logical device!");
    }
    graphics_device = VulkanRaii<vk::Device>{temp_device, [](vk::Device &device) { device.destroy(); }};
    LOGI("------------------create LOGIcalDevice success-----------------");
}

void VulkanContext::getQueue()
{
    auto device = graphics_device.get();
    QueueFamilyIndices indices = queue_family_indices;
#ifdef ONE_QUEUE
    graphics_queue = device.getQueue(indices.graphicsFamily, 0);
    compute_queue = device.getQueue(indices.graphicsFamily, 0);
    present_queue = device.getQueue(indices.graphicsFamily, 0);
#else
    graphics_queue = device.getQueue(indices.graphicsFamily, 0);
    compute_queue = device.getQueue(indices.graphicsFamily, 1);
    if (indices.graphicsFamily != indices.presentFamily) {
        present_queue = device.getQueue(indices.presentFamily, 0);
    } else {
        present_queue = device.getQueue(indices.graphicsFamily, 2);
    }
#endif // ONE_QUEUE
}

void VulkanContext::createCommandPools()
{
    auto device = graphics_device.get();
    auto raii_commandpool_deleter = [device = device](auto &obj) { device.destroyCommandPool(obj); };

    auto &indices = queue_family_indices;

    // graphics_queue_command_pool
    {
        VkCommandPoolCreateInfo pool_info = {};
        pool_info.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
        pool_info.queueFamilyIndex = indices.graphicsFamily;
        pool_info.flags = 0; // Optional
        // hint the command pool will rerecord buffers by VK_COMMAND_POOL_CREATE_TRANSIENT_BIT
        // allow buffers to be rerecorded individually by VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
        graphics_queue_command_pool =
            VulkanRaii<vk::CommandPool>(device.createCommandPool(pool_info, nullptr), raii_commandpool_deleter);
    }

    // compute_queue_command_pool
    {
        VkCommandPoolCreateInfo cmd_pool_info = {};
        cmd_pool_info.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
        cmd_pool_info.queueFamilyIndex = indices.graphicsFamily;
        cmd_pool_info.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
        compute_queue_command_pool =
            VulkanRaii<vk::CommandPool>(device.createCommandPool(cmd_pool_info, nullptr), raii_commandpool_deleter);
    }

    LOGI("------------------createCommandPools success-----------------");
}

SwapChainSupportDetails SwapChainSupportDetails::querySwapChainSupport(VkPhysicalDevice device, VkSurfaceKHR surface)
{
    SwapChainSupportDetails details;
    vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device, surface, &details.capabilities);

    // Getting supported surface formats
    uint32_t format_count;
    vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &format_count, nullptr);
    if (format_count != 0) {
        details.formats.resize(format_count);
        vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &format_count, details.formats.data());
    }

    // Getting supported present modes
    uint32_t present_mode_count;
    vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &present_mode_count, nullptr);
    if (present_mode_count != 0) {
        details.present_modes.resize(present_mode_count);
        vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &present_mode_count, details.present_modes.data());
    }

    return details;
}