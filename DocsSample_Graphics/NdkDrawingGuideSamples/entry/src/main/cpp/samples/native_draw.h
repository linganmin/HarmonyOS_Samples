/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef NDKDRAWINGGUIDESAMPLES_NATIVE_DRAW_H
#define NDKDRAWINGGUIDESAMPLES_NATIVE_DRAW_H
#include <multimedia/image_framework/image_pixel_map_mdk.h>
#include <native_drawing/drawing_bitmap.h>
#include <native_drawing/drawing_brush.h>
#include <native_drawing/drawing_canvas.h>
#include <native_drawing/drawing_color.h>
#include <native_drawing/drawing_color_filter.h>
#include <native_drawing/drawing_image_filter.h>
#include <native_drawing/drawing_shader_effect.h>
#include <native_drawing/drawing_filter.h>
#include <native_drawing/drawing_font.h>
#include <native_drawing/drawing_font_collection.h>
#include <native_drawing/drawing_image.h>
#include <native_drawing/drawing_matrix.h>
#include <native_drawing/drawing_path.h>
#include <native_drawing/drawing_path_effect.h>
#include <native_drawing/drawing_pen.h>
#include <native_drawing/drawing_pixel_map.h>
#include <native_drawing/drawing_point.h>
#include <native_drawing/drawing_rect.h>
#include <native_drawing/drawing_region.h>
#include <native_drawing/drawing_register_font.h>
#include <native_drawing/drawing_round_rect.h>
#include <native_drawing/drawing_sampling_options.h>
#include <native_drawing/drawing_shader_effect.h>
#include <native_drawing/drawing_text_blob.h>
#include <native_drawing/drawing_text_declaration.h>
#include <native_drawing/drawing_text_typography.h>
#include <native_drawing/drawing_typeface.h>
#include <native_drawing/drawing_types.h>

enum DrawType { NONE, CANVASSTATE, SHAPE, PATH, PICTEXT, COMPLEX };

class NativeDraw {
public:
    NativeDraw(OH_Drawing_Canvas* canvas, uint64_t width, uint64_t height): canvas_(canvas), width_(width), height_(height) {}
    ~NativeDraw() = default;
    void DrawPathBrush();
    void DrawPathLine();
    void DrawPathShade();
    void DrawTextBlob();
    void DrawImageRect();
    void DrawPixelMapBrush(NativePixelMap* nativePixelMap);
    void DrawComplexPath();
    void DrawComplex();
    void DrawMatrix();
    void Clip();
    void MoveClip();
    void DrawShapeWithPen();
    void DrawShapeWithBrush();

private:
    uint64_t width_ = 0;
    uint64_t height_ = 0;
    uint64_t textSize_ = 40;
    OH_Drawing_Canvas* canvas_ = nullptr;
};

#endif //NDKDRAWINGGUIDESAMPLES_NATIVE_DRAW_H
