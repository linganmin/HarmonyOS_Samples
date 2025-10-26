/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
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

#ifndef NDKOPENGL_FRAME_HANDLE_H
#define NDKOPENGL_FRAME_HANDLE_H
#include "tetrahedron.h"
class AppNapi;
enum RotateMode {
    AUTO_ROTATE = 0,
    DAMPING_RATATE,
    STOP_ROTATE,
};
class FrameHandle {
public:
    FrameHandle();
    virtual ~FrameHandle() {}
    void Init(AppNapi *app_napi, Tetrahedron *tetrahedron);
    void SetRotate(RotateMode rotateMode);
    void OnFrameHandle(uint64_t timestamp, uint64_t targetTimestamp);

private:
    void ConstantSpeedRotation();
    void DampingRotation();
private:
    AppNapi *app_napi_;
    Tetrahedron *tetrahedron_;
    RotateMode rotate_mode_;
    uint64_t index_;
};

#endif // NDKOPENGL_FRAME_HANDLE_H
