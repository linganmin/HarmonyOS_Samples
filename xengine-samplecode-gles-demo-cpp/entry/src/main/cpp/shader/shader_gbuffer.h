#ifndef SHADER_SHADER_GBUFFER_H
#define SHADER_SHADER_GBUFFER_H
#include <string>

const std::string gBufferVS = R"""(#version 320 es
precision highp float;
precision highp int;

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec2 aTexCoords;

out vec4 FragPos;
out vec2 TexCoords;
out vec3 Normal;
out vec3 Normal2;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    vec4 worldPos = model * vec4(aPos, 1.0);
    FragPos = worldPos;
    TexCoords = aTexCoords;

    mat3 normalMatrix = transpose(inverse(mat3(model)));
    mat3 normalMatrix2 = transpose(inverse(mat3(view * model)));
    Normal = normalMatrix * aNormal;
    Normal2 = normalMatrix2 * aNormal;

    gl_Position = projection * view * model * vec4(aPos, 1.0);
}
)""";

const std::string gBufferFS = R"""(#version 320 es
precision highp float;
precision highp int;
layout (location = 0) out vec4 gPosition;
layout (location = 1) out vec3 gNormal;
layout (location = 2) out vec4 gAlbedoSpec;
layout (location = 3) out vec3 gNormal2;

in vec2 TexCoords;
in vec4 FragPos;
in vec3 Normal;
in vec3 Normal2;

uniform sampler2D texture_diffuse1;
uniform sampler2D texture_specular1;

void main()
{
    gPosition = FragPos;
    gNormal = normalize(Normal);
    gNormal2 = normalize(Normal2);
    gAlbedoSpec = texture(texture_diffuse1, TexCoords);
}
)""";

#endif //SHADER_SHADER_GBUFFER_H
