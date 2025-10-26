#ifndef SHADER_SHADER_DRAW_H
#define SHADER_SHADER_DRAW_H
#include <string>
const std::string drawVS = R"""(#version 320 es
precision highp float;
precision highp int;
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoords;

out vec2 TexCoords;

void main()
{
    TexCoords = aTexCoords;
    gl_Position = vec4(aPos, 1.0);
}
)""";

const std::string drawFS = R"""(#version 320 es
precision highp float;
precision highp int;

out vec4 FragColor;

in vec2 TexCoords;

uniform sampler2D screenTexture;

void main()
{
    FragColor = texture(screenTexture, TexCoords);
}
)""";
#endif //SHADER_SHADER_DRAW_H
