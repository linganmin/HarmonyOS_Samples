#version 320 es

#define DIFFUSE_UNIT                    1
#define NORMAL_UNIT                     2

#define AMBIENT_LIGHT_COLOR             3
#define SPOT_LIGHT_COLOR                3
#define SPOT_LIGHT_LOCATION             4

layout(location = 0) in smooth highp vec2                                                    a_UV;
layout(location = 1) in smooth highp vec3                                                    a_FragmentView;
layout(location = 2) in smooth highp vec3                                                    a_NormalView;
layout(location = 3) in smooth highp vec3                                                    a_TangentView;
layout(location = 4) in smooth highp vec3                                                    a_BitangentView;
layout(location = 5) in flat highp vec3                                                      a_Diffuse;

layout(binding = DIFFUSE_UNIT) uniform lowp sampler2D                   g_Diffuse; // Modify
layout(binding = NORMAL_UNIT) uniform lowp sampler2D                    g_Normal; // Modify

layout(binding = AMBIENT_LIGHT_COLOR, std140) uniform Params
{
    highp vec3 g_AmbientLightColor;
    highp vec3 g_SpotLightColor;
    highp vec3 g_SpotLightLocation;
};

highp float TARGET_SHININESS = 128.0F;

layout(location = 0) out lowp vec4                                      o_Color;

mediump vec3 GetFinalNormalView(in mediump vec3 tangentView, in mediump vec3 bitangentView, in mediump vec3 normalView)
{
    mediump vec3 normalData = fma(texture(g_Normal, a_UV).xyz, vec3(2.0F), vec3(-1.0F));  // Modify
    mediump mat3 tbnView = mat3(tangentView, bitangentView, normalView);
    return normalize(tbnView * normalData);
}

mediump float GetSpecular ( in mediump vec3 finalNormalView, in mediump vec3 toViewerView, in mediump vec3 toLightView,
    in mediump float shininess)
{
    // See https://en.wikipedia.org/wiki/Blinn%E2%80%93Phong_reflection_model

    mediump vec3 halfVector = normalize(toViewerView + toLightView);
    mediump float angleFactor = max(0.0F, dot(halfVector, finalNormalView));
    return pow(angleFactor, shininess);
}

void main()
{
    mediump vec3 diffuseData = texture(g_Diffuse, a_UV).xyz;
    mediump vec3 normalView = GetFinalNormalView(a_TangentView, a_BitangentView, a_NormalView);

    mediump vec3 toView = -normalize(a_FragmentView);
    mediump float lambertian = max(0.0F, dot(toView, normalView));

    mediump vec3 toLight = normalize(g_SpotLightLocation - a_FragmentView);
    lambertian = max(0.0F, dot(normalView, toLight));
    mediump vec3 specularFactor = g_SpotLightColor * GetSpecular(normalView, toView, toLight, TARGET_SHININESS);

    o_Color = vec4(g_AmbientLightColor + fma(diffuseData, vec3(lambertian), specularFactor), 1.0F);
}