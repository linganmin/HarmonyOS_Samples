#ifndef CORE_HPP
#define CORE_HPP

#include <renderer.hpp>
#include <scene_base.hpp>
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <rawfile/raw_file_manager.h>
#include <thread>
#include <vector>
namespace OpenGTX {

enum class PredictionMode : uint16_t 
{ 
    EXTRAPOLATION = 0U, 
    INTERPOLATION = 1U 
};

class Core final {
public:
    Core() = default;

    Core(Core const &) = delete;
    Core &operator=(Core const &) = delete;

    Core(Core &&) = delete;
    Core &operator=(Core &&) = delete;

    ~Core() = default;

    [[nodiscard]] static bool InitApp(napi_env env, napi_value exports) noexcept;
    [[nodiscard]] static bool InitUI(OH_NativeXComponent *xComponent) noexcept;
    
    static Core *GetInstance() { return &Core::instance_; }
    NativeResourceManager *GetResourceManager() { return nativeResourceManager_; }
    napi_env GetEnv() { return core_env; }
    void SetEnv(napi_env env);
    [[nodiscard]] static bool CheckNAPIResult(napi_status result, napi_env env, char const *from,char const *message) noexcept;
    float PixelsPerCentimeter() noexcept { return pixelsPerCentimeter_; }

private:
    using CommandHandler = bool (Core::*)() noexcept;
    using RendererBodyHandler = void (Core::*)() noexcept;

    enum class Command : uint8_t
    {
        DISABLE_PREDICTION = 0U,
        ENABLE_PREDICTION,
        PAUSE,
        QUIT,
        RESUME,
        SWAPCHAIN_CREATED,
        SWAPCHAIN_DESTROYED,
        SWITCH_MODE,
        SWITCH_TARGETFPS,
        SWITCH_SCENEID,
        COUNT
        
    };

    [[nodiscard]] bool ExecuteMessageQueue() noexcept;
    void WaitMessageQueueEmpty() noexcept;

    void InitCommandHandlers() noexcept;

    void OnAboutDestroy() noexcept;
    void OnBackground() noexcept;
    void OnDisablePredictionRequest() noexcept;
    void OnEnablePredictionRequest() noexcept;
    void OnForeground() noexcept;
    void OnSetPrediction(bool enable) noexcept;
    void OnSurfaceChanged(OH_NativeXComponent *nativeComponent, Renderer::Window window) noexcept;
    void OnSurfaceCreated(OH_NativeXComponent *nativeComponent, Renderer::Window window) noexcept;
    void OnSurfaceDestroyed() noexcept;
    void OnCreate(NativeResourceManager *nativeResourceManager) noexcept;
    
    void OnSwitchModeRequest(int index) noexcept;
    void OnSwitchTargetFPSRequest(int index) noexcept;
    void OnSwitchSceneIDRequest(int index) noexcept;

    // Render body handlers.
    void OnFrame() noexcept;
    void OnIdle() noexcept;

    // Internal queue handlers.
    [[nodiscard]] bool OnEnablePrediction() noexcept;
    [[nodiscard]] bool OnDisablePrediction() noexcept;
    [[nodiscard]] bool OnQuit() noexcept;
    [[nodiscard]] bool OnPause() noexcept;
    [[nodiscard]] bool OnSwapchainCreated() noexcept;
    [[nodiscard]] bool OnSwapchainDestroyed() noexcept;
    [[nodiscard]] bool OnResume() noexcept;

    [[nodiscard]] bool OnSwitchMode() noexcept;
    [[nodiscard]] bool OnSwitchTargetFPS() noexcept;
    [[nodiscard]] bool OnSwitchSceneID() noexcept;

    // ArkTS handlers.
    [[nodiscard]] static napi_value OnBackground(napi_env env, napi_callback_info info);
    [[nodiscard]] static napi_value OnCreate(napi_env env, napi_callback_info info);
    [[nodiscard]] static napi_value OnDestroy(napi_env env, napi_callback_info info);
    [[nodiscard]] static napi_value OnDisablePrediction(napi_env env, napi_callback_info info);
    [[nodiscard]] static napi_value OnEnablePrediction(napi_env env, napi_callback_info info);
    [[nodiscard]] static napi_value OnForeground(napi_env env, napi_callback_info info);

    [[nodiscard]] static napi_value OnSwitchMode(napi_env env, napi_callback_info info);
    [[nodiscard]] static napi_value OnSwitchTargetFPS(napi_env env, napi_callback_info info);
    [[nodiscard]] static napi_value OnSwitchSceneID(napi_env env, napi_callback_info info);

    // XComponent callbacks.
    static void OnXComponentDispatchTouchEvent(OH_NativeXComponent *component, void *window);
    static void OnXComponentSurfaceChanged(OH_NativeXComponent *component, void *window);
    static void OnXComponentSurfaceCreated(OH_NativeXComponent *component, void *window);
    static void OnXComponentSurfaceDestroyed(OH_NativeXComponent *component, void *window);

    std::vector<Command> readQueue_{};
    std::vector<Command> writeQueue_{};

    CommandHandler commandHandlers_[static_cast<size_t>(Command::COUNT)]{};
    RendererBodyHandler rendererBodyHandler_ = &Core::OnIdle;

    std::thread thread_{};
    std::mutex mutex_{};

    Renderer renderer_{};
    std::unique_ptr<SceneBase> scene_{};

    OH_NativeXComponent *nativeComponent_ = nullptr;
    Renderer::Window nativeWindow_ = nullptr;
    NativeResourceManager *nativeResourceManager_ = nullptr;
    static Core instance_;

    napi_env core_env;
    static float pixelsPerCentimeter_;
    constexpr static float INCHES_IN_CENTIMETER = 1.0F / 2.54F;

    int m_switchModeIndex = 0;
    int m_switchTargetFPSIndex = 0;
    int m_switchSceneIDIndex = 0;
};

} // namespace OpenGTX

#endif // CORE_HPP
