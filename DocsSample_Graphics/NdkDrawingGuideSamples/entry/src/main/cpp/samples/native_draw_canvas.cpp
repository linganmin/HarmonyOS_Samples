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
 * 裁剪
 */
void NativeDraw::Clip()
{
    const float startX = 80.f;
    const float startY = 50.0f;
    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *startBlob = OH_Drawing_TextBlobCreateFromString("裁剪", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob, startX, startY);
    OH_Drawing_TextBlobDestroy(startBlob);
    
    OH_Drawing_Brush *brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush, 0xff0000ff);
    OH_Drawing_CanvasAttachBrush(canvas_, brush); 
    OH_Drawing_CanvasSave(canvas_);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(startX, startY + textSize_, startX + 150, startY + textSize_ + 200);
    OH_Drawing_CanvasClipRect(canvas_, rect, OH_Drawing_CanvasClipOp::INTERSECT, true); 
    OH_Drawing_Point *point = OH_Drawing_PointCreate(startX + 150, startY + textSize_ + 200);
    // 被裁剪的圆1
    OH_Drawing_CanvasDrawCircle(canvas_, point, 150);
    OH_Drawing_CanvasRestore(canvas_);
    OH_Drawing_Point *point2 = OH_Drawing_PointCreate(startX + 900, startY + textSize_ + 200);
    // 未被裁剪的圆
    OH_Drawing_CanvasDrawCircle(canvas_, point2, 150);
    OH_Drawing_Rect *rect2 = OH_Drawing_RectCreate(startX + 400, startY + textSize_, startX + 550, startY + textSize_ + 200);
    OH_Drawing_CanvasClipRect(canvas_, rect2, OH_Drawing_CanvasClipOp::DIFFERENCE, true); 
    OH_Drawing_Point *point3 = OH_Drawing_PointCreate(startX + 550, startY + textSize_ + 200);
    // 被裁剪的圆2
    OH_Drawing_CanvasDrawCircle(canvas_, point3, 150);
    OH_Drawing_CanvasRestore(canvas_);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_BrushDestroy(brush);

    OH_Drawing_FontDestroy(font);
}


/**
 * 缩放、平移和选择
 */
void NativeDraw::DrawMatrix()
{
    // 矩阵变换-缩放
    const float startX = 80.f;
    const float startY = 650.0f;
    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *startBlob = OH_Drawing_TextBlobCreateFromString("矩阵变换-缩放", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob, startX, startY);
    OH_Drawing_TextBlobDestroy(startBlob);
    
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(0xFF, 0xFF, 0x00, 0x00));
    OH_Drawing_PenSetWidth(pen, 20);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_CanvasSave(canvas_);
    OH_Drawing_Matrix *matrix = OH_Drawing_MatrixCreateScale(1.3f, 1.3f, 1.3f, 1.3f);
    OH_Drawing_CanvasConcatMatrix(canvas_, matrix);
    OH_Drawing_Point* point = OH_Drawing_PointCreate(startX + 50, startY + textSize_ + 90);
    OH_Drawing_CanvasDrawCircle(canvas_, point, 70);
    OH_Drawing_CanvasRestore(canvas_);
    OH_Drawing_CanvasDrawCircle(canvas_, point, 70);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_PointDestroy(point);
    OH_Drawing_MatrixDestroy(matrix);
    
    // 矩阵变换-平移和旋转
    const float startX2 = startX + width_ / 2;
    OH_Drawing_TextBlob *startBlob2 = OH_Drawing_TextBlobCreateFromString("矩阵变换-平移和旋转", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob2, startX2, startY);
    OH_Drawing_TextBlobDestroy(startBlob2);
    
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_CanvasSave(canvas_);
    OH_Drawing_Matrix *matrix2 = OH_Drawing_MatrixCreateTranslation(150, 150);
    OH_Drawing_CanvasConcatMatrix(canvas_, matrix2);
    OH_Drawing_Matrix* matrix3 = OH_Drawing_MatrixCreateRotation(15, startX + width_ / 2, startY + textSize_ + 50);
    OH_Drawing_CanvasConcatMatrix(canvas_, matrix3);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(startX2, startY + textSize_ + 50,
        startX2 + 300, startY + textSize_ + 300);
    OH_Drawing_CanvasDrawRect(canvas_, rect);
    OH_Drawing_CanvasRestore(canvas_);
    OH_Drawing_CanvasDrawRect(canvas_, rect);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_MatrixDestroy(matrix2);
    
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_FontDestroy(font);
}

/**
 * 裁剪+平移
 */
void NativeDraw::MoveClip()
{
    const float startX = 80.f;
    const float startY = 1250.0f;
    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *startBlob = OH_Drawing_TextBlobCreateFromString("裁剪+平移", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob, startX, startY);
    OH_Drawing_TextBlobDestroy(startBlob);
    
    OH_Drawing_Brush *brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush, 0xff0000ff);
    OH_Drawing_CanvasAttachBrush(canvas_, brush); 
    OH_Drawing_CanvasSave(canvas_);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(startX, startY + textSize_, startX + 250, startY + textSize_ + 300);
    OH_Drawing_CanvasClipRect(canvas_, rect, OH_Drawing_CanvasClipOp::INTERSECT, true); 
    OH_Drawing_CanvasTranslate(canvas_, 100, 100);
    OH_Drawing_Point *point = OH_Drawing_PointCreate(startX + 150, startY + textSize_ + 200);
    // 被裁剪的圆
    OH_Drawing_CanvasDrawCircle(canvas_, point, 150);
    OH_Drawing_CanvasRestore(canvas_);
    OH_Drawing_Point *point2 = OH_Drawing_PointCreate(startX + 550, startY + textSize_ + 200);
    // 未被裁剪的圆
    OH_Drawing_CanvasDrawCircle(canvas_, point2, 150);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_BrushDestroy(brush);

    OH_Drawing_FontDestroy(font);
}