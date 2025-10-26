#version 320 es

#define VERTICES            0
#define UVS                 1
#define NORMALS             2
#define TANGENTS            3
#define BITANGENTS          4

layout(location = VERTICES) in highp vec3                   v_Vertex;
layout(location = UVS) in highp vec2                        v_UV;
layout(location = NORMALS) in highp vec3                    v_Normal;
layout(location = TANGENTS) in highp vec3                   v_Tangent;
layout(location = BITANGENTS) in highp vec3                 v_Bitangent;

layout(binding = 0, std140) uniform Params
{
    highp mat4            vi_ViewTransform;
    highp mat4            vi_PerspectiveTransform;
    highp mat4            vi_VPTransform;
};

layout(binding = 5, std140) uniform InstanceParams
{
    highp mat4            vi_ModelTransform;
    highp vec4            vi_ModelDiffuseColor;
};

layout(location = 0) out smooth highp vec2                                       a_UV;
layout(location = 1) out smooth highp vec3                                       a_FragmentView;
layout(location = 2) out smooth highp vec3                                       a_NormalView;
layout(location = 3) out smooth highp vec3                                       a_TangentView;
layout(location = 4) out smooth highp vec3                                       a_BitangentView;
layout(location = 5) out flat highp vec3                                         a_Diffuse;

void main()
{
    highp mat4 vpTransform = vi_ViewTransform * vi_ModelTransform;
    a_FragmentView = (vpTransform * vec4(v_Vertex, 1.0F)).xyz;
    highp mat3 n = mat3(vpTransform);

    a_NormalView = n * v_Normal;
    a_TangentView = n * v_Tangent;
    a_BitangentView = n * v_Bitangent;

    a_UV = vec2(v_UV.x, 1.0 - v_UV.y);
    a_Diffuse = vi_ModelDiffuseColor.xyz;
    gl_Position = vi_VPTransform * vi_ModelTransform * vec4(v_Vertex, 1.0F);
}