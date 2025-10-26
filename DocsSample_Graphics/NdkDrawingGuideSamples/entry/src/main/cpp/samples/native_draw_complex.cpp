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

#include "sample_demo.h"

/**
 * 复杂绘制效果
 */
void NativeDraw::DrawComplex()
{
    // ShaderEffect
    const float startX = 80.f;
    const float startY = 50.0f;
    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *startBlob = OH_Drawing_TextBlobCreateFromString("ShaderEffect", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob, startX, startY);
    OH_Drawing_TextBlobDestroy(startBlob);
    
    const float startY2 = 100.0f + textSize_;
    OH_Drawing_Point *startPt = OH_Drawing_PointCreate(startX, startY2);
    OH_Drawing_Point *endPt = OH_Drawing_PointCreate(400, 400);
    uint32_t colors[] = {0xFFFFFF00, 0xFFFF0000, 0xFF0000FF};
    float pos[] = {0.0f, 0.5f, 1.0f};
    OH_Drawing_ShaderEffect *colorShaderEffect =
        OH_Drawing_ShaderEffectCreateLinearGradient(startPt, endPt, colors, pos, 3, OH_Drawing_TileMode::CLAMP);
    OH_Drawing_Brush* brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetShaderEffect(brush, colorShaderEffect);
    OH_Drawing_CanvasAttachBrush(canvas_, brush); 
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(startX, startY2, 400, 400);
    OH_Drawing_CanvasDrawRect(canvas_, rect);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_ShaderEffectDestroy(colorShaderEffect);
    OH_Drawing_PointDestroy(startPt);
    OH_Drawing_PointDestroy(endPt);
    
    // ImageFilter
    const float startX2 = startX + width_ / 2;
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *startBlob2 = OH_Drawing_TextBlobCreateFromString("ImageFilter", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob2, startX2, startY);
    OH_Drawing_TextBlobDestroy(startBlob2);
    
    OH_Drawing_Pen *pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetAntiAlias(pen, true);
    OH_Drawing_PenSetColor(pen, 0xffff0000);
    OH_Drawing_PenSetWidth(pen, 20);
    OH_Drawing_ImageFilter *imageFilter =
        OH_Drawing_ImageFilterCreateBlur(20.0f, 20.0f, OH_Drawing_TileMode::CLAMP, nullptr); 
    OH_Drawing_Filter *filter = OH_Drawing_FilterCreate();
    OH_Drawing_FilterSetImageFilter(filter, imageFilter);
    OH_Drawing_PenSetFilter(pen, filter);
    OH_Drawing_CanvasAttachPen(canvas_, pen); 
    OH_Drawing_Rect *rect2 = OH_Drawing_RectCreate(startX2, startY2, startX2 + 400, startY2 + 400);
    OH_Drawing_CanvasDrawRect(canvas_, rect2); 
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_ImageFilterDestroy(imageFilter);
    OH_Drawing_RectDestroy(rect2);
    OH_Drawing_FilterDestroy(filter);
    
    // PathEffect
    const float startY3 = startY2 + 500;
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *startBlob3 = OH_Drawing_TextBlobCreateFromString("PathEffect", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob3, startX, startY3);
    OH_Drawing_TextBlobDestroy(startBlob3);

    OH_Drawing_Pen *iPen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetAntiAlias(iPen, true);
    OH_Drawing_PenSetColor(iPen, OH_Drawing_ColorSetArgb(0xFF, 0xFF, 0x00, 0x00));
    OH_Drawing_PenSetWidth(iPen, 10.0f);
    float intervals[] = {20.0f, 10.0f};
    OH_Drawing_PathEffect *pathEffect = OH_Drawing_CreateDashPathEffect(intervals, 2, 0);
    OH_Drawing_PenSetPathEffect(iPen, pathEffect);
    OH_Drawing_CanvasAttachPen(canvas_, iPen);
    OH_Drawing_CanvasDrawLine(canvas_, startX, startY3 + textSize_, startX + 300.f, startY3 + textSize_ + 500.f);
    OH_Drawing_PathEffectDestroy(pathEffect);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_PenDestroy(iPen);
    
    OH_Drawing_FontDestroy(font);
}