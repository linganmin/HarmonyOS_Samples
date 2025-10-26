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
// [Start tile_sample]
struct FCocTileSample {
    float FgdMinCoc;
    float FgdMaxCoc;
    float BgdMinCoc;
    float BgdMaxCoc;
};
void main() {
    uint u12 = 0u;
    FCocTileSample t10[3];
    while (u12 < 3u) {
        t10[int(u12)].FgdMinCoc = a;
        t10[int(u12)].FgdMaxCoc = b;
        t10[int(u12)].BgdMinCoc = c;
        t10[int(u12)].BgdMaxCoc = d;
        u12++;
    }
}
// [End tile_sample]

// [Start pre_sion]
precision highp float;
varying mediump vec4 in0;
mediump vec2 var0 = in0.xw;
mediump vec2 var1 = in0.zy;
mediump vec2 var2 = (var0 + var1) / 2.0f;
// [End pre_sion]

// [Start vec_hp]
precision highp float;
varying vec4 in0;
vec2 var0 = in0.xw;
vec2 var1 = in0.zy;
vec2 var2 = (var0 + var1) / 2.0f;

// [End vec_hp]

// [Start xyz]
if (_61.x) {
    vec3 _513 = (-_37.xyz) * _462._m0[_440 / 8]._m0.www + _462._m0[_440 / 8]._m0.xyz;
    _179.x = _516 + _462._m0[_440 / 8]._m3.w;
    _516 *= _462._m0[_440 / 8]._m2.x;
    _516 *= _462._m0[_440 / 8]._m3.w;
    _559 = dot(_462._m0[_440 / 8]._m3.xyz, _71.xyz);
    _559 = (_559 * _462._m0[_440 / 8]._m2.z) + _462._m0[_440 / 8]._m2.w;
}
// [End xyz]

// [Start xyzw]
if (_61.x) {
    vec4 ldubo_mo = _462._m0[_440 / 8]._m0.xyzw;
    vec4 ldubo_m2 = _462._m0[_440 / 8]._m2.xyzw;
    vec4 ldubo_m3 = _462._m0[_440 / 8]._m3.xyzw;
    vec3 _513 = (-_37.xyz) * ldubo_mo.www + ldubo_mo.xyz;
    _179.x = _516 + ldubo_m3.w;
    _516 *= ldubo_m2.x;
    _516 *= ldubo_m3.w;
    _559 = dot(ldubo_m3.xyz, _71.xyz);
    _559 = (_559 * ldubo_m2.z) + ldubo_m2.w;
}
// [End xyzw]

// [Start array_index]
vec4 UniformArrayDynamicIndex(int i) {
    if (i <= 0) return UArray[0];
    else if (i == 1) return UArray[1];
    else if (i == 2) return UArray[2];
    else if (i == 3) return UArray[3];
    else if (i == 4) return UArray[4];
    else if (i == 5) return UArray[5];
    else if (i == 6) return UArray[6];
    else if (i == 7) return UArray[7];
    else if (i == 8) return UArray[8];
    else if (i == 9) return UArray[9];
    else if (i == 10) return UArray[10];
    else if (i == 11) return UArray[11];
    else if (i == 12) return UArray[12];
    else if (i == 13) return UArray[13];
    else if (i == 14) return UArray[14];
    else if (i == 15) return UArray[15];
    else if (i == 16) return UArray[16];
    else if (i == 17) return UArray[17];
    else if (i == 18) return UArray[18];
    else if (i == 19) return UArray[19];
    else if (i == 20) return UArray[20];
    else if (i == 21) return UArray[21];
    else if (i == 22) return UArray[22];
    else if (i == 23) return UArray[23];
    else if (i == 24) return UArray[24];
    else if (i == 25) return UArray[25];
    else if (i == 26) return UArray[26];
    else if (i == 27) return UArray[27];
    else if (i == 28) return UArray[28];
    else if (i == 29) return UArray[29];
    else if (i == 30) return UArray[30];
    else if (i == 31) return UArray[31];
    return UArray[0];
}
// [End array_index]

// [Start uniform_index]
vec4 UniformArrayDynamicIndex(int i) {
    if (i <0 || i > 31)
        i = 0;
    return UArray[i];
}
// [End uniform_index]

// [Start for_loop]
for (i = 0; i < 2 ; i++) {}
// [End for_loop]

// [Start break]
i = 0;
for (;;) {
    if (((i * 2 ) + 1 >=4)) {
        break;
    }
    i++;
}
// [End break]