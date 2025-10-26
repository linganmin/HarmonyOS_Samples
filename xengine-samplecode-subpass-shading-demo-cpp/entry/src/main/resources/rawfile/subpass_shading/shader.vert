#version 450

layout(binding = 0, std140) uniform SceneObjectUbo
{
    mat4 model;
} transform;

layout(binding = 1, std430) readonly buffer CameraUbo
{
    mat4 view;
    mat4 proj;
    mat4 projview;
    vec3 cam_pos;
} camera;

layout(location = 0) in vec3 in_position;
layout(location = 0) out vec3 frag_color;
layout(location = 1) in vec3 in_color;
layout(location = 1) out vec2 frag_tex_coord;
layout(location = 2) in vec2 in_tex_coord;
layout(location = 2) out vec3 frag_normal;
layout(location = 3) in vec3 in_normal;
layout(location = 3) out vec3 frag_pos_world;

void main()
{
    mat4 invtransmodel = transpose(inverse(transform.model));
    mat4 mvp = camera.projview * transform.model;
    gl_Position = mvp * vec4(in_position, 1.0);
    frag_color = in_color;
    frag_tex_coord = in_tex_coord;
    frag_normal = normalize((invtransmodel * vec4(in_normal, 0.0)).xyz);
    frag_pos_world = vec3((transform.model * vec4(in_position, 1.0)).xyz);
}

