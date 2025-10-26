/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef MATH_COMMON_HPP
#define MATH_COMMON_HPP
#include <cmath>

#undef INLINE
#ifndef INLINE
#define INLINE inline
#endif

#define ALIGN16

namespace FrameGeneration {
inline constexpr float PI = 3.141593F;
inline constexpr float EPS = 1e-3f;
inline constexpr float DEG2RAD = PI / 180.0F;
} // namespace FrameGeneration

#endif // MATH_COMMON_HPP
