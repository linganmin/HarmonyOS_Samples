#version 450
layout(binding = 2, std140) uniform Params
{
    mat4 transform;
};

layout(location = 0) out vec2 fragTexCoord;

const highp vec4 verts[4U] = vec4[](
    vec4(-1.0F, -1.0F, 0.0F, 0.0F),
    vec4(1.0F, -1.0F, 1.0F, 0.0F),
    vec4(-1.0F, 1.0F, 0.0F, 1.0F),
    vec4(1.0F, 1.0F, 1.0F, 1.0F)
);

void main()
{
    highp vec4 v = verts[gl_VertexIndex];

    gl_Position = transform * vec4(v.x, v.y, 0.0, 1.0);
    fragTexCoord = v.zw;
}