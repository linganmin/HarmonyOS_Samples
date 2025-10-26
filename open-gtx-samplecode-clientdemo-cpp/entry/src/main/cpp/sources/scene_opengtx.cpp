#include <scene_opengtx.hpp>
#include <stencil_ids.hpp>
#include <log.hpp>

namespace OpenGTX {

namespace {
// Constant declaration
static const int32_t OGBT_TARGET_FPS_90 = 90;
static const int32_t OGBT_RES_WIDTH = 1080;
static const int32_t OGBT_RES_HEIGHT = 1920;
static const int32_t OGBT_GAME_MAIN_THREAD_ID = 567;
static const int32_t OGBT_GAME_RENDER_THREAD_ID = 789;
static const int32_t OGBT_GAME_DEFAULT_THREAD_ID = 123;
static const int32_t OGBT_MIN_FPS = 30;
static const int32_t OGBT_MAX_FPS = 90;
static const int32_t OGBT_RECOMMEND_FPS = 60;
static const int32_t OGBT_NETWORK_LATENCY_DOWN = 10;
static const int32_t OGBT_NETWORK_LATENCY_UP = 100;
static const int32_t OGBT_NETWORK_LATENCY_TOTAL = 101;
static std::string OGBT_PACKAGE_NAME = "com.aaaa.bbbb";
static std::string OGBT_APP_VERSION = "13.0.0.305";
static std::string OGBT_ENGINE_VERSION = "111";
static std::string OGBT_NETWORK_SERVER_IP = "255.255.255.255";
static std::string OGBT_DESCRIPTION = "OTHERS_SCENE";
} // namespace

void Config_OpenGTX_DeviceInfoCallback(OpenGTX_TempLevel level)
{
    GOLOGE("Config_OpenGTX_DeviceInfoCallback OpenGTX_TempLevel: %d.", level);
}

bool SceneOpenGTX::OnContextCreated(Renderer &renderer) noexcept
{
    return SceneBase::OnContextCreated(renderer) && opaqueLayer_.Init();
}

void SceneOpenGTX::OnContextDestroyed() noexcept
{
    opaqueLayer_.Destroy();
    SceneBase::OnContextDestroyed();
}

bool SceneOpenGTX::OnDisablePrediction() noexcept
{
    predictionEnabled_ = false;

    if (predictionPaused_) {
        return true;
    }
    // Deactivate OpenGTX algorithm
    OpenGTX_ErrorCode errorCode = HMS_OpenGTX_Deactivate(contextGtx_);
    if (errorCode != OPENGTX_SUCCESS) {
        GOLOGE("HMS_OpenGTX_Deactivate execution failed, error code: %d.", errorCode);
    }
    predictionPaused_ = (errorCode == OPENGTX_SUCCESS);
    return predictionPaused_;
}

bool SceneOpenGTX::OnEnablePrediction() noexcept
{
    predictionEnabled_ = true;
    if (!predictionPaused_) {
        return true;
    }
    // Activating an OpenGTX Context Instance
    OpenGTX_ErrorCode errorCode = HMS_OpenGTX_Activate(contextGtx_);
    if (errorCode != OPENGTX_SUCCESS) {
        GOLOGE("HMS_OpenGTX_Activate execution failed, error code: %d.", errorCode);
    }
    predictionPaused_ = (errorCode != OPENGTX_SUCCESS);
    return !predictionPaused_;
}

bool SceneOpenGTX::OnSwitchMode(int index) noexcept
{
    GOLOGE("OnSwitchMode selected index: %d.", index);
    return true;
}

bool SceneOpenGTX::OnSwitchTargetFPS(int index) noexcept
{
    GOLOGE("OnSwitchTargetFPS selected index: %d.", index);
    return true;
}
bool SceneOpenGTX::OnSwitchSceneID(int index) noexcept
{
    GOLOGE("OnSwitchSceneID selected index: %d.", index);
    return true;
}

bool SceneOpenGTX::OnFrame() noexcept
{
    // Showing real frame...
    UpdateAndRenderOpaqueScene(scene_);
    BlitToDisplay(scene_.texture_);

    float guiDelta = guiTimer_.DiffTime();
    guiTimer_.RestartTimer();
    gui_.Draw(*renderer_, guiDelta);

    renderer_->Present();

    if (!predictionEnabled_ || predictionPaused_) {
        return false;
    }
    return true;
}

bool SceneOpenGTX::OnSwapchainCreated() noexcept 
{
    if (!SceneBase::OnSwapchainCreated()) {
        return false;
    }
    auto const &si = renderer_->GetSurfaceInfo();
    if ((canvasW_ == si.width) && (canvasH_ == si.height)) {
        if ((contextGtx_ == nullptr) || !predictionPaused_) {
            return true;
        }
        // Activating an OpenGTX Context Instance
        OpenGTX_ErrorCode errorCode = HMS_OpenGTX_Activate(contextGtx_);
        if (errorCode != OPENGTX_SUCCESS) {
            GOLOGE("HMS_OpenGTX_Activate execution failed, error code: %d.", errorCode);
        }
        predictionPaused_ = (errorCode != OPENGTX_SUCCESS);
        return !predictionPaused_;
    }
    realFrameCollected_ = false;
    
    if (contextGtx_ == nullptr) {
        // Create an OpenGTX context instance and specify the device information callback function.
        contextGtx_ = HMS_OpenGTX_CreateContext(Config_OpenGTX_DeviceInfoCallback);
    }

    OpenGTX_ErrorCode errorCode = OPENGTX_SUCCESS;
    // Declare the OpenGTX attribute configuration structure.
    OpenGTX_ConfigDescription configGtx;
    configGtx.mode = SCENE_MODE;
    configGtx.targetFPS = OGBT_TARGET_FPS_90;
    configGtx.packageName = OGBT_PACKAGE_NAME.data();
    configGtx.appVersion = OGBT_APP_VERSION.data();
    configGtx.engineType = OTHERS_ENGINE;
    configGtx.engineVersion = OGBT_ENGINE_VERSION.data();
    configGtx.gameType = MOBA;
    configGtx.pictureQualityMaxLevel = UHD;
    configGtx.resolutionMaxValue.height = OGBT_RES_HEIGHT;
    configGtx.resolutionMaxValue.width = OGBT_RES_WIDTH;
    configGtx.gameMainThreadId = OGBT_GAME_MAIN_THREAD_ID;
    configGtx.gameRenderThreadId = OGBT_GAME_RENDER_THREAD_ID;
    configGtx.gameKeyThreadIds[0] = OGBT_GAME_DEFAULT_THREAD_ID;
    configGtx.gameKeyThreadIds[1] = OGBT_GAME_DEFAULT_THREAD_ID;
    configGtx.gameKeyThreadIds[2] = OGBT_GAME_DEFAULT_THREAD_ID;
    configGtx.gameKeyThreadIds[3] = OGBT_GAME_DEFAULT_THREAD_ID;
    configGtx.gameKeyThreadIds[4] = OGBT_GAME_DEFAULT_THREAD_ID;
    configGtx.vulkanSupport = true;
    // Set OpenGTX Configuration
    errorCode = HMS_OpenGTX_SetConfiguration(contextGtx_, &configGtx);
    if (errorCode != OPENGTX_SUCCESS) {
        GOLOGE("HMS_OpenGTX_SetConfiguration execution failed, error code: %d.", errorCode);
        return false;
    }

    // Activating an OpenGTX Context Instance
    errorCode = HMS_OpenGTX_Activate(contextGtx_);
    if (errorCode != OPENGTX_SUCCESS) {
        GOLOGE("HMS_OpenGTX_Activate execution failed, error code: %d.", errorCode);
        return false;
    }

    // Send Game Scene Information
    OpenGTX_GameSceneInfo gameSceneInfo;
    gameSceneInfo.sceneID = OTHERS_SCENE;
    gameSceneInfo.description = OGBT_DESCRIPTION.data();
    gameSceneInfo.recommendFPS = OGBT_RECOMMEND_FPS;
    gameSceneInfo.minFPS = OGBT_MIN_FPS;
    gameSceneInfo.maxFPS = OGBT_MAX_FPS;
    gameSceneInfo.resolutionCurValue.height = OGBT_RES_HEIGHT;
    gameSceneInfo.resolutionCurValue.width = OGBT_RES_WIDTH;
    errorCode = HMS_OpenGTX_DispatchGameSceneInfo(contextGtx_, &gameSceneInfo);
    if (errorCode != OPENGTX_SUCCESS) {
        GOLOGE("HMS_OpenGTX_DispatchGameSceneInfo execution failed, error code: %d.", errorCode);
        return false;
    }
    
    // Send Game Network Information.
    OpenGTX_NetworkInfo networkInfo;
    networkInfo.networkLatency.down = OGBT_NETWORK_LATENCY_DOWN;
    networkInfo.networkLatency.up = OGBT_NETWORK_LATENCY_UP;
    networkInfo.networkLatency.total = OGBT_NETWORK_LATENCY_TOTAL;
    networkInfo.networkServerIP = OGBT_NETWORK_SERVER_IP.data();
    errorCode = HMS_OpenGTX_DispatchNetworkInfo(contextGtx_, &networkInfo);
    if (errorCode != OPENGTX_SUCCESS) {
        GOLOGE("HMS_OpenGTX_DispatchNetworkInfo execution failed, error code: %d.", errorCode);
        return false;
    }

    // Update Game Rendering Camera Information.
    OpenGTX_FrameRenderInfo frameRenderInfo;
    frameRenderInfo.mainCameraPosition = {0, 0, 0};
    frameRenderInfo.mainCameraRotate = {0, 0, 0};
    errorCode = HMS_OpenGTX_DispatchFrameRenderInfo(contextGtx_, &frameRenderInfo);
    if (errorCode != OPENGTX_SUCCESS) {
        GOLOGE("HMS_OpenGTX_DispatchFrameRenderInfo execution failed, error code: %d.", errorCode);
        return false;
    } 

    predictionPaused_ = (errorCode != OPENGTX_SUCCESS);
    if (predictionPaused_) {
        return false;
    }
    canvasW_ = si.width;
    canvasH_ = si.height;
    return true;
}

bool SceneOpenGTX::OnSwapchainDestroyed() noexcept
{
    if (predictionPaused_) {
        return true;
    }
    // Destroys the OpenGTX context instance and releases memory resources.
    OpenGTX_ErrorCode errorCode = HMS_OpenGTX_DestroyContext(&contextGtx_);
    predictionPaused_ = (errorCode == OPENGTX_SUCCESS);
    if (errorCode != OPENGTX_SUCCESS) {
        GOLOGE("HMS_OpenGTX_DestroyContext execution failed, error code: %d.", errorCode);
        return false;
    }
    return predictionPaused_;
}

void SceneOpenGTX::UpdateAndRenderOpaqueScene(FBO const &fbo) noexcept
{
    float const sceneDelta = sceneTimer_.DiffTime();
    sceneTimer_.RestartTimer();

    camera_.Update(sceneDelta);
    HandleFPS(sceneDelta);

    glDepthMask(GL_TRUE);
    CheckOpenGLError();

    glStencilMask(std::numeric_limits<GLuint>::max());
    CheckOpenGLError();

    glClearStencil(STENCIL_SKYBOX);
    CheckOpenGLError();

    lastViewProj_ = camera_.GetViewProjectionMatrix();
    lastView_ = camera_.GetViewMatrix();
    lastProj_ = camera_.GetProjectionMatrix();
    
    if (predictionEnabled_) {
        OpenGTX_FrameRenderInfo frameRenderInfo;
        frameRenderInfo.mainCameraPosition = static_cast<OpenGTX_Vector3>(camera_.GetPosition());
        frameRenderInfo.mainCameraRotate = static_cast<OpenGTX_Vector3>(camera_.GetRotation());
        OpenGTX_ErrorCode errorCode =  HMS_OpenGTX_DispatchFrameRenderInfo(contextGtx_,&frameRenderInfo);
        if (errorCode != OPENGTX_SUCCESS) {
            GOLOGE("HMS_OpenGTX_DispatchFrameRenderInfo execution failed, error code: %d.", errorCode);
        }
    }

    renderer_->BeginRenderTarget(fbo, BACKGROUND.x_, BACKGROUND.y_, BACKGROUND.z_, 1.0F);
    opaqueLayer_.Render(sceneDelta, camera_.GetViewMatrix(), lastViewProj_);

    renderer_->EndRenderTarget();
}

} // namespace OpenGTX
