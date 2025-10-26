#include <texture_loader.hpp>
#include <renderer.hpp>
#include <memory>
#include "resources_load.hpp"
#include <utility>

namespace OpenGTX {

GLuint TextureLoader::Load(char const *image) noexcept
{
    uint32_t width;
    uint32_t height;
    return Load(width, height, image);
}

GLuint TextureLoader::Load(uint32_t &width, uint32_t &height,
    char const *image) noexcept
{
    uint8_t numChannels;
    
    char *buf = ReadRawFile(image);
    auto data = Decode(reinterpret_cast<uint8_t *>(buf));
    width = data->width;
    height = data->height;
    numChannels = static_cast<uint8_t>(data->pixelFormZat + 1);

    // clang-format off

    constexpr std::pair<GLenum, GLenum> const params[] = {
        {GL_RGB8, GL_RGB},
        {GL_RGBA8, GL_RGBA}
    };

    // clang-format on

    if(!(numChannels == 3U || numChannels == 4U)){
        GOLOGE("NumChannels does not meet expectations");
        return 0U;
    }
    auto const [internalFormat, format] = params[static_cast<size_t>(numChannels == 4U)];

    GLuint const texture = Renderer::CreateTexture(internalFormat, static_cast<GLuint>(width),
        static_cast<GLuint>(height), Renderer::GetMipLevels(width, height));

    glBindTexture(GL_TEXTURE_2D, texture);
    CheckOpenGLError();

    Renderer::SetUploadTextureAlignment(width, internalFormat);

    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, static_cast<GLsizei>(width), static_cast<GLsizei>(height), format,
        GL_UNSIGNED_BYTE, data->imageBuffer);

    CheckOpenGLError();

    glGenerateMipmap(GL_TEXTURE_2D);
    CheckOpenGLError();

    return texture;
}

} // namespace OpenGTX
