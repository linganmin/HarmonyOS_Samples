/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include <core.hpp>
#include <log.hpp>

namespace {
constexpr auto TIMEOUT = std::chrono::milliseconds(10U);
constexpr size_t RESOURCE_MANAGER_IDX = 0U;
constexpr size_t DPI_IDX = 1U;
constexpr size_t PREDICTION_MODE_IDX = 2U;
constexpr size_t EXPECTED_PARAMS = 3U;

[[nodiscard]] bool CheckXComponentResult(int32_t result, char const *from, char const *message) noexcept
{
    if (result == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return true;
    }

    static std::unordered_map<int32_t, char const *> const mapper{
        {OH_NATIVEXCOMPONENT_RESULT_FAILED, "OH_NATIVEXCOMPONENT_RESULT_FAILED"},
        {OH_NATIVEXCOMPONENT_RESULT_BAD_PARAMETER, "OH_NATIVEXCOMPONENT_RESULT_BAD_PARAMETER"}
    };

    if (auto const findResult = mapper.find(result); findResult != mapper.cend()) {
        GOLOGE("%s - %s. Error %s", from, message, findResult->second);
        return false;
    }

    GOLOGE("%s - %s. Unknown error code %d", from, message, result);
    return false;
}
} // end of anonymous namespace

Core Core::instance_{};
float Core::pixelsPerCentimeter_ = 360.0F;

bool Core::InitApp(napi_env env, napi_value exports) noexcept
{
    constexpr napi_property_descriptor const methods[] = {
        {"create", nullptr, &Core::OnCreate, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"destroy", nullptr, &Core::OnDestroy, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"disablePrediction", nullptr, &Core::OnDisablePrediction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"enablePrediction", nullptr, &Core::OnEnablePrediction, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"onBackground", nullptr, &Core::OnBackground, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"onForeground", nullptr, &Core::OnForeground, nullptr, nullptr, nullptr, napi_default, nullptr }
    };

    return CheckNAPIResult(napi_define_properties(env, exports, std::size(methods), methods), env, "Core::InitApp",
        "Can't export methods.");
}

bool Core::InitUI(OH_NativeXComponent *xComponent) noexcept
{
    // About static keyword: OH_NativeXComponent_RegisterCallback implicitly requires
    // to make callback structure valid at any point of time.
    static OH_NativeXComponent_Callback callbacks{
        .OnSurfaceCreated = &Core::OnXComponentSurfaceCreated,
        .OnSurfaceChanged = &Core::OnXComponentSurfaceChanged,
        .OnSurfaceDestroyed = &Core::OnXComponentSurfaceDestroyed,
        .DispatchTouchEvent = &Core::OnXComponentDispatchTouchEvent
    };

    return CheckXComponentResult(OH_NativeXComponent_RegisterCallback(xComponent, &callbacks), "Core::InitUI",
        "Can't set callbacks for XComponent");
}

void Core::SetEnv(napi_env env)
{
    core_env = env;
}

bool Core::ExecuteMessageQueue() noexcept
{
    {
        std::unique_lock<std::mutex> const lock(mutex_);
        readQueue_.swap(writeQueue_);
    }

    bool result = true;

    for (auto const command : readQueue_) {
        CommandHandler const handler = commandHandlers_[static_cast<size_t>(command)];

        // C++ calling method by pointer syntax.
        result &= (this->*handler)();
    }

    readQueue_.clear();
    return result;
}

void Core::WaitMessageQueueEmpty() noexcept
{
    for (;;) {
        bool const c0 = readQueue_.empty();
        bool const c1 = writeQueue_.empty();
        if (c0 & c1) {
            return;
        }

        std::this_thread::sleep_for(TIMEOUT);
    }
}

void Core::InitCommandHandlers() noexcept
{
    commandHandlers_[static_cast<size_t>(Command::QUIT)] = &Core::OnQuit;
    commandHandlers_[static_cast<size_t>(Command::ENABLE_PREDICTION)] = &Core::OnEnablePrediction;
    commandHandlers_[static_cast<size_t>(Command::DISABLE_PREDICTION)] = &Core::OnDisablePrediction;
    commandHandlers_[static_cast<size_t>(Command::PAUSE)] = &Core::OnPause;
    commandHandlers_[static_cast<size_t>(Command::RESUME)] = &Core::OnResume;
    commandHandlers_[static_cast<size_t>(Command::SWAPCHAIN_CREATED)] = &Core::OnSwapchainCreated;
    commandHandlers_[static_cast<size_t>(Command::SWAPCHAIN_DESTROYED)] = &Core::OnSwapchainDestroyed;
    commandHandlers_[static_cast<size_t>(Command::SWAPCHAIN_RECREATED)] = &Core::OnRecreate;
}

void Core::OnAboutDestroy() noexcept
{
    {
        std::unique_lock<std::mutex> const lock(mutex_);
        writeQueue_.push_back(Command::QUIT);
    }

    if (thread_.joinable()) {
        thread_.join();
    }
}

void Core::OnBackground() noexcept
{
    std::unique_lock<std::mutex> const lock(mutex_);
}

void Core::OnDisablePredictionRequest() noexcept
{
    std::unique_lock<std::mutex> const lock(mutex_);
    writeQueue_.push_back(Command::DISABLE_PREDICTION);
}

void Core::OnEnablePredictionRequest() noexcept
{
    std::unique_lock<std::mutex> const lock(mutex_);
    writeQueue_.push_back(Command::ENABLE_PREDICTION);
}

void Core::OnForeground() noexcept
{
    std::unique_lock<std::mutex> const lock(mutex_);
    writeQueue_.push_back(Command::RESUME);
}

void Core::OnSurfaceChanged(OH_NativeXComponent *nativeComponent, Window window) noexcept
{
    std::unique_lock<std::mutex> const lock(mutex_);
    nativeComponent_ = nativeComponent;
    nativeWindow_ = window;
    writeQueue_.push_back(Command::SWAPCHAIN_RECREATED);
}

void Core::OnSurfaceCreated(OH_NativeXComponent *nativeComponent, Window window) noexcept
{
    {
        std::unique_lock<std::mutex> const lock(mutex_);
        nativeComponent_ = nativeComponent;
        nativeWindow_ = window;
        writeQueue_.push_back(Command::SWAPCHAIN_CREATED);
    }

    WaitMessageQueueEmpty();
}

void Core::OnSurfaceDestroyed() noexcept
{
    {
        std::unique_lock<std::mutex> const lock(mutex_);
        writeQueue_.push_back(Command::SWAPCHAIN_DESTROYED);
    }

    WaitMessageQueueEmpty();
}

void Core::OnCreate(NativeResourceManager *nativeResourceManager) noexcept
{
    nativeResourceManager_ = nativeResourceManager;

    InitCommandHandlers();
    thread_ = std::thread([this]() noexcept {
        while (ExecuteMessageQueue()) {
            // C++ calling method by pointer syntax.
            (this->*rendererBodyHandler_)();
        }
    });
}

void Core::OnFrame() noexcept
{
    vulkanBackend_->Render();
}

void Core::OnIdle() noexcept
{
    std::this_thread::sleep_for(TIMEOUT);
}

bool Core::OnEnablePrediction() noexcept
{
    vulkanBackend_->FGSetPredictionState(true);
    return true;
}

bool Core::OnDisablePrediction() noexcept
{
    vulkanBackend_->FGSetPredictionState(false);
    return true;
}

bool Core::OnQuit() noexcept
{
    return false;
}

bool Core::OnPause() noexcept
{
    rendererBodyHandler_ = &Core::OnIdle;
    return true;
}

bool Core::OnRecreate() noexcept 
{
    rendererBodyHandler_ = &Core::OnIdle;
    vulkanBackend_->Recreate();
    rendererBodyHandler_ = &Core::OnFrame;
    return true;
}

bool Core::OnSwapchainCreated() noexcept
{
    uint64_t w = 0U;
    uint64_t h = 0U;
    int32_t const result = OH_NativeXComponent_GetXComponentSize(nativeComponent_, nativeWindow_, &w, &h);
    if (!CheckXComponentResult(result, "Core::OnSwapchainCreated", "Can't get resolution")) {
        return false;
    }
    vulkanBackend_->Reset(static_cast<OHNativeWindow *>(nativeWindow_), nativeResourceManager_);
    vulkanBackend_->InitVulkan();
    rendererBodyHandler_ = &Core::OnFrame;
    return true;
}

bool Core::OnSwapchainDestroyed() noexcept
{
    rendererBodyHandler_ = &Core::OnIdle;
    vulkanBackend_->Cleanup();
    return true;
}

bool Core::OnResume() noexcept
{
    rendererBodyHandler_ = &Core::OnFrame;
    return true;
}

napi_value Core::OnBackground(napi_env /* env */, napi_callback_info /* info */)
{
    instance_.OnBackground();
    return nullptr;
}

bool Core::isNumber(napi_env env, napi_value v, const char *errorMessage) noexcept
{
    napi_valuetype type;

    // Perform the type checking
    if (!CheckNAPIResult(napi_typeof(env, v, &type), env, "isNumber", errorMessage)) {
        return false;
    }

    if (type == napi_number) {
        return true;
    }

    // Log the error
    printf("isNumber - %s\n", errorMessage); // Replace this with actual logging mechanism
    return false;
}

napi_value Core::OnCreate(napi_env env, napi_callback_info info)
{
    size_t argc = EXPECTED_PARAMS;
    napi_value argv[EXPECTED_PARAMS]{};

    bool const result = CheckNAPIResult(napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr), env,
        "Core::OnCreate", "Can't extract arguments");
    if (!result) {
        return nullptr;
    }

    if (argc != EXPECTED_PARAMS) {
        GOLOGE("Core::OnCreate - Parameters expected: %zu, got: %zu", EXPECTED_PARAMS, argc);
        return nullptr;
    }

    auto extractInteger = [env](napi_value v, const char *errorMessage) noexcept -> std::optional<int32_t> {
        if (!Core::isNumber(env, v, errorMessage)) {
            return std::nullopt;
        }

        int32_t value;

        if (CheckNAPIResult(napi_get_value_int32(env, v, &value), env, "Core::OnCreate", errorMessage)) {
            return value;
        }

        return std::nullopt;
    };

    auto const predictionMode = extractInteger(argv[PREDICTION_MODE_IDX], "Can't extract prediction mode");
    if (!predictionMode) {
        return nullptr;
    }

    PredictionMode predictionMode_ = static_cast<PredictionMode>(*predictionMode);
    vkt::HelloVK::ENABLE_EXTRAPOLATION = predictionMode_ == PredictionMode::EXTRAPOLATION ? true : false;
    napi_value dpi = argv[DPI_IDX];

    if (!isNumber(env, dpi, "Can't extract DPI")) {
        return nullptr;
    }

    double dpiValue;

    if (!CheckNAPIResult(napi_get_value_double(env, dpi, &dpiValue), env, "Core::OnCreate", "Can't extract DPI")) {
        return nullptr;
    }

    pixelsPerCentimeter_ = dpiValue * INCHES_IN_CENTIMETER;

    if (NativeResourceManager *rm = OH_ResourceManager_InitNativeResourceManager(env, argv[RESOURCE_MANAGER_IDX]); rm) {
        instance_.OnCreate(rm);
        return nullptr;
    }

    GOLOGE("Core::OnCreate - Can't acquire native resource manager.'");
    return nullptr;
}

napi_value Core::OnDestroy(napi_env /* env */, napi_callback_info /* info */)
{
    instance_.OnAboutDestroy();
    return nullptr;
}

napi_value Core::OnDisablePrediction(napi_env /* env */, napi_callback_info /* info */)
{
    instance_.OnDisablePredictionRequest();
    return nullptr;
}

napi_value Core::OnEnablePrediction(napi_env /* env */, napi_callback_info /* info */)
{
    instance_.OnEnablePredictionRequest();
    return nullptr;
}

napi_value Core::OnForeground(napi_env /* env */, napi_callback_info /* info */)
{
    instance_.OnForeground();
    return nullptr;
}

void Core::OnXComponentDispatchTouchEvent(OH_NativeXComponent * /* component */, void * /* window */)
{
    // NOTHING
}

void Core::OnXComponentSurfaceChanged(OH_NativeXComponent *component, void *window)
{
    if (!component || !window) {
        GOLOGE("Core::OnXComponentSurfaceChanged invalid parameters");
        return;
    }
    instance_.OnSurfaceChanged(component, reinterpret_cast<Window>(window));
}

void Core::OnXComponentSurfaceCreated(OH_NativeXComponent *component, void *window)
{
    if (!component || !window) {
        GOLOGE("Core::OnXComponentSurfaceCreated execution failed");
        return;
    }
    instance_.OnSurfaceCreated(component, reinterpret_cast<Window>(window));
}

void Core::OnXComponentSurfaceDestroyed(OH_NativeXComponent * /* component */, void * /* window */)
{
    instance_.OnSurfaceDestroyed();
}

bool Core::CheckNAPIResult(napi_status result, napi_env env, char const *from, char const *message) noexcept
{
    if (result == napi_ok) {
        return true;
    }

    napi_extended_error_info const *info;
    napi_get_last_error_info(env, &info);

    constexpr char const format[] =
R"__(NAPI error:
    From: %s
    Message: %s
    JS message: %s
    Engine error code: %u)__";

    GOLOGE(format, from, message, info->error_message, info->engine_error_code);
    return false;
}
