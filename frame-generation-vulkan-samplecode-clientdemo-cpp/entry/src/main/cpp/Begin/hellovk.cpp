/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "hellovk.h"
#include "fif.h"
#include <set>
#include <unordered_set>
#include <log.hpp>
#include <AAssetImporter.h>
#include <DescriptorPool.h>
#include <CommandPool.h>
#include <Utils.h>
#include <securec.h>

bool vkt::HelloVK::ENABLE_EXTRAPOLATION = false;
namespace vkt {
namespace {
static constexpr VkQueryType VK_QUERY_TYPE_HISS_MOTION_VECTOR_DRAW_TRACKING_HUAWEI =
    static_cast<VkQueryType>(1000000000);
[[nodiscard]] const char *ToStringMessageSeverity(VkDebugUtilsMessageSeverityFlagBitsEXT s)
{
    switch (s) {
        case VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT:
            return "VERBOSE";
        case VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT:
            return "ERROR";
        case VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT:
            return "WARNING";
        case VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT:
            return "INFO";
        default:
            return "UNKNOWN";
    }
}

[[nodiscard]] const char *ToStringMessageType(VkDebugUtilsMessageTypeFlagsEXT s)
{
    if (s == (VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT |
        VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT)) {
        return "General | Validation | Performance";
    }

    if (s == (VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT)) {
        return "Validation | Performance";
    }

    if (s == (VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT)) {
        return "General | Performance";
    }

    if (s == (VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT)) {
        return "Performance";
    }

    if (s == (VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT)) {
        return "General | Validation";
    }

    if (s == VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT) {
        return "Validation";
    }

    if (s == VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT) {
        return "General";
    }

    return "Unknown";
}

VKAPI_ATTR VkBool32 VKAPI_CALL DebugCallback(VkDebugUtilsMessageSeverityFlagBitsEXT messageSeverity,
    VkDebugUtilsMessageTypeFlagsEXT messageType, const VkDebugUtilsMessengerCallbackDataEXT *pCallbackData,
    void * /* pUserData */)
{
    static std::unordered_set<uint32_t> const validationFilter{ // Unspecified message. Safe to ignore it.
        0x00000000U, 0x675DC32EU
    };

    auto const messageID = static_cast<uint32_t>(pCallbackData->messageIdNumber);
    if (validationFilter.contains(messageID)) {
        return VK_FALSE;
    }

    auto ms = ToStringMessageSeverity(messageSeverity);
    auto mt = ToStringMessageType(messageType);
    GOLOGI("[%s: %s]\n%s\n", ms, mt, pCallbackData->pMessage);

    return VK_FALSE;
}

void PopulateDebugMessengerCreateInfo(VkDebugUtilsMessengerCreateInfoEXT &createInfo)
{
    constexpr static VkValidationFeatureEnableEXT const validationFeatures[] = {
        VK_VALIDATION_FEATURE_ENABLE_BEST_PRACTICES_EXT,
        VK_VALIDATION_FEATURE_ENABLE_SYNCHRONIZATION_VALIDATION_EXT
    };

    constexpr static VkValidationFeaturesEXT validationInfo {
        .sType = VK_STRUCTURE_TYPE_VALIDATION_FEATURES_EXT,
        .pNext = nullptr,
        .enabledValidationFeatureCount = static_cast<uint32_t>(std::size(validationFeatures)),
        .pEnabledValidationFeatures = validationFeatures,
        .disabledValidationFeatureCount = 0U,
        .pDisabledValidationFeatures = nullptr
    };

    createInfo = {};
    createInfo.pNext = &validationInfo;
    createInfo.sType = VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;

    createInfo.messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT |
        VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT;

    createInfo.messageType = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT |
        VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;

    createInfo.pfnUserCallback = &DebugCallback;
}

[[nodiscard]] VkResult CreateDebugUtilsMessengerEXT(VkInstance instance,
    const VkDebugUtilsMessengerCreateInfoEXT *pCreateInfo, const VkAllocationCallbacks *pAllocator,
    VkDebugUtilsMessengerEXT *pDebugMessenger)
{
    auto func = (PFN_vkCreateDebugUtilsMessengerEXT)vkGetInstanceProcAddr(instance, "vkCreateDebugUtilsMessengerEXT");
    if (func != nullptr) {
        return func(instance, pCreateInfo, pAllocator, pDebugMessenger);
    }

    return VK_ERROR_EXTENSION_NOT_PRESENT;
}

void DestroyDebugUtilsMessengerEXT(VkInstance instance, VkDebugUtilsMessengerEXT debugMessenger,
    const VkAllocationCallbacks *pAllocator)
{
    auto func = (PFN_vkDestroyDebugUtilsMessengerEXT)vkGetInstanceProcAddr(instance, "vkDestroyDebugUtilsMessengerEXT");
    if (func != nullptr) {
        func(instance, debugMessenger, pAllocator);
    }
}

FG_Mat4x4 ConvertGLMMat4x4ToFGMat4x4(glm::mat4 matrix)
{
    FG_Mat4x4 ret;
    for (uint32_t i = 0U; i < 4U; ++i) {
        for (uint32_t j = 0U; j < 4U; ++j) {
            ret.data[4U * i + j] = matrix[i][j];
        }
    }

    return ret;
}

/**
 * GetPrerotationMatrix handles screen rotation with 3 hardcoded rotation
 * matrices (detailed below). We skip the 180 degrees rotation.
 */
void GetPrerotationMatrix(const VkSurfaceCapabilitiesKHR &capabilities,
    const VkSurfaceTransformFlagBitsKHR &pretransformFlag, std::array<float, 16> &mat)
{
    // mat is initialized to the identity matrix
    mat = { 1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1., 0., 0., 0., 0., 1. };
    if (pretransformFlag & VK_SURFACE_TRANSFORM_ROTATE_90_BIT_KHR) {
        // mat is set to a 90 deg rotation matrix
        mat = { 0., 1., 0., 0., -1., 0, 0., 0., 0., 0., 1., 0., 0., 0., 0., 1. };
        return;
    }

    if (pretransformFlag & VK_SURFACE_TRANSFORM_ROTATE_270_BIT_KHR) {
        // mat is set to 270 deg rotation matrix
        mat = { 0., -1., 0., 0., 1., 0, 0., 0., 0., 0., 1., 0., 0., 0., 0., 1. };
    }
}
} // end of anonymous namespace

void HelloVK::InitVulkan()
{
    CreateInstance();
    CreateSurface();
    PickPhysicalDevice();
    CreateLogicalDeviceAndQueue();
    SetupDebugMessenger();
    EstablishDisplaySizeIdentity();
    CreateSwapChain();
    CreateImageViews();
    FGInitDevice();
    FGCreateCommandPool();
    FGCreateColorResources();
    FGCreateDepthResources();
    VulkanFG::DescriptorPool::Instance().Init();
    FGCreateSwapchainSyncObjects();
    FGInitUIRenderer();
    FGInitMainSceneRenderer();
    FGInitFrameFlowInstance();
    FGCreateFrameFlowResources();

    m_initialized = true;
}

void HelloVK::Reset(OHNativeWindow *newWindow, NativeResourceManager *newManager)
{
    m_window.reset(newWindow);
    m_assetManager = newManager;
    VulkanFG::AAssetImporter::Instance().Init(newManager);

    if (m_initialized) {
        CreateSurface();
        RecreateSwapChain();
    }
}

void HelloVK::RecreateSwapChain()
{
    vkDeviceWaitIdle(m_device);
    CleanupSwapChain();
    if (recreateDisplaySize) {
        EstablishDisplaySizeIdentity();
    }
    CreateSwapChain();
    CreateImageViews();
    FGCreateDepthResources();
    FGCreateSwapchainSyncObjects();

    FGDestroyColorResources();
    FGCreateColorResources();
    FGDestroyUIRenderer();
    FGDestroyMainSceneRenderer();
    FGInitUIRenderer();
    FGInitMainSceneRenderer();
    ResetResolution();
    FGDestroyFrameFlowResources();
    FGCreateFrameFlowResources();
}

void HelloVK::Render()
{
    if (ENABLE_EXTRAPOLATION) {
        FGBalancedExtraRender();
        return;
    }

    if (ENABLE_PRESENT_BY_SYSTEM) {
        FGBalancedPresentBySystemRender();
        return;
    }
    FGBalancedInterRender();
}

void HelloVK::OnOrientationChange()
{
    RecreateSwapChain();
    m_orientationChanged = false;
}

void HelloVK::CleanupSwapChain()
{
    m_sceneDepthStencil.Destroy();

    for (auto const &info : m_swapchainInfo) {
        if (info.renderEnd != VK_NULL_HANDLE) {
            vkDestroySemaphore(m_device, info.renderEnd, nullptr);
        }
    }

    m_swapchainInfo.clear();

    if (m_sceneFramebuffer != VK_NULL_HANDLE) {
        vkDestroyFramebuffer(m_device, m_sceneFramebuffer, nullptr);
        m_sceneFramebuffer = VK_NULL_HANDLE;
    }

    for (size_t i = 0; i < m_swapChainImageViews.size(); i++) {
        vkDestroyImageView(m_device, m_swapChainImageViews[i], nullptr);
    }

    vkDestroySwapchainKHR(m_device, m_swapChain, nullptr);
}

void HelloVK::Recreate() { 
    recreateDisplaySize = true; 
}

void HelloVK::Cleanup()
{
    vkDeviceWaitIdle(m_device);
    FGDestroyFrameFlowResources();
    FGDestroyFlowInstance();
    CleanupSwapChain();

    for (auto &info : m_framesInFlights) {
        if (info.commandPool != VK_NULL_HANDLE) {
            vkDestroyCommandPool(m_device, info.commandPool, nullptr);
        }

        if (info.fence != VK_NULL_HANDLE) {
            vkDestroyFence(m_device, info.fence, nullptr);
        }

        if (info.acquire != VK_NULL_HANDLE) {
            vkDestroySemaphore(m_device, info.acquire, nullptr);
        }
    }

    m_framesInFlights.clear();

    vkDestroyDevice(m_device, nullptr);

    if (ENABLE_VALIDATION_LAYERS) {
        DestroyDebugUtilsMessengerEXT(m_instance, m_debugMessenger, nullptr);
    }

    vkDestroySurfaceKHR(m_instance, m_surface, nullptr);
    vkDestroyInstance(m_instance, nullptr);
    m_initialized = false;
}

void HelloVK::SetupDebugMessenger()
{
    if (!ENABLE_VALIDATION_LAYERS) {
        return;
    }

    VkDebugUtilsMessengerCreateInfoEXT createInfo{};
    PopulateDebugMessengerCreateInfo(createInfo);

    VK_CHECK(CreateDebugUtilsMessengerEXT(m_instance, &createInfo, nullptr, &m_debugMessenger));
}

bool HelloVK::CheckValidationLayerSupport()
{
    uint32_t layerCount;
    vkEnumerateInstanceLayerProperties(&layerCount, nullptr);

    std::vector<VkLayerProperties> availableLayers(layerCount);
    vkEnumerateInstanceLayerProperties(&layerCount, availableLayers.data());

    for (const char *layerName : m_validationLayers) {
        bool layerFound = false;
        for (const auto &layerProperties : availableLayers) {
            GOLOGI("Avalible %s", layerProperties.layerName);
            if (strcmp(layerName, layerProperties.layerName) == 0) {
                layerFound = true;
                break;
            }
        }

        if (!layerFound) {
            return false;
        }
    }

    return true;
}

std::vector<const char *> HelloVK::GetRequiredExtensions(bool enableValidationLayers)
{
    std::vector<const char *> extensions = { VK_KHR_SURFACE_EXTENSION_NAME, VK_OHOS_SURFACE_EXTENSION_NAME };

    if (enableValidationLayers) {
        extensions.push_back(VK_EXT_DEBUG_UTILS_EXTENSION_NAME);
    }

    return extensions;
}

void HelloVK::CreateInstance()
{
    // validation layers requested, but not available!
    if (ENABLE_VALIDATION_LAYERS && !CheckValidationLayerSupport()) {
        GOLOGE("Validation layers are unavailable");
        return;
    }
    auto requiredExtensions = GetRequiredExtensions(ENABLE_VALIDATION_LAYERS);

    VkApplicationInfo appInfo{};
    appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    appInfo.pApplicationName = "Hello Triangle";
    appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.pEngineName = "No Engine";
    appInfo.engineVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.apiVersion = VK_API_VERSION_1_3;

    VkInstanceCreateInfo createInfo{};
    createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    createInfo.pApplicationInfo = &appInfo;
    createInfo.enabledExtensionCount = (uint32_t)requiredExtensions.size();
    createInfo.ppEnabledExtensionNames = requiredExtensions.data();
    createInfo.pApplicationInfo = &appInfo;

    if (ENABLE_VALIDATION_LAYERS) {
        VkDebugUtilsMessengerCreateInfoEXT debugCreateInfo{};
        createInfo.enabledLayerCount = static_cast<uint32_t>(m_validationLayers.size());
        createInfo.ppEnabledLayerNames = m_validationLayers.data();
        PopulateDebugMessengerCreateInfo(debugCreateInfo);
        createInfo.pNext = &debugCreateInfo;
    }

    VK_CHECK(vkCreateInstance(&createInfo, nullptr, &m_instance));

    if (ENABLE_VALIDATION_LAYERS) {
        VulkanFG::SetupDebugLabels(m_instance);
    }

    uint32_t extensionCount = 0;
    vkEnumerateInstanceExtensionProperties(nullptr, &extensionCount, nullptr);
    std::vector<VkExtensionProperties> extensions(extensionCount);
    vkEnumerateInstanceExtensionProperties(nullptr, &extensionCount, extensions.data());
    GOLOGI("available extensions");
    for (const auto &extension : extensions) {
        GOLOGI("\t %s", extension.extensionName);
    }
}

/*
 * CreateSurface can only be called after the ohos ecosystem has had the
 * chance to provide a native window. This happens after the APP_CMD_START event
 * has had a chance to be called.
 *
 * Notice the window.get() call which is only valid after window has been set to
 * a non null value
 */
void HelloVK::CreateSurface()
{
    if (!m_window) {
        GOLOGE("window not initialized");
        return;
    }

    const VkSurfaceCreateInfoOHOS create_info {
        .sType = VK_STRUCTURE_TYPE_SURFACE_CREATE_INFO_OHOS,
        .pNext = nullptr,
        .flags = 0,
        .window = m_window.get()
    };

    VK_CHECK(vkCreateSurfaceOHOS(m_instance, &create_info, nullptr, &m_surface));
}

// BEGIN DEVICE SUITABILITY
// Functions to find a suitable physical device to execute Vulkan commands.

QueueFamilyIndices HelloVK::FindQueueFamilies(VkPhysicalDevice device)
{
    QueueFamilyIndices indices;

    uint32_t queueFamilyCount = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(device, &queueFamilyCount, nullptr);

    std::vector<VkQueueFamilyProperties> queueFamilies(queueFamilyCount);
    vkGetPhysicalDeviceQueueFamilyProperties(device, &queueFamilyCount, queueFamilies.data());

    int i = 0;
    for (const auto &queueFamily : queueFamilies) {
        if (queueFamily.queueFlags & VK_QUEUE_GRAPHICS_BIT) {
            indices.graphicsFamily = i;
        }

        VkBool32 presentSupport = false;
        vkGetPhysicalDeviceSurfaceSupportKHR(device, i, m_surface, &presentSupport);
        if (presentSupport) {
            indices.presentFamily = i;
        }

        if (indices.isComplete()) {
            break;
        }

        ++i;
    }
    return indices;
}

bool HelloVK::CheckDeviceExtensionSupport(VkPhysicalDevice device)
{
    uint32_t extensionCount;
    vkEnumerateDeviceExtensionProperties(device, nullptr, &extensionCount, nullptr);

    std::vector<VkExtensionProperties> availableExtensions(extensionCount);
    vkEnumerateDeviceExtensionProperties(device, nullptr, &extensionCount, availableExtensions.data());

    std::set<std::string> requiredExtensions(m_deviceExtensions.begin(), m_deviceExtensions.end());

    for (const auto &extension : availableExtensions) {
        requiredExtensions.erase(extension.extensionName);
    }

    if (ENABLE_VALIDATION_LAYERS) {
        // Workaround: Probably OHOS Vulkan bug...
        if (requiredExtensions.size() == 1U && *requiredExtensions.cbegin() == VK_KHR_SWAPCHAIN_EXTENSION_NAME) {
            return true;
        }
    }

    return requiredExtensions.empty();
}

SwapChainSupportDetails HelloVK::QuerySwapChainSupport(VkPhysicalDevice device)
{
    SwapChainSupportDetails details;

    vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device, m_surface, &details.capabilities);

    uint32_t formatCount;
    vkGetPhysicalDeviceSurfaceFormatsKHR(device, m_surface, &formatCount, nullptr);

    if (formatCount != 0) {
        details.formats.resize(formatCount);
        vkGetPhysicalDeviceSurfaceFormatsKHR(device, m_surface, &formatCount, details.formats.data());
    }

    uint32_t presentModeCount;
    vkGetPhysicalDeviceSurfacePresentModesKHR(device, m_surface, &presentModeCount, nullptr);

    if (presentModeCount != 0) {
        details.presentModes.resize(presentModeCount);
        vkGetPhysicalDeviceSurfacePresentModesKHR(device, m_surface, &presentModeCount, details.presentModes.data());
    }
    return details;
}

bool HelloVK::IsDeviceSuitable(VkPhysicalDevice device)
{
    QueueFamilyIndices indices = FindQueueFamilies(device);
    bool extensionsSupported = CheckDeviceExtensionSupport(device);
    bool swapChainAdequate = false;
    if (extensionsSupported) {
        SwapChainSupportDetails swapChainSupport = QuerySwapChainSupport(device);
        swapChainAdequate = !swapChainSupport.formats.empty() && !swapChainSupport.presentModes.empty();
    }

    return indices.isComplete() && extensionsSupported && swapChainAdequate;
}

void HelloVK::PickPhysicalDevice()
{
    uint32_t deviceCount = 0;
    vkEnumeratePhysicalDevices(m_instance, &deviceCount, nullptr);

    if (deviceCount <= 0) {
        GOLOGE("failed to find GPUs with Vulkan support!");
        return;
    }

    std::vector<VkPhysicalDevice> devices(deviceCount);
    vkEnumeratePhysicalDevices(m_instance, &deviceCount, devices.data());

    for (const auto &device : devices) {
        if (IsDeviceSuitable(device)) {
            m_physicalDevice = device;
            break;
        }
    }

    if (m_physicalDevice == VK_NULL_HANDLE) {
        GOLOGE("failed to find a suitable GPU!");
        return;
    }

    vkGetPhysicalDeviceFeatures(m_physicalDevice, &m_physicalDeviceFeatures);
    vkGetPhysicalDeviceProperties(m_physicalDevice, &m_physicalDeviceProperties);
}
// END DEVICE SUITABILITY

void HelloVK::CreateLogicalDeviceAndQueue()
{
    QueueFamilyIndices indices = FindQueueFamilies(m_physicalDevice);
    std::vector<VkDeviceQueueCreateInfo> queueCreateInfos;
    std::set<uint32_t> uniqueQueueFamilies = { indices.graphicsFamily.value(), indices.presentFamily.value() };
    float queuePriority = 1.0F;
    for (uint32_t queueFamily : uniqueQueueFamilies) {
        VkDeviceQueueCreateInfo queueCreateInfo{};
        queueCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
        queueCreateInfo.queueFamilyIndex = queueFamily;
        queueCreateInfo.queueCount = 1;
        queueCreateInfo.pQueuePriorities = &queuePriority;
        queueCreateInfos.push_back(queueCreateInfo);
    }

    VkDeviceCreateInfo createInfo{};
    VkPhysicalDeviceFeatures deviceFeatures{};
    VkPhysicalDeviceFloat16Int8FeaturesKHR float16Int8Features{};
    float16Int8Features.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FLOAT16_INT8_FEATURES_KHR;
    float16Int8Features.pNext = nullptr;
    float16Int8Features.shaderFloat16 = VK_TRUE;
    float16Int8Features.shaderInt8 = VK_FALSE;
    createInfo.pNext = &float16Int8Features;

    deviceFeatures.samplerAnisotropy = m_physicalDeviceFeatures.samplerAnisotropy;
    deviceFeatures.shaderInt16 = VK_TRUE;
    deviceFeatures.fragmentStoresAndAtomics = VK_TRUE;

    createInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
    createInfo.queueCreateInfoCount = static_cast<uint32_t>(queueCreateInfos.size());
    createInfo.pQueueCreateInfos = queueCreateInfos.data();
    createInfo.pEnabledFeatures = &deviceFeatures;
    createInfo.enabledExtensionCount = static_cast<uint32_t>(m_deviceExtensions.size());
    createInfo.ppEnabledExtensionNames = m_deviceExtensions.data();

    VK_CHECK(vkCreateDevice(m_physicalDevice, &createInfo, nullptr, &m_device));

    vkGetDeviceQueue(m_device, indices.graphicsFamily.value(), 0, &m_graphicsQueue);
    vkGetDeviceQueue(m_device, indices.presentFamily.value(), 0, &m_presentQueue);
}

void HelloVK::EstablishDisplaySizeIdentity()
{
    VkSurfaceCapabilitiesKHR capabilities;
    vkGetPhysicalDeviceSurfaceCapabilitiesKHR(m_physicalDevice, m_surface, &capabilities);

    float ratio;
    if (capabilities.currentExtent.width < capabilities.currentExtent.height) {
        ratio = static_cast<float>(capabilities.currentExtent.width) / m_resolution;
    } else {
        ratio = static_cast<float>(capabilities.currentExtent.height) / m_resolution;
    }
    capabilities.currentExtent.width = static_cast<uint32_t>(capabilities.currentExtent.width / ratio);
    capabilities.currentExtent.height = static_cast<uint32_t>(capabilities.currentExtent.height / ratio);

    m_displaySizeIdentity = capabilities.currentExtent;
}

void HelloVK::ExecuteCreateSwapChain(VkSwapchainCreateInfoKHR &createInfo, uint32_t imageCount, VkFormat format)
{
    VK_CHECK(vkCreateSwapchainKHR(m_device, &createInfo, nullptr, &m_swapChain));
    vkGetSwapchainImagesKHR(m_device, m_swapChain, &imageCount, nullptr);
    m_swapChainImages.resize(imageCount);
    vkGetSwapchainImagesKHR(m_device, m_swapChain, &imageCount, m_swapChainImages.data());

    for (uint32_t i = 0U; i < imageCount; ++i) {
        char label[256U];
        int iRet = snprintf_s(label, std::size(label), std::size(label), "Swapchain image #%u", i);
        if (iRet == -1) {
            printf("snprintf_s failed, label = %s.\n", label);
        }
        
        VulkanFG::SetLabel(m_device, m_swapChainImages[i], VK_OBJECT_TYPE_IMAGE, label);
    }

    m_swapChainImageFormat = format;
    m_swapChainExtent = m_displaySizeIdentity;
    GOLOGI("create swapchain image count: %u", imageCount);
}

void HelloVK::CreateSwapChain()
{
    SwapChainSupportDetails swapChainSupport = QuerySwapChainSupport(m_physicalDevice);

    auto chooseSwapSurfaceFormat = [](const std::vector<VkSurfaceFormatKHR> &availableFormats) {
        for (const auto &availableFormat : availableFormats) {
            if (availableFormat.format == VK_FORMAT_B8G8R8A8_SRGB &&
                availableFormat.colorSpace == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR) {
                return availableFormat;
            }
        }

        return availableFormats[0];
    };

    VkSurfaceFormatKHR surfaceFormat = chooseSwapSurfaceFormat(swapChainSupport.formats);

    /*
     * Please check
     * https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VkPresentModeKHR.html
     * for a discourse on different present modes.
     *
     * VK_PRESENT_MODE_FIFO_KHR = Hard Vsync
     * This is always supported on ohos phones
     */
    VkPresentModeKHR presentMode = VK_PRESENT_MODE_FIFO_KHR;

    uint32_t imageCount = swapChainSupport.capabilities.minImageCount + 1;
    if (swapChainSupport.capabilities.maxImageCount > 0 && imageCount > swapChainSupport.capabilities.maxImageCount) {
        imageCount = swapChainSupport.capabilities.maxImageCount;
    }
    GOLOGI("minSwapchain image count: %u request: %u", swapChainSupport.capabilities.minImageCount, imageCount);
    m_pretransformFlag = VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR;

    VkSwapchainCreateInfoKHR createInfo{};
    createInfo.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
    createInfo.surface = m_surface;
    createInfo.minImageCount = imageCount;
    createInfo.imageFormat = surfaceFormat.format;
    createInfo.imageColorSpace = surfaceFormat.colorSpace;
    createInfo.imageExtent = m_displaySizeIdentity;
    createInfo.imageArrayLayers = 1;

    createInfo.imageUsage =
        VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK_IMAGE_USAGE_TRANSFER_DST_BIT | VK_IMAGE_USAGE_SAMPLED_BIT;

    createInfo.preTransform = m_pretransformFlag;

    QueueFamilyIndices indices = FindQueueFamilies(m_physicalDevice);
    uint32_t queueFamilyIndices[] = {indices.graphicsFamily.value(), indices.presentFamily.value()};

    if (indices.graphicsFamily != indices.presentFamily) {
        createInfo.imageSharingMode = VK_SHARING_MODE_CONCURRENT;
        createInfo.queueFamilyIndexCount = 2U;
        createInfo.pQueueFamilyIndices = queueFamilyIndices;
    } else {
        createInfo.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE;
        createInfo.queueFamilyIndexCount = 0U;
        createInfo.pQueueFamilyIndices = nullptr;
    }

    createInfo.compositeAlpha = VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR;
    createInfo.presentMode = presentMode;
    createInfo.clipped = VK_TRUE;
    createInfo.oldSwapchain = VK_NULL_HANDLE;

    ExecuteCreateSwapChain(createInfo, imageCount, surfaceFormat.format);
}

void HelloVK::CreateImageViews()
{
    m_swapChainImageViews.resize(m_swapChainImages.size());
    for (size_t i = 0; i < m_swapChainImages.size(); ++i) {
        VkImageViewCreateInfo createInfo{};
        createInfo.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
        createInfo.image = m_swapChainImages[i];
        createInfo.viewType = VK_IMAGE_VIEW_TYPE_2D;
        createInfo.format = m_swapChainImageFormat;
        createInfo.components.r = VK_COMPONENT_SWIZZLE_IDENTITY;
        createInfo.components.g = VK_COMPONENT_SWIZZLE_IDENTITY;
        createInfo.components.b = VK_COMPONENT_SWIZZLE_IDENTITY;
        createInfo.components.a = VK_COMPONENT_SWIZZLE_IDENTITY;
        createInfo.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
        createInfo.subresourceRange.baseMipLevel = 0;
        createInfo.subresourceRange.levelCount = 1;
        createInfo.subresourceRange.baseArrayLayer = 0;
        createInfo.subresourceRange.layerCount = 1;
        VK_CHECK(vkCreateImageView(m_device, &createInfo, nullptr, &m_swapChainImageViews[i]));
    }
}

void HelloVK::Acquire(VkSemaphore acquire)
{
    VkResult const result = vkAcquireNextImageKHR(m_device, m_swapChain, std::numeric_limits<uint64_t>::max(), acquire,
        VK_NULL_HANDLE, &m_imageIndex);
    if (result == VK_SUCCESS) {
        return;
    }

    if (result != VK_ERROR_OUT_OF_DATE_KHR) {
        GOLOGE("Unexpected acquire result: %d", result);
        return;
    }

    RecreateSwapChain();

    VK_CHECK(vkAcquireNextImageKHR(m_device, m_swapChain, std::numeric_limits<uint64_t>::max(), acquire, VK_NULL_HANDLE,
        &m_imageIndex));
}

void HelloVK::Present(VkPresentInfoKHR const &presentInfo)
{
    VkResult const result = vkQueuePresentKHR(m_presentQueue, &presentInfo);
    if (result == VK_SUCCESS) {
        return;
    }

    if (result == VK_SUBOPTIMAL_KHR) {
        m_orientationChanged = true;
        return;
    }

    if (result == VK_ERROR_OUT_OF_DATE_KHR || recreateDisplaySize) {
        RecreateSwapChain();
        recreateDisplaySize = false;
        return;
    }

    GOLOGE("Unexpected present result: %d", result);
}

void HelloVK::FGInitDevice()
{
    VulkanFG::Device::Instance().Init(VulkanFG::Device::DeviceDescriptor()
        .Name("Device")
        .Instance(m_instance)
        .PhysicalDevice(m_physicalDevice)
        .LogicalDevice(m_device)
        .QueueFamilyIndex(0)
        .Queue(m_graphicsQueue));
}

void HelloVK::FGCreateColorResources()
{
    m_sceneColor.Init(VulkanFG::Image::ImageDescriptor()
        .Name("Scene Color")
        .Width(m_swapChainExtent.width)
        .Height(m_swapChainExtent.height)
        .Format(m_swapChainImageFormat)
        .Tile(VK_IMAGE_TILING_OPTIMAL)
        .MemProperties(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
        .InitialLayout(VK_IMAGE_LAYOUT_UNDEFINED)
        .Usage(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK_IMAGE_USAGE_TRANSFER_SRC_BIT | VK_IMAGE_USAGE_SAMPLED_BIT));

    m_sceneColor.GetNativeImageView();

    m_predictedColor.Init(VulkanFG::Image::ImageDescriptor()
        .Name("Predicted Color")
        .Width(m_swapChainExtent.width)
        .Height(m_swapChainExtent.height)
        .Format(m_swapChainImageFormat)
        .Tile(VK_IMAGE_TILING_OPTIMAL)
        .MemProperties(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
        .InitialLayout(VK_IMAGE_LAYOUT_UNDEFINED)
        .Usage(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK_IMAGE_USAGE_TRANSFER_SRC_BIT | VK_IMAGE_USAGE_SAMPLED_BIT));

    m_predictedColor.GetNativeImageView();
}

void HelloVK::FGDestroyColorResources()
{
    m_sceneColor.Destroy();
    m_predictedColor.Destroy();
}

void HelloVK::FGCreateDepthResources()
{
    VkFormat const format = VulkanFG::Device::Instance().FindDepthFormat();

    m_sceneDepthStencil.Init(VulkanFG::Image::ImageDescriptor()
        .Name("Scene Depth/Stencil")
        .Width(m_swapChainExtent.width)
        .Height(m_swapChainExtent.height)
        .Format(format)
        .Tile(VK_IMAGE_TILING_OPTIMAL)
        .MemProperties(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)
        .InitialLayout(VK_IMAGE_LAYOUT_UNDEFINED)
        .Usage(VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT | VK_IMAGE_USAGE_SAMPLED_BIT));

    m_sceneDepthStencil.GetNativeImageView(format, VK_IMAGE_ASPECT_DEPTH_BIT | VK_IMAGE_ASPECT_STENCIL_BIT);
}

void HelloVK::CreateCommandPoolResources(const VkSemaphoreCreateInfo &semaphoreInfo,
    VkCommandPoolCreateInfo const &poolInfo, const VkFenceCreateInfo &fenceInfo,
    VkCommandBufferAllocateInfo &commandBufferAllocateInfo)
{
    for (uint32_t i = 0U; i < VulkanFG::FRAMES_IN_FLIGHT; ++i) {
        FrameInFlight &fif = m_framesInFlights[static_cast<size_t>(i)];
        if (vkCreateSemaphore(m_device, &semaphoreInfo, nullptr, &fif.acquire) != VK_SUCCESS) {
            GOLOGE("Can't create acquire semaphore!");
            return;
        }

        if (vkCreateCommandPool(m_device, &poolInfo, nullptr, &fif.commandPool) != VK_SUCCESS) {
            GOLOGE("Can't create command pool!");
            return;
        }

        commandBufferAllocateInfo.commandPool = fif.commandPool;
        if (vkAllocateCommandBuffers(m_device, &commandBufferAllocateInfo, &fif.commandBuffer) != VK_SUCCESS) {
            GOLOGE("Can't create command buffer!");
            return;
        }

        char label[256U];
        int iRet = snprintf_s(label, std::size(label), std::size(label), "FiF #%u", i);
        if (iRet == -1) {
            printf("snprintf_s failed, label = %s.\n", label);
        }
        VulkanFG::SetLabel(m_device, fif.commandBuffer, VK_OBJECT_TYPE_COMMAND_BUFFER, label);

        if (vkCreateFence(m_device, &fenceInfo, nullptr, &fif.fence) != VK_SUCCESS) {
            GOLOGE("Can't create fence!");
            return;
        }
    }
}

void HelloVK::FGCreateCommandPool()
{
    VulkanFG::CommandPool::Instance().Init(VulkanFG::CommandPool::CommandPoolDescriptor()
        .Name("CommandPool")
        .Device(m_device)
        .Flags(0U)
        .QueueFamilyIndex(VulkanFG::Device::Instance().GetQueueFamilyIndex())
        .Queue(VulkanFG::Device::Instance().GetNativeQueue()));

    constexpr VkSemaphoreCreateInfo semaphoreInfo {
        .sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U
    };

    VkCommandPoolCreateInfo const poolInfo {
        .sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
        .pNext = nullptr,
        .flags = VK_COMMAND_POOL_CREATE_TRANSIENT_BIT,
        .queueFamilyIndex = VulkanFG::Device::Instance().GetQueueFamilyIndex()
    };

    constexpr VkFenceCreateInfo fenceInfo {
        .sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO,
        .pNext = nullptr,
        .flags = VK_FENCE_CREATE_SIGNALED_BIT
    };

    VkCommandBufferAllocateInfo commandBufferAllocateInfo {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .pNext = nullptr,
        .commandPool = VK_NULL_HANDLE,
        .level = VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        .commandBufferCount = 1U
    };

    m_framesInFlights.clear();
    m_framesInFlights.resize(VulkanFG::FRAMES_IN_FLIGHT);
    m_writingCommandBufferIdx = 0U;

    CreateCommandPoolResources(semaphoreInfo, poolInfo, fenceInfo, commandBufferAllocateInfo);
}

void HelloVK::FGCreateSwapchainSyncObjects()
{
    size_t const count = m_swapChainImages.size();
    m_swapchainInfo.clear();
    m_swapchainInfo.resize(count);

    constexpr VkSemaphoreCreateInfo semaphoreInfo {
        .sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U
    };

    for (auto &info : m_swapchainInfo) {
        if (vkCreateSemaphore(m_device, &semaphoreInfo, nullptr, &info.renderEnd) != VK_SUCCESS) {
            GOLOGE("Can't create render end semaphore!");
            return;
        }
    }
}

void HelloVK::FGInitUIRenderer()
{
    VulkanFG::UIRenderer::UIRendererDescriptor desc{};
    desc.frameInFlightNum = VulkanFG::FRAMES_IN_FLIGHT;
    desc.frameBufferNum = m_swapChainImages.size();
    desc.canvasWidth = m_swapChainExtent.width;
    desc.canvasHeight = m_swapChainExtent.height;
    desc.colorFormat = m_swapChainImageFormat;

    for (auto &item : m_swapChainImageViews) {
        desc.colorImageViews.push_back(item);
    }

    VulkanFG::UIRenderer &renderer = VulkanFG::UIRenderer::Instance();
    renderer.Init(desc);

    m_sceneColorBackground = renderer.MakeBackground(m_sceneColor);
    m_predictedColorBackground = renderer.MakeBackground(m_predictedColor);
}

void HelloVK::FGInitMainSceneRenderer()
{
    VulkanFG::MainSceneRenderer &sceneRenderer = VulkanFG::MainSceneRenderer::Instance();

    sceneRenderer.Init(VulkanFG::MainSceneRenderer::MainSceneRendererDescriptor {
        .frameInFlightNum = VulkanFG::FRAMES_IN_FLIGHT,
        .frameBufferNum = VulkanFG::FRAMES_IN_FLIGHT,
        .frameBufferWidth = m_swapChainExtent.width,
        .frameBufferHeight = m_swapChainExtent.height,
        .colorFormat = m_sceneColor.GetFormat(),
        .depthStencilFormat = m_sceneDepthStencil.GetFormat()
    });

    VkImageView const attachments[] = {m_sceneColor.GetNativeImageView(), m_sceneDepthStencil.GetNativeImageView()};

    VkFramebufferCreateInfo framebufferInfo {
        .sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .renderPass = sceneRenderer.GetRenderPass(),
        .attachmentCount = static_cast<uint32_t>(std::size(attachments)),
        .pAttachments = attachments,
        .width = m_swapChainExtent.width,
        .height = m_swapChainExtent.height,
        .layers = 1U
    };

    if (vkCreateFramebuffer(m_device, &framebufferInfo, nullptr, &m_sceneFramebuffer) != VK_SUCCESS) {
        GOLOGE("Can't create scene framebuffer!");
    }
}

void HelloVK::FGDestroyUIRenderer()
{
    VulkanFG::UIRenderer::Instance().Destroy();
}

void HelloVK::FGDestroyMainSceneRenderer()
{
    VulkanFG::MainSceneRenderer::Instance().Destroy();
}
FG_DispatchDescription_VK HelloVK::GetFGDispatchDescription(VkCommandBuffer commandBuffer, uint8_t fifIndex)
{
     dispatch = {
        .inputColorInfo = {
            .image = m_ffSceneColor,

            .initialSync {
                .accessMask = VK_ACCESS_SHADER_READ_BIT,
                .layout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                .stages = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
            },

            .finalSync {
                .accessMask = VK_ACCESS_SHADER_READ_BIT,
                .layout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                .stages = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
            }
        },

        .outputColorInfo = {
            .image = m_ffPredictedColor,

            .initialSync {
                .accessMask = VK_ACCESS_SHADER_READ_BIT,
                .layout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                .stages = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
            },

            .finalSync {
                .accessMask = VK_ACCESS_SHADER_READ_BIT,
                .layout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                .stages = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
            }
        },

        .viewProj = m_viewProj,
        .invViewProj = m_invViewProj,
        .vkCommandBuffer = commandBuffer,
        .frameIdx = fifIndex
    };

    if (!ENABLE_AI_PREDICTION) {
        dispatch.inputDepthStencilInfo = {
            .image = m_ffDepthStencil,

            .initialSync {
                .accessMask = VK_ACCESS_SHADER_READ_BIT,
                .layout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                .stages = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
            },

            .finalSync {
                .accessMask = VK_ACCESS_SHADER_READ_BIT,
                .layout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL,
                .stages = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
            }
        };
    }
    return dispatch;
}

std::optional<FG_ErrorCode> HelloVK::FGDispatch(VkCommandBuffer commandBuffer, uint8_t fifIndex)
{
    FG_DispatchDescription_VK dispatch = GetFGDispatchDescription(commandBuffer, fifIndex);

    if (m_predictedFrameFirstUsage) {
        FG_ImageSync_VK &outInitial = dispatch.outputColorInfo.initialSync;
        outInitial.accessMask = VK_ACCESS_NONE;
        outInitial.layout = VK_IMAGE_LAYOUT_UNDEFINED;
        outInitial.stages = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT;
    }

    FG_ErrorCode const code = HMS_FG_Dispatch_VK(m_context, &dispatch);
    if ((code == FG_SUCCESS) | (code == FG_COLLECTING_PREVIOUS_FRAMES)) {
        return code;
    }

    GOLOGE("Unexpected result when drawing inter ff frame: %u", code);
    return std::nullopt;
}

void HelloVK::CreateFGContext()
{
    FG_ContextDescription_VK contextDescription{};
    contextDescription.vkInstance = VulkanFG::Device::Instance().GetNativeInstance();
    contextDescription.vkPhysicalDevice = VulkanFG::Device::Instance().GetNativePhysicalDevice();
    contextDescription.vkDevice = VulkanFG::Device::Instance().GetNativeDevice();
    contextDescription.framesInFlight = static_cast<uint8_t>(VulkanFG::FRAMES_IN_FLIGHT);
    contextDescription.fnVulkanLoaderFunction = vkGetInstanceProcAddr;
    m_context = HMS_FG_CreateContext_VK(&contextDescription);
    if (!m_context) {
        GOLOGE("HMS_FG_CreateContext_VK execution failed");
        return;
    }
}

void HelloVK::FGInitFrameFlowInstance()
{
    CreateFGContext();
    
    FG_AlgorithmModeInfo aInfo{};
    aInfo.predictionMode = ENABLE_EXTRAPOLATION ? FG_PREDICTION_MODE_EXTRAPOLATION : FG_PREDICTION_MODE_INTERPOLATION;
    aInfo.meMode = ENABLE_VBMV ? FG_ME_MODE_ENHANCED : FG_ME_MODE_BASIC;

    if(ENABLE_VBMV){
        VkQueryPoolCreateInfo createInfo{};
        createInfo.sType = VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO;
        createInfo.queryType = VK_QUERY_TYPE_HISS_MOTION_VECTOR_DRAW_TRACKING_HUAWEI;
        createInfo.queryCount = 1;
        vkCreateQueryPool(m_device, &createInfo, nullptr, &m_queryPool);
    }
    FG_ErrorCode errorCode = HMS_FG_SetAlgorithmMode_VK(m_context, &aInfo);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_SetAlgorithmMode_VK execution failed, error code: %d.", errorCode);
        return;
    }

    FG_Dimension2D inputColorResolution{};
    inputColorResolution.width = m_swapChainExtent.width;
    inputColorResolution.height = m_swapChainExtent.height;
    FG_Dimension2D inputDepthStencilResolution{};
    inputDepthStencilResolution.width = m_swapChainExtent.width;
    inputDepthStencilResolution.height = m_swapChainExtent.height;
    FG_Dimension2D outputColorResolution{};
    outputColorResolution.width = m_swapChainExtent.width;
    outputColorResolution.height = m_swapChainExtent.height;
    FG_ResolutionInfo rInfo{};
    rInfo.inputColorResolution = inputColorResolution;
    rInfo.inputDepthStencilResolution = inputDepthStencilResolution;
    rInfo.outputColorResolution = outputColorResolution;

    errorCode = HMS_FG_SetResolution_VK(m_context, &rInfo);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_SetResolution_VK execution failed, error code: %d.", errorCode);
        return;
    }

    errorCode = HMS_FG_SetCvvZSemantic_VK(m_context, FG_CVV_Z_SEMANTIC_ZERO_TO_ONE_FORWARD_Z);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_SetCvvZSemantic_VK execution failed, error code: %d.", errorCode);
        return;
    }

    FG_ImageFormat_VK imageFormat{};
    imageFormat.inputColorFormat = m_swapChainImageFormat;
    imageFormat.inputDepthStencilFormat = m_sceneDepthStencil.GetFormat();
    imageFormat.outputColorFormat = m_swapChainImageFormat;

    errorCode = HMS_FG_SetImageFormat_VK(m_context, &imageFormat);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_SetImageFormat_VK execution failed, error code: %d.", errorCode);
        return;
    }
    
    if (ENABLE_PRESENT_BY_SYSTEM) {
        FG_IntegrationInfo integrationInfo {};
        integrationInfo.presentMode = FG_PRESENT_BY_SYSTEM;
        integrationInfo.textureCachedByGame = false;
        integrationInfo.needFlipInputColor = false;
        integrationInfo.needFlipOutputColor = false;
    
        errorCode = HMS_FG_SetIntegrationMode_VK(m_context, &integrationInfo);
        if (errorCode != FG_SUCCESS) {
            return;
        }
    }

    FGSetPredictionState(true);
}

void HelloVK::FGDestroyFlowInstance()
{
    FG_ErrorCode errorCode = HMS_FG_Deactivate_VK(m_context);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_Deactivate_VK execution failed, error code: %d", errorCode);
        return;
    }
    errorCode = HMS_FG_DestroyContext_VK(&m_context);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_DestroyContext_VK execution failed, error code: %d", errorCode);
        return;
    }
}

void HelloVK::FGCreateFrameFlowResources()
{
    m_ffSceneColor = HMS_FG_CreateImage_VK(m_context, m_sceneColor.GetNativeImage(), m_sceneColor.GetNativeImageView());
    if (!m_ffSceneColor) {
        GOLOGE("HMS_FG_RegisterImage_VK m_ffSceneColor execution failed.");
        return;
    }

    m_ffDepthStencil = HMS_FG_CreateImage_VK(m_context, m_sceneDepthStencil.GetNativeImage(),
        m_sceneDepthStencil.GetNativeImageView());
    if (!m_ffDepthStencil) {
        GOLOGE("HMS_FG_RegisterImage_VK m_ffDepthStencil execution failed.");
        return;
    }

    m_ffPredictedColor =
        HMS_FG_CreateImage_VK(m_context, m_predictedColor.GetNativeImage(), m_predictedColor.GetNativeImageView());
    if (!m_ffPredictedColor) {
        GOLOGE("HMS_FG_RegisterImage_VK m_ffPredictedColor execution failed.");
        return;
    }
}

void HelloVK::FGDestroyFrameFlowResources()
{
    FG_ErrorCode errorCode = HMS_FG_DestroyImage_VK(m_context, m_ffSceneColor);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_UnregisterImage_VK m_ffSceneColor execution failed.");
        return;
    }

    errorCode = HMS_FG_DestroyImage_VK(m_context, m_ffDepthStencil);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_UnregisterImage_VK m_ffDepthStencil execution failed.");
        return;
    }

    errorCode = HMS_FG_DestroyImage_VK(m_context, m_ffPredictedColor);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_UnregisterImage_VK m_ffPredictedColor execution failed.");
        return;
    }
}

VkSubmitInfo HelloVK::CreateSubmitInfo(FrameInFlight *fif, const VkPipelineStageFlags &waitStage)
{
    VkSubmitInfo submitInfo{
        .sType = VK_STRUCTURE_TYPE_SUBMIT_INFO,
        .pNext = nullptr,
        .waitSemaphoreCount = 1U,
        .pWaitSemaphores = &fif->acquire,
        .pWaitDstStageMask = &waitStage,
        .commandBufferCount = 1U,
        .pCommandBuffers = &fif->commandBuffer,
        .signalSemaphoreCount = 1U,
        .pSignalSemaphores = &m_swapchainInfo[m_imageIndex].renderEnd
    };

    return submitInfo;
}

VkPresentInfoKHR HelloVK::CreatePresentInfo(VkResult &presentResult)
{
    static VkPresentInfoKHR presentInfo{
        .sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
        .pNext = nullptr,
        .waitSemaphoreCount = 1U,
        .pWaitSemaphores = &m_swapchainInfo[m_imageIndex].renderEnd,
        .swapchainCount = 1U,
        .pSwapchains = &m_swapChain,
        .pImageIndices = &m_imageIndex,
        .pResults = &presentResult
    };

    return presentInfo;
}

void HelloVK::InterGeneratePredictedFrame(FrameInFlight *fif, uint8_t fifIndex, VulkanFG::UIRenderer &uiRenderer)
{
    // SDK collected enough data and successfully predicted frame. Presenting predicted frame and UI...
    m_predictedFrameFirstUsage = false;

    uiRenderer.Draw(fif->commandBuffer, m_imageIndex, static_cast<uint32_t>(fifIndex), m_predictedColorBackground);

    VK_CHECK(vkEndCommandBuffer(fif->commandBuffer));

    constexpr VkPipelineStageFlags waitStage = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT |
        VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT | VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT;

    VkSubmitInfo const submitInfo = CreateSubmitInfo(fif, waitStage);

    VK_CHECK(vkQueueSubmit(m_graphicsQueue, 1U, &submitInfo, fif->fence));

    VkResult presentResult;

    VkPresentInfoKHR const presentInfo = CreatePresentInfo(presentResult);

    Present(presentInfo);

    fif = &m_framesInFlights[m_writingCommandBufferIdx];

    UpdateWritingCommandBufferIdx();
}

VkCommandBufferBeginInfo HelloVK::CreateBeginInfo()
{
    VkCommandBufferBeginInfo beginCB{
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
        .pNext = nullptr,
        .flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
        .pInheritanceInfo = nullptr
    };

    return beginCB;
}

void HelloVK::RenderAndUpdateCameraInfo(VulkanFG::MainSceneRenderer &sceneRenderer, FrameInFlight *fif,
    uint8_t fifIndex)
{
	if (ENABLE_VBMV) {
		vkCmdBeginQuery(fif->commandBuffer, m_queryPool, 0, 0);
    }
    sceneRenderer.Render(fif->commandBuffer, m_sceneFramebuffer, static_cast<size_t>(fifIndex));
    if (ENABLE_VBMV) {
        vkCmdEndQuery(fif->commandBuffer, m_queryPool, 0);
    }
		
    m_viewProj = ConvertGLMMat4x4ToFGMat4x4(sceneRenderer.GetSceneViewProjMatrix());
    m_invViewProj = ConvertGLMMat4x4ToFGMat4x4(glm::inverse(sceneRenderer.GetSceneViewProjMatrix()));
}

void HelloVK::UpdateWritingCommandBufferIdx()
{
    ++m_writingCommandBufferIdx;
    m_writingCommandBufferIdx = m_writingCommandBufferIdx % static_cast<size_t>(VulkanFG::FRAMES_IN_FLIGHT);
}

void HelloVK::ResetStatus(FrameInFlight *fif, VkCommandBufferBeginInfo &beginCB)
{
    Acquire(fif->acquire);

    VK_CHECK(vkResetFences(m_device, 1U, &fif->fence));
    VK_CHECK(vkResetCommandPool(m_device, fif->commandPool, 0U));
    VK_CHECK(vkBeginCommandBuffer(fif->commandBuffer, &beginCB));
}

void HelloVK::ResetStatus(FrameInFlight *fif)
{
    Acquire(fif->acquire);

    VK_CHECK(vkResetFences(m_device, 1U, &fif->fence));
    VK_CHECK(vkResetCommandPool(m_device, fif->commandPool, 0U));
}

void HelloVK::InterRealFrameDisplay(FrameInFlight *fif)
{
    constexpr VkPipelineStageFlags waitStage = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT |
        VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT | VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT;

    VkSubmitInfo const submitInfo = CreateSubmitInfo(fif, waitStage);

    VK_CHECK(vkQueueSubmit(m_graphicsQueue, 1U, &submitInfo, fif->fence));

    VkResult presentResult;

    VkPresentInfoKHR const presentInfo = CreatePresentInfo(presentResult);

    Present(presentInfo);
}

void HelloVK::ExtraGeneratePredictedFrame(FrameInFlight *fif, uint8_t fifIndex, VulkanFG::UIRenderer &uiRenderer,
    VkSubmitInfo &submitInfo, VkPresentInfoKHR &presentInfo)
{
    auto const code = FGDispatch(fif->commandBuffer, fifIndex);
    if (!code) {
        return;
    }

    // Rendering predicted frame...
    submitInfo.pCommandBuffers = &fif->commandBuffer;

    if (*code != FG_SUCCESS) {
        m_unfinishedCommandBuffer = true;
        return;
    }

    m_predictedFrameFirstUsage = false;
    uiRenderer.Draw(fif->commandBuffer, m_imageIndex, static_cast<uint32_t>(fifIndex), m_predictedColorBackground);

    VK_CHECK(vkEndCommandBuffer(fif->commandBuffer));

    submitInfo.pWaitSemaphores = &fif->acquire;
    submitInfo.pCommandBuffers = &fif->commandBuffer;
    submitInfo.pSignalSemaphores = &m_swapchainInfo[m_imageIndex].renderEnd;
    VK_CHECK(vkQueueSubmit(m_graphicsQueue, 1U, &submitInfo, fif->fence));

    presentInfo.pWaitSemaphores = &m_swapchainInfo[m_imageIndex].renderEnd;
    presentInfo.pImageIndices = &m_imageIndex;
    Present(presentInfo);
}

void HelloVK::FGBalancedInterRender()
{
    /*
     * Balancing workload by moving generation new real frame together with output of the previous real frame.
     * You should understand that frame output is very cheap operation. Usually it's just screen quad or blit.
     * Without such reordering the rendering will be very unbalanced from GPU workload point of view:
     * 1) rendering real frame and save result to image (heavy)
     * 2) rendering predicted frame (heavy operation)
     * 3) apply UI (light operation)
     * 4) present predicted frame (commit, two heavy and one light operations)
     * 5) rendering image of real frame (light operation)
     * 6) apply UI (light operation)
     * 7) present real frame (commit, two light operations)
     *
     * To eliminate such issue the order should be the following:
     * 1) rendering predicted frame (heavy operation)
     * 2) apply UI (light operation)
     * 3) present predicted frame (commit, one heavy and one light operations)
     * 4) blit previous real frame from image (light operation)
     * 5) apply UI (light operation)
     * 6) rendering next real frame and save result to image (heavy operation)
     * 7) present real frame (commit, one heavy and two light operations)
     */

    if (!m_window) {
        return;
    }

    if (m_orientationChanged) {
        OnOrientationChange();
    }

    auto const fifIndex = static_cast<uint8_t>(m_writingCommandBufferIdx);
    FrameInFlight *fif = &m_framesInFlights[m_writingCommandBufferIdx];
    UpdateWritingCommandBufferIdx();

    VK_CHECK(vkWaitForFences(m_device, 1U, &fif->fence, VK_TRUE, std::numeric_limits<uint64_t>::max()));

    ResetStatus(fif);

    VkCommandBufferBeginInfo beginCB = CreateBeginInfo();

    VK_CHECK(vkBeginCommandBuffer(fif->commandBuffer, &beginCB));

    VulkanFG::MainSceneRenderer &sceneRenderer = VulkanFG::MainSceneRenderer::Instance();
    sceneRenderer.Update(static_cast<uint32_t>(fifIndex));

    VulkanFG::UIRenderer &uiRenderer = VulkanFG::UIRenderer::Instance();
    uiRenderer.Update(static_cast<uint32_t>(fifIndex));

    if (!m_realFrameCollected) {
        RenderAndUpdateCameraInfo(sceneRenderer, fif, fifIndex);
    } else {
        m_realFrameCollected = false;
    }

    bool const runPrediction = m_predictionEnabled & !m_predictionPaused;
    if (runPrediction) {
        auto const code = FGDispatch(fif->commandBuffer, fifIndex);
        if (!code) {
            GOLOGE("FGDispatch fail, errCode: %d", code);
        }

        if (*code == FG_SUCCESS) {
            InterGeneratePredictedFrame(fif, fifIndex, uiRenderer);

            VK_CHECK(vkWaitForFences(m_device, 1U, &fif->fence, VK_TRUE, std::numeric_limits<uint64_t>::max()));

            ResetStatus(fif, beginCB);
        }
    }

    uiRenderer.Draw(fif->commandBuffer, m_imageIndex, static_cast<uint32_t>(fifIndex), m_sceneColorBackground);

    if (runPrediction) {
        /*
         * Balancing work by making new real frame. This is usually heavy GPU call.
         * Pay attention that 'recordSceneCommandBuffer' before prediction block will be skipped
         * on next 'FGBalancedInterRender' call because of m_realFrameCollected flag.
         */
        RenderAndUpdateCameraInfo(sceneRenderer, fif, fifIndex);
        m_realFrameCollected = true;
    }

    VK_CHECK(vkEndCommandBuffer(fif->commandBuffer));

    InterRealFrameDisplay(fif);
}

void HelloVK::FGBalancedExtraRender()
{
    if (!m_window) {
        return;
    }

    if (m_orientationChanged) {
        OnOrientationChange();
    }

    VkCommandBufferBeginInfo beginCB = CreateBeginInfo();

    auto fifIndex = static_cast<uint8_t>(m_writingCommandBufferIdx);
    FrameInFlight *fif = &m_framesInFlights[m_writingCommandBufferIdx];

    if (m_unfinishedCommandBuffer) {
        size_t const cases[] = {m_writingCommandBufferIdx - 1U, static_cast<size_t>(VulkanFG::FRAMES_IN_FLIGHT - 1U)};
        m_writingCommandBufferIdx = cases[static_cast<size_t>(m_writingCommandBufferIdx == 0U)];

        fifIndex = static_cast<uint8_t>(m_writingCommandBufferIdx);
        fif = &m_framesInFlights[m_writingCommandBufferIdx];
    } else {
        VK_CHECK(vkWaitForFences(m_device, 1U, &fif->fence, VK_TRUE, std::numeric_limits<uint64_t>::max()));

        ResetStatus(fif, beginCB);
    }

    UpdateWritingCommandBufferIdx();

    VulkanFG::MainSceneRenderer &sceneRenderer = VulkanFG::MainSceneRenderer::Instance();
    sceneRenderer.Update(static_cast<uint32_t>(fifIndex));

    VulkanFG::UIRenderer &uiRenderer = VulkanFG::UIRenderer::Instance();
    uiRenderer.Update(static_cast<uint32_t>(fifIndex));

    // Showing real frame...
    RenderAndUpdateCameraInfo(sceneRenderer, fif, fifIndex);

    uiRenderer.Draw(fif->commandBuffer, m_imageIndex, static_cast<uint32_t>(fifIndex), m_sceneColorBackground);

    VK_CHECK(vkEndCommandBuffer(fif->commandBuffer));

    constexpr VkPipelineStageFlags waitStage = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT |
        VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT | VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT;

    VkSubmitInfo submitInfo = CreateSubmitInfo(fif, waitStage);

    VK_CHECK(vkQueueSubmit(m_graphicsQueue, 1U, &submitInfo, fif->fence));
    m_unfinishedCommandBuffer = false;

    VkResult presentResult;

    VkPresentInfoKHR presentInfo = CreatePresentInfo(presentResult);

    Present(presentInfo);

    if (!m_predictionEnabled | m_predictionPaused) {
        return;
    }

    fif = &m_framesInFlights[m_writingCommandBufferIdx];
    UpdateWritingCommandBufferIdx();

    VK_CHECK(vkWaitForFences(m_device, 1U, &fif->fence, VK_TRUE, std::numeric_limits<uint64_t>::max()));

    ResetStatus(fif, beginCB);

    // Showing predicted frame...
    auto const code = FGDispatch(fif->commandBuffer, fifIndex);

    if (!code) {
        GOLOGE("FGDispatch fail, errCode: %d", code);
    }
    // Rendering predicted frame...
    ExtraGeneratePredictedFrame(fif, fifIndex, uiRenderer, submitInfo, presentInfo);
}

void HelloVK::FGBalancedPresentBySystemRender() {
    if (!m_window) {
        return;
    }

    if (m_orientationChanged) {
        OnOrientationChange();
    }

    auto const fifIndex = static_cast<uint8_t>(m_writingCommandBufferIdx);
    FrameInFlight *fif = &m_framesInFlights[m_writingCommandBufferIdx];
    m_writingCommandBufferIdx = ++m_writingCommandBufferIdx % static_cast<size_t>(VulkanFG::FRAMES_IN_FLIGHT);

    VK_CHECK(vkWaitForFences(m_device, 1U, &fif->fence, VK_TRUE, std::numeric_limits<uint64_t>::max()));

    Acquire(fif->acquire);

    VK_CHECK(vkResetFences(m_device, 1U, &fif->fence));
    VK_CHECK(vkResetCommandPool(m_device, fif->commandPool, 0U));

    // clang-format off
    constexpr VkCommandBufferBeginInfo beginCB {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
        .pNext = nullptr,
        .flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
        .pInheritanceInfo = nullptr
    };
    // clang-format on

    VK_CHECK(vkBeginCommandBuffer(fif->commandBuffer, &beginCB));

    VulkanFG::MainSceneRenderer &sceneRenderer = VulkanFG::MainSceneRenderer::Instance();
    sceneRenderer.Update(static_cast<uint32_t>(fifIndex));

    VulkanFG::UIRenderer &uiRenderer = VulkanFG::UIRenderer::Instance();
    uiRenderer.Update(static_cast<uint32_t>(fifIndex));

    sceneRenderer.Render(fif->commandBuffer, m_sceneFramebuffer, static_cast<size_t>(fifIndex));
    m_viewProj = ConvertGLMMat4x4ToFGMat4x4(sceneRenderer.GetSceneViewProjMatrix());
    m_invViewProj = ConvertGLMMat4x4ToFGMat4x4(glm::inverse(sceneRenderer.GetSceneViewProjMatrix()));

    bool const runPrediction = m_predictionEnabled & !m_predictionPaused;
    if (runPrediction) {
        auto const code = FGDispatch(fif->commandBuffer, fifIndex);

        if (!code) {
            GOLOGE("FGDispatch fail, errCode: %d", code);
        }
    }

    uiRenderer.Draw(fif->commandBuffer, m_imageIndex, static_cast<uint32_t>(fifIndex), m_sceneColorBackground);

    VK_CHECK(vkEndCommandBuffer(fif->commandBuffer));

    constexpr VkPipelineStageFlags waitStage = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT |
                                               VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT |
                                               VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT;

    // clang-format off
    VkSubmitInfo const submitInfo {
        .sType = VK_STRUCTURE_TYPE_SUBMIT_INFO,
        .pNext = nullptr,
        .waitSemaphoreCount = 1U,
        .pWaitSemaphores = &fif->acquire,
        .pWaitDstStageMask = &waitStage,
        .commandBufferCount = 1U,
        .pCommandBuffers = &fif->commandBuffer,
        .signalSemaphoreCount = 1U,
        .pSignalSemaphores = &m_swapchainInfo[m_imageIndex].renderEnd
    };
    // clang-format on

    VK_CHECK(vkQueueSubmit(m_graphicsQueue, 1U, &submitInfo, fif->fence));

    VkResult presentResult;

    // clang-format off
    VkPresentInfoKHR const presentInfo {
        .sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
        .pNext = nullptr,
        .waitSemaphoreCount = 1U,
        .pWaitSemaphores = &m_swapchainInfo[m_imageIndex].renderEnd,
        .swapchainCount = 1U,
        .pSwapchains = &m_swapChain,
        .pImageIndices = &m_imageIndex,
        .pResults = &presentResult
    };
    // clang-format on

    Present(presentInfo);
}

void HelloVK::FGSetPredictionState(bool enable)
{
    m_predictionEnabled = enable;

    if (enable) {
        if (!m_predictionPaused) {
            return;
        }

        m_predictionPaused = HMS_FG_Activate_VK(m_context) != FG_SUCCESS;
        return;
    }

    if (!m_predictionPaused) {
        m_predictionPaused = HMS_FG_Deactivate_VK(m_context) == FG_SUCCESS;
    }
}

void HelloVK::ResetResolution() {
    if (recreateDisplaySize) {
        FG_Dimension2D inputColorResolution{};
        inputColorResolution.width = m_swapChainExtent.width;
        inputColorResolution.height = m_swapChainExtent.height;
        FG_Dimension2D inputDepthStencilResolution{};
        inputDepthStencilResolution.width = m_swapChainExtent.width;
        inputDepthStencilResolution.height = m_swapChainExtent.height;
        FG_Dimension2D outputColorResolution{};
        outputColorResolution.width = m_swapChainExtent.width;
        outputColorResolution.height = m_swapChainExtent.height;
        FG_ResolutionInfo rInfo{};
        rInfo.inputColorResolution = inputColorResolution;
        rInfo.inputDepthStencilResolution = inputDepthStencilResolution;
        rInfo.outputColorResolution = outputColorResolution;
    
        if (HMS_FG_SetResolution_VK(m_context, &rInfo) != FG_SUCCESS) {
            GOLOGE("HMS_FG_SetResolution_VK execution failed");
        }
    }
}
} // namespace vkt