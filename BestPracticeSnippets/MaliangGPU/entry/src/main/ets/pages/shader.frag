/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * 最佳实践：马良GPU最佳实践
 */
// [Start base]
vec2 baseCoord = ve2(0.0);
vec2 offset[4] = {...};
float weight[4] = {...};
vec4 color = vec4(0.0);
for (int i = 0; i < 4; i++) {
    color += weight[i] * texture(texSampler, baseCoord + offset[i]);
}
// [End base]
// [Start type]
struct unity_ Type {
  vec4 vecArrA[4];
  vec4 vecArrB[4];
};
layout(std140) uniform UnityInstancing_PerDraw0 {
  unity_Type unity_Array[32];
};
void main() {
  u_xlati0 = gl_InstanceID + unity_BaseInstanceID;
  u_xlati0 = u_xlati0 << 2;
  u_xlat1.yw = (-_mhyWorldOffset.zx) + unity_Array[u_xlati0 / 4].vecArrA[3].zx;
}
// [End type]
// [Start vec_Arr]
struct unity_ Type {
    vec4 vecArrA[4];
};
layout(std140) uniform UnityInstancing_PerDraw0 {
    unity_Type unity_Array[32];
};
void main() {
    u_xlati0 = gl_InstanceID + unity_BaseInstanceID;
    u_xlati0 = u_xlati0 << 2;
    u_xlat1.yw = (-_mhyWorldOffset.zx) + unity_Array[u_xlati0 / 4].vecArrA[3].zx;
}
// [End vec_Arr]

// [Start version]
// Vertex shader
#version 300 es
in vec4 in_position;
in vec2 in_coord;
out vec2 texCoord;
void main() {
    gl_Position = in_position;
    texCoord = in_coord;
}


// Fragment shader
#version 300 es
precision highp int;
precision highp float;
in vec2 texCoord;
uniform vec2 texOffset;
layout(location = 0) out highp vec4 fragColor0;
layout(location = 0) uniform highp sampler2D sampler0;
void main() {
    vec2 coord = texCoord + texOffset;
    fragColor0 = texture(sampler0, coord);
}
// [End version]

// [Start position]
// Vertex shader
#version 300 es
in vec4 in_position;
in vec2 in_coord;
out vec2 texCoord;
uniform vec2 texOffset;
void main() {
    gl_Position = in_position;
    texCoord = in_coord + texOffset;
}


// Fragment shader
#version 300 es
precision highp int;
precision highp float;
in vec2 texCoord;
uniform vec2 texOffset;
layout(location = 0) out highp vec4 fragColor0;
layout(location = 0) uniform highp sampler2D sampler0;
void main() {
    fragColor0 = texture(sampler0, texCoord);
}

// [End position]

// [Start highp]
highp vec4 t0 = texture(texture_unit0, texcoord, bias);
highp vec4 t1 = texture(texture_unit1, texcoord, bias);
highp vec4 t2 = texture(texture_unit2, texcoord, bias);
highp vec4 t3 = texture(texture_unit3, texcoord, bias);
// [End highp]

// [Start text1]
vec4 t0 = texelFetchOffset(texture_unit0, texcoord0, lod, offset0);
vec4 t1 = texelFetchOffset(texture_unit0, texcoord0, lod, offset1);
vec4 t2 = texelFetchOffset(texture_unit0, texcoord0, lod, offset2);
vec4 t3 = texelFetchOffset(texture_unit0, texcoord0, lod, offset3);
// [End text1]
// [Start texture]
vec4 t0 = texture(texture_unit0, texcoord0 + vec2(-0.25, 0), bias0);
vec4 t1 = texture(texture_unit0, texcoord0 + vec2(0.0, 0.25), bias1);
vec4 t2 = texture(texture_unit0, texcoord0 + vec2(0.0, 0.0), bias2);
vec4 t3 = texture(texture_unit0, texcoord0 + vec2(-0.25, 0.25), bias3);
// [End texture]

// [Start sampler]
uniform lowp/mediump sampler2D texture_unit0;
uniform highp float w[4];
vec4 t0 = texelFetchOffset(texture_unit0, texcoord0, lod, offset0);
vec4 t1 = texelFetchOffset(texture_unit0, texcoord0, lod, offset1);
vec4 t2 = texelFetchOffset(texture_unit0, texcoord0, lod, offset2);
vec4 t3 = texelFetchOffset(texture_unit0, texcoord0, lod, offset3);
vec4 conv_enable = w[0] * t0 + w[1] * t1 + w[2] * t2 + w[3] * t3;
// [End sampler]

// [Start text_2d]
uniform lowp/mediump sampler2D texture_unit0;
vec4 t0 = texelFetchOffset(texture_unit0, texcoord0, lod, offset0);
vec4 t1 = texelFetchOffset(texture_unit0, texcoord0, lod, offset1);
vec4 t2 = texelFetchOffset(texture_unit0, texcoord0, lod, offset2);
vec4 t3 = texelFetchOffset(texture_unit0, texcoord0, lod, offset3);
vec4 max_enable = max(max(max(t0, t1), t2), t3);
// [End text_2d]

// [Start offset1]
uniform lowp/mediump sampler2D texture_unit0;
vec4 t0 = texelFetchOffset(texture_unit0, texcoord0, lod, offset0);
vec4 t1 = texelFetchOffset(texture_unit0, texcoord0, lod, offset1);
vec4 t2 = texelFetchOffset(texture_unit0, texcoord0, lod, offset2);
vec4 t3 = texelFetchOffset(texture_unit0, texcoord0, lod, offset3);
vec4 min_enable = min(min(min(t0, t1), t2), t3);
// [End offset1]

// [Start mem]
cl_mem clImportMemoryARM(cl_context context,
    cl_mem_flags flags,
    const cl_import_properties_arm *properties,
    void *memory,
    size_t size,
    cl_int *errorcode_ret);
    // [End mem]

// [Start native]
native_sin();
native_cos();
native_tan();
native_divide();
native_exp();
native_sqrt();
half_sqrt();
// [End native]

// [Start draw]
vkCmdBeginRenderPass(renderpass1)；
vkCmdDraw()；
vkCmdEndRenderPass()；
vkCmdPipelineBarrier(src: rendering, dst:compute)；
vkCmdDispatch()；
vkCmdPipelineBarrier(src: compute, dst:rendering)；
vkCmdBeginRenderPass(renderpass2)；
vkCmdDraw()；
vkCmdEndRenderPass()；
// [End draw]

// [Start pass]
vkCmdBeginRenderPass(renderpass1);
vkCmdDraw();
vkCmdEndRenderPass();
vkCmdPipelineBarrier(src:rendering, dst:compute);
vkCmdDispatch();
vkCmdBeginRenderPass(renderpass3);
vkCmdDraw();
vkCmdEndRenderPass();
vkCmdPipelineBarrier(src:compute, dst:rendering);
vkCmdBeginRenderPass(renderpass2);
vkCmdDraw();
vkCmdEndRenderPass();
// [End pass]

// [Start sample1]
struct FCocTileSample {
    vec4 Fgd;
};
void main() {
    uint u12 = 0u;
    FCocTileSample t10[3];
    while (u12 < 3u) {
        t10[int(u12)].Fgd = a;
        u12++;
    }
}
// [Start sample1]