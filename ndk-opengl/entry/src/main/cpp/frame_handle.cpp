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

#include "frame_handle.h"
#include "app_napi.h"
const int DA_MAX                              (360);
const int OMIGA_MAX                           (30);
const int DAMPING_FACTING                     (10);

static int Normalize(int angle)
{
    int ret = angle % CIRCUMFERENCE_DEGREE;
    if (ret < 0) {
        ret += CIRCUMFERENCE_DEGREE;
    }

    return ret;
}
FrameHandle::FrameHandle()
    : app_napi_(nullptr), tetrahedron_(nullptr)
{
    rotate_mode_ = STOP_ROTATE;
}
void FrameHandle::Init(AppNapi *app_napi, Tetrahedron *tetrahedron)
{
    app_napi_ = app_napi;
    tetrahedron_ = tetrahedron;
}

void FrameHandle::SetRotate(RotateMode rotateMode)
{
    index_= 0;
    rotate_mode_ = rotateMode;
}

void FrameHandle::OnFrameHandle(uint64_t timestamp, uint64_t targetTimestamp)
{
    index_++;
    if (rotate_mode_ == AUTO_ROTATE) {
        ConstantSpeedRotation();
    }
    if (rotate_mode_ == DAMPING_RATATE) {
        DampingRotation();
    }
}

void FrameHandle::DampingRotation()
{
    if (index_ >= DA_MAX) {
        rotate_mode_ = STOP_ROTATE;
    } else {
        float tetrahedron_angleX = tetrahedron_->GetAngleX();
        float tetrahedron_angleY = tetrahedron_->GetAngleY();
        const float const_e = 2.718281828459045;
        float factor = DAMPING_FACTING * float (index_) / DA_MAX;
        float da = 5 * OMIGA_MAX * pow(const_e, 0 - factor);
        tetrahedron_angleX += 0;
        tetrahedron_angleY += da;
        tetrahedron_angleX = Normalize(tetrahedron_angleX);
        tetrahedron_angleY = Normalize(tetrahedron_angleY);
        tetrahedron_->Update(tetrahedron_angleX, tetrahedron_angleY);
    }
}

void FrameHandle::ConstantSpeedRotation()
{
    float tetrahedron_angleX = tetrahedron_->GetAngleX();
    float tetrahedron_angleY = tetrahedron_->GetAngleY();
    tetrahedron_angleX += 0;
    tetrahedron_angleY += 1;
    tetrahedron_angleX = Normalize(tetrahedron_angleX);
    tetrahedron_angleY = Normalize(tetrahedron_angleY);
    tetrahedron_->Update(tetrahedron_angleX, tetrahedron_angleY);
}