#version 450

layout(binding = 0, std430) readonly buffer CameraUbo
{
    mat4 view;
    mat4 proj;
    mat4 projview;
    vec3 cam_pos;
} camera;

layout(binding = 0, std140) uniform SceneObjectUbo
{
    mat4 model;
} transform;

layout(location = 0) in vec3 in_position;

void main()
{
    mat4 mvp = camera.projview * transform.model;
    gl_Position = mvp * vec4(in_position, 1.0);
}

