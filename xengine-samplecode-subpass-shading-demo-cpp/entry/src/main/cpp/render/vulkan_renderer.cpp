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

#include "vulkan_renderer.h"
#include "scene.h"
#include "vulkan_model.h"
#include "vulkan_raii.h"
#include "util.h"
#include "vulkan_util.h"
#include "vulkan_context.h"
#include "texture.h"

#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/random.hpp>

#include <vulkan/vulkan.h>
#include <vulkan/vulkan.hpp>

#include <functional>
#include <vector>
#include <array>
#include <string>
#include <algorithm>
#include <fstream>
#include <iostream>
#include <chrono>
#include <unistd.h>

#define VK_SUBPASS_SHADING

static bool g_openSleep = false;
static bool g_coutFlag = false;
using util::Vertex;

const int MAX_POINT_LIGHT_COUNT = 10;
const int MAX_POINT_LIGHT_PER_TILE = 1023;
const int TILE_SIZE = 8;

struct PointLight {
public:
    glm::vec3 pos;
    float radius = {5.0f};
    glm::vec3 intensity = {1.0f, 1.0f, 1.0f};
    float padding;

    PointLight() {}

    PointLight(glm::vec3 pos, float radius, glm::vec3 intensity) : pos(pos), radius(radius), intensity(intensity){};
};


// uniform buffer object for model transformation
struct SceneObjectUbo {
    glm::mat4 model;
};

// uniform buffer object for camera
struct CameraUbo {
    glm::mat4 view;
    glm::mat4 proj;
    glm::mat4 projview;
    glm::vec3 camPos;
};

struct PushConstantObject {
    glm::ivec2 viewportSize;
    glm::ivec2 tileNums;
    int debugViewIndex;

    PushConstantObject(int viewportSizeX, int viewportSizeY, int tileNumX, int tileNumY,
                       int debugViewIndex = 0)
        : viewportSize(viewportSizeX, viewportSizeY), tileNums(tileNumX, tileNumY),
          debugViewIndex(debugViewIndex) {}
};

struct LightVisiblity {
    unsigned int count;
    unsigned int lightIndices[MAX_POINT_LIGHT_PER_TILE];
};


class VulkanRendererImpl {
public:
    explicit VulkanRendererImpl(OHNativeWindow *window);

    void resize(int width, int height);

    void requestDraw(float deltatime);

    void cleanUp();

    void setCamera(const glm::mat4 &view, const glm::vec3 campos);

    int getDebugViewIndex() const { return debugViewIndex; }

    void changeDebugViewIndex(int targetView)
    {
        debugViewIndex = targetView % 5;
        recreateSwapChain();
    }

private:
    VulkanContext vulkanContext;

    VulkanUtil utility{vulkanContext};

    QueueFamilyIndices queueFamilyIndices;
    VkPhysicalDevice physicalDevice;
    VkDevice graphicsDevice;
    vk::Device device;
    vk::Queue graphicsQueue;
    vk::Queue presentQueue;
    vk::Queue computeQueue;
    vk::CommandPool graphicsCommandPool;
    vk::CommandPool computeCommandPool;

    VulkanRaii<vk::SwapchainKHR> swapChain;
    std::vector<VkImage> swapChainImages;
    VkFormat swapChainImageFormat;
    VkExtent2D swapChainExtent;
    std::vector<VulkanRaii<vk::ImageView>> swapChainImageviews;
    std::vector<VulkanRaii<vk::Framebuffer>> swapChainFrameBuffers;
    std::vector<VulkanRaii<vk::Framebuffer>> depthPrePassFrameBuffers;

    std::vector<VulkanRaii<VkImage>> swapChainImagesLightPass;
    std::vector<VulkanRaii<VkImageView>> swapChainImageViewsLightPass;
    std::vector<VulkanRaii<vk::Framebuffer>> swapChainFrameBuffersLightPass;

    VulkanRaii<vk::RenderPass> renderPass;
    VulkanRaii<vk::RenderPass> depthPrePass; // the depth prepass which happens before formal render pass

    VulkanRaii<vk::DescriptorSetLayout> objectDescriptorSetLayout;
    VulkanRaii<vk::DescriptorSetLayout> cameraDescriptorSetLayout;
    VulkanRaii<vk::DescriptorSetLayout> materialDescriptorSetLayout;
    VulkanRaii<VkPipelineLayout> pipelineLayout;
    VulkanRaii<VkPipeline> graphicsPipeline;
    VulkanRaii<vk::PipelineLayout> depthPipelineLayout;
    VulkanRaii<vk::Pipeline> depthPipeline;

    // shared between compute queue and graphics queue
    VulkanRaii<vk::DescriptorSetLayout> lightCullingDescriptorSetLayout;
    VulkanRaii<vk::DescriptorSetLayout> intermediateDescriptorSetLayout; // which is exclusive to compute queue
#if defined(VK_SUBPASS_SHADING)
    VulkanRaii<vk::DescriptorSetLayout> combineDescriptorSetLayout;        // combine camera and instance
    VulkanRaii<vk::DescriptorSetLayout> subpassShadingDescriptorSetLayout; // subpass shading
#endif
    VulkanRaii<VkPipelineLayout> computePipelineLayout;
    VulkanRaii<VkPipeline> computePipeline;

    std::vector<VkCommandBuffer> commandBuffers; // buffers will be released when pool destroyed
    std::vector<VkCommandBuffer> commandBuffersLast;
    std::vector<VkCommandBuffer> depthPrepassCommandBuffers;

    std::vector<VulkanRaii<vk::Semaphore>> imageAvailableSemaphores;
    std::vector<VulkanRaii<vk::Semaphore>> renderFinishedSemaphores;
    std::vector<VulkanRaii<vk::Semaphore>> renderFinishedSemaphoresLast;
#if not defined(VK_SUBPASS_SHADING)
    std::vector<VkCommandBuffer> lightCullingCommandBuffers;
    std::vector<VulkanRaii<vk::Semaphore>> lightCullingCompletedSemaphores;
#endif
    std::vector<VulkanRaii<vk::Semaphore>> depthPrepassFinishedSemaphores;
    std::vector<VkFence> inFlightFences;
    int currentFrame = 0;

    std::vector<VulkanRaii<VkImage>> depthImages;
    std::vector<VulkanRaii<VkDeviceMemory>> depthImageMemorys;
    std::vector<VulkanRaii<VkDeviceMemory>> imageLightPassMemorys;
    std::vector<VulkanRaii<VkImageView>> depthImageViews;

    // texture image
    VulkanRaii<VkSampler> textureSampler;

    // uniform buffers
    VulkanRaii<VkBuffer> objectUniformBuffer;
    VulkanRaii<VkDeviceMemory> objectUniformBufferMemory;
    VulkanRaii<VkBuffer> cameraUniformBbuffer;
    VulkanRaii<VkDeviceMemory> cameraUniformBufferMemory;

    VulkanRaii<VkBuffer> cameraUniformBufferLight;
    VulkanRaii<VkDeviceMemory> cameraUniformBufferMemoryLight;

    VulkanRaii<VkDescriptorPool> descriptorPool;
    VkDescriptorSet objectDescriptorSet;
    vk::DescriptorSet cameraDescriptorSet;
    VkDescriptorSet lightCullingDescriptorSet;
    vk::DescriptorSet intermediateDescriptorSet;
#if defined(VK_SUBPASS_SHADING)
    VkDescriptorSet combineDescriptorSet;
    vk::DescriptorSet subpassShadingDescriptorSet;
#endif
    // vertex buffer
    VulkanModel model;

    VulkanRaii<VkBuffer> pointLightBuffer;
    VulkanRaii<VkDeviceMemory> pointLightBufferMemory;
    VulkanRaii<VkBuffer> lightsStagingBuffer;
    VulkanRaii<VkDeviceMemory> lightsStagingBufferMemory;
    VkDeviceSize pointLightBufferSize;

    std::vector<util::Vertex> vertices;

    std::vector<PointLight> pointlights;

    // This storage buffer stores visible lights for each tile
    // which is output from the light culling compute shader
    // max MAX_POINT_LIGHT_PER_TILE point lights per tile
    VulkanRaii<VkBuffer> lightVisibilityBuffer;
    VulkanRaii<VkDeviceMemory> lightVisibilityBufferMemory;
    VkDeviceSize lightVisibilityBufferSize = 0;

    int windowFrameBufferWidth;
    int windowFrameBufferHeight;

    glm::mat4 viewMatrix;
    glm::vec3 camPos;
    int tileCountPerRow;
    int tileCountPerCol;
    int debugViewIndex = 0;

    void initialize()
    {
        createSwapChain();
        createSwapChainImageViews();
        createRenderPasses();
        createDescriptorSetLayouts();
        createGraphicsPipelines();
        createComputePipeline();
        createDepthResources();
        createFrameBuffers();
        createTextureSampler();
        createUniformBuffers();
        createLights();
        createDescriptorPool();
        model = VulkanModel::loadModelFromFile(vulkanContext,
            util::getContentPath(GetGlobalTestSceneConfiguration().modelFile), textureSampler.get(),
            descriptorPool.get(), materialDescriptorSetLayout.get());
        createSceneObjectDescriptorSet();
        createCameraDescriptorSet();
        createIntermediateDescriptorSet();
        updateIntermediateDescriptorSet();
        createLigutCullingDescriptorSet();
#if defined(VK_SUBPASS_SHADING)
        createCombineDescriptorSet();
#endif
        createLightVisibilityBuffer();
        createGraphicsCommandBuffers();
#if not defined(VK_SUBPASS_SHADING)
        createLightCullingCommandBuffers();
        createDepthPrePassCommandBuffers();
#endif

#if defined(VK_SUBPASS_SHADING)
        createSubpassShadingDescriptorSet();
        updateSubpassShadingDescriptorSet();
        createCombineCommandBuffers();
#endif
        createSemaphores();

#if defined(VK_SUBPASS_SHADING)
        VkPhysicalDeviceSubgroupProperties subgroupProperties;
        subgroupProperties.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBGROUP_PROPERTIES;
        subgroupProperties.pNext = NULL;
        VkPhysicalDeviceProperties2 physicalDeviceProperties;
        physicalDeviceProperties.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2;
        physicalDeviceProperties.pNext = &subgroupProperties;
        vkGetPhysicalDeviceProperties2(physicalDevice, &physicalDeviceProperties);
#endif
    }

    void recreateSwapChain()
    {
        vkDeviceWaitIdle(graphicsDevice);
        createSwapChain();
        createSwapChainImageViews();
        createRenderPasses();
        createGraphicsPipelines();
        createDepthResources();
        createFrameBuffers();
        createLightVisibilityBuffer(); // since it's size will scale with window;
        updateIntermediateDescriptorSet();
        createGraphicsCommandBuffers();
#if defined(VK_SUBPASS_SHADING)
        updateSubpassShadingDescriptorSet();
        createCombineCommandBuffers();
#endif
#if not defined(VK_SUBPASS_SHADING)
        createLightCullingCommandBuffers();
        createDepthPrePassCommandBuffers();
#endif
}
    void createSwapChain();

    void createSwapChainImageViews();

    void createRenderPasses();

    void createDescriptorSetLayouts();

    void createGraphicsPipelines();

    void createDepthResources();

    void createFrameBuffers();

    void createTextureSampler();

    void createUniformBuffers();

    void createLights();

    void createDescriptorPool();

    void createSceneObjectDescriptorSet();

    void createCameraDescriptorSet();

    void createIntermediateDescriptorSet();

    void updateIntermediateDescriptorSet();

    void createGraphicsCommandBuffers();

    void createSemaphores();

    void createComputePipeline();

    void createLigutCullingDescriptorSet();

    void createLightVisibilityBuffer();

#if defined(VK_SUBPASS_SHADING)
    void createCombineDescriptorSet();

    void createSubpassShadingDescriptorSet();

    void updateSubpassShadingDescriptorSet();

    void createCombineCommandBuffers();
#endif
#if not defined(VK_SUBPASS_SHADING)
    void createLightCullingCommandBuffers();

    void createDepthPrePassCommandBuffers();
#endif

    void updateUniformBuffers(float deltatime);

    void drawFrame();

    VulkanRaii<VkShaderModule> createShaderModule(const std::vector<char> &code);
};

VulkanRendererImpl::VulkanRendererImpl(NativeWindow *window) : vulkanContext(window)
{
    queueFamilyIndices = vulkanContext.getQueueFamilyIndices();
    physicalDevice = vulkanContext.getPhysicalDevice();
    graphicsDevice = vulkanContext.getDevice();
    device = vulkanContext.getDevice();
    graphicsQueue = vulkanContext.getGraphicsQueue();
    presentQueue = vulkanContext.getPresentQueue();
    computeQueue = vulkanContext.getComputeQueue();
    graphicsCommandPool = vulkanContext.getGraphicsCommandPool();
    computeCommandPool = vulkanContext.getComputeCommandPool();

    std::tie(windowFrameBufferWidth, windowFrameBufferHeight) = vulkanContext.getWindowFrameBufferSize();
    // LOGI("Window width %{public}d, height %{public}d.", windowFrameBufferWidth, windowFrameBufferHeight);

    initialize();
    // LOGI("VulkanRenderer_Impl initialized.");
}

void VulkanRendererImpl::resize(int width, int height)
{
    if (width == 0 || height == 0) {
        return;
    }

    std::tie(windowFrameBufferWidth, windowFrameBufferHeight) = vulkanContext.getWindowFrameBufferSize();

    recreateSwapChain();
}

void VulkanRendererImpl::requestDraw(float deltatime)
{
    updateUniformBuffers(deltatime);
    drawFrame();
}

void VulkanRendererImpl::cleanUp()
{
    for (int i = 0; i < swapChainFrameBuffers.size(); ++i) {
        vkDestroyFence(graphicsDevice, inFlightFences[i], nullptr);
    }
    vkDeviceWaitIdle(graphicsDevice);
}

void VulkanRendererImpl::setCamera(const glm::mat4 &view, const glm::vec3 campos)
{
    viewMatrix = view;
    this->camPos = campos;
}

void VulkanRendererImpl::createSwapChain()
{
    auto supportDetails =
        SwapChainSupportDetails::querySwapChainSupport(physicalDevice, vulkanContext.getWindowSurface());

    VkSurfaceFormatKHR surfaceFormat = utility.chooseSwapSurfaceFormat(supportDetails.formats);
    VkPresentModeKHR presentMode = utility.chooseSwapPresentMode(supportDetails.present_modes);
    presentMode = VK_PRESENT_MODE_FIFO_KHR;
    VkExtent2D extent = utility.chooseSwapExtent(supportDetails.capabilities);
    uint32_t queueLength = supportDetails.capabilities.minImageCount + 1;
    if (supportDetails.capabilities.maxImageCount > 0 && queueLength > supportDetails.capabilities.maxImageCount) {
        // 0 for maxImageCount means no limit
        queueLength = supportDetails.capabilities.maxImageCount;
    }
    VkSwapchainCreateInfoKHR createInfo = {};
    createInfo.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
    createInfo.surface = vulkanContext.getWindowSurface();
    createInfo.minImageCount = queueLength;
    createInfo.imageFormat = surfaceFormat.format;
    createInfo.imageColorSpace = surfaceFormat.colorSpace;
    createInfo.imageExtent = extent;
    createInfo.imageArrayLayers = 1;                             // >1 when developing stereoscopic application
    createInfo.imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT; // render directly
    // VK_IMAGE_USAGE_TRANSFER_DST_BIT and memory operation to enable post processing

    QueueFamilyIndices indices =
        QueueFamilyIndices::findQueueFamilies(physicalDevice, vulkanContext.getWindowSurface());
    uint32_t tmpQueueFamilyIndices[] = {static_cast<uint32_t>(indices.graphicsFamily),
                                        static_cast<uint32_t>(indices.presentFamily)};

    if (indices.graphicsFamily != indices.presentFamily) {
        createInfo.imageSharingMode = VK_SHARING_MODE_CONCURRENT;
        createInfo.queueFamilyIndexCount = 2;
        createInfo.pQueueFamilyIndices = tmpQueueFamilyIndices;
    } else {
        createInfo.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE;
        createInfo.queueFamilyIndexCount = 0;     // Optional
        createInfo.pQueueFamilyIndices = nullptr; // Optional
    }
    
    if (supportDetails.capabilities.supportedTransforms & VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR) {
        // We prefer a non-rotated transform
        createInfo.preTransform = VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR;
    } else {
        createInfo.preTransform = supportDetails.capabilities.currentTransform;
    }
    createInfo.compositeAlpha =
        VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR; // ignore alpha channel (for blending with other windows)

    createInfo.presentMode = presentMode;
    createInfo.clipped = VK_TRUE; // ignore pixels obscured

    auto oldSwapChain = std::move(swapChain);     // which will be destroyed when out of scope
    createInfo.oldSwapchain = oldSwapChain.get(); // required when recreating a swap chain (like resizing windows)

    VkSwapchainKHR tmpSwapChain;
    vulkan_util::checkResult(vkCreateSwapchainKHR(graphicsDevice, &createInfo, nullptr, &tmpSwapChain),
                             "Failed to create swap chain!");

    swapChain = VulkanRaii<vk::SwapchainKHR>(tmpSwapChain,
                                         [device = this->device](auto &obj) { device.destroySwapchainKHR(obj); });

    uint32_t imageCount;
    vkGetSwapchainImagesKHR(graphicsDevice, swapChain.get(), &imageCount, nullptr);
    swapChainImages.resize(imageCount);
    vkGetSwapchainImagesKHR(graphicsDevice, swapChain.get(), &imageCount, swapChainImages.data());

    swapChainImagesLightPass.clear();
    swapChainImagesLightPass.resize(swapChainImages.size());

    imageLightPassMemorys.clear();
    imageLightPassMemorys.resize(swapChainImages.size());

    for (uint32_t i = 0; i < swapChainImages.size(); i++) {
        VkImage tmp_image;
        std::tie(swapChainImagesLightPass[i], imageLightPassMemorys[i]) =
            utility.createImage(extent.width, extent.height, surfaceFormat.format, VK_IMAGE_TILING_OPTIMAL,
                                VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
    }
    swapChainImageFormat = surfaceFormat.format;
    swapChainExtent = extent;
}

void VulkanRendererImpl::createSwapChainImageViews()
{
    auto raiiDeleter = [device = this->device](auto &obj) { device.destroyImageView(obj); };

    swapChainImageviews.clear(); // VRaii will delete old objects
    swapChainImageviews.reserve(swapChainImages.size());

    for (uint32_t i = 0; i < swapChainImages.size(); i++) {
        VkImageView tmpImageview;
        utility.createImageView(swapChainImages[i], swapChainImageFormat, VK_IMAGE_ASPECT_COLOR_BIT,
                                &tmpImageview);
        swapChainImageviews.emplace_back(tmpImageview, raiiDeleter);
    }
    swapChainImageViewsLightPass.clear();
    swapChainImageViewsLightPass.resize(swapChainImages.size());
    for (uint32_t i = 0; i < swapChainImages.size(); i++) {
        swapChainImageViewsLightPass[i] = utility.createImageView(
            swapChainImagesLightPass[i].get(), swapChainImageFormat, VK_IMAGE_ASPECT_COLOR_BIT);
    }
}

void VulkanRendererImpl::createRenderPasses()
{
    auto renderPassDeleter = [device = this->device](auto &obj) { device.destroyRenderPass(obj); };

    // depth pre pass
#if defined(VK_SUBPASS_SHADING)
    {
        /* Setup the attachment descriptions */
        VkAttachmentDescription2 depthAttachmentDescr = {};
        depthAttachmentDescr.sType = VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_2;
        depthAttachmentDescr.pNext = nullptr;
        depthAttachmentDescr.flags = 0;
        depthAttachmentDescr.format = utility.findDepthFormat();
        depthAttachmentDescr.samples = VK_SAMPLE_COUNT_1_BIT;
        depthAttachmentDescr.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
        depthAttachmentDescr.storeOp = VK_ATTACHMENT_STORE_OP_STORE;
        depthAttachmentDescr.stencilLoadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
        depthAttachmentDescr.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
        depthAttachmentDescr.initialLayout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
        depthAttachmentDescr.finalLayout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
        // LOGI("zzg depth desc create over");
        VkAttachmentDescription2 attachmentDescrs[1] = {depthAttachmentDescr};
        /* Setup the attachment references */
        VkAttachmentReference2 inputAttachmentRefs[1];
        inputAttachmentRefs[0].sType = VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2;
        inputAttachmentRefs[0].pNext = nullptr;
        inputAttachmentRefs[0].attachment = 0;
        inputAttachmentRefs[0].layout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL;
        inputAttachmentRefs[0].aspectMask = VK_IMAGE_ASPECT_DEPTH_BIT | VK_IMAGE_ASPECT_STENCIL_BIT;

        VkAttachmentReference2 depthAttachmentRef[1];
        depthAttachmentRef[0].sType = VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2;
        depthAttachmentRef[0].pNext = nullptr;
        depthAttachmentRef[0].attachment = 0;
        depthAttachmentRef[0].layout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
        depthAttachmentRef[0].aspectMask = VK_IMAGE_ASPECT_DEPTH_BIT | VK_IMAGE_ASPECT_STENCIL_BIT;

        /* Setup the subpass */
        VkSubpassDescription2 subpass = {};
        subpass.sType = VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_2;
        subpass.pNext = nullptr;
        subpass.flags = 0;
        subpass.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS;
        subpass.viewMask = 0;
        subpass.inputAttachmentCount = 0;
        subpass.pInputAttachments = nullptr;
        subpass.colorAttachmentCount = 0;
        subpass.pColorAttachments = nullptr;
        subpass.pResolveAttachments = nullptr;
        subpass.pDepthStencilAttachment = &depthAttachmentRef[0];
        subpass.preserveAttachmentCount = 0;
        subpass.pPreserveAttachments = nullptr;

        VkSubpassDescription2 subpass1 = {};
        subpass1.sType = VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_2;
        subpass1.pNext = nullptr;
        subpass1.flags = 0;
        subpass1.pipelineBindPoint = VK_PIPELINE_BIND_POINT_SUBPASS_SHADING_HUAWEI;
        subpass1.viewMask = 0;
        subpass1.inputAttachmentCount = 1;
        subpass1.pInputAttachments = &inputAttachmentRefs[0];
        subpass1.colorAttachmentCount = 0;
        subpass1.pColorAttachments = nullptr;
        subpass1.pResolveAttachments = nullptr;
        subpass1.pDepthStencilAttachment = nullptr;
        subpass1.preserveAttachmentCount = 0;
        subpass1.pPreserveAttachments = nullptr;

        VkSubpassDescription2 subpasses[2] = {subpass, subpass1};

        VkMemoryBarrier2KHR fragmentToCompute = {};
        fragmentToCompute.sType = VK_STRUCTURE_TYPE_MEMORY_BARRIER_2_KHR;
        fragmentToCompute.pNext = nullptr;
        fragmentToCompute.srcStageMask = VK_PIPELINE_STAGE_2_FRAGMENT_SHADER_BIT_KHR;
        fragmentToCompute.dstStageMask = VK_PIPELINE_STAGE_2_SUBPASS_SHADING_BIT_HUAWEI;
        fragmentToCompute.srcAccessMask = VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;
        fragmentToCompute.dstAccessMask = VK_ACCESS_INPUT_ATTACHMENT_READ_BIT;

        VkSubpassDependency2 dependency[1] = {};
        dependency[0].sType = VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2;
        dependency[0].pNext = &fragmentToCompute;
        dependency[0].srcSubpass = 0;
        dependency[0].dstSubpass = 1;
        dependency[0].srcStageMask = 0;
        dependency[0].dstStageMask = 0;
        dependency[0].srcAccessMask = 0;
        dependency[0].dstAccessMask = 0;
        dependency[0].dependencyFlags = 0;
        dependency[0].viewOffset = 0;

        /* Setup the render pass create info with all the above */
        VkRenderPassCreateInfo2 rpInfo = {};
        rpInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO_2_KHR;
        rpInfo.pNext = nullptr;
        rpInfo.attachmentCount = 1; // 2:count
        rpInfo.pAttachments = attachmentDescrs;
        rpInfo.subpassCount = 2; // 2:count
        rpInfo.pSubpasses = subpasses;
        rpInfo.dependencyCount = 1;
        rpInfo.pDependencies = dependency;
        VkRenderPass pass = nullptr;
        VkResult result = vkCreateRenderPass2(device, &rpInfo, nullptr, &pass);
        if (result != VK_SUCCESS) {
            LOGE("create RenderPass2 result is %d", result);
        }
        depthPrePass = VulkanRaii<vk::RenderPass>(pass, renderPassDeleter);
    }
#endif

#if not defined(VK_SUBPASS_SHADING)
    {
        VkAttachmentDescription depthAttachment = {};
        depthAttachment.format = utility.findDepthFormat();
        depthAttachment.samples = VK_SAMPLE_COUNT_1_BIT;
        depthAttachment.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
        depthAttachment.storeOp = VK_ATTACHMENT_STORE_OP_STORE;
        depthAttachment.stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE;
        depthAttachment.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
        depthAttachment.initialLayout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
        depthAttachment.finalLayout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL;

        VkAttachmentReference depthAttachmentRef = {};
        depthAttachmentRef.attachment = 0;
        depthAttachmentRef.layout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;

        VkSubpassDescription subpass = {};
        subpass.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS;
        subpass.colorAttachmentCount = 0;
        subpass.pDepthStencilAttachment = &depthAttachmentRef;

        // overwrite subpass dependency to make it wait until VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
        VkSubpassDependency dependency = {};
        dependency.srcSubpass = VK_SUBPASS_EXTERNAL;
        dependency.dstSubpass = 0; // 0  refers to the subpass
        dependency.srcStageMask = VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
        dependency.srcAccessMask = VK_ACCESS_MEMORY_READ_BIT;
        dependency.dstStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
        dependency.dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;

        std::array<VkAttachmentDescription, 1> attachments = {depthAttachment};

        VkRenderPassCreateInfo renderPassInfo = {};
        renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
        renderPassInfo.attachmentCount = (uint32_t)attachments.size();
        renderPassInfo.pAttachments = attachments.data();
        renderPassInfo.subpassCount = 1;
        renderPassInfo.pSubpasses = &subpass;
        renderPassInfo.dependencyCount = 1;
        renderPassInfo.pDependencies = &dependency;

        VkRenderPass pass;
        if (vkCreateRenderPass(graphicsDevice, &renderPassInfo, nullptr, &pass) != VK_SUCCESS) {
            throw std::runtime_error("failed to create depth pre-pass!");
        }
        depthPrePass = VulkanRaii<vk::RenderPass>(pass, renderPassDeleter);
    }
#endif

    // the render pass
    {
        VkAttachmentDescription colorAttachment = {};
        colorAttachment.format = swapChainImageFormat;
        colorAttachment.samples = VK_SAMPLE_COUNT_1_BIT;
        colorAttachment.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;            // before rendering
        colorAttachment.storeOp = VK_ATTACHMENT_STORE_OP_STORE;          // after rendering
        colorAttachment.stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE; // no stencil
        colorAttachment.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
        colorAttachment.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
        colorAttachment.finalLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR; // to be directly used in swap chain

        VkAttachmentDescription depthAttachment = {};
        depthAttachment.format = utility.findDepthFormat();
        depthAttachment.samples = VK_SAMPLE_COUNT_1_BIT;
        depthAttachment.loadOp = VK_ATTACHMENT_LOAD_OP_LOAD;
        depthAttachment.storeOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
        depthAttachment.stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE;
        depthAttachment.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
        depthAttachment.initialLayout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL;
        depthAttachment.finalLayout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;

        VkAttachmentReference colorAttachmentRef = {};
        colorAttachmentRef.attachment = 0;
        colorAttachmentRef.layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;

        VkAttachmentReference depthAttachmentRef = {};
        depthAttachmentRef.attachment = 1;
        depthAttachmentRef.layout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL;

        VkSubpassDescription subpass = {};
        subpass.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS;
        subpass.colorAttachmentCount = 1;
        subpass.pColorAttachments = &colorAttachmentRef;
        subpass.pDepthStencilAttachment = &depthAttachmentRef;

        // overwrite subpass dependency to make it wait until VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
        VkSubpassDependency dependency = {};
        dependency.srcSubpass = VK_SUBPASS_EXTERNAL;
        dependency.dstSubpass = 0; // 0  refers to the subpass
        dependency.srcStageMask = VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
        dependency.srcAccessMask = VK_ACCESS_MEMORY_READ_BIT;
        dependency.dstStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
        dependency.dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;

        std::array<VkAttachmentDescription, 2> attachments = {colorAttachment, depthAttachment};

        VkRenderPassCreateInfo renderPassInfo = {};
        renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
        renderPassInfo.attachmentCount = (uint32_t)attachments.size();
        renderPassInfo.pAttachments = attachments.data();
        renderPassInfo.subpassCount = 1;
        renderPassInfo.pSubpasses = &subpass;
        renderPassInfo.dependencyCount = 1;
        renderPassInfo.pDependencies = &dependency;

        VkRenderPass tmpRenderPass;
        if (vkCreateRenderPass(graphicsDevice, &renderPassInfo, nullptr, &tmpRenderPass) != VK_SUCCESS) {
            throw std::runtime_error("failed to create render pass!");
        }
        renderPass = VulkanRaii<vk::RenderPass>(tmpRenderPass, renderPassDeleter);
    }
}

void VulkanRendererImpl::createDescriptorSetLayouts()
{
    auto raiiLayoutDeleter = [device = this->device](auto &layout) { device.destroyDescriptorSetLayout(layout); };

    // instance_descriptor_set_layout
    {
        // Transform information
        // create descriptor for uniform buffer objects
        VkDescriptorSetLayoutBinding uboLayoutBinding = {};
        uboLayoutBinding.binding = 0;
        uboLayoutBinding.descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
        uboLayoutBinding.descriptorCount = 1;
        uboLayoutBinding.stageFlags =
            VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT; // only referencing from vertex shader
        // VK_SHADER_STAGE_ALL_GRAPHICS
        uboLayoutBinding.pImmutableSamplers = nullptr; // Optional

        std::array<VkDescriptorSetLayoutBinding, 1> bindings = {uboLayoutBinding};
        VkDescriptorSetLayoutCreateInfo layoutInfo = {};
        layoutInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
        layoutInfo.bindingCount = (uint32_t)bindings.size();
        layoutInfo.pBindings = bindings.data();

        objectDescriptorSetLayout = VulkanRaii<vk::DescriptorSetLayout>(
            device.createDescriptorSetLayout(layoutInfo, nullptr), raiiLayoutDeleter);
    }

    // camera_ds_layout
    {
        std::vector<VkDescriptorSetLayoutBinding> setLayoutBindings = {};
        {
            VkDescriptorSetLayoutBinding lb = {};
            lb.binding = 0;
            lb.descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
            lb.descriptorCount = 1;
#if defined(VK_SUBPASS_SHADING)
            lb.stageFlags =
                VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT | VK_SHADER_STAGE_SUBPASS_SHADING_BIT_HUAWEI;
#endif
#if not defined(VK_SUBPASS_SHADING)
            lb.stageFlags = VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT | VK_SHADER_STAGE_COMPUTE_BIT;
#endif
            lb.pImmutableSamplers = nullptr;
            setLayoutBindings.push_back(lb);
        }

        {
            VkDescriptorSetLayoutBinding lb = {};
            lb.binding = 1;
            lb.descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
            lb.descriptorCount = 1;
#if defined(VK_SUBPASS_SHADING)
            lb.stageFlags =
                VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT | VK_SHADER_STAGE_SUBPASS_SHADING_BIT_HUAWEI;
#endif
#if not defined(VK_SUBPASS_SHADING)
            lb.stageFlags = VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT | VK_SHADER_STAGE_COMPUTE_BIT;
#endif
            lb.pImmutableSamplers = nullptr;
            setLayoutBindings.push_back(lb);
        }

        VkDescriptorSetLayoutCreateInfo layoutInfo = {};
        layoutInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
        layoutInfo.bindingCount = static_cast<uint32_t>(setLayoutBindings.size());
        layoutInfo.pBindings = setLayoutBindings.data();

        cameraDescriptorSetLayout =  VulkanRaii<vk::DescriptorSetLayout>(
            device.createDescriptorSetLayout(layoutInfo, nullptr), raiiLayoutDeleter);
    }

    // light_culling_descriptor_set_layout, shared between compute pipeline and graphics pipeline
    {
        std::vector<VkDescriptorSetLayoutBinding> setLayoutBindings = {};

        {
            // create descriptor for storage buffer for light culling results
            VkDescriptorSetLayoutBinding lb = {};
            lb.binding = 0;
            lb.descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
            lb.descriptorCount = 1;
#if defined(VK_SUBPASS_SHADING)
            lb.stageFlags = VK_SHADER_STAGE_SUBPASS_SHADING_BIT_HUAWEI | VK_SHADER_STAGE_FRAGMENT_BIT;
#endif
#if not defined(VK_SUBPASS_SHADING)
            lb.stageFlags = VK_SHADER_STAGE_COMPUTE_BIT | VK_SHADER_STAGE_FRAGMENT_BIT;
#endif
            lb.pImmutableSamplers = nullptr;
            setLayoutBindings.push_back(lb);
        }

        {
            // uniform buffer for point lights
            VkDescriptorSetLayoutBinding lb = {};
            lb.binding = 1;
            lb.descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
            lb.descriptorCount = 1; // maybe we can use this for different types of lights
#if defined(VK_SUBPASS_SHADING)
            lb.stageFlags = VK_SHADER_STAGE_SUBPASS_SHADING_BIT_HUAWEI | VK_SHADER_STAGE_FRAGMENT_BIT;
#endif
#if not defined(VK_SUBPASS_SHADING)
            lb.stageFlags = VK_SHADER_STAGE_COMPUTE_BIT | VK_SHADER_STAGE_FRAGMENT_BIT;
#endif
            lb.pImmutableSamplers = nullptr;
            setLayoutBindings.push_back(lb);
        }

        VkDescriptorSetLayoutCreateInfo layoutInfo = {};
        layoutInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
        layoutInfo.bindingCount = static_cast<uint32_t>(setLayoutBindings.size());
        layoutInfo.pBindings = setLayoutBindings.data();

        lightCullingDescriptorSetLayout = VulkanRaii<vk::DescriptorSetLayout>(
            device.createDescriptorSetLayout(layoutInfo, nullptr), raiiLayoutDeleter);
    }

    // descriptor set layout for intermediate objects during render passes, such as z-buffer
    {
        // reads from depth attachment of previous frame
        // descriptor for texture sampler
        vk::DescriptorSetLayoutBinding samplerLayoutBinding = {
            0,                                                                      // binding
            vk::DescriptorType::eCombinedImageSampler,                              // descriptorType
            1,                                                                      // descriptoCount
            vk::ShaderStageFlagBits::eCompute | vk::ShaderStageFlagBits::eFragment, // stageFlags
            nullptr,                                                                // pImmutableSamplers
        };

        vk::DescriptorSetLayoutCreateInfo createInfo = {
            vk::DescriptorSetLayoutCreateFlags(), // flags
            1,
            &samplerLayoutBinding,
        };

        intermediateDescriptorSetLayout = VulkanRaii<vk::DescriptorSetLayout>(
            device.createDescriptorSetLayout(createInfo, nullptr), raiiLayoutDeleter);
    }

#if defined(VK_SUBPASS_SHADING)
    // subpass set layout for intermediate objects during render passes, such as z-buffer
    {
        // reads from depth attachment of previous frame
        // descriptor for texture sampler
        vk::DescriptorSetLayoutBinding sampler_layout_binding = {
            0,                                                                                   // binding
            vk::DescriptorType::eInputAttachment,                                                // descriptorType
            1,                                                                                   // descriptoCount
            vk::ShaderStageFlagBits::eSubpassShadingHUAWEI | vk::ShaderStageFlagBits::eFragment, // stageFlags
            nullptr,                                                                             // pImmutableSamplers
        };

        vk::DescriptorSetLayoutCreateInfo createInfo = {
            vk::DescriptorSetLayoutCreateFlags(), // flags
            1,
            &sampler_layout_binding,
        };

        subpassShadingDescriptorSetLayout = VulkanRaii<vk::DescriptorSetLayout>(
            device.createDescriptorSetLayout(createInfo, nullptr), raiiLayoutDeleter);
    }
#endif

    // material_descriptror_layout
    {
        // reads from depth attachment of previous frame
        // descriptor for texture sampler
        vk::DescriptorSetLayoutBinding uniformLayoutBinding = {
            0,                                  // binding
            vk::DescriptorType::eUniformBuffer, // descriptorType
            1,                                  // descriptorCount
            vk::ShaderStageFlagBits::eFragment, // stageFlags
            nullptr,                            // pImmutableSamplers
        };

        vk::DescriptorSetLayoutBinding albedoMapLayoutBinding = {
            1,                                         // binding
            vk::DescriptorType::eCombinedImageSampler, // descriptorType
            1,                                         // descriptorCount
            vk::ShaderStageFlagBits::eFragment,        // stageFlags
            nullptr,                                   // pImmutableSamplers
        };

        vk::DescriptorSetLayoutBinding normapLayoutBinding = {
            2,                                         // binding
            vk::DescriptorType::eCombinedImageSampler, // descriptorType
            1,                                         // descriptorCount
            vk::ShaderStageFlagBits::eFragment,        // stageFlags
            nullptr,                                   // pImmutableSamplers
        };

        std::array<vk::DescriptorSetLayoutBinding, 3> bindings = {uniformLayoutBinding, albedoMapLayoutBinding,
                                                                  normapLayoutBinding};

        vk::DescriptorSetLayoutCreateInfo createInfo = {vk::DescriptorSetLayoutCreateFlags(), // flags
                                                        static_cast<uint32_t>(bindings.size()), bindings.data()};

        materialDescriptorSetLayout = VulkanRaii<vk::DescriptorSetLayout>(
            device.createDescriptorSetLayout(createInfo, nullptr), raiiLayoutDeleter);
    }
#if defined(VK_SUBPASS_SHADING)
    // combine_descriptor_set_layout
    {
        // Transform information
        // create descriptor for uniform buffer objects
        VkDescriptorSetLayoutBinding ubo_layout_binding = {};
        ubo_layout_binding.binding = 0;
        ubo_layout_binding.descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
        ubo_layout_binding.descriptorCount = 1;
        ubo_layout_binding.stageFlags =
            VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT; // only referencing from vertex shader
        // VK_SHADER_STAGE_ALL_GRAPHICS
        ubo_layout_binding.pImmutableSamplers = nullptr; // Optional

        VkDescriptorSetLayoutBinding camera_layout_binding = {};
        camera_layout_binding.binding = 1;
        camera_layout_binding.descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
        camera_layout_binding.descriptorCount = 1;
        camera_layout_binding.stageFlags =
            VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT | VK_SHADER_STAGE_COMPUTE_BIT;
        camera_layout_binding.pImmutableSamplers = nullptr;

        std::array<VkDescriptorSetLayoutBinding, 2> bindings = {ubo_layout_binding, camera_layout_binding};
        VkDescriptorSetLayoutCreateInfo layout_info = {};
        layout_info.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
        layout_info.bindingCount = (uint32_t)bindings.size();
        layout_info.pBindings = bindings.data();

        combineDescriptorSetLayout = VulkanRaii<vk::DescriptorSetLayout>(
            device.createDescriptorSetLayout(layout_info, nullptr), raiiLayoutDeleter);
    }
#endif
}

void VulkanRendererImpl::createGraphicsPipelines()
{
    auto raiiPipelineLayoutDeleter = [device = this->device](auto &obj) { device.destroyPipelineLayout(obj); };
    auto raiiPipelineDeleter = [device = this->device](auto &obj) { device.destroyPipeline(obj); };

    // create main pipeline
    {
#if defined(VK_SUBPASS_SHADING)
        auto vert_shader_code = util::readFile(util::getContentPath("subpass_shading/vert.spv"));
        auto frag_shader_code = util::readFile(util::getContentPath("subpass_shading/frag.spv"));
#endif
#if not defined(VK_SUBPASS_SHADING)
        auto vert_shader_code = util::readFile(util::getContentPath("forward_plus/vert.spv"));
        auto frag_shader_code = util::readFile(util::getContentPath("forward_plus/frag.spv"));
#endif

        auto vert_shader_module = createShaderModule(vert_shader_code);
        auto frag_shader_module = createShaderModule(frag_shader_code);
        // LOGI("createShaderModule SUCCESS FOR forwardplus_vert&forwardplus_frag.");

        VkPipelineShaderStageCreateInfo vert_shader_stage_info = {};
        vert_shader_stage_info.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
        vert_shader_stage_info.stage = VK_SHADER_STAGE_VERTEX_BIT;
        vert_shader_stage_info.module = vert_shader_module.get();
        vert_shader_stage_info.pName = "main";

        VkPipelineShaderStageCreateInfo frag_shader_stage_info = {};
        frag_shader_stage_info.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
        frag_shader_stage_info.stage = VK_SHADER_STAGE_FRAGMENT_BIT;
        frag_shader_stage_info.module = frag_shader_module.get();
        frag_shader_stage_info.pName = "main";

        VkPipelineShaderStageCreateInfo shaderStages[] = {vert_shader_stage_info, frag_shader_stage_info};

        // vertex data info
        VkPipelineVertexInputStateCreateInfo vertex_input_info = {};
        vertex_input_info.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;

        auto binding_description = vulkan_util::getVertexBindingDesciption();
        auto attr_description = vulkan_util::getVertexAttributeDescriptions();

        vertex_input_info.vertexBindingDescriptionCount = 1;
        vertex_input_info.pVertexBindingDescriptions = &binding_description;
        vertex_input_info.vertexAttributeDescriptionCount = (uint32_t)attr_description.size();
        vertex_input_info.pVertexAttributeDescriptions = attr_description.data(); // Optional

        // input assembler
        VkPipelineInputAssemblyStateCreateInfo input_assembly_info = {};
        input_assembly_info.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO;
        input_assembly_info.topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
        input_assembly_info.primitiveRestartEnable = VK_FALSE;

        // viewport
        VkViewport viewport = {};
        viewport.x = 0.0f;
        viewport.y = 0.0f;
        viewport.width = (float)swapChainExtent.width;
        viewport.height = (float)swapChainExtent.height;
        viewport.minDepth = 0.0f;
        viewport.maxDepth = 1.0f;
        VkRect2D scissor = {};
        scissor.offset = {0, 0};
        scissor.extent = swapChainExtent;
        VkPipelineViewportStateCreateInfo viewport_state_info = {};
        viewport_state_info.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO;
        viewport_state_info.viewportCount = 1;
        viewport_state_info.pViewports = &viewport;
        viewport_state_info.scissorCount = 1;
        viewport_state_info.pScissors = &scissor;

        VkPipelineRasterizationStateCreateInfo rasterizer = {};
        rasterizer.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO;
        rasterizer.depthClampEnable = VK_FALSE;
        rasterizer.rasterizerDiscardEnable = VK_FALSE;
        rasterizer.polygonMode = VK_POLYGON_MODE_FILL;
        rasterizer.lineWidth = 1.0f; // requires wideLines feature enabled when larger than one
        rasterizer.cullMode = VK_CULL_MODE_BACK_BIT;
        rasterizer.frontFace = VK_FRONT_FACE_COUNTER_CLOCKWISE; // inverted Y during projection matrix
        rasterizer.depthBiasEnable = VK_FALSE;
        rasterizer.depthBiasConstantFactor = 0.0f; // Optional
        rasterizer.depthBiasClamp = 0.0f;          // Optional
        rasterizer.depthBiasSlopeFactor = 0.0f;    // Optional

        // no multisampling
        VkPipelineMultisampleStateCreateInfo multisampling = {};
        multisampling.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO;
        multisampling.sampleShadingEnable = VK_FALSE;
        multisampling.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT;
        multisampling.minSampleShading = 1.0f;          // Optional
        multisampling.pSampleMask = nullptr;            /// Optional
        multisampling.alphaToCoverageEnable = VK_FALSE; // Optional
        multisampling.alphaToOneEnable = VK_FALSE;      // Optional

        // depth and stencil
        VkPipelineDepthStencilStateCreateInfo depth_stencil = {};
        depth_stencil.sType = VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO;
        depth_stencil.depthTestEnable = VK_TRUE;
        depth_stencil.depthWriteEnable = VK_FALSE; // not VK_TRUE since we have a depth prepass
        depth_stencil.depthCompareOp =
            VK_COMPARE_OP_LESS_OR_EQUAL; // not VK_COMPARE_OP_LESS since we have a depth prepass;
        depth_stencil.depthBoundsTestEnable = VK_FALSE;
        depth_stencil.stencilTestEnable = VK_FALSE;

        VkPipelineColorBlendAttachmentState color_blend_attachment = {};
        color_blend_attachment.colorWriteMask =
            VK_COLOR_COMPONENT_R_BIT | VK_COLOR_COMPONENT_G_BIT | VK_COLOR_COMPONENT_B_BIT | VK_COLOR_COMPONENT_A_BIT;
        // Use alpha blending
        color_blend_attachment.blendEnable = VK_TRUE;
        color_blend_attachment.srcColorBlendFactor = VK_BLEND_FACTOR_SRC_ALPHA;
        color_blend_attachment.dstColorBlendFactor = VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA;
        color_blend_attachment.colorBlendOp = VK_BLEND_OP_ADD;
        color_blend_attachment.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE;
        color_blend_attachment.dstAlphaBlendFactor = VK_BLEND_FACTOR_ZERO;
        color_blend_attachment.alphaBlendOp = VK_BLEND_OP_ADD;

        VkPipelineColorBlendStateCreateInfo color_blending_info = {};
        color_blending_info.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO;
        color_blending_info.logicOpEnable = VK_FALSE;
        color_blending_info.logicOp = VK_LOGIC_OP_COPY; // Optional
        color_blending_info.attachmentCount = 1;
        color_blending_info.pAttachments = &color_blend_attachment;
        color_blending_info.blendConstants[0] = 0.0f; // Optional
        color_blending_info.blendConstants[1] = 0.0f; // Optional
        color_blending_info.blendConstants[2] = 0.0f; // Optional
        color_blending_info.blendConstants[3] = 0.0f; // Optional

        // parameters allowed to be changed without recreating a pipeline
        VkDynamicState dynamicStates[] = {VK_DYNAMIC_STATE_VIEWPORT, VK_DYNAMIC_STATE_LINE_WIDTH};
        VkPipelineDynamicStateCreateInfo dynamic_state_info = {};
        dynamic_state_info.dynamicStateCount = static_cast<uint32_t>(sizeof(dynamicStates) / sizeof(dynamicStates[0]));
        dynamic_state_info.pDynamicStates = dynamicStates;

        VkPushConstantRange push_constant_range = {};
        push_constant_range.offset = 0;
        push_constant_range.size = sizeof(PushConstantObject);
        push_constant_range.stageFlags = VK_SHADER_STAGE_FRAGMENT_BIT;

        // no uniform variables or push constants
        VkPipelineLayoutCreateInfo pipeline_layout_info = {};
        pipeline_layout_info.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
        std::vector<VkDescriptorSetLayout> set_layouts = {};
#if defined(VK_SUBPASS_SHADING)
        set_layouts = {combineDescriptorSetLayout.get(), lightCullingDescriptorSetLayout.get(),
                       intermediateDescriptorSetLayout.get(), materialDescriptorSetLayout.get()};
#endif
#if not defined(VK_SUBPASS_SHADING)
        set_layouts = {objectDescriptorSetLayout.get(), cameraDescriptorSetLayout.get(),
                       lightCullingDescriptorSetLayout.get(), intermediateDescriptorSetLayout.get(),
                       materialDescriptorSetLayout.get()};
#endif
        pipeline_layout_info.setLayoutCount = static_cast<uint32_t>(set_layouts.size()); // Optional
        pipeline_layout_info.pSetLayouts = set_layouts.data();                           // Optional
        pipeline_layout_info.pushConstantRangeCount = 1;                                 // Optional
        pipeline_layout_info.pPushConstantRanges = &push_constant_range;                 // Optional

        VkPipelineLayout temp_layout;
        auto pipeline_layout_result =
            vkCreatePipelineLayout(graphicsDevice, &pipeline_layout_info, nullptr, &temp_layout);
        if (pipeline_layout_result != VK_SUCCESS) {
            throw std::runtime_error("failed to create pipeline layout!");
        }
        pipelineLayout = VulkanRaii<VkPipelineLayout>(temp_layout, raiiPipelineLayoutDeleter);

        VkGraphicsPipelineCreateInfo pipelineInfo = {};
        pipelineInfo.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO;
        pipelineInfo.stageCount = static_cast<uint32_t>(sizeof(shaderStages) / sizeof(shaderStages[0]));
        pipelineInfo.pStages = shaderStages;

        pipelineInfo.pVertexInputState = &vertex_input_info;
        pipelineInfo.pInputAssemblyState = &input_assembly_info;
        pipelineInfo.pViewportState = &viewport_state_info;
        pipelineInfo.pRasterizationState = &rasterizer;
        pipelineInfo.pMultisampleState = &multisampling;
        pipelineInfo.pDepthStencilState = &depth_stencil;
        pipelineInfo.pColorBlendState = &color_blending_info;
        pipelineInfo.pDynamicState = nullptr; // Optional
        pipelineInfo.layout = pipelineLayout.get();
        pipelineInfo.renderPass = renderPass.get();
        pipelineInfo.subpass = 0;
        pipelineInfo.basePipelineHandle = VK_NULL_HANDLE; // not deriving from existing pipeline
        pipelineInfo.basePipelineIndex = -1;              // Optional
        pipelineInfo.flags = VK_PIPELINE_CREATE_ALLOW_DERIVATIVES_BIT;

        VkPipeline temp_pipeline;
        auto pipeline_result =
            vkCreateGraphicsPipelines(graphicsDevice, VK_NULL_HANDLE, 1, &pipelineInfo, nullptr, &temp_pipeline);
        // LOGE("pipeline result:%{public}d", pipeline_result);
        graphicsPipeline = VulkanRaii<VkPipeline>(temp_pipeline, raiiPipelineDeleter);

        if (pipeline_result != VK_SUCCESS) {
            throw std::runtime_error("failed to create graphics pipeline!");
        }

        // -------------------------------------depth prepass pipeline ------------------------------------------------

        {
            VkPipelineDepthStencilStateCreateInfo pre_pass_depth_stencil = {depth_stencil};
            pre_pass_depth_stencil.depthCompareOp = VK_COMPARE_OP_LESS;
            pre_pass_depth_stencil.depthWriteEnable = VK_TRUE;
#if not defined(VK_SUBPASS_SHADING)
            auto depth_vert_shader_code = util::readFile(util::getContentPath("forward_plus/depth.vert.spv"));
#endif
#if defined(VK_SUBPASS_SHADING)
            auto depth_vert_shader_code = util::readFile(util::getContentPath("subpass_shading/depth.vert.spv"));
#endif
            auto depth_vert_shader_module = createShaderModule(depth_vert_shader_code);
            VkPipelineShaderStageCreateInfo depth_vert_shader_stage_info = {};
            depth_vert_shader_stage_info.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
            depth_vert_shader_stage_info.stage = VK_SHADER_STAGE_VERTEX_BIT;
            depth_vert_shader_stage_info.module = depth_vert_shader_module.get();
            depth_vert_shader_stage_info.pName = "main";
            VkPipelineShaderStageCreateInfo depth_shader_stages[] = {depth_vert_shader_stage_info};

            std::array<vk::DescriptorSetLayout, 2> depth_set_layouts = {objectDescriptorSetLayout.get(),
                                                                        cameraDescriptorSetLayout.get()};

            vk::PipelineLayoutCreateInfo depth_layout_info = {
                vk::PipelineLayoutCreateFlags(),                 // flags
                static_cast<uint32_t>(depth_set_layouts.size()), // setLayoutCount
                depth_set_layouts.data(),                        // setlayouts
                0,                                               // pushConstantRangeCount
                nullptr                                          // pushConstantRanges
            };
            depthPipelineLayout = VulkanRaii<vk::PipelineLayout>(
                device.createPipelineLayout(depth_layout_info, nullptr), raiiPipelineLayoutDeleter);

            VkGraphicsPipelineCreateInfo depth_pipeline_info = {};
            depth_pipeline_info.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO;
            depth_pipeline_info.stageCount = 1;
            depth_pipeline_info.pStages = depth_shader_stages;

            depth_pipeline_info.pVertexInputState = &vertex_input_info;
            depth_pipeline_info.pInputAssemblyState = &input_assembly_info;
            depth_pipeline_info.pViewportState = &viewport_state_info;
            depth_pipeline_info.pRasterizationState = &rasterizer;
            depth_pipeline_info.pMultisampleState = &multisampling;
            depth_pipeline_info.pDepthStencilState = &pre_pass_depth_stencil;
            depth_pipeline_info.pColorBlendState = nullptr;
            depth_pipeline_info.pDynamicState = nullptr; // Optional
            depth_pipeline_info.layout = depthPipelineLayout.get();
            depth_pipeline_info.renderPass = depthPrePass.get();
            depth_pipeline_info.subpass = 0;
            depth_pipeline_info.basePipelineHandle = graphicsPipeline.get(); // not deriving from existing pipeline
            depth_pipeline_info.basePipelineIndex = -1;                       // Optional
            depth_pipeline_info.flags = VK_PIPELINE_CREATE_DERIVATIVE_BIT;

            depthPipeline = VulkanRaii<vk::Pipeline>(
                device.createGraphicsPipeline(vk::PipelineCache(), depth_pipeline_info, nullptr).value,
                raiiPipelineDeleter);
        }
    }
}

void VulkanRendererImpl::createFrameBuffers()
{
    auto raiiFrameBufferDeleter = [device = this->device](auto &obj) { device.destroyFramebuffer(obj); };

    // swap chain frame buffers
    {
        swapChainFrameBuffers.clear(); // VDeleter will delete old objects
        swapChainFrameBuffers.reserve(swapChainImageviews.size());

        for (size_t i = 0; i < swapChainImageviews.size(); i++) {
            std::array<VkImageView, 1> attachments = {swapChainImageviews[i].get()};

            VkFramebufferCreateInfo framebuffer_info = {};
            framebuffer_info.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
            framebuffer_info.renderPass = renderPass.get();
            framebuffer_info.attachmentCount = (uint32_t)attachments.size();
            framebuffer_info.pAttachments = attachments.data();
            framebuffer_info.width = swapChainExtent.width;
            framebuffer_info.height = swapChainExtent.height;
            framebuffer_info.layers = 1;

            swapChainFrameBuffers.emplace_back(device.createFramebuffer(framebuffer_info, nullptr),
                                               raiiFrameBufferDeleter);
        }
    }

    {
        swapChainFrameBuffersLightPass.clear(); // VDeleter will delete old objects
        for (size_t i = 0; i < swapChainImages.size(); i++) {
            std::array<VkImageView, 2> attachments = {swapChainImageViewsLightPass[i].get(),
                                                      depthImageViews[i].get()};

            VkFramebufferCreateInfo framebuffer_info = {};
            framebuffer_info.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
            framebuffer_info.renderPass = renderPass.get();
            framebuffer_info.attachmentCount = (uint32_t)attachments.size();
            framebuffer_info.pAttachments = attachments.data();
            framebuffer_info.width = swapChainExtent.width;
            framebuffer_info.height = swapChainExtent.height;
            framebuffer_info.layers = 1;

            swapChainFrameBuffersLightPass.emplace_back(device.createFramebuffer(framebuffer_info, nullptr),
                                                        raiiFrameBufferDeleter);
        }
    }

    {
        depthPrePassFrameBuffers.clear(); // VDeleter will delete old objects
        depthPrePassFrameBuffers.reserve(swapChainImageviews.size());
        // LOGI("start create depth frameBuffer size is %d", depth_pre_pass_framebuffers.size());
        for (int i = 0; i < swapChainImageviews.size(); ++i) {
            std::array<VkImageView, 1> attachments = {depthImageViews[i].get()};

            VkFramebufferCreateInfo framebuffer_info = {};
            framebuffer_info.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
            framebuffer_info.renderPass = depthPrePass.get();
            framebuffer_info.attachmentCount = (uint32_t)attachments.size();
            framebuffer_info.pAttachments = attachments.data();
            framebuffer_info.width = swapChainExtent.width;
            framebuffer_info.height = swapChainExtent.height;
            framebuffer_info.layers = 1;

            depthPrePassFrameBuffers.emplace_back(device.createFramebuffer(framebuffer_info, nullptr),
                                                  raiiFrameBufferDeleter);
        }
        // LOGI("end create depth frameBuffer, size is %d", depth_pre_pass_framebuffers.size());
    }
}

void VulkanRendererImpl::createDepthResources()
{
    VkFormat depth_format = utility.findDepthFormat();

    depthImages.clear(); // VRaii will delete old objects
    depthImages.resize(swapChainImages.size());

    depthImageMemorys.clear();
    depthImageMemorys.resize(swapChainImages.size());

    depthImageViews.clear();
    depthImageViews.resize(swapChainImages.size());

//     LOGI("depthImages size is %d, depthImageMemorys size is %d, depthImageViews size is %d", depthImages.size(),
//          depthImageMemorys.size(), depthImageViews.size());
    for (int i = 0; i < depthImages.size(); ++i) {
        // for depth pre pass and output as texture
        std::tie(depthImages[i], depthImageMemorys[i]) =
            utility.createImage(swapChainExtent.width, swapChainExtent.height, depth_format,
            VK_IMAGE_TILING_OPTIMAL, VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT | VK_IMAGE_USAGE_SAMPLED_BIT |
            VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
        depthImageViews[i] = utility.createImageView(depthImages[i].get(), depth_format, VK_IMAGE_ASPECT_DEPTH_BIT);
        utility.transitImageLayout(depthImages[i].get(), VK_IMAGE_LAYOUT_UNDEFINED,
                                   VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL);
//         LOGI("depthImageViews init over, %p", &depthImageViews[i]);
    }
}

void VulkanRendererImpl::createTextureSampler()
{
    VkSamplerCreateInfo sampler_info = {};
    sampler_info.sType = VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO;
    sampler_info.magFilter = VK_FILTER_LINEAR;
    sampler_info.minFilter = VK_FILTER_LINEAR;

    sampler_info.addressModeU = VK_SAMPLER_ADDRESS_MODE_REPEAT;
    sampler_info.addressModeV = VK_SAMPLER_ADDRESS_MODE_REPEAT;
    sampler_info.addressModeW = VK_SAMPLER_ADDRESS_MODE_REPEAT;

    sampler_info.anisotropyEnable = VK_TRUE;
    sampler_info.maxAnisotropy = 16;

    sampler_info.borderColor = VK_BORDER_COLOR_INT_OPAQUE_BLACK;
    sampler_info.unnormalizedCoordinates = VK_FALSE;

    sampler_info.compareEnable = VK_FALSE;
    sampler_info.compareOp = VK_COMPARE_OP_ALWAYS;

    sampler_info.mipmapMode = VK_SAMPLER_MIPMAP_MODE_LINEAR;
    sampler_info.mipLodBias = 0.0f;
    sampler_info.minLod = 0.0f;
    sampler_info.maxLod = 0.0f;

    VkSampler sampler;
    if (vkCreateSampler(graphicsDevice, &sampler_info, nullptr, &sampler) != VK_SUCCESS) {
        throw std::runtime_error("Failed to create texture sampler!");
    }
    textureSampler = VulkanRaii<VkSampler>(sampler, [device = this->device](auto &obj) {device.destroySampler(obj);});
}

void VulkanRendererImpl::createUniformBuffers()
{
    // create buffers for scene object
    {
        VkDeviceSize bufferSize = sizeof(SceneObjectUbo);
        std::tie(objectUniformBuffer, objectUniformBufferMemory) =
            utility.createBuffer(bufferSize, VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT,
                                 VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
                                 queueFamilyIndices.graphicsFamily, 0);
    }
    {
        SceneObjectUbo ubo = {};
        ubo.model = glm::scale(glm::mat4(1.0f), glm::vec3(GetGlobalTestSceneConfiguration().scale));
        void *data;
        vkMapMemory(graphicsDevice, objectUniformBufferMemory.get(), 0, sizeof(ubo), 0, &data);
        memcpy(data, &ubo, sizeof(ubo));
        vkUnmapMemory(graphicsDevice, objectUniformBufferMemory.get());
    }
    // create buffers for camera
    {
        VkDeviceSize bufferSize = sizeof(CameraUbo);
        std::tie(cameraUniformBbuffer, cameraUniformBufferMemory) = utility.createBuffer(
            bufferSize, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT,
            VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
            queueFamilyIndices.graphicsFamily, 0);
    }
    // create buffers for light
    {
        VkDeviceSize bufferSize = sizeof(CameraUbo);
        std::tie(cameraUniformBufferLight, cameraUniformBufferMemoryLight) = utility.createBuffer(
            bufferSize, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT,
            VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
            queueFamilyIndices.graphicsFamily, 0);
    }
}

void VulkanRendererImpl::createLights()
{
    glm::vec3 color = glm::vec3(0, 1, 0);
    pointlights.emplace_back(glm::vec3(3.0, 1.0, -2.0), 4.0f, color);
    color = glm::vec3(1, 1, 0);
    pointlights.emplace_back(glm::vec3(5.0, 2.0, -1.0), 8.0f, color);
    color = glm::vec3(1, 0, 0);
    pointlights.emplace_back(glm::vec3(-4.0, 2.0, 2.0), 7.0f, color);
    color = glm::vec3(0, 0, 1);
    pointlights.emplace_back(glm::vec3(-4.0, 2.0, 1.0), 9.0f, color);
    color = glm::vec3(1, 0, 0);
    pointlights.emplace_back(glm::vec3(-12.0, 5.0, 0.0), 20.0f, color);

    auto light_num = static_cast<int>(pointlights.size());

    pointLightBufferSize = sizeof(PointLight) * MAX_POINT_LIGHT_COUNT + sizeof(glm::vec4);

    std::tie(lightsStagingBuffer, lightsStagingBufferMemory) =
        utility.createBuffer(pointLightBufferSize, VK_BUFFER_USAGE_TRANSFER_SRC_BIT,
                             VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
    std::tie(pointLightBuffer, pointLightBufferMemory) = utility.createBuffer(pointLightBufferSize,
        VK_BUFFER_USAGE_STORAGE_BUFFER_BIT | VK_BUFFER_USAGE_TRANSFER_DST_BIT,
        VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT); // using barrier to sync
}

void VulkanRendererImpl::createDescriptorPool()
{
#if defined(VK_SUBPASS_SHADING)
    // Create descriptor pool for uniform buffer
    std::array<VkDescriptorPoolSize, 4> pool_sizes = {};
    // std::array<VkDescriptorPoolSize, 2> pool_sizes = {};
    pool_sizes[0].type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
    pool_sizes[0].descriptorCount = 200;
    pool_sizes[1].type = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
    pool_sizes[1].descriptorCount = 200;
    pool_sizes[2].type = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
    pool_sizes[2].descriptorCount = 6; // light visiblity buffer in graphics pipeline and compute pipeline
    pool_sizes[3].type = VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT;
    pool_sizes[3].descriptorCount = 200; // subpass shading input
#endif
#if not defined(VK_SUBPASS_SHADING)
    // Create descriptor pool for uniform buffer
    std::array<VkDescriptorPoolSize, 3> pool_sizes = {};
    pool_sizes[0].type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
    pool_sizes[0].descriptorCount = 100;
    pool_sizes[1].type = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
    pool_sizes[1].descriptorCount = 100;
    pool_sizes[2].type = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
    pool_sizes[2].descriptorCount = 50; // light visiblity buffer in graphics pipeline and compute pipeline
#endif

    VkDescriptorPoolCreateInfo pool_info = {};
    pool_info.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO;
    pool_info.poolSizeCount = (uint32_t)pool_sizes.size();
    pool_info.pPoolSizes = pool_sizes.data();
    pool_info.maxSets = 200;
    pool_info.flags = 0;

    VkDescriptorPool pool;
    if (vkCreateDescriptorPool(graphicsDevice, &pool_info, nullptr, &pool) != VK_SUCCESS) {
        throw std::runtime_error("Failed to create descriptor pool!");
    }

    descriptorPool =
        VulkanRaii<VkDescriptorPool>(pool, [device = this->device](auto &obj) { device.destroyDescriptorPool(obj); });
}

void VulkanRendererImpl::createSceneObjectDescriptorSet()
{
    VkDescriptorSetLayout layouts[] = {objectDescriptorSetLayout.get()};
    VkDescriptorSetAllocateInfo alloc_info = {};
    alloc_info.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
    alloc_info.descriptorPool = descriptorPool.get();
    alloc_info.descriptorSetCount = 1;
    alloc_info.pSetLayouts = layouts;

    if (vkAllocateDescriptorSets(graphicsDevice, &alloc_info, &objectDescriptorSet) != VK_SUCCESS) {
        throw std::runtime_error("Failed to allocate descriptor set!");
    }

    // refer to the uniform object buffer
    VkDescriptorBufferInfo buffer_info = {};
    buffer_info.buffer = objectUniformBuffer.get();
    buffer_info.offset = 0;
    buffer_info.range = sizeof(SceneObjectUbo);

    std::array<VkWriteDescriptorSet, 1> descriptor_writes = {};

    // ubo
    descriptor_writes[0].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    descriptor_writes[0].dstSet = objectDescriptorSet;
    descriptor_writes[0].dstBinding = 0;
    descriptor_writes[0].dstArrayElement = 0;
    descriptor_writes[0].descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
    descriptor_writes[0].descriptorCount = 1;
    descriptor_writes[0].pBufferInfo = &buffer_info;
    descriptor_writes[0].pImageInfo = nullptr;       // Optional
    descriptor_writes[0].pTexelBufferView = nullptr; // Optional

    vkUpdateDescriptorSets(graphicsDevice, (uint32_t)descriptor_writes.size(), descriptor_writes.data(), 0, nullptr);
}

void VulkanRendererImpl::createCameraDescriptorSet()
{
    // Create descriptor set
    {
        vk::DescriptorSetAllocateInfo alloc_info = {
            descriptorPool.get(),               // descriptorPool
            1,                                   // descriptorSetCount
            cameraDescriptorSetLayout.data(), // pSetLayouts
        };

        cameraDescriptorSet = device.allocateDescriptorSets(alloc_info)[0];
    }

    // Write desciptor set
    {
        // refer to the uniform object buffer
        vk::DescriptorBufferInfo camera_uniform_buffer_info{
            cameraUniformBbuffer.get(), // buffer_
            0,                           // offset_
            sizeof(CameraUbo)            // range_
        };

        vk::DescriptorBufferInfo camera_uniform_buffer_info_light{
            cameraUniformBufferLight.get(), // buffer_
            0,                                 // offset_
            sizeof(CameraUbo)                  // range_
        };

        std::vector<vk::WriteDescriptorSet> descriptor_writes = {};

        descriptor_writes.emplace_back(
            cameraDescriptorSet,                // dstSet
            0,                                  // dstBinding
            0,                                  // distArrayElement
            1,                                  // descriptorCount
            vk::DescriptorType::eStorageBuffer, // descriptorType
            nullptr,                            // pImageInfo
            &camera_uniform_buffer_info,        // pBufferInfo
            nullptr);                           // pTexBufferView
        
        descriptor_writes.emplace_back(
            cameraDescriptorSet,                // dstSet
            1,                                  // dstBinding
            0,                                  // distArrayElement
            1,                                  // descriptorCount
            vk::DescriptorType::eStorageBuffer, // descriptorType
            nullptr,                            // pImageInfo
            &camera_uniform_buffer_info_light,  // pBufferInfo
            nullptr);                           // pTexBufferView

        std::array<vk::CopyDescriptorSet, 0> descriptor_copies;
        device.updateDescriptorSets(descriptor_writes, descriptor_copies);
    }
}

void VulkanRendererImpl::createIntermediateDescriptorSet()
{
    // Create descriptor set
    {
        vk::DescriptorSetAllocateInfo alloc_info = {
            descriptorPool.get(),                     // descriptorPool
            1,                                         // descriptorSetCount
            intermediateDescriptorSetLayout.data(), // pSetLayouts
        };

        intermediateDescriptorSet = device.allocateDescriptorSets(alloc_info)[0];
    }
}

#if defined(VK_SUBPASS_SHADING)

void VulkanRendererImpl::createSubpassShadingDescriptorSet()
{
    // Create descriptor set
    {
        vk::DescriptorSetAllocateInfo alloc_info = {
            descriptorPool.get(),                       // descriptorPool
            1,                                           // descriptorSetCount
            subpassShadingDescriptorSetLayout.data()}; // pSetLayouts
        subpassShadingDescriptorSet = device.allocateDescriptorSets(alloc_info)[0];
    }
}

void VulkanRendererImpl::updateSubpassShadingDescriptorSet()
{
    // Write desciptor set
    // LOGI("start update subpass desc");
    std::vector<vk::WriteDescriptorSet> descriptor_writes = {};
    for (int i = 0; i < swapChainFrameBuffers.size(); ++i) {
        vk::DescriptorImageInfo depth_image_info = {textureSampler.get(), depthImageViews[i].get(),
                                                    vk::ImageLayout::eShaderReadOnlyOptimal};

        descriptor_writes.emplace_back(
            subpassShadingDescriptorSet,        // dstSet
            0,                                    // dstBinding
            0,                                    // distArrayElement
            1,                                    // descriptorCount
            vk::DescriptorType::eInputAttachment, // descriptorType
            &depth_image_info,                    // pImageInfo
            nullptr,                              // pBufferInfo
            nullptr);                             // pTexBufferView
    }

    std::array<vk::CopyDescriptorSet, 0> descriptor_copies;
    device.updateDescriptorSets(descriptor_writes, descriptor_copies);
    // LOGI("end update subpass desc, %d", descriptor_writes.size());
}

void VulkanRendererImpl::updateIntermediateDescriptorSet()
{
    // Write desciptor set
    // LOGI("start update Intermediate desc");
    std::vector<vk::WriteDescriptorSet> descriptor_writes = {};
    for (int i = 0; i < swapChainFrameBuffers.size(); ++i) {
        vk::DescriptorImageInfo depth_image_info = {textureSampler.get(), depthImageViews[i].get(),
                                                    vk::ImageLayout::eShaderReadOnlyOptimal};

        descriptor_writes.emplace_back(
            intermediateDescriptorSet,                 // dstSet
            0,                                         // dstBinding
            0,                                         // distArrayElement
            1,                                         // descriptorCount
            vk::DescriptorType::eCombinedImageSampler, // descriptorType
            &depth_image_info,                         // pImageInfo
            nullptr,                                   // pBufferInfo
            nullptr);                                  // pTexBufferView
    }

    std::array<vk::CopyDescriptorSet, 0> descriptor_copies;
    device.updateDescriptorSets(descriptor_writes, descriptor_copies);
    // LOGI("end update Intermediate desc, %d", descriptor_writes.size());
}

void VulkanRendererImpl::createCombineDescriptorSet()
{
    VkDescriptorSetLayout layouts[] = {combineDescriptorSetLayout.get()};
    VkDescriptorSetAllocateInfo alloc_info = {};
    alloc_info.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
    alloc_info.descriptorPool = descriptorPool.get();
    alloc_info.descriptorSetCount = 1;
    alloc_info.pSetLayouts = layouts;

    if (vkAllocateDescriptorSets(graphicsDevice, &alloc_info, &combineDescriptorSet) != VK_SUCCESS) {
        // throw std::runtime_error("Failed to allocate descriptor set!");
        std::cout << "createCombineDescriptorSet throw exception. " << std::endl;
    }

    // refer to the uniform object buffer
    VkDescriptorBufferInfo object_buffer_info = {};
    object_buffer_info.buffer = objectUniformBuffer.get();
    object_buffer_info.offset = 0;
    object_buffer_info.range = sizeof(SceneObjectUbo);

    VkDescriptorBufferInfo camera_buffer_info = {};
    camera_buffer_info.buffer = cameraUniformBbuffer.get();
    camera_buffer_info.offset = 0;
    camera_buffer_info.range = sizeof(CameraUbo);

    // std::array<VkWriteDescriptorSet, 4> descriptor_writes = {};
    std::array<VkWriteDescriptorSet, 2> descriptor_writes = {};

    // ubo
    descriptor_writes[0].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    descriptor_writes[0].dstSet = combineDescriptorSet;
    descriptor_writes[0].dstBinding = 0;
    descriptor_writes[0].dstArrayElement = 0;
    descriptor_writes[0].descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
    descriptor_writes[0].descriptorCount = 1;
    descriptor_writes[0].pBufferInfo = &object_buffer_info;
    descriptor_writes[0].pImageInfo = nullptr;       // Optional
    descriptor_writes[0].pTexelBufferView = nullptr; // Optional

    // camera
    descriptor_writes[1].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    descriptor_writes[1].dstSet = combineDescriptorSet;
    descriptor_writes[1].dstBinding = 1;
    descriptor_writes[1].dstArrayElement = 0;
    descriptor_writes[1].descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
    descriptor_writes[1].descriptorCount = 1;
    descriptor_writes[1].pBufferInfo = &camera_buffer_info;
    descriptor_writes[1].pImageInfo = nullptr;       // Optional
    descriptor_writes[1].pTexelBufferView = nullptr; // Optional

    vkUpdateDescriptorSets(graphicsDevice, (uint32_t)descriptor_writes.size(), descriptor_writes.data(), 0, nullptr);
}

void VulkanRendererImpl::createCombineCommandBuffers()
{
    if (depthPrepassCommandBuffers.size() > 0) {
        vkFreeCommandBuffers(graphicsDevice, graphicsCommandPool, (uint32_t)depthPrepassCommandBuffers.size(),
                             depthPrepassCommandBuffers.data());
    }
    depthPrepassCommandBuffers.clear();
    depthPrepassCommandBuffers.resize(swapChainFrameBuffers.size());

    VkCommandBufferAllocateInfo alloc_info = {};
    alloc_info.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    alloc_info.commandPool = graphicsCommandPool;
    alloc_info.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    alloc_info.commandBufferCount = (uint32_t)depthPrepassCommandBuffers.size();

    auto alloc_result = vkAllocateCommandBuffers(graphicsDevice, &alloc_info, depthPrepassCommandBuffers.data());
    if (alloc_result != VK_SUCCESS) {
        throw std::runtime_error("failed to allocate depth_prepass_command_buffers!");
    }

    // LOGI("allocate commandBuffer result is %d", depth_prepass_command_buffers.size());
    for (int i = 0; i < depthPrepassCommandBuffers.size(); ++i) {
        // LOGI("start record depth command, index is %d, command is %d", i,&depth_prepass_command_buffers[i]);
        //  Begin command
        VkCommandBufferBeginInfo begin_info = {};
        begin_info.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
        begin_info.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
        begin_info.pInheritanceInfo = nullptr; // Optional

        vkBeginCommandBuffer(depthPrepassCommandBuffers[i], &begin_info);
        // LOGI("begin depth command over, then renderPass begin");
        //  render pass
        VkRenderPassBeginInfo render_pass_info = {};
        render_pass_info.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
        render_pass_info.renderPass = depthPrePass.get();
        render_pass_info.framebuffer = depthPrePassFrameBuffers[i].get();
        render_pass_info.renderArea.offset = {0, 0};
        render_pass_info.renderArea.extent = swapChainExtent;
        std::array<VkClearValue, 1> clear_values = {};
        VkClearDepthStencilValue clearDepthStencilValue = {};
        clearDepthStencilValue.depth = 1.0f;
        clearDepthStencilValue.stencil = 0;
        clear_values[0].depthStencil = clearDepthStencilValue;

        render_pass_info.clearValueCount = (uint32_t)clear_values.size();
        render_pass_info.pClearValues = clear_values.data();
        vkCmdBeginRenderPass(depthPrepassCommandBuffers[i], &render_pass_info, VK_SUBPASS_CONTENTS_INLINE);

        vkCmdBindPipeline(depthPrepassCommandBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, depthPipeline.get());
        std::array<VkDescriptorSet, 2> depth_descriptor_sets = {objectDescriptorSet, cameraDescriptorSet};
        vkCmdBindDescriptorSets(depthPrepassCommandBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS,
                                depthPipelineLayout.get(), 0, static_cast<uint32_t>(depth_descriptor_sets.size()),
                                depth_descriptor_sets.data(), 0, nullptr);

        for (const auto &part : model.getMeshParts()) {
            VkBuffer depth_vertex_buffers[] = {part.vertex_buffer_section.buffer};
            VkDeviceSize offsets[] = {part.vertex_buffer_section.offset};

            vkCmdBindVertexBuffers(depthPrepassCommandBuffers[i], 0, 1, depth_vertex_buffers, offsets);
            vkCmdBindIndexBuffer(depthPrepassCommandBuffers[i], part.index_buffer_section.buffer,
                                 part.index_buffer_section.offset, VK_INDEX_TYPE_UINT32);
            vkCmdDrawIndexed(depthPrepassCommandBuffers[i], static_cast<uint32_t>(part.index_count), 1, 0, 0, 0);
        }
        vkCmdNextSubpass(depthPrepassCommandBuffers[i], VK_SUBPASS_CONTENTS_INLINE);
        vkCmdBindPipeline(depthPrepassCommandBuffers[i], VK_PIPELINE_BIND_POINT_SUBPASS_SHADING_HUAWEI,
                          computePipeline.get());
        PushConstantObject pco = {static_cast<int>(swapChainExtent.width), static_cast<int>(swapChainExtent.height),
                                  tileCountPerRow, tileCountPerCol};

        vkCmdPushConstants(depthPrepassCommandBuffers[i], computePipelineLayout.get(),
                           VK_SHADER_STAGE_SUBPASS_SHADING_BIT_HUAWEI, 0, sizeof(pco), &pco);
        std::array<VkDescriptorSet, 3> subpass_descriptor_sets = {lightCullingDescriptorSet, cameraDescriptorSet,
                                                                  subpassShadingDescriptorSet};
        vkCmdBindDescriptorSets(depthPrepassCommandBuffers[i], VK_PIPELINE_BIND_POINT_SUBPASS_SHADING_HUAWEI,
                                computePipelineLayout.get(), 0, static_cast<uint32_t>(subpass_descriptor_sets.size()),
                                subpass_descriptor_sets.data(), 0, nullptr);
        PFN_vkCmdSubpassShadingHUAWEI vkCmdSubpassShadingHUAWEI =
            (PFN_vkCmdSubpassShadingHUAWEI)vkGetDeviceProcAddr(device, "vkCmdSubpassShadingHUAWEI");
        vkCmdSubpassShadingHUAWEI(depthPrepassCommandBuffers[i]);
        vkCmdEndRenderPass(depthPrepassCommandBuffers[i]);
        auto record_result = vkEndCommandBuffer(depthPrepassCommandBuffers[i]);
        if (record_result != VK_SUCCESS) {
            throw std::runtime_error("Failed to record depth_prepass_command_buffers!");
        }
    }
}
#endif

#if not defined(VK_SUBPASS_SHADING)
void VulkanRendererImpl::updateIntermediateDescriptorSet()
{
    // Write desciptor set
    std::vector<vk::WriteDescriptorSet> descriptor_writes = {};
    for (int i = 0; i < swapChainFrameBuffers.size(); ++i) {
        vk::DescriptorImageInfo depth_image_info = {textureSampler.get(), depthImageViews[i].get(),
                                                    vk::ImageLayout::eShaderReadOnlyOptimal};

        descriptor_writes.emplace_back(
            intermediateDescriptorSet,               // dstSet
            0,                                         // dstBinding
            0,                                         // distArrayElement
            1,                                         // descriptorCount
            vk::DescriptorType::eCombinedImageSampler, // descriptorType
            &depth_image_info,                         // pImageInfo
            nullptr,                                   // pBufferInfo
            nullptr);                                 // pTexBufferView
    }

    std::array<vk::CopyDescriptorSet, 0> descriptor_copies;
    device.updateDescriptorSets(descriptor_writes, descriptor_copies);
}

void VulkanRendererImpl::createLightCullingCommandBuffers()
{
    if (lightCullingCommandBuffers.size() > 0) {
        vkFreeCommandBuffers(graphicsDevice, computeCommandPool, (uint32_t)lightCullingCommandBuffers.size(),
                             lightCullingCommandBuffers.data());
    }
    lightCullingCommandBuffers.clear();
    lightCullingCommandBuffers.resize(swapChainFrameBuffers.size());

    VkCommandBufferAllocateInfo alloc_info = {};
    alloc_info.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    alloc_info.commandPool = computeCommandPool;
    alloc_info.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    alloc_info.commandBufferCount = (uint32_t)lightCullingCommandBuffers.size();

    auto alloc_result = vkAllocateCommandBuffers(graphicsDevice, &alloc_info, lightCullingCommandBuffers.data());
    if (alloc_result != VK_SUCCESS) {
        throw std::runtime_error("failed to allocate lightCullingCommandBuffers!");
    }
    for (int i = 0; i < lightCullingCommandBuffers.size(); ++i) {
        VkCommandBufferBeginInfo begin_info = {};
        begin_info.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
        begin_info.flags = VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT;
        begin_info.pInheritanceInfo = nullptr; // Optional

        vkBeginCommandBuffer(lightCullingCommandBuffers[i], &begin_info);
        {
            // barrier before
            std::vector<VkBufferMemoryBarrier> barriers_before;
            VkBufferMemoryBarrier lightVisibilityB = {};
            lightVisibilityB.sType = VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
            lightVisibilityB.srcAccessMask = VK_ACCESS_SHADER_READ_BIT;
            lightVisibilityB.dstAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
            lightVisibilityB.srcQueueFamilyIndex = 0;
            lightVisibilityB.dstQueueFamilyIndex = 0;
            lightVisibilityB.buffer = lightVisibilityBuffer.get();
            lightVisibilityB.offset = 0;
            lightVisibilityB.size = lightVisibilityBufferSize;
            barriers_before.emplace_back(lightVisibilityB);

            VkBufferMemoryBarrier lightVisibilityP = {};
            lightVisibilityP.sType = VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
            lightVisibilityP.srcAccessMask = VK_ACCESS_SHADER_READ_BIT;
            lightVisibilityP.dstAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
            lightVisibilityP.srcQueueFamilyIndex = 0;
            lightVisibilityP.dstQueueFamilyIndex = 0;
            lightVisibilityP.buffer = pointLightBuffer.get();
            lightVisibilityP.offset = 0;
            lightVisibilityP.size = pointLightBufferSize;
            barriers_before.emplace_back(lightVisibilityP);

            vkCmdPipelineBarrier(lightCullingCommandBuffers[i], VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT,
                                 VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
                                 VK_DEPENDENCY_BY_REGION_BIT,
                                 0, nullptr, barriers_before.size(), barriers_before.data(), 0, nullptr);

            std::array<VkDescriptorSet, 3> lightCullingDesc = {lightCullingDescriptorSet, cameraDescriptorSet,
                                                               intermediateDescriptorSet};
            vkCmdBindDescriptorSets(lightCullingCommandBuffers[i], VK_PIPELINE_BIND_POINT_COMPUTE,
                                    computePipelineLayout.get(), 0, lightCullingDesc.size(), lightCullingDesc.data(),
                                    0, nullptr);

            PushConstantObject pco = {static_cast<int>(swapChainExtent.width),
                                      static_cast<int>(swapChainExtent.height), tileCountPerRow,
                                      tileCountPerCol};

            vkCmdPushConstants(lightCullingCommandBuffers[i], computePipelineLayout.get(),
                               VK_SHADER_STAGE_COMPUTE_BIT, 0, sizeof(pco), &pco);
            vkCmdBindPipeline(lightCullingCommandBuffers[i], VK_PIPELINE_BIND_POINT_COMPUTE, computePipeline.get());
            vkCmdDispatch(lightCullingCommandBuffers[i], tileCountPerRow, tileCountPerCol, 1);

            // barrier after
            std::vector<VkBufferMemoryBarrier> barriers_after;
            VkBufferMemoryBarrier lightVisibilityBF = {};
            lightVisibilityBF.sType = VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
            lightVisibilityBF.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
            lightVisibilityBF.dstAccessMask = VK_ACCESS_SHADER_READ_BIT;
            lightVisibilityBF.srcQueueFamilyIndex = 0;
            lightVisibilityBF.dstQueueFamilyIndex = 0;
            lightVisibilityBF.buffer = lightVisibilityBuffer.get();
            lightVisibilityBF.offset = 0;
            lightVisibilityBF.size = lightVisibilityBufferSize;
            barriers_before.emplace_back(lightVisibilityBF);

            VkBufferMemoryBarrier lightVisibilityPF = {};
            lightVisibilityPF.sType = VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER;
            lightVisibilityPF.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
            lightVisibilityPF.dstAccessMask = VK_ACCESS_SHADER_READ_BIT;
            lightVisibilityPF.srcQueueFamilyIndex = 0;
            lightVisibilityPF.dstQueueFamilyIndex = 0;
            lightVisibilityPF.buffer = pointLightBuffer.get();
            lightVisibilityPF.offset = 0;
            lightVisibilityPF.size = pointLightBufferSize;
            barriers_before.emplace_back(lightVisibilityPF);

            vkCmdPipelineBarrier(lightCullingCommandBuffers[i], VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
                                 VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT,
                                 VK_DEPENDENCY_BY_REGION_BIT,
                                 0, nullptr, barriers_after.size(), barriers_after.data(), 0, nullptr);
            vkEndCommandBuffer(lightCullingCommandBuffers[i]);
        }
    }
}

void VulkanRendererImpl::createDepthPrePassCommandBuffers()
{
    if (depthPrepassCommandBuffers.size() > 0) {
        vkFreeCommandBuffers(graphicsDevice, graphicsCommandPool, (uint32_t)depthPrepassCommandBuffers.size(),
                             depthPrepassCommandBuffers.data());
    }
    depthPrepassCommandBuffers.clear();
    depthPrepassCommandBuffers.resize(swapChainFrameBuffers.size());

    VkCommandBufferAllocateInfo alloc_info = {};
    alloc_info.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    alloc_info.commandPool = graphicsCommandPool;
    alloc_info.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    // primary: can be submitted to a queue but cannot be called from other command buffers
    // secondary: can be called by others but cannot be submitted to a queue
    alloc_info.commandBufferCount = (uint32_t)depthPrepassCommandBuffers.size();

    auto alloc_result = vkAllocateCommandBuffers(graphicsDevice, &alloc_info, depthPrepassCommandBuffers.data());
    if (alloc_result != VK_SUCCESS) {
        throw std::runtime_error("failed to allocate command buffers!");
    }

    // Recording Commands
    for (int i = 0; i < depthPrepassCommandBuffers.size(); ++i) {
        VkCommandBufferBeginInfo begin_info = {};
        begin_info.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
        begin_info.flags = VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT;
        begin_info.pInheritanceInfo = nullptr; // Optional

        vkBeginCommandBuffer(depthPrepassCommandBuffers[i], &begin_info);
        {
            std::array<VkClearValue, 1> clear_values = {};
            VkClearDepthStencilValue clearDepthStencilValue = {};
            clearDepthStencilValue.depth = 1.0f;
            clearDepthStencilValue.stencil = 0;
            clear_values[0].depthStencil = clearDepthStencilValue;
            VkRenderPassBeginInfo depth_pass_info = {};
            depth_pass_info.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
            depth_pass_info.renderPass = depthPrePass.get();
            depth_pass_info.framebuffer = depthPrePassFrameBuffers[i].get();
            depth_pass_info.renderArea.offset = {0, 0};
            depth_pass_info.renderArea.extent = swapChainExtent;
            depth_pass_info.clearValueCount = static_cast<uint32_t>(clear_values.size());
            depth_pass_info.pClearValues = clear_values.data();

            vkCmdBeginRenderPass(depthPrepassCommandBuffers[i], &depth_pass_info, VK_SUBPASS_CONTENTS_INLINE);
            for (const auto &part : model.getMeshParts()) {
                vkCmdBindPipeline(depthPrepassCommandBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS,
                                  depthPipeline.get());

                std::array<VkDescriptorSet, 2> depth_descriptor_sets = {objectDescriptorSet, cameraDescriptorSet};

                vkCmdBindDescriptorSets(depthPrepassCommandBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS,
                                        depthPipelineLayout.get(), 0, depth_descriptor_sets.size(),
                                        depth_descriptor_sets.data(), 0, nullptr);

                // bind vertex buffer
                VkBuffer depth_vertex_buffers[] = {part.vertex_buffer_section.buffer};
                VkDeviceSize depth_offsets[] = {part.vertex_buffer_section.offset};
                vkCmdBindVertexBuffers(depthPrepassCommandBuffers[i], 0, 1, depth_vertex_buffers, depth_offsets);
                vkCmdBindIndexBuffer(depthPrepassCommandBuffers[i], part.index_buffer_section.buffer,
                                     part.index_buffer_section.offset, VK_INDEX_TYPE_UINT32);
                vkCmdDrawIndexed(depthPrepassCommandBuffers[i], static_cast<uint32_t>(part.index_count), 1, 0, 0, 0);
            }
            vkCmdEndRenderPass(depthPrepassCommandBuffers[i]);
        }
        auto record_result = vkEndCommandBuffer(depthPrepassCommandBuffers[i]);
        if (record_result != VK_SUCCESS) {
            throw std::runtime_error("Failed to record depth_prepass_command_buffer!");
        }
    }
}

#endif


void VulkanRendererImpl::createGraphicsCommandBuffers()
{
    // Free old command buffers, if any
    if (commandBuffers.size() > 0) {
        vkFreeCommandBuffers(graphicsDevice, graphicsCommandPool, (uint32_t)commandBuffers.size(),
                             commandBuffers.data());
    }
    commandBuffers.clear();

    commandBuffers.resize(swapChainFrameBuffers.size());

    VkCommandBufferAllocateInfo alloc_info = {};
    alloc_info.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    alloc_info.commandPool = graphicsCommandPool;
    alloc_info.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    // primary: can be submitted to a queue but cannot be called from other command buffers
    // secondary: can be called by others but cannot be submitted to a queue
    alloc_info.commandBufferCount = (uint32_t)commandBuffers.size();

    auto alloc_result = vkAllocateCommandBuffers(graphicsDevice, &alloc_info, commandBuffers.data());
    if (alloc_result != VK_SUCCESS) {
        throw std::runtime_error("failed to allocate command buffers!");
    }

    // record command buffers
    for (size_t i = 0; i < commandBuffers.size(); i++) {
        VkCommandBufferBeginInfo begin_info = {};
        begin_info.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
#if defined(VK_SUBPASS_SHADING)
        begin_info.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;
#endif
#if not defined(VK_SUBPASS_SHADING)
        begin_info.flags = VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT;
#endif
        begin_info.pInheritanceInfo = nullptr; // Optional

        vkBeginCommandBuffer(commandBuffers[i], &begin_info);

        // render pass
        {
            VkRenderPassBeginInfo render_pass_info = {};
            render_pass_info.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
            render_pass_info.renderPass = renderPass.get();
            render_pass_info.framebuffer = swapChainFrameBuffersLightPass[i].get();
            render_pass_info.renderArea.offset = {0, 0};
            render_pass_info.renderArea.extent = swapChainExtent;

            std::array<VkClearValue, 2> clear_values = {};
            clear_values[0].color = {1.0f, 0.0f, 0.0f, 1.0f};
            VkClearDepthStencilValue clearDepthStencilValue = {};
            clearDepthStencilValue.depth = 1.0f;
            clearDepthStencilValue.stencil = 0;
            clear_values[1].depthStencil = clearDepthStencilValue;
            render_pass_info.clearValueCount = (uint32_t)clear_values.size();
            render_pass_info.pClearValues = clear_values.data();

            vkCmdBeginRenderPass(commandBuffers[i], &render_pass_info, VK_SUBPASS_CONTENTS_INLINE);

            PushConstantObject pco = {static_cast<int>(swapChainExtent.width),
                                      static_cast<int>(swapChainExtent.height), tileCountPerRow,
                                      tileCountPerCol, debugViewIndex};
            vkCmdPushConstants(commandBuffers[i], pipelineLayout.get(), VK_SHADER_STAGE_FRAGMENT_BIT, 0, sizeof(pco),
                               &pco);

            vkCmdBindPipeline(commandBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, graphicsPipeline.get());

#if defined(VK_SUBPASS_SHADING)
            std::array<VkDescriptorSet, 3> descriptor_sets = {combineDescriptorSet, lightCullingDescriptorSet,
                                                              intermediateDescriptorSet};
#endif
#if not defined(VK_SUBPASS_SHADING)
            std::array<VkDescriptorSet, 4> descriptor_sets = {objectDescriptorSet, cameraDescriptorSet,
                                                              lightCullingDescriptorSet,
                                                              intermediateDescriptorSet};
#endif
            vkCmdBindDescriptorSets(commandBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, pipelineLayout.get(), 0,
                                    static_cast<uint32_t>(descriptor_sets.size()), descriptor_sets.data(), 0, nullptr);
            for (const auto &part : model.getMeshParts()) {
                // bind vertex buffer
                VkBuffer vertex_buffers[] = {part.vertex_buffer_section.buffer};
                VkDeviceSize offsets[] = {part.vertex_buffer_section.offset};
                vkCmdBindVertexBuffers(commandBuffers[i], 0, 1, vertex_buffers, offsets);
                vkCmdBindIndexBuffer(commandBuffers[i], part.index_buffer_section.buffer,
                                     part.index_buffer_section.offset, VK_INDEX_TYPE_UINT32);

                std::array<VkDescriptorSet, 1> mesh_descriptor_sets = {part.material_descriptor_set};
                vkCmdBindDescriptorSets(commandBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, pipelineLayout.get(),
                                        static_cast<uint32_t>(descriptor_sets.size()),
                                        static_cast<uint32_t>(mesh_descriptor_sets.size()), mesh_descriptor_sets.data(),
                                        0, nullptr);
                vkCmdDrawIndexed(commandBuffers[i], static_cast<uint32_t>(part.index_count), 1, 0, 0, 0);
            }
            // LOGI("zzg draw mash over, command index is %d, record commandBuffer add is %p", i,&command_buffers[i]);
            vkCmdEndRenderPass(commandBuffers[i]);
        }

        auto record_result = vkEndCommandBuffer(commandBuffers[i]);
        if (record_result != VK_SUCCESS) {
            throw std::runtime_error("Failed to record command buffer!");
        }
    }

    if (commandBuffersLast.size() > 0) {
        vkFreeCommandBuffers(graphicsDevice, graphicsCommandPool, (uint32_t)commandBuffersLast.size(),
                             commandBuffersLast.data());
    }
    commandBuffersLast.clear();
    commandBuffersLast.resize(swapChainImageviews.size());

    VkCommandBufferAllocateInfo alloc_info_last = {};
    alloc_info_last.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    alloc_info_last.commandPool = graphicsCommandPool;
    alloc_info_last.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    // primary: can be submitted to a queue but cannot be called from other command buffers
    // secondary: can be called by others but cannot be submitted to a queue
    alloc_info_last.commandBufferCount = (uint32_t)commandBuffersLast.size();

    alloc_result = vkAllocateCommandBuffers(graphicsDevice, &alloc_info, commandBuffersLast.data());
    if (alloc_result != VK_SUCCESS) {
        throw std::runtime_error("failed to allocate command buffers!");
    }

    // commandBufferLast
    for (size_t i = 0; i < commandBuffersLast.size(); i++) {
        VkCommandBufferBeginInfo begin_info = {};
        begin_info.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
        begin_info.flags = VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT;
        begin_info.pInheritanceInfo = nullptr; // Optional

        VkCommandBufferBeginInfo beginInfo = {};
        vkBeginCommandBuffer(commandBuffersLast[i], &begin_info);

        VkImageMemoryBarrier layoutTransitionBarrier = {};
        layoutTransitionBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        layoutTransitionBarrier.srcAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
        layoutTransitionBarrier.dstAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
        layoutTransitionBarrier.oldLayout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
        layoutTransitionBarrier.newLayout = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
        // Replace it with the color rt of the lighting pass you created.
        layoutTransitionBarrier.image = swapChainImagesLightPass[i].get();
        layoutTransitionBarrier.subresourceRange = {VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1};
        vkCmdPipelineBarrier(commandBuffersLast[i], VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
                             VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, nullptr, 0, nullptr, 1, &layoutTransitionBarrier);

        VkImageBlit imageBlit = {};
        // Source
        imageBlit.srcSubresource.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
        imageBlit.srcSubresource.layerCount = 1;
        imageBlit.srcSubresource.mipLevel = 0;
        imageBlit.srcOffsets[1].x = int32_t(swapChainExtent.width);
        imageBlit.srcOffsets[1].y = int32_t(swapChainExtent.height);
        imageBlit.srcOffsets[1].z = 1;

        // Destination
        imageBlit.dstSubresource.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
        imageBlit.dstSubresource.layerCount = 1;
        imageBlit.dstSubresource.mipLevel = 0;
        imageBlit.dstOffsets[1].x = int32_t(swapChainExtent.width);
        imageBlit.dstOffsets[1].y = int32_t(swapChainExtent.height);
        imageBlit.dstOffsets[1].z = 1;
        // Fill in the necessary information for the blit
        vkCmdBlitImage(commandBuffersLast[i], swapChainImagesLightPass[i].get(),
                       VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, swapChainImages[i], VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                       1, &imageBlit, VK_FILTER_LINEAR);

        VkImageMemoryBarrier presentBarrier = {};
        presentBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        presentBarrier.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT;
        presentBarrier.dstAccessMask = VK_ACCESS_MEMORY_READ_BIT;
        presentBarrier.oldLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL;
        presentBarrier.newLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
        presentBarrier.image = swapChainImages[i];
        presentBarrier.subresourceRange = {VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1};
        vkCmdPipelineBarrier(commandBuffersLast[i], VK_PIPELINE_STAGE_TRANSFER_BIT,
                             VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, 0, 0, nullptr, 0, nullptr, 1, &presentBarrier);

        VkImageMemoryBarrier layoutTransitionBarrier02 = {};
        layoutTransitionBarrier02.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
        layoutTransitionBarrier02.srcAccessMask = VK_ACCESS_TRANSFER_READ_BIT;
        layoutTransitionBarrier02.dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
        layoutTransitionBarrier02.oldLayout = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
        layoutTransitionBarrier02.newLayout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
        // Replace it with the color rt of the lighting pass you created.
        layoutTransitionBarrier02.image = swapChainImagesLightPass[i].get();
        layoutTransitionBarrier02.subresourceRange = {VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1};
        vkCmdPipelineBarrier(commandBuffersLast[i], VK_PIPELINE_STAGE_TRANSFER_BIT,
                             VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, 0, 0, nullptr, 0, nullptr, 1,
                             &layoutTransitionBarrier);
        vkEndCommandBuffer(commandBuffersLast[i]);
    }
}

void VulkanRendererImpl::createSemaphores()
{
    vk::SemaphoreCreateInfo semaphore_info = {vk::SemaphoreCreateFlags()};
    auto destroyFunc = [&device = this->device](auto &obj) { device.destroySemaphore(obj); };

    VkSemaphoreTypeCreateInfo semaphoreCreateInfo = {};
    semaphoreCreateInfo.sType = VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO;
    semaphoreCreateInfo.pNext = nullptr;
    semaphoreCreateInfo.semaphoreType = VK_SEMAPHORE_TYPE_TIMELINE;
    semaphore_info.pNext = &semaphoreCreateInfo;
    VkFenceCreateInfo fenceCreateInfo = {};
    fenceCreateInfo.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
    fenceCreateInfo.flags = VK_FENCE_CREATE_SIGNALED_BIT;
    imageAvailableSemaphores.resize(swapChainFrameBuffers.size());
    renderFinishedSemaphores.resize(swapChainFrameBuffers.size());
    renderFinishedSemaphoresLast.resize(swapChainFrameBuffers.size());
#if not defined(VK_SUBPASS_SHADING)
    lightCullingCompletedSemaphores.resize(swapChainFrameBuffers.size());
#endif
    depthPrepassFinishedSemaphores.resize(swapChainFrameBuffers.size());
    inFlightFences.resize(swapChainFrameBuffers.size());
    // LOGE("swapchain frameBuffer size is %lu", imageAvailableSemaphores.size());
    for (int i = 0; i < swapChainFrameBuffers.size(); ++i) {
        renderFinishedSemaphores[i] =
            VulkanRaii<vk::Semaphore>(device.createSemaphore(semaphore_info, nullptr), destroyFunc);
        imageAvailableSemaphores[i] =
            VulkanRaii<vk::Semaphore>(device.createSemaphore(semaphore_info, nullptr), destroyFunc);
        renderFinishedSemaphoresLast[i] =
            VulkanRaii<vk::Semaphore>(device.createSemaphore(semaphore_info, nullptr), destroyFunc);
#if not defined(VK_SUBPASS_SHADING)
        lightCullingCompletedSemaphores[i] =
            VulkanRaii<vk::Semaphore>(device.createSemaphore(semaphore_info, nullptr), destroyFunc);
#endif
        depthPrepassFinishedSemaphores[i] =
            VulkanRaii<vk::Semaphore>(device.createSemaphore(semaphore_info, nullptr), destroyFunc);

        if (VK_SUCCESS != vkCreateFence(device, &fenceCreateInfo, nullptr, &inFlightFences[i])) {
            throw std::runtime_error("Failed to create fence!");
        }
        LOGI("create semaphore and fence over.");
    }
}

/**
 * Create compute pipeline for light culling
 */
#if defined(VK_SUBPASS_SHADING)

void VulkanRendererImpl::createComputePipeline()
{
    // Step 1: Create Pipeline
    {
        auto raiiPipelineLayoutDeleter = [device = this->device](auto &obj) { device.destroyPipelineLayout(obj); };
        auto raiiPipelineDeleter = [device = this->device](auto &obj) { device.destroyPipeline(obj); };

        VkPushConstantRange push_constant_range = {};
        push_constant_range.offset = 0;
        push_constant_range.size = sizeof(PushConstantObject);

        push_constant_range.stageFlags = VK_SHADER_STAGE_SUBPASS_SHADING_BIT_HUAWEI;
        std::array<VkDescriptorSetLayout, 3> set_layouts = {lightCullingDescriptorSetLayout.get(),
                                                            cameraDescriptorSetLayout.get(),
                                                            subpassShadingDescriptorSetLayout.get()};

        VkPipelineLayoutCreateInfo pipeline_layout_info = {};
        pipeline_layout_info.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;

        pipeline_layout_info.setLayoutCount = static_cast<int>(set_layouts.size());
        pipeline_layout_info.pSetLayouts = set_layouts.data();
        pipeline_layout_info.pushConstantRangeCount = 1;
        pipeline_layout_info.pPushConstantRanges = &push_constant_range;

        VkPipelineLayout temp_layout;
        vulkan_util::checkResult(vkCreatePipelineLayout(graphicsDevice, &pipeline_layout_info, nullptr, &temp_layout));
        computePipelineLayout = VulkanRaii<VkPipelineLayout>(temp_layout, raiiPipelineLayoutDeleter);

        VkPipeline temp_pipeline;

        auto light_culling_comp_shader_code =
            util::readFile(util::getContentPath("subpass_shading/subpass_shading.comp.spv"));
        auto comp_shader_module = createShaderModule(light_culling_comp_shader_code);
        VkExtent2D maxWorkgroupSize;

        PFN_vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI =
            (PFN_vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI)vkGetDeviceProcAddr(
                device, "vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI");
        if (vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI == nullptr) {
            LOGE("PFN_vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI empty");
        }
        // LOGI("zzg vkGetDeviceProcAddr, vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI is
        // %p",vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI);
        vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI(graphicsDevice, depthPrePass.get(), &maxWorkgroupSize);
        // LOGI("Subpass shadinig workgroup size,width=%d, height=%d", maxWorkgroupSize.width,maxWorkgroupSize.height);

        maxWorkgroupSize.width = 8;
        maxWorkgroupSize.height = 8;
        VkSpecializationMapEntry subpassShadingConstantMapEntries[] = {{0, 0 * sizeof(uint32_t), sizeof(uint32_t)},
                                                                       {1, 1 * sizeof(uint32_t), sizeof(uint32_t)}};

        VkSpecializationInfo subpassShadingConstants = {2, subpassShadingConstantMapEntries, sizeof(VkExtent2D),
                                                        &maxWorkgroupSize};

        VkSubpassShadingPipelineCreateInfoHUAWEI subpassShadingPipelineCreateInfo{
            VK_STRUCTURE_TYPE_SUBPASS_SHADING_PIPELINE_CREATE_INFO_HUAWEI, NULL, depthPrePass.get(), 1};

        VkPipelineShaderStageCreateInfo subpassShadingPipelineStageCreateInfo{
            VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
            NULL,
            0,
            VK_SHADER_STAGE_SUBPASS_SHADING_BIT_HUAWEI,
            comp_shader_module.get(),
            "main",
            &subpassShadingConstants};

        VkComputePipelineCreateInfo subpassShadingComputePipelineCreateInfo = {};
        subpassShadingComputePipelineCreateInfo.sType = VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO,
        subpassShadingComputePipelineCreateInfo.pNext = &subpassShadingPipelineCreateInfo;
        subpassShadingComputePipelineCreateInfo.flags = 0;
        subpassShadingComputePipelineCreateInfo.stage = subpassShadingPipelineStageCreateInfo;
        subpassShadingComputePipelineCreateInfo.layout = computePipelineLayout.get();
        subpassShadingComputePipelineCreateInfo.basePipelineHandle = VK_NULL_HANDLE;
        subpassShadingComputePipelineCreateInfo.basePipelineIndex = 0;

        VkSubpassShadingPipelineCreateInfoHUAWEI *pNextInfo =
            (VkSubpassShadingPipelineCreateInfoHUAWEI *)subpassShadingComputePipelineCreateInfo.pNext;

        VkPipelineShaderStageCreateInfo &stage = subpassShadingComputePipelineCreateInfo.stage;

        VkSpecializationInfo *pSpecializationInfo =
            (VkSpecializationInfo *)subpassShadingComputePipelineCreateInfo.stage.pSpecializationInfo;

        for (uint32_t j = 0; j < subpassShadingConstants.mapEntryCount; ++j) {
            VkSpecializationMapEntry *pMapEntries = (VkSpecializationMapEntry *)&pSpecializationInfo->pMapEntries[j];
        }

        vkCreateComputePipelines(graphicsDevice, VK_NULL_HANDLE, 1, &subpassShadingComputePipelineCreateInfo, NULL,
                                 &temp_pipeline);
        computePipeline = VulkanRaii<VkPipeline>(temp_pipeline, raiiPipelineDeleter);
    };
}

#endif

#if not defined(VK_SUBPASS_SHADING)

void VulkanRendererImpl::createComputePipeline()
{
    // Step 1: Create Pipeline
    {
        auto raii_pipeline_layout_deleter = [device = this->device](auto &obj) { device.destroyPipelineLayout(obj); };
        auto raii_pipeline_deleter = [device = this->device](auto &obj) { device.destroyPipeline(obj); };

        VkPushConstantRange push_constant_range = {};
        push_constant_range.offset = 0;
        push_constant_range.size = sizeof(PushConstantObject);
        push_constant_range.stageFlags = VK_SHADER_STAGE_COMPUTE_BIT;

        VkPipelineLayoutCreateInfo pipeline_layout_info = {};
        pipeline_layout_info.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
        std::array<VkDescriptorSetLayout, 3> set_layouts = {lightCullingDescriptorSetLayout.get(),
                                                            cameraDescriptorSetLayout.get(),
                                                            intermediateDescriptorSetLayout.get()};
        pipeline_layout_info.setLayoutCount = static_cast<int>(set_layouts.size());
        pipeline_layout_info.pSetLayouts = set_layouts.data();
        pipeline_layout_info.pushConstantRangeCount = 1;
        pipeline_layout_info.pPushConstantRanges = &push_constant_range;

        VkPipelineLayout temp_layout;
        vulkan_util::checkResult(vkCreatePipelineLayout(graphicsDevice, &pipeline_layout_info, nullptr, &temp_layout));
        computePipelineLayout = VulkanRaii<VkPipelineLayout>(temp_layout, raii_pipeline_layout_deleter);

        auto light_culling_comp_shader_code =
            util::readFile(util::getContentPath("forward_plus/light_culling.comp.spv"));

        auto comp_shader_module = createShaderModule(light_culling_comp_shader_code);
        VkPipelineShaderStageCreateInfo comp_shader_stage_info = {};
        comp_shader_stage_info.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
        comp_shader_stage_info.stage = VK_SHADER_STAGE_COMPUTE_BIT;
        comp_shader_stage_info.module = comp_shader_module.get();
        comp_shader_stage_info.pName = "main";

        VkComputePipelineCreateInfo pipeline_create_info;
        pipeline_create_info.sType = VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO;
        pipeline_create_info.stage = comp_shader_stage_info;
        pipeline_create_info.layout = computePipelineLayout.get();
        pipeline_create_info.pNext = nullptr;
        pipeline_create_info.flags = 0;
        pipeline_create_info.basePipelineHandle = VK_NULL_HANDLE; // not deriving from existing pipeline
        pipeline_create_info.basePipelineIndex = -1;              // Optional

        VkPipeline temp_pipeline;
        vulkan_util::checkResult(vkCreateComputePipelines(graphicsDevice, VK_NULL_HANDLE, 1, &pipeline_create_info,
                                                          nullptr, &temp_pipeline));
        computePipeline = VulkanRaii<VkPipeline>(temp_pipeline, raii_pipeline_deleter);
    };
}

#endif

/**
 * creating light visiblity descriptor sets for both passes
 */
void VulkanRendererImpl::createLigutCullingDescriptorSet()
{
    // create shared dercriptor set between compute pipeline and rendering pipeline
    {
        VkDescriptorSetLayout layouts[] = {lightCullingDescriptorSetLayout.get()};
        VkDescriptorSetAllocateInfo alloc_info = {};
        alloc_info.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
        alloc_info.descriptorPool = descriptorPool.get();
        alloc_info.descriptorSetCount = 1;
        alloc_info.pSetLayouts = layouts;

        lightCullingDescriptorSet = device.allocateDescriptorSets(alloc_info)[0];
    }
}

// just for sizing information
struct _Dummy_VisibleLightsForTile {
    uint32_t count;
    std::array<uint32_t, MAX_POINT_LIGHT_PER_TILE> lightindices;
};

/**
 * Create or recreate light visibility buffer and its descriptor
 */
void VulkanRendererImpl::createLightVisibilityBuffer()
{
    assert(sizeof(_Dummy_VisibleLightsForTile) == sizeof(int) * (MAX_POINT_LIGHT_PER_TILE + 1));

    tileCountPerRow = (swapChainExtent.width - 1) / TILE_SIZE + 1;
    tileCountPerCol = (swapChainExtent.height - 1) / TILE_SIZE + 1;

    lightVisibilityBufferSize = sizeof(_Dummy_VisibleLightsForTile) * tileCountPerRow * tileCountPerCol;

    std::tie(lightVisibilityBuffer, lightVisibilityBufferMemory) = utility.createBuffer(
        lightVisibilityBufferSize, VK_BUFFER_USAGE_STORAGE_BUFFER_BIT,
        VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT | VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT); // using barrier to sync

    // Write desciptor set in compute shader
    {
        // refer to the uniform object buffer
        vk::DescriptorBufferInfo light_visibility_buffer_info{
            lightVisibilityBuffer.get(), // buffer_
            0,                             // offset_
            lightVisibilityBufferSize   // range_
        };

        // refer to the uniform object buffer
        vk::DescriptorBufferInfo pointlight_buffer_info = {
            pointLightBuffer.get(), // buffer_
            0,                       // offset_
            pointLightBufferSize   // range_
        };

        std::vector<vk::WriteDescriptorSet> descriptor_writes = {};

        descriptor_writes.emplace_back(lightCullingDescriptorSet,       // dstSet
                                       0,                                  // dstBinding
                                       0,                                  // distArrayElement
                                       1,                                  // descriptorCount
                                       vk::DescriptorType::eStorageBuffer, // descriptorType
                                       nullptr,                            // pImageInfo
                                       &light_visibility_buffer_info,      // pBufferInfo
                                       nullptr);                           // pTexBufferView

        descriptor_writes.emplace_back(
            lightCullingDescriptorSet,         // dstSet
            1,                                  // dstBinding
            0,                                  // distArrayElement
            1,                                  // descriptorCount
            vk::DescriptorType::eStorageBuffer, // descriptorType
            nullptr,                            // pImageInfo
            &pointlight_buffer_info,            // pBufferInfo
            nullptr);                           // pTexBufferView
        std::array<vk::CopyDescriptorSet, 0> descriptor_copies;
        device.updateDescriptorSets(descriptor_writes, descriptor_copies);
    }
}

void VulkanRendererImpl::updateUniformBuffers(float deltatime)
{
    static auto start_time = std::chrono::high_resolution_clock::now();
    //    LOGI("---- updateUniformBuffers  start time is %d", start_time);
    // Adding data to scene object buffer

    // update camera ubo
    {
        CameraUbo ubo = {};
        ubo.view = viewMatrix;
        ubo.proj = glm::perspective(glm::radians(45.0f), swapChainExtent.width / (float)swapChainExtent.height,
                                    0.1f, 50.0f);
        ubo.proj[1][1] *= -1; // since the Y axis of Vulkan NDC points down
        ubo.projview = ubo.proj * ubo.view;
        ubo.camPos = camPos;

        void *data;
        vkMapMemory(graphicsDevice, cameraUniformBufferMemory.get(), 0, sizeof(ubo), 0, &data);
        memcpy(data, &ubo, sizeof(ubo));
        vkUnmapMemory(graphicsDevice, cameraUniformBufferMemory.get());
    }

    {
        CameraUbo ubo = {};
        ubo.view = viewMatrix;
        ubo.proj = glm::perspective(glm::radians(45.0f), swapChainExtent.width / (float)swapChainExtent.height,
                                    0.1f, 50.0f);
        ubo.proj[1][1] *= -1; // since the Y axis of Vulkan NDC points down
        ubo.projview = ubo.proj * ubo.view;
        ubo.camPos = camPos;

        void *data;
        vkMapMemory(graphicsDevice, cameraUniformBufferMemoryLight.get(), 0, sizeof(ubo), 0, &data);
        memcpy(data, &ubo, sizeof(ubo));
        vkUnmapMemory(graphicsDevice, cameraUniformBufferMemoryLight.get());
    }

    // update light ubo
    {
        auto light_num = static_cast<int>(pointlights.size());
        VkDeviceSize bufferSize = sizeof(PointLight) * MAX_POINT_LIGHT_COUNT + sizeof(glm::vec4);
        auto pointlights_size = sizeof(PointLight) * pointlights.size();
        void *data;
        vkMapMemory(graphicsDevice, lightsStagingBufferMemory.get(), 0, pointLightBufferSize, 0, &data);
        memcpy(data, &light_num, sizeof(int));
        memcpy((char *)data + sizeof(glm::vec4), pointlights.data(), pointlights_size);
        vkUnmapMemory(graphicsDevice, lightsStagingBufferMemory.get());
        utility.copyBuffer(lightsStagingBuffer.get(), pointLightBuffer.get(), pointLightBufferSize);
    }
    static auto end_time = std::chrono::high_resolution_clock::now();
    //    LOGI("------ updateUniformBuffers  end time is %d", end_time);
}

const uint64_t ACQUIRE_NEXT_IMAGE_TIMEOUT{std::numeric_limits<uint64_t>::max()};

void VulkanRendererImpl::drawFrame()
{
    // 0. waitFence
    vkWaitForFences(graphicsDevice, 1, &inFlightFences[currentFrame], VK_TRUE, UINT64_MAX);
    vkResetFences(graphicsDevice, 1, &inFlightFences[currentFrame]);
    // 1. Acquiring an image from the swap chain
    uint32_t imageIndex;
    {
        auto aquiring_result =
            vkAcquireNextImageKHR(graphicsDevice, swapChain.get(), ACQUIRE_NEXT_IMAGE_TIMEOUT,
                                  imageAvailableSemaphores[currentFrame].get(), VK_NULL_HANDLE, &imageIndex);
        // LOGI("Success to acquire swap chain image: %d.", imageIndex);
        if (aquiring_result == VK_ERROR_OUT_OF_DATE_KHR) {
            // when swap chain needs recreation
            recreateSwapChain();
            return;
        } else if (aquiring_result != VK_SUCCESS && aquiring_result != VK_SUBOPTIMAL_KHR) {
            // LOGE("Failed to acquire swap chain image!");
            throw std::runtime_error("Failed to acquire swap chain image!");
        }
    }

    // 1. submit depth pre-pass command buffer
    {
        VkSubmitInfo submit_info = {};
        submit_info.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO;
        submit_info.waitSemaphoreCount = 0;
        submit_info.pWaitSemaphores = nullptr;
        submit_info.pWaitDstStageMask = nullptr;
        submit_info.commandBufferCount = 1;
        submit_info.pCommandBuffers = &depthPrepassCommandBuffers[imageIndex];
        VkSemaphore signal_semaphores[] = {depthPrepassFinishedSemaphores[currentFrame].get()};
        submit_info.signalSemaphoreCount = 1;
        submit_info.pSignalSemaphores = signal_semaphores;

        auto submit_result = vkQueueSubmit(graphicsQueue, 1, &submit_info, nullptr);
        if (submit_result != VK_SUCCESS) {
            throw std::runtime_error("Failed to submit draw command buffer!");
        }
    }
    if (g_openSleep) {
        usleep(1000 * 40);
    }

#if not defined(VK_SUBPASS_SHADING)
    {
        LOGI("start compute command buffer");
        VkSemaphore wait_semaphores[] = {depthPrepassFinishedSemaphores[currentFrame].get()};
        VkPipelineStageFlags wait_stages[] = {VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT};
        VkSubmitInfo submit_info = {};
        submit_info.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO;
        submit_info.waitSemaphoreCount = 1;
        submit_info.pWaitSemaphores = wait_semaphores;
        submit_info.pWaitDstStageMask = wait_stages;
        submit_info.commandBufferCount = 1;
        submit_info.pCommandBuffers = &lightCullingCommandBuffers[imageIndex];
        submit_info.signalSemaphoreCount = 1;
        VkSemaphore signal_semaphores[] = {lightCullingCompletedSemaphores[currentFrame].get()};
        submit_info.pSignalSemaphores = signal_semaphores;

        auto submit_result = vkQueueSubmit(computeQueue, 1, &submit_info, nullptr);
        if (submit_result != VK_SUCCESS) {
            throw std::runtime_error("Failed to submit light culling command buffer!");
        }
        LOGI("submit compute command");
    }
#endif
    // 2. Submitting the command buffer
    {
        VkSubmitInfo submit_info = {};
        submit_info.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO;
#if defined(VK_SUBPASS_SHADING)
        VkSemaphore wait_semaphores[] = {depthPrepassFinishedSemaphores[currentFrame].get(),
                                         imageAvailableSemaphores[currentFrame].get()};
#endif
#if not defined(VK_SUBPASS_SHADING)
        VkSemaphore wait_semaphores[] = {imageAvailableSemaphores[currentFrame].get(),
                                         lightCullingCompletedSemaphores[currentFrame].get()};
#endif
        VkPipelineStageFlags wait_stages[] = {VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT}; // which stage to execute
        submit_info.waitSemaphoreCount = static_cast<uint32_t>(sizeof(wait_stages) / sizeof(wait_stages[0]));
        submit_info.pWaitSemaphores = wait_semaphores;
        submit_info.pWaitDstStageMask = wait_stages;
        submit_info.commandBufferCount = 1;
        submit_info.pCommandBuffers = &commandBuffers[imageIndex];
        VkSemaphore signal_semaphores[] = {renderFinishedSemaphoresLast[currentFrame].get()};
        submit_info.signalSemaphoreCount = 1;
        submit_info.pSignalSemaphores = signal_semaphores;

        auto submit_result = vkQueueSubmit(graphicsQueue, 1, &submit_info, inFlightFences[currentFrame]);
        if (submit_result != VK_SUCCESS) {
            throw std::runtime_error("Failed to submit draw command buffer!");
        }
        VkSubmitInfo submitInfoLast = {};
        submitInfoLast.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO;
        VkSemaphore waitSemaphoresLast[] = {renderFinishedSemaphoresLast[currentFrame].get()};
        VkPipelineStageFlags waitStagesLast[] = {VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT}; // which stage to execute
        submitInfoLast.waitSemaphoreCount = 1;
        submitInfoLast.pWaitSemaphores = waitSemaphoresLast;
        submitInfoLast.pWaitDstStageMask = waitStagesLast;
        submitInfoLast.commandBufferCount = 1;
        submitInfoLast.pCommandBuffers = &commandBuffersLast[imageIndex];
        VkSemaphore signalSemaphoresLast[] = {renderFinishedSemaphores[currentFrame].get()};
        submitInfoLast.signalSemaphoreCount = 1;
        submitInfoLast.pSignalSemaphores = signalSemaphoresLast;

        submit_result = vkQueueSubmit(graphicsQueue, 1, &submitInfoLast, nullptr);
        if (submit_result != VK_SUCCESS) {
            throw std::runtime_error("Failed to submit draw command buffer!");
        }
    }
    if (g_openSleep) {
        usleep(1000 * 80);
    }
//     vkDeviceWaitIdle(device);
    // 3. Submitting the result back to the swap chain to show it on screen
    {
        VkPresentInfoKHR presentInfo = {};
        presentInfo.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;
        presentInfo.waitSemaphoreCount = 1;
        VkSemaphore present_wait_semaphores[] = {renderFinishedSemaphores[currentFrame].get()};
        presentInfo.pWaitSemaphores = present_wait_semaphores;
        VkSwapchainKHR swapChains[] = {swapChain.get()};
        presentInfo.swapchainCount = 1;
        presentInfo.pSwapchains = swapChains;
        presentInfo.pImageIndices = &imageIndex;
        presentInfo.pResults = nullptr; // Optional, check for if every single chains is successful

        if (g_coutFlag) {
            void *data;
            vkMapMemory(graphicsDevice, lightVisibilityBufferMemory.get(), 0, lightVisibilityBufferSize, 0,
                        &data);
            LightVisiblity *lightVisiblities = (LightVisiblity *)data;

            int tileCount = 0;
            if (swapChainExtent.width == 1280) {
                tileCount = 14400;
            }
            LightVisiblity *target = new LightVisiblity[tileCount];
            int size = tileCount * sizeof(LightVisiblity);
            memset(target, 0, size);
            memcpy(target, lightVisiblities, size);
            LightVisiblity temp;
            std::string stringRes = "";

            std::string fileName = "/data/local/tmp/light.log";
            std::ofstream testFile;
            testFile.open(fileName, std::ios_base::app);

            for (int i = 0; i < tileCount; ++i) {
                temp = target[i];
                int tempCount = temp.count;
                LOGI("dump index i = %d, light count is %d", i, tempCount);
                stringRes = stringRes + "\n" + std::to_string(i) + "--" + std::to_string(tempCount) + "=";
                for (int j = 0; j < tempCount; ++j) {
                    stringRes = stringRes + "--" + std::to_string(temp.lightIndices[j]) + ",";
                }
            }
            testFile << stringRes;
            testFile.close();
            LOGI("zzg write file over");
            vkUnmapMemory(graphicsDevice, lightVisibilityBufferMemory.get());
            g_coutFlag = false;
        }

        VkResult presentResult = vkQueuePresentKHR(presentQueue, &presentInfo);
        if (presentResult == VK_ERROR_OUT_OF_DATE_KHR || presentResult == VK_SUBOPTIMAL_KHR) {
            LOGI("recreateSwapChain...");
            recreateSwapChain();
        } else if (presentResult != VK_SUCCESS) {
            throw std::runtime_error("Failed to present swap chain image!");
        } else {
            LOGI("Success to submit present.");
        }
        currentFrame = (currentFrame + 1) % swapChainFrameBuffers.size();
    }
    if (g_openSleep) {
        usleep(1000 * 160);
    }
}

// Take a screenshot from the current swapchain image
// This is done using a blit from the swapchain image to a linear image whose memory content is then saved as a ppm
// image Getting the image date directly from a swapchain image wouldn't work as they're usually stored in an
// implementation dependent optimal tiling format Note: This requires the swapchain images to be created with the
// VK_IMAGE_USAGE_TRANSFER_SRC_BIT flag (see VulkanSwapChain::create)
VulkanRaii<VkShaderModule> VulkanRendererImpl::createShaderModule(const std::vector<char> &code)
{
    VkShaderModuleCreateInfo createInfo = {};
    createInfo.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
    createInfo.codeSize = code.size();
    createInfo.pCode = (uint32_t *)code.data();

    VkShaderModule temp_sm;
    auto result = vkCreateShaderModule(graphicsDevice, &createInfo, nullptr, &temp_sm);
    if (result != VK_SUCCESS) {
        throw std::runtime_error("failed to create shader module!");
    }
    return VulkanRaii<VkShaderModule>(temp_sm, [device = this->device](auto &obj) { device.destroyShaderModule(obj); });
}

VulkanRenderer::VulkanRenderer(NativeWindow *window) : p_impl(std::make_unique<VulkanRendererImpl>(window)) {}

VulkanRenderer::~VulkanRenderer() = default;

int VulkanRenderer::getDebugViewIndex() const { return p_impl->getDebugViewIndex(); }

void VulkanRenderer::resize(int width, int height) { p_impl->resize(width, height); }

void VulkanRenderer::changeDebugViewIndex(int targetView) { p_impl->changeDebugViewIndex(targetView); }

void VulkanRenderer::requestDraw(float deltatime) { p_impl->requestDraw(deltatime); }

void VulkanRenderer::cleanUp() { p_impl->cleanUp(); }

void VulkanRenderer::setCamera(const glm::mat4 &view, const glm::vec3 campos) { p_impl->setCamera(view, campos); }
