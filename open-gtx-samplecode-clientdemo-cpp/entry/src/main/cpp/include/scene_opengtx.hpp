#ifndef SCENE_OPENGTX_HPP
#define SCENE_OPENGTX_HPP

#include "opaque_layer.hpp"
#include "scene_base.hpp"

namespace OpenGTX {

class SceneOpenGTX final : public SceneBase {
public:
    SceneOpenGTX() = default;

    SceneOpenGTX(SceneOpenGTX const &) = delete;
    SceneOpenGTX& operator= (SceneOpenGTX const &) = delete;

    SceneOpenGTX(SceneOpenGTX &&) = delete;
    SceneOpenGTX& operator= (SceneOpenGTX &&) = delete;

    ~SceneOpenGTX() override = default;

private:
    [[nodiscard]] bool OnContextCreated(Renderer &renderer) noexcept override;
    void OnContextDestroyed() noexcept override;
    [[nodiscard]] bool OnDisablePrediction() noexcept override;
    [[nodiscard]] bool OnEnablePrediction() noexcept override;
    [[nodiscard]] bool OnFrame() noexcept override;
    [[nodiscard]] bool OnSwapchainCreated() noexcept override;
    [[nodiscard]] bool OnSwapchainDestroyed() noexcept override;
    
    [[nodiscard]] bool OnSwitchMode(int index) noexcept override;
    [[nodiscard]] bool OnSwitchTargetFPS(int index) noexcept override;
    [[nodiscard]] bool OnSwitchSceneID(int index) noexcept override;

    void UpdateAndRenderOpaqueScene(FBO const &fbo) noexcept;

    OpaqueLayer opaqueLayer_ {};
    bool realFrameCollected_ = false;
};

} // namespace OpenGTX

#endif // SCENE_OPENGTX_HPP
