/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#pragma once
#include <native_window/external_window.h>
#include <rawfile/raw_file_manager.h>
#include <optional>
#include <vector>
#include <Image.h>
#include <UIRenderer.h>
#include <MainSceneRenderer.h>
#include <graphics_game_sdk/frame_generation_vk.h>

/**
 * HelloVK contains the core of Vulkan pipeline setup. It includes recording
 * draw commands as well as screen clearing during the render pass.
 *
 * Please refer to: https://vulkan-tutorial.com/ for a gentle Vulkan
 * introduction.
 */

namespace vkt {
struct QueueFamilyIndices final {
    std::optional<uint32_t> graphicsFamily;
    std::optional<uint32_t> presentFamily;

    bool isComplete()
    {
        return graphicsFamily.has_value() && presentFamily.has_value();
    }
};

struct SwapChainSupportDetails final {
    VkSurfaceCapabilitiesKHR capabilities;
    std::vector<VkSurfaceFormatKHR> formats;
    std::vector<VkPresentModeKHR> presentModes;
};

struct ANativeWindowDeleter final {
    void operator () (OHNativeWindow *window)
    {
        OH_NativeWindow_DestroyNativeWindow(window);
    }
};

class HelloVK {
public:
    void InitVulkan();
    void Render();
    void Cleanup();
    void CleanupSwapChain();
    void Reset(OHNativeWindow *newWindow, NativeResourceManager *newManager);
    void FGSetPredictionState(bool enable);
	void Recreate();

    bool m_initialized = false;
    static bool ENABLE_EXTRAPOLATION;

private:
    struct SwapchainInfo final {
        VkSemaphore renderEnd = VK_NULL_HANDLE;
    };

    struct FrameInFlight final {
        VkCommandPool commandPool = VK_NULL_HANDLE;
        VkCommandBuffer commandBuffer = VK_NULL_HANDLE;
        VkSemaphore acquire = VK_NULL_HANDLE;
        VkFence fence = VK_NULL_HANDLE;
    };

    void CreateInstance();
    void CreateSurface();
    void SetupDebugMessenger();
    void PickPhysicalDevice();
    void CreateLogicalDeviceAndQueue();
    void CreateSwapChain();
    void CreateImageViews();
    [[nodiscard]] QueueFamilyIndices FindQueueFamilies(VkPhysicalDevice device);
    [[nodiscard]] bool CheckDeviceExtensionSupport(VkPhysicalDevice device);
    [[nodiscard]] bool IsDeviceSuitable(VkPhysicalDevice device);
    [[nodiscard]] bool CheckValidationLayerSupport();
    [[nodiscard]] std::vector<const char *> GetRequiredExtensions(bool enableValidation);
    [[nodiscard]] SwapChainSupportDetails QuerySwapChainSupport(VkPhysicalDevice device);
    void RecreateSwapChain();
    void OnOrientationChange();
    void EstablishDisplaySizeIdentity();
	void ResetResolution();

    void Acquire(VkSemaphore acquire);
    void Present(VkPresentInfoKHR const &presentInfo);

    void FGInitDevice();
    void FGInitUIRenderer();
    void FGDestroyUIRenderer();
    void FGInitMainSceneRenderer();
    void FGDestroyMainSceneRenderer();
    void FGCreateColorResources();
    void FGCreateDepthResources();
    void FGCreateCommandPool();
    void FGCreateSwapchainSyncObjects();
    void FGDestroyColorResources();
    [[nodiscard]] std::optional<FG_ErrorCode> FGDispatch(VkCommandBuffer commandBuffer, uint8_t fifIndex);

    void FGInitFrameFlowInstance();
    void FGDestroyFlowInstance();
    void FGCreateFrameFlowResources();
    void FGDestroyFrameFlowResources();
    void FGBalancedInterRender();
    void FGBalancedExtraRender();
	void FGBalancedPresentBySystemRender();
    
    constexpr static bool ENABLE_PRESENT_BY_SYSTEM = false;
    constexpr static bool ENABLE_AI_PREDICTION = false;
    constexpr static bool ENABLE_VBMV = false;
		
    void CreateCommandPoolResources(const VkSemaphoreCreateInfo &semaphoreInfo,
        VkCommandPoolCreateInfo const &poolInfo, const VkFenceCreateInfo &fenceInfo,
        VkCommandBufferAllocateInfo &commandBufferAllocateInfo);
    FG_DispatchDescription_VK GetFGDispatchDescription(VkCommandBuffer commandBuffer, uint8_t fifIndex);
    void CreateFGContext();
    void ExecuteCreateSwapChain(VkSwapchainCreateInfoKHR &createInfo, uint32_t imageCount, VkFormat format);
    VkSubmitInfo CreateSubmitInfo(FrameInFlight *fif, const VkPipelineStageFlags &waitStage);
    VkPresentInfoKHR CreatePresentInfo(VkResult &presentResult);
    void InterGeneratePredictedFrame(FrameInFlight *fif, uint8_t fifIndex, VulkanFG::UIRenderer &uiRenderer);
    void InterRealFrameDisplay(FrameInFlight *fif);
    void ExtraGeneratePredictedFrame(FrameInFlight *fif, uint8_t fifIndex, VulkanFG::UIRenderer &uiRenderer,
        VkSubmitInfo &submitInfo, VkPresentInfoKHR &presentInfo);
    void UpdateWritingCommandBufferIdx();
    VkCommandBufferBeginInfo CreateBeginInfo();
    void RenderAndUpdateCameraInfo(VulkanFG::MainSceneRenderer &sceneRenderer, FrameInFlight *fif, uint8_t fifIndex);
    void ResetStatus(FrameInFlight *fif, VkCommandBufferBeginInfo &beginCB);
    void ResetStatus(FrameInFlight *fif);
    /*
     * In order to enable validation layer toggle this to true and
     * follow the README.md instructions concerning the validation
     * layers. You will be required to add separate vulkan validation
     * '*.so' files in order to enable this.
     *
     * The validation layers are not shipped with the APK as they are sizeable.
     */
    constexpr static bool ENABLE_VALIDATION_LAYERS = false;

    std::vector<char const *> const m_validationLayers = { "VK_LAYER_KHRONOS_validation", "VK_LAYER_OHOS_surface" };

    std::vector<char const *> const m_deviceExtensions = { VK_KHR_SWAPCHAIN_EXTENSION_NAME,
                                                           VK_KHR_SHADER_FLOAT16_INT8_EXTENSION_NAME };

    std::unique_ptr<OHNativeWindow, ANativeWindowDeleter> m_window;
    NativeResourceManager *m_assetManager = nullptr;

    VkInstance m_instance = VK_NULL_HANDLE;
    VkDebugUtilsMessengerEXT m_debugMessenger = VK_NULL_HANDLE;

    VkSurfaceKHR m_surface = VK_NULL_HANDLE;

    VkQueryPool m_queryPool;
    VkPhysicalDevice m_physicalDevice = VK_NULL_HANDLE;
    VkDevice m_device = VK_NULL_HANDLE;
    VkPhysicalDeviceProperties m_physicalDeviceProperties;
    VkPhysicalDeviceFeatures m_physicalDeviceFeatures;

    VkSwapchainKHR m_swapChain = VK_NULL_HANDLE;
    VkFormat m_swapChainImageFormat = VK_FORMAT_UNDEFINED;
    VkExtent2D m_swapChainExtent{};
    VkExtent2D m_displaySizeIdentity{};
	bool recreateDisplaySize = false; 

    VkQueue m_graphicsQueue = VK_NULL_HANDLE;
    VkQueue m_presentQueue = VK_NULL_HANDLE;

    bool m_orientationChanged = false;
    VkSurfaceTransformFlagBitsKHR m_pretransformFlag;

    FG_Image_VK *m_ffSceneColor = nullptr;
    FG_Image_VK *m_ffDepthStencil = nullptr;
    FG_Image_VK *m_ffPredictedColor = nullptr;

    std::vector<VkImage> m_swapChainImages{};
    std::vector<VkImageView> m_swapChainImageViews{};
    FG_Context_VK *m_context = nullptr;

    std::vector<FrameInFlight> m_framesInFlights{};
    size_t m_writingCommandBufferIdx = 0U;
    std::vector<SwapchainInfo> m_swapchainInfo{};
    uint32_t m_imageIndex = 0U;

    VulkanFG::Image m_sceneDepthStencil{};

    VulkanFG::Image m_sceneColor{};
    VkDescriptorSet m_sceneColorBackground = VK_NULL_HANDLE;

    VulkanFG::Image m_predictedColor{};
    VkDescriptorSet m_predictedColorBackground = VK_NULL_HANDLE;

    bool m_predictedFrameFirstUsage = true;
    VkFramebuffer m_sceneFramebuffer = VK_NULL_HANDLE;

    bool m_predictionEnabled = true;
    bool m_predictionPaused = true;
    bool m_realFrameCollected = false;
    bool m_unfinishedCommandBuffer = false;

    FG_Mat4x4 m_viewProj{};
    FG_Mat4x4 m_invViewProj{};
	FG_DispatchDescription_VK dispatch{};
    uint32_t m_resolution = 720;
};
} // namespace vkt
