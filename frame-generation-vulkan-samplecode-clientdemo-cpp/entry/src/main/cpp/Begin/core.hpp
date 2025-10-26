/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#pragma once
#include <ace/xcomponent/native_interface_xcomponent.h>
#include <rawfile/raw_file_manager.h>
#include <thread>
#include <vector>
#include "hellovk.h"

enum class PredictionMode : uint16_t {
    EXTRAPOLATION = 0U,
    INTERPOLATION = 1U
};

class Core final {
public:
    Core() = default;

    Core(Core const &) = delete;
    Core &operator = (Core const &) = delete;

    Core(Core &&) = delete;
    Core &operator = (Core &&) = delete;

    ~Core() = default;

    [[nodiscard]] static bool InitApp(napi_env env, napi_value exports) noexcept;
    [[nodiscard]] static bool InitUI(OH_NativeXComponent *xComponent) noexcept;

    static Core *GetInstance()
    {
        return &Core::instance_;
    }
    void SetEnv(napi_env env);
    [[nodiscard]] static bool CheckNAPIResult(napi_status result, napi_env env, char const *from,
        char const *message) noexcept;

    using Window = void *;

private:
    using CommandHandler = bool (Core::*)() noexcept;
    using RendererBodyHandler = void (Core::*)() noexcept;

    enum class Command : uint8_t {
        DISABLE_PREDICTION = 0U,
        ENABLE_PREDICTION,
        PAUSE,
        QUIT,
        RESUME,
        SWAPCHAIN_CREATED,
        SWAPCHAIN_DESTROYED,
        SWAPCHAIN_RECREATED,
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
    void OnSurfaceChanged(OH_NativeXComponent *nativeComponent, Window window) noexcept;
    void OnSurfaceCreated(OH_NativeXComponent *nativeComponent, Window window) noexcept;
    void OnSurfaceDestroyed() noexcept;
    void OnCreate(NativeResourceManager *nativeResourceManager) noexcept;
    bool OnRecreate() noexcept;

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

    // ArkTS handlers.
    [[nodiscard]] static napi_value OnBackground(napi_env env, napi_callback_info info);
    [[nodiscard]] static napi_value OnCreate(napi_env env, napi_callback_info info);
    [[nodiscard]] static napi_value OnDestroy(napi_env env, napi_callback_info info);
    [[nodiscard]] static napi_value OnDisablePrediction(napi_env env, napi_callback_info info);
    [[nodiscard]] static napi_value OnEnablePrediction(napi_env env, napi_callback_info info);
    [[nodiscard]] static napi_value OnForeground(napi_env env, napi_callback_info info);

    // XComponent callbacks.
    static void OnXComponentDispatchTouchEvent(OH_NativeXComponent *component, void *window);
    static void OnXComponentSurfaceChanged(OH_NativeXComponent *component, void *window);
    static void OnXComponentSurfaceCreated(OH_NativeXComponent *component, void *window);
    static void OnXComponentSurfaceDestroyed(OH_NativeXComponent *component, void *window);

    static bool isNumber(napi_env env, napi_value v, const char *errorMessage) noexcept;

    std::vector<Command> readQueue_{};
    std::vector<Command> writeQueue_{};

    CommandHandler commandHandlers_[static_cast<size_t>(Command::COUNT)]{};
    RendererBodyHandler rendererBodyHandler_ = &Core::OnIdle;

    std::thread thread_{};
    std::mutex mutex_{};

    OH_NativeXComponent *nativeComponent_ = nullptr;
    Window nativeWindow_ = nullptr;
    NativeResourceManager *nativeResourceManager_ = nullptr;
    static Core instance_;

    std::unique_ptr<vkt::HelloVK> vulkanBackend_ = std::make_unique<vkt::HelloVK>();
    napi_env core_env;
    static float pixelsPerCentimeter_;
    constexpr static float INCHES_IN_CENTIMETER = 1.0F / 2.54F;
};
