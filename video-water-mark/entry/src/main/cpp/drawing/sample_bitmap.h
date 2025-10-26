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

#ifndef SAMPLE_BITMAP_H
#define SAMPLE_BITMAP_H

#include <cstdint>
#include <string>
#include <native_drawing/drawing_bitmap.h>
#include <native_drawing/drawing_color.h>
#include <native_drawing/drawing_canvas.h>
#include <native_drawing/drawing_pen.h>
#include <native_drawing/drawing_brush.h>
#include <native_drawing/drawing_path.h>
#include <native_drawing/drawing_text_blob.h>

class SampleBitMap {
public:
    SampleBitMap() = default;
    ~SampleBitMap();
    
    void SetWidth(uint64_t width);
    void SetHeight(uint64_t height);
    void* GetText(void);
    void Create(void);
    void Destroy(void);
    void DrawText(void);
    
private:
    uint64_t width_ = 0;
    uint64_t height_ = 0;

    OH_Drawing_Bitmap *cBitmap_ = nullptr;
    OH_Drawing_Canvas *cCanvas_ = nullptr;
};

#endif  // SAMPLE_BITMAP_H
