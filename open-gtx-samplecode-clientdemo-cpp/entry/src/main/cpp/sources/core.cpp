#include <core.hpp>
#include <asset.hpp>
#include <log.hpp>
#include <scene_opengtx.hpp>

namespace OpenGTX {

namespace {

constexpr auto TIMEOUT = std::chrono::milliseconds(10U);

[[nodiscard]] bool CheckXComponentResult(int32_t result, char const *from, char const *message) noexcept
{
    if (result == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        return true;
    }

    // clang-format off
    static std::unordered_map<int32_t, char const *> const mapper{
        {OH_NATIVEXCOMPONENT_RESULT_FAILED, "OH_NATIVEXCOMPONENT_RESULT_FAILED"},
        {OH_NATIVEXCOMPONENT_RESULT_BAD_PARAMETER, "OH_NATIVEXCOMPONENT_RESULT_BAD_PARAMETER"}
    };

    // clang-format on
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
    // clang-format off

    constexpr napi_property_descriptor const methods[] = {
        {
            .utf8name = "Create",
            .name = nullptr,
            .method = &Core::OnCreate,
            .getter = nullptr,
            .setter = nullptr,
            .value = nullptr,
            .attributes = napi_default,
            .data = nullptr
        },
        {
            .utf8name = "Destroy",
            .name = nullptr,
            .method = &Core::OnDestroy,
            .getter = nullptr,
            .setter = nullptr,
            .value = nullptr,
            .attributes = napi_default,
            .data = nullptr
        },
        {
            .utf8name = "DisablePrediction",
            .name = nullptr,
            .method = &Core::OnDisablePrediction,
            .getter = nullptr,
            .setter = nullptr,
            .value = nullptr,
            .attributes = napi_default,
            .data = nullptr
        },
        {
            .utf8name = "EnablePrediction",
            .name = nullptr,
            .method = &Core::OnEnablePrediction,
            .getter = nullptr,
            .setter = nullptr,
            .value = nullptr,
            .attributes = napi_default,
            .data = nullptr
        },
        {
            .utf8name = "SwitchMode",
            .name = nullptr,
            .method = &Core::OnSwitchMode,
            .getter = nullptr,
            .setter = nullptr,
            .value = nullptr,
            .attributes = napi_default,
            .data = nullptr
        },
        {
            .utf8name = "SwitchTargetFPS",
            .name = nullptr,
            .method = &Core::OnSwitchTargetFPS,
            .getter = nullptr,
            .setter = nullptr,
            .value = nullptr,
            .attributes = napi_default,
            .data = nullptr
        },
        {
            .utf8name = "SwitchSceneID",
            .name = nullptr,
            .method = &Core::OnSwitchSceneID,
            .getter = nullptr,
            .setter = nullptr,
            .value = nullptr,
            .attributes = napi_default,
            .data = nullptr
        },
        {
            .utf8name = "OnBackground",
            .name = nullptr,
            .method = &Core::OnBackground,
            .getter = nullptr,
            .setter = nullptr,
            .value = nullptr,
            .attributes = napi_default,
            .data = nullptr
        },
        {
            .utf8name = "OnForeground",
            .name = nullptr,
            .method = &Core::OnForeground,
            .getter = nullptr,
            .setter = nullptr,
            .value = nullptr,
            .attributes = napi_default,
            .data = nullptr
        }
    };

    // clang-format on

    return CheckNAPIResult(napi_define_properties(env, exports, std::size(methods), methods), env,
        "Core::InitApp", "Can't export methods.");
}

bool Core::InitUI(OH_NativeXComponent *xComponent) noexcept
{
    // clang-format off

    // About static keyword: OH_NativeXComponent_RegisterCallback implicitly requires 
    // to make callback structure valid at any point of time.
    static OH_NativeXComponent_Callback callbacks{
        .OnSurfaceCreated = &Core::OnXComponentSurfaceCreated,
        .OnSurfaceChanged = &Core::OnXComponentSurfaceChanged,
        .OnSurfaceDestroyed = &Core::OnXComponentSurfaceDestroyed,
        .DispatchTouchEvent = &Core::OnXComponentDispatchTouchEvent
    };

    // clang-format on

    return CheckXComponentResult(OH_NativeXComponent_RegisterCallback(xComponent, &callbacks), "Core::InitUI",
        "Can't set callbacks for XComponent");
}

void Core::SetEnv(napi_env env) { core_env = env; }

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

    commandHandlers_[static_cast<size_t>(Command::SWITCH_MODE)] = &Core::OnSwitchMode;
    commandHandlers_[static_cast<size_t>(Command::SWITCH_TARGETFPS)] = &Core::OnSwitchTargetFPS;
    commandHandlers_[static_cast<size_t>(Command::SWITCH_SCENEID)] = &Core::OnSwitchSceneID;
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
    writeQueue_.push_back(Command::PAUSE);
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

void Core::OnSwitchModeRequest(int index) noexcept
{
    m_switchModeIndex = index;
    std::unique_lock<std::mutex> const lock(mutex_);
    writeQueue_.push_back(Command::SWITCH_MODE);
}
void Core::OnSwitchTargetFPSRequest(int index) noexcept
{
    m_switchTargetFPSIndex = index;
    std::unique_lock<std::mutex> const lock(mutex_);
    writeQueue_.push_back(Command::SWITCH_TARGETFPS);
}
void Core::OnSwitchSceneIDRequest(int index) noexcept
{
    m_switchSceneIDIndex = index;
    std::unique_lock<std::mutex> const lock(mutex_);
    writeQueue_.push_back(Command::SWITCH_SCENEID);
}

void Core::OnForeground() noexcept
{
    std::unique_lock<std::mutex> const lock(mutex_);
    writeQueue_.push_back(Command::RESUME);
}

void Core::OnSetPrediction(bool enable) noexcept
{
    std::unique_lock<std::mutex> const lock(mutex_);
    writeQueue_.push_back(enable ? Command::ENABLE_PREDICTION : Command::DISABLE_PREDICTION);
}

void Core::OnSurfaceChanged(OH_NativeXComponent *nativeComponent, Renderer::Window window) noexcept
{
    GOLOGD("Set MainThread MakeCurrent Null");
    eglMakeCurrent(renderer_.GetDisplay(), EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
    std::unique_lock<std::mutex> const lock(mutex_);
    nativeComponent_ = nativeComponent;
    nativeWindow_ = window;
    writeQueue_.push_back(Command::SWAPCHAIN_DESTROYED);
    writeQueue_.push_back(Command::SWAPCHAIN_CREATED);
}

void Core::OnSurfaceCreated(OH_NativeXComponent *nativeComponent, Renderer::Window window) noexcept
{
    {
        GOLOGD("Set MainThread MakeCurrent Null");
        eglMakeCurrent(renderer_.GetDisplay(), EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
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
    scene_ = std::make_unique<SceneOpenGTX>();

    Asset::Init(nativeResourceManager_);
    if (!renderer_.InitRender() || !scene_->OnContextCreated(renderer_)) {
            return;
    }
    thread_ = std::thread(
        [this]() noexcept {
            while (ExecuteMessageQueue()) {
                // C++ calling method by pointer syntax.
                (this->*rendererBodyHandler_)();
            }
        }
    );
}

void Core::OnFrame() noexcept
{
    if (!scene_->OnFrame()) {
        GOLOGW("Core::OnFrame - OpenGtx Deactivation.");
    }
}

void Core::OnIdle() noexcept
{
    std::this_thread::sleep_for(TIMEOUT);
}

bool Core::OnEnablePrediction() noexcept
{
    return scene_->OnEnablePrediction();
}

bool Core::OnDisablePrediction() noexcept
{
    return scene_->OnDisablePrediction();
}

bool Core::OnSwitchMode() noexcept
{ 
    return scene_->OnSwitchMode(m_switchModeIndex);
}

bool Core::OnSwitchTargetFPS() noexcept
{ 
    return scene_->OnSwitchTargetFPS(m_switchTargetFPSIndex);
}

bool Core::OnSwitchSceneID() noexcept
{ 
    return scene_->OnSwitchSceneID(m_switchSceneIDIndex);
}

bool Core::OnQuit() noexcept
{
    scene_->OnContextDestroyed();
    renderer_.ShutDownRender();
    return false;
}

bool Core::OnPause() noexcept
{
    rendererBodyHandler_ = &Core::OnIdle;
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

    if (renderer_.HasSwapchain()) {
        if (!scene_->OnSwapchainDestroyed()) {
            return false;
        }

        renderer_.DestroySwapchain();
    }

    if (!renderer_.InitSwapchain(nativeWindow_, true)) {
        return false;
    }

    renderer_.SetSwapchainResolution(static_cast<uint32_t>(w), static_cast<uint32_t>(h));

    if (!scene_->OnSwapchainCreated()) {
        return false;
    }

    rendererBodyHandler_ = &Core::OnFrame;
    return true;
}

bool Core::OnSwapchainDestroyed() noexcept
{
    rendererBodyHandler_ = &Core::OnIdle;

    if (!renderer_.HasSwapchain()) {
        return true;
    }

    if (!scene_->OnSwapchainDestroyed()) {
        return false;
    }

    renderer_.DestroySwapchain();
    return true;
}

bool Core::OnResume() noexcept
{
    constexpr RendererBodyHandler const cases[] = {&Core::OnIdle, &Core::OnFrame};
    rendererBodyHandler_ = cases[static_cast<size_t>(renderer_.HasSwapchain())];
    return true;
}

napi_value Core::OnBackground(napi_env /*env*/, napi_callback_info /*info*/)
{
    instance_.OnBackground();
    return nullptr;
}

napi_value Core::OnCreate(napi_env env, napi_callback_info info)
{
    if (!env) {
        GOLOGE("env is null");
        return nullptr;
    }
    if (!info) {
        GOLOGE("env is null");
        return nullptr;
    }

    constexpr size_t expectedParams = 2U;

    constexpr size_t resourceManagerIdx = 0U;
    constexpr size_t dpiIdx = 1U;

    size_t argc = expectedParams;
    napi_value argv[expectedParams]{};

    bool const result = CheckNAPIResult(napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr), env,
        "Core::OnCreate", "Can't extract arguments");

    if (!result) {
        return nullptr;
    }

    if (argc != expectedParams) {
        GOLOGE("Core::OnCreate - Parameters expected: %zu, got: %zu", expectedParams, argc);
        return nullptr;
    }

    auto const isNumber = [env](napi_value v, char const *errorMessage) noexcept -> bool {
        napi_valuetype type;

        if (!CheckNAPIResult(napi_typeof(env, v, &type), env, "Core::OnCreate", errorMessage)) {
            return false;
        }

        if (type == napi_number) {
            return true;
        }

        GOLOGE("Core::OnCreate - %s", errorMessage);
        return false;
    };

    napi_value dpi = argv[dpiIdx];

    if (!isNumber(dpi, "Can't extract DPI")) {
        return nullptr;
    }

    double dpiValue;

    if (!CheckNAPIResult(napi_get_value_double(env, dpi, &dpiValue), env, "Core::OnCreate", "Can't extract DPI")) {
        return nullptr;
    }
    
    pixelsPerCentimeter_ = dpiValue * INCHES_IN_CENTIMETER;

    if (NativeResourceManager *rm = OH_ResourceManager_InitNativeResourceManager(env, argv[resourceManagerIdx]); rm) {
        instance_.OnCreate(rm);
        return nullptr;
    }

    GOLOGE("Core::OnCreate - Can't acquire native resource manager.'");
    return nullptr;
}

napi_value Core::OnDestroy(napi_env /*env*/, napi_callback_info /*info*/)
{
    instance_.OnAboutDestroy();
    return nullptr;
}

napi_value Core::OnSwitchMode(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int value0;
    napi_get_value_int32(env, args[0], &value0);
    instance_.OnSwitchModeRequest(value0);
    return nullptr; 
}

napi_value Core::OnSwitchTargetFPS(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int value0;
    napi_get_value_int32(env, args[0], &value0);
    instance_.OnSwitchTargetFPSRequest(value0);
    return nullptr;
}

napi_value Core::OnSwitchSceneID(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int value0;
    napi_get_value_int32(env, args[0], &value0);
    instance_.OnSwitchSceneIDRequest(value0);
    return nullptr;
}


napi_value Core::OnDisablePrediction(napi_env /*env*/, napi_callback_info /*info*/)
{
    instance_.OnDisablePredictionRequest();
    return nullptr;
}

napi_value Core::OnEnablePrediction(napi_env /*env*/, napi_callback_info /*info*/)
{
    instance_.OnEnablePredictionRequest();
    return nullptr;
}

napi_value Core::OnForeground(napi_env /*env*/, napi_callback_info /*info*/)
{
    instance_.OnForeground();
    return nullptr;
}

void Core::OnXComponentDispatchTouchEvent(OH_NativeXComponent */*component*/, void */*window*/)
{
    // NOTHING
}

void Core::OnXComponentSurfaceChanged(OH_NativeXComponent *component, void *window)
{
    if (!component) {
        GOLOGE("component is null");
        return;
    }
    if (!window) {
        GOLOGE("window is null");
        return;
    }
    instance_.OnSurfaceChanged(component, reinterpret_cast<Renderer::Window>(window));
}

void Core::OnXComponentSurfaceCreated(OH_NativeXComponent *component, void *window)
{
    if (!component) {
        GOLOGE("component is null");
        return;
    }
    if (!window) {
        GOLOGE("window is null");
        return;
    }
    instance_.OnSurfaceCreated(component, reinterpret_cast<Renderer::Window>(window));
}

void Core::OnXComponentSurfaceDestroyed(OH_NativeXComponent */*component*/, void */*window*/)
{
    instance_.OnSurfaceDestroyed();
}

bool Core::CheckNAPIResult(napi_status result, napi_env env, char const *from, char const *message) noexcept {
    if (result == napi_ok) {
        return true;
    }

    napi_extended_error_info const *info;
    napi_get_last_error_info(env, &info);

    // clang-format off

    constexpr char const format[] =
R"__(NAPI error:
    From: %s
    Message: %s
    JS message: %s
    Engine error code: %u)__";

    // clang-format on

    GOLOGE(format, from, message, info->error_message, info->engine_error_code);
    return false;
}

} // namespace OpenGTX
