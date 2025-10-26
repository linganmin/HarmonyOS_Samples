#ifndef SHADER_SHADER_LIGHT_H
#define SHADER_SHADER_LIGHT_H
#include <string>

const std::string lightVS = R"""(#version 320 es
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

const std::string lightFS = R"""(#version 320 es
precision highp float;
precision highp int;
out vec4 FragColor;

in vec2 TexCoords;

struct PointLight {
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float constant;
    float linear;
    float quadratic;
};

struct DirLight {
    vec3 lightdir;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

#define NR_POINT_LIGHTS 40

uniform sampler2D gPosition;
uniform sampler2D gNormal;
uniform sampler2D gAlbedo;

uniform vec3 viewPos;
uniform PointLight pointLights[NR_POINT_LIGHTS];
uniform DirLight dirLight;

vec3 CalcDirLight(DirLight light, vec3 normal, vec3 fragPos, vec3 viewDir, float AmbientOcclusion, vec3 Diffuse);
vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir, float AmbientOcclusion, vec3 Diffuse);

void main()
{
    // retrieve data from gbuffer
    vec3 FragPos = texture(gPosition, TexCoords).rgb;
    vec3 Normal = texture(gNormal, TexCoords).rgb;
    vec3 Diffuse = texture(gAlbedo, TexCoords).rgb;
	float Specular = texture(gAlbedo, TexCoords).a;
	vec3 norm = normalize(Normal);
	vec3 viewDir = normalize(viewPos - FragPos);
	vec3 result = CalcDirLight(dirLight, norm, FragPos, viewDir,1.0f, Diffuse);
	for(int i = 0; i < NR_POINT_LIGHTS; i++)
		result += CalcPointLight(pointLights[i], norm, FragPos, viewDir, 1.0f, Diffuse);
	FragColor = vec4(result, 1.0);
}

vec3 CalcDirLight(DirLight light, vec3 normal, vec3 fragPos, vec3 viewDir, float AmbientOcclusion, vec3 Diffuse) {
    vec3 lightDir = normalize(-light.lightdir);
    // diffuse shading
    float diff = max(dot(normal, lightDir), 0.0);
    // specular shading
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 1.0);
    
    float shadow = 0.0f;
    // combine results
    vec3 ambient = light.ambient * Diffuse * AmbientOcclusion;
    vec3 diffuse = light.diffuse * diff * Diffuse;
    vec3 specular = light.specular * spec * Diffuse;
    return ambient + (diffuse + specular);
}

vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir, float AmbientOcclusion, vec3 Diffuse)
{
    vec3 lightDir = normalize(light.position - fragPos);// L
    float diff = max(dot(normal, lightDir), 0.0); // NdotL
    vec3 reflectDir = reflect(-lightDir, normal);// R
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 1.0);//spec
    float distance = length(lightDir);//dist
    float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * (distance * distance));
    vec3 ambient = light.ambient * Diffuse * AmbientOcclusion;
    vec3 diffuse = light.diffuse * diff * Diffuse;
    vec3 specular = light.specular * spec * Diffuse;
    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;
    return (ambient + diffuse + specular);
}

)""";
#endif //SHADER_SHADER_LIGHT_H
