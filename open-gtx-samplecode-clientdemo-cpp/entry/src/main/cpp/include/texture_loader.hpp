#ifndef TEXTURE_LOADER_HPP
#define TEXTURE_LOADER_HPP
#include <GLES3/gl32.h>

namespace OpenGTX {

class TextureLoader final {
    public:

    TextureLoader() = delete;

    TextureLoader(TextureLoader const &) = delete;
    TextureLoader &operator= (TextureLoader const &) = delete;

    TextureLoader(TextureLoader &&) = delete;
    TextureLoader &operator= (TextureLoader &&) = delete;

    ~TextureLoader() = delete;

    [[nodiscard]] static GLuint Load(char const *image) noexcept;
    [[nodiscard]] static GLuint Load(uint32_t &width, uint32_t &height, char const *image) noexcept;
};

} // namespace OpenGTX

#endif // TEXTURE_LOADER_HPP
