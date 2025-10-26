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
 * 描边效果
 */
void NativeDraw::DrawShapeWithPen()
{
    int32_t w = width_ / 4;
    const float startX = 200.f;
    const float startY = 60.f;
    OH_Drawing_Font *font_title = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font_title, textSize_);
    OH_Drawing_TextBlob *stringTextBlob =
        OH_Drawing_TextBlobCreateFromString("几何形状绘制-描边", font_title, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringTextBlob, startX, startY);
    OH_Drawing_TextBlobDestroy(stringTextBlob);

    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font, textSize_);
    // pen
    OH_Drawing_Pen *pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(0xFF, 0x45, 0x71, 0xC4));
    OH_Drawing_PenSetAntiAlias(pen, true);
    float penWidth = 3.f;
    OH_Drawing_PenSetWidth(pen, penWidth);

    // rect
    const float startX1 = 20.f;
    const float startY1 = 120.f;
    OH_Drawing_TextBlob *stringRect = OH_Drawing_TextBlobCreateFromString("DrawRect", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringRect, startX1, startY1);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(0 + 20.f, 150.f, w - 20.f, 250.f);
    OH_Drawing_CanvasDrawRect(canvas_, rect);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_TextBlobDestroy(stringRect);

    // roundrect
    const float startX2 = w;
    const float startY2 = 120.f;
    OH_Drawing_TextBlob *stringRoundRect =
        OH_Drawing_TextBlobCreateFromString("DrawRoundRect", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringRoundRect, startX2, startY2);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_Rect *rectRoundRect = OH_Drawing_RectCreate(w + 20.f, 150.f, w * 2 - 20.f, 250.f);
    OH_Drawing_RoundRect *roundRect = OH_Drawing_RoundRectCreate(rectRoundRect, 20.f, 20.f);
    OH_Drawing_CanvasDrawRoundRect(canvas_, roundRect);
    OH_Drawing_RectDestroy(rectRoundRect);
    OH_Drawing_RoundRectDestroy(roundRect);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_TextBlobDestroy(stringRoundRect);

    // line
    const float startX3 = w * 2 + 30;
    const float startY3 = 120.f;
    OH_Drawing_TextBlob *stringLine = OH_Drawing_TextBlobCreateFromString("DrawLine", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringLine, startX3, startY3);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    // w * 2 + 20.f Indicates the x coordinate of the start point of the line segment.
    // w * 3 - 20.f indicates the x coordinate of the end point of the line segment.
    OH_Drawing_CanvasDrawLine(canvas_, w * 2 + 20.f, 200.f, w * 3 - 20.f, 200.f);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_TextBlobDestroy(stringLine);

    // arc
    const float startX4 = w * 3 + 10;
    const float startY4 = 120.f;
    OH_Drawing_TextBlob *stringArc = OH_Drawing_TextBlobCreateFromString("DrawArc", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringArc, startX4, startY4);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_Rect *rectArc = OH_Drawing_RectCreate(w * 3 - 50.f, 150.f, w * 4 - 20.f, 350.f);
    OH_Drawing_CanvasDrawArc(canvas_, rectArc, 0, -90); // -90 Indicates the sweepAngle of the arc.
    OH_Drawing_RectDestroy(rectArc);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_TextBlobDestroy(stringArc);

    // path
    const float startX5 = 20.f;
    const float startY5 = 320.f;
    OH_Drawing_TextBlob *stringPath = OH_Drawing_TextBlobCreateFromString("DrawPath", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringPath, startX5, startY5);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_Path *path = OH_Drawing_PathCreate();
    OH_Drawing_Rect *rect_first = OH_Drawing_RectCreate(10.f, 350.f, w / 2, 450.f);
    OH_Drawing_PathAddArc(path, rect_first, 0, -130.f);
    OH_Drawing_Rect *rect_second = OH_Drawing_RectCreate(w / 2, 350.f, w - 20.f, 450.f);
    OH_Drawing_PathAddArc(path, rect_second, 50.f, 130.f);
    OH_Drawing_CanvasDrawPath(canvas_, path);
    OH_Drawing_RectDestroy(rect_first);
    OH_Drawing_RectDestroy(rect_second);
    OH_Drawing_PathReset(path);
    OH_Drawing_PathDestroy(path);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_TextBlobDestroy(stringPath);

    // circle
    const float startX6 = w + 20;
    const float startY6 = 320.f;
    OH_Drawing_TextBlob *stringCircle = OH_Drawing_TextBlobCreateFromString("DrawCircle", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringCircle, startX6, startY6);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_Point *point = OH_Drawing_PointCreate(w * 3 / 2, 400.f);
    OH_Drawing_CanvasDrawCircle(canvas_, point, 50.f);
    OH_Drawing_PointDestroy(point);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_TextBlobDestroy(stringCircle);

    // oval
    const float startX7 = w * 2 + 25;
    const float startY7 = 320.f;
    OH_Drawing_TextBlob *stringOval = OH_Drawing_TextBlobCreateFromString("DrawOval", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringOval, startX7, startY7);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_Rect *rectOval = OH_Drawing_RectCreate(w * 2 + 20.f, 350.f, w * 3 - 20.f, 430.f);
    OH_Drawing_CanvasDrawOval(canvas_, rectOval);
    OH_Drawing_RectDestroy(rectOval);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_TextBlobDestroy(stringOval);

    // DrawRegion
    const float startX8 = 20.f;
    const float startY8 = 520.f;
    OH_Drawing_TextBlob *stringTextBlob2 = OH_Drawing_TextBlobCreateFromString("DrawRegion", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringTextBlob2, startX8, startY8);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    // 计算正五边形的顶点坐标
    int centerX = 70;
    int centerY = startY8 + textSize_ + 70;
    int sideLength = 60;
    double angleIncrement = 2 * M_PI / 5;
    OH_Drawing_Path *path_region = OH_Drawing_PathCreate();
    // 5 represents the angle of the shape.
    for (int i = 0; i < 5; ++i) {
        double angle = angleIncrement * i;
        int x = centerX + sideLength * cos(angle - 60.f);
        int y = centerY - sideLength * sin(angle - 60.f);
        if (i == 0) {
            OH_Drawing_PathMoveTo(path_region, x, y);
        } else {
            OH_Drawing_PathLineTo(path_region, x, y);
        }
    }
    OH_Drawing_PathClose(path_region);
    OH_Drawing_Rect *rect_region = OH_Drawing_RectCreate(0, 600.f, 700.f, 850.f);
    OH_Drawing_PathGetBounds(path_region, rect_region);
    OH_Drawing_Region *region = OH_Drawing_RegionCreate();
    OH_Drawing_Region *clip = OH_Drawing_RegionCreate();
    OH_Drawing_RegionSetRect(clip, rect_region);
    OH_Drawing_RegionSetPath(region, path_region, clip);
    OH_Drawing_CanvasDrawRegion(canvas_, region);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_RegionDestroy(region);
    OH_Drawing_RegionDestroy(clip);
    OH_Drawing_PathDestroy(path_region);
    OH_Drawing_RectDestroy(rect_region);
    OH_Drawing_TextBlobDestroy(stringTextBlob);

    // point
    const float startX9 = w;
    const float startY9 = startY8;
    OH_Drawing_TextBlob *startBlob = OH_Drawing_TextBlobCreateFromString("DrawPoint", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob, startX9, startY9);
    OH_Drawing_TextBlobDestroy(startBlob);

    constexpr float penWidth2 = 8.0f;
    OH_Drawing_PenSetWidth(pen, penWidth2);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    const OH_Drawing_Point2D points[] = {startX9 + 50, startY9 + 100};
    OH_Drawing_CanvasDrawPoint(canvas_, points);
    OH_Drawing_CanvasDetachPen(canvas_);

    // destory
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_FontDestroy(font);
    OH_Drawing_FontDestroy(font_title);
}

/**
 * 填充效果
 */
void NativeDraw::DrawShapeWithBrush()
{
    int32_t w = width_ / 4;
    const float startX = 200.f;
    const float startY = 860.f;
    OH_Drawing_Font *font_title = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font_title, textSize_);
    OH_Drawing_TextBlob *stringTextBlob =
        OH_Drawing_TextBlobCreateFromString("几何形状绘制-填充", font_title, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringTextBlob, startX, startY - textSize_ - 10);
    OH_Drawing_TextBlobDestroy(stringTextBlob);

    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font, textSize_);
    // brush
    OH_Drawing_Brush *brush = OH_Drawing_BrushCreate();
    uint32_t color = 0xff4472c3;
    OH_Drawing_BrushSetColor(brush, color);

    // rect
    const float startX1 = 20.f;
    const float startY1 = startY + textSize_ * 2 + 10;
    OH_Drawing_TextBlob *stringRect = OH_Drawing_TextBlobCreateFromString("DrawRect", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringRect, startX1, startY);
    OH_Drawing_CanvasAttachBrush(canvas_, brush);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(startX1, startY1, w - 20.f, startY1 + 100);
    OH_Drawing_CanvasDrawRect(canvas_, rect);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_TextBlobDestroy(stringRect);

    // roundrect
    const float startX2 = w;
    const float startY2 = startY1;
    OH_Drawing_TextBlob *stringRoundRect =
        OH_Drawing_TextBlobCreateFromString("DrawRoundRect", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringRoundRect, startX2, startY );
    OH_Drawing_CanvasAttachBrush(canvas_, brush);
    OH_Drawing_Rect *rectRoundRect = OH_Drawing_RectCreate(w + 20.f, startY2, w * 2 - 20.f, startY2 + 100);
    OH_Drawing_RoundRect *roundRect = OH_Drawing_RoundRectCreate(rectRoundRect, 20.f, 20.f);
    OH_Drawing_CanvasDrawRoundRect(canvas_, roundRect);
    OH_Drawing_RectDestroy(rectRoundRect);
    OH_Drawing_RoundRectDestroy(roundRect);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_TextBlobDestroy(stringRoundRect);

    // line
    const float startX3 = w * 2 + 30;
    const float startY3 = startY1;
    OH_Drawing_TextBlob *stringLine = OH_Drawing_TextBlobCreateFromString("DrawLine", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringLine, startX3, startY);
    OH_Drawing_CanvasAttachBrush(canvas_, brush);
    // w * 2 + 20.f indicates the x coordinate of the start point of the line segment.
    // w * 3 - 20.f indicates the x coordinate of the end point of the line segment.
    OH_Drawing_CanvasDrawLine(canvas_, w * 2 + 20.f, startY3 + 60, w * 3 - 20.f, startY3 + 60);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_TextBlobDestroy(stringLine);
    // arc
    const float startX4 = w * 3 + 10;
    const float startY4 = startY1;
    OH_Drawing_TextBlob *stringArc = OH_Drawing_TextBlobCreateFromString("DrawArc", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringArc, startX4, startY);
    OH_Drawing_CanvasAttachBrush(canvas_, brush);
    // w * 3 - 50.f Indicates the left position of the rect.
    OH_Drawing_Rect *rectArc = OH_Drawing_RectCreate(w * 3 - 50.f, startY4, w * 4 - 20.f, startY4 + 200);
    OH_Drawing_CanvasDrawArc(canvas_, rectArc, 0, -90); // -90 Indicates the sweepAngle of the arc.
    OH_Drawing_RectDestroy(rectArc);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_TextBlobDestroy(stringArc);

    // path
    const float startX5 = 20.f;
    const float startY5_text = startY1 + 200;
    const float startY5 = startY5_text + textSize_;
    OH_Drawing_TextBlob *stringPath = OH_Drawing_TextBlobCreateFromString("DrawPath", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringPath, startX5, startY5_text);
    OH_Drawing_CanvasAttachBrush(canvas_, brush);
    OH_Drawing_Path *path = OH_Drawing_PathCreate();
    OH_Drawing_Rect *rect_first = OH_Drawing_RectCreate(10.f, startY5, w / 2, startY5 + 100);
    OH_Drawing_PathAddArc(path, rect_first, 0, -130.f);
    OH_Drawing_Rect *rect_second = OH_Drawing_RectCreate(w / 2, startY5, w - 20.f, startY5 + 100);
    OH_Drawing_PathAddArc(path, rect_second, 50.f, 130.f);
    OH_Drawing_CanvasDrawPath(canvas_, path);
    OH_Drawing_RectDestroy(rect_first);
    OH_Drawing_RectDestroy(rect_second);
    OH_Drawing_PathReset(path);
    OH_Drawing_PathDestroy(path);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_TextBlobDestroy(stringPath);

    // circle
    const float startX6 = w + 20;
    const float startY6 = startY5;
    OH_Drawing_TextBlob *stringCircle = OH_Drawing_TextBlobCreateFromString("DrawCircle", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringCircle, startX6, startY5_text);
    OH_Drawing_CanvasAttachBrush(canvas_, brush);
    // w * 3 / 2 Indicates the x-axis coordinates of the point.
    OH_Drawing_Point *point = OH_Drawing_PointCreate(w * 3 / 2, startY5 + 50);
    OH_Drawing_CanvasDrawCircle(canvas_, point, 50.f);
    OH_Drawing_PointDestroy(point);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_TextBlobDestroy(stringCircle);

    // oval
    const float startX7 = w * 2 + 25;
    const float startY7 = startY5;
    OH_Drawing_TextBlob *stringOval = OH_Drawing_TextBlobCreateFromString("DrawOval", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringOval, startX7, startY5_text);
    OH_Drawing_CanvasAttachBrush(canvas_, brush);
    // w * 2 + 20.f Indicates the left position of the rect.
    OH_Drawing_Rect *rectOval = OH_Drawing_RectCreate(w * 2 + 20.f, startY7, w * 3 - 20.f, startY7 + 80);
    OH_Drawing_CanvasDrawOval(canvas_, rectOval);
    OH_Drawing_RectDestroy(rectOval);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_TextBlobDestroy(stringOval);

    // background
    OH_Drawing_Brush *brushLayer = OH_Drawing_BrushCreate();
    uint32_t colorLayer = 0xffffffff;
    OH_Drawing_BrushSetColor(brushLayer, colorLayer);
    OH_Drawing_Rect *rectLayer = OH_Drawing_RectCreate(0, 0, 0, 0);
    OH_Drawing_CanvasSaveLayer(canvas_, rectLayer, brushLayer);
    const float startX8 = w * 3 - 10;
    const float startY8 = startY5;
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *stringBackground =
        OH_Drawing_TextBlobCreateFromString("DrawBackground", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringBackground, startX8, startY5_text);
    OH_Drawing_CanvasAttachBrush(canvas_, brush);
    // w * 3 + 20.f Indicates the left position of the rect.
    OH_Drawing_Rect *rectBackground = OH_Drawing_RectCreate(w * 3 + 20.f, startY8, w * 4, startY8 + 100);
    OH_Drawing_CanvasClipRect(canvas_, rectBackground, INTERSECT, true);
    OH_Drawing_CanvasDrawBackground(canvas_, brush);
    OH_Drawing_RectDestroy(rectBackground);
    OH_Drawing_TextBlobDestroy(stringBackground);
    OH_Drawing_CanvasRestore(canvas_);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_CanvasDetachPen(canvas_);
    
    // DrawRegion
    const float startX9 = 20.f;
    const float startY9 = startY5 + 200;
    OH_Drawing_TextBlob *stringTextBlob2 = OH_Drawing_TextBlobCreateFromString("DrawRegion", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringTextBlob2, startX9, startY9);
    OH_Drawing_CanvasAttachBrush(canvas_, brush);
    // 计算正五边形的顶点坐标
    int centerX = 70;
    int centerY = startY9 + textSize_ + 70;
    int sideLength = 60;
    double angleIncrement = 2 * M_PI / 5;
    OH_Drawing_Path *path_region = OH_Drawing_PathCreate();
    // 5 represents the angle of the shape.
    for (int i = 0; i < 5; ++i) {
        double angle = angleIncrement * i;
        int x = centerX + sideLength * cos(angle - 60.f);
        int y = centerY - sideLength * sin(angle - 60.f);
        if (i == 0) {
            OH_Drawing_PathMoveTo(path_region, x, y);
        } else {
            OH_Drawing_PathLineTo(path_region, x, y);
        }
    }
    OH_Drawing_PathClose(path_region);
    OH_Drawing_Rect *rect_region = OH_Drawing_RectCreate(0, centerY - 50, 700.f, centerY + 200);
    OH_Drawing_PathGetBounds(path_region, rect_region);
    OH_Drawing_Region *region = OH_Drawing_RegionCreate();
    OH_Drawing_Region *clip = OH_Drawing_RegionCreate();
    OH_Drawing_RegionSetRect(clip, rect_region);
    OH_Drawing_RegionSetPath(region, path_region, clip);
    OH_Drawing_CanvasDrawRegion(canvas_, region);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_RegionDestroy(region);
    OH_Drawing_RegionDestroy(clip);
    OH_Drawing_PathDestroy(path_region);
    OH_Drawing_RectDestroy(rect_region);
    OH_Drawing_TextBlobDestroy(stringTextBlob);
    
    // destroy
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_FontDestroy(font);
    OH_Drawing_FontDestroy(font_title);
}