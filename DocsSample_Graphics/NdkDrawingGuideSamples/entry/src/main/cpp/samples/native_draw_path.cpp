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
 * 路径填充
 */
void NativeDraw::DrawComplexPath()
{
    // 路径填充
    const float startX = 80.f;
    const float startY = 50.0f;
    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *startBlob = OH_Drawing_TextBlobCreateFromString("路径填充", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob, startX, startY);
    OH_Drawing_TextBlobDestroy(startBlob);
    OH_Drawing_FontDestroy(font);

    int len = 130;
    float aX = 150.0f;
    float aY = 100.0f;
    float dX = aX - len * std::sin(18.0f);
    float dY = aY + len * std::cos(18.0f);
    float cX = aX + len * std::sin(18.0f);
    float cY = dY;
    float bX = aX + (len / 2.0);
    float bY = aY + std::sqrt((cX - dX) * (cX - dX) + (len / 2.0) * (len / 2.0));
    float eX = aX - (len / 2.0);
    float eY = bY;
    OH_Drawing_Path *cPath = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(cPath, aX, aY);
    OH_Drawing_PathLineTo(cPath, bX, bY);
    OH_Drawing_PathLineTo(cPath, cX, cY);
    OH_Drawing_PathLineTo(cPath, dX, dY);
    OH_Drawing_PathLineTo(cPath, eX, eY);
    OH_Drawing_PathClose(cPath);
    OH_Drawing_Brush *cBrush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(cBrush, OH_Drawing_ColorSetArgb(0xFF, 0x00, 0x00, 0xFF));
    OH_Drawing_CanvasAttachBrush(canvas_, cBrush);
    OH_Drawing_CanvasDrawPath(canvas_, cPath);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_BrushDestroy(cBrush);
    OH_Drawing_PathDestroy(cPath);

    // 路径描边
    const float startX2 = 380.f;
    const float startY2 = 50.0f;
    OH_Drawing_Font *font2 = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font2, textSize_);
    OH_Drawing_TextBlob *startBlob2 = OH_Drawing_TextBlobCreateFromString("路径描边", font2, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob2, startX2, startY2);
    OH_Drawing_TextBlobDestroy(startBlob2);
    OH_Drawing_FontDestroy(font2);

    OH_Drawing_Path *cPath2 = OH_Drawing_PathCreate();
    float centerX = 450.0f;
    float centerY = 200.0f;
    float outerRadius = 100.f; // 外圆半径
    float innerRadius = 40.f;  // 内圆半径
    float points = 5;          // 五角星的角数
    for (int i = 0; i < points * 2; i++) { // points * 2 is the number of points
        float angle = (i * M_PI) / points;                     // 计算角度
        float radius = i % 2 == 0 ? outerRadius : innerRadius; // 交替使用外圆半径和内圆半径
        float x = centerX + radius * std::cos(angle + 60.0);
        float y = centerY + radius * std::sin(angle + 60.0);
        if (i == 0) {
            OH_Drawing_PathMoveTo(cPath2, x, y);
        } else {
            OH_Drawing_PathLineTo(cPath2, x, y);
        }
    }
    OH_Drawing_PathClose(cPath2);
    constexpr float penWidth = 8.0f;
    OH_Drawing_Pen *cPen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetAntiAlias(cPen, true);
    OH_Drawing_PenSetColor(cPen, OH_Drawing_ColorSetArgb(0xFF, 0x00, 0x00, 0xFF));
    OH_Drawing_PenSetWidth(cPen, penWidth);
    OH_Drawing_PenSetJoin(cPen, LINE_ROUND_JOIN);
    OH_Drawing_CanvasAttachPen(canvas_, cPen);
    OH_Drawing_CanvasDrawPath(canvas_, cPath2);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_PenDestroy(cPen);
    OH_Drawing_PathDestroy(cPath2);

    // 曲线闭合
    const float startX3 = 80.f;
    const float startY3 = 360.0f;
    OH_Drawing_Font *font3 = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font3, textSize_);
    OH_Drawing_TextBlob *startBlob3 = OH_Drawing_TextBlobCreateFromString("曲线闭合", font3, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob3, startX3, startY3);
    OH_Drawing_TextBlobDestroy(startBlob3);
    OH_Drawing_FontDestroy(font3);

    OH_Drawing_Path *Path = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(Path, startX3, startY3 + 50);
    OH_Drawing_PathRCubicTo(Path, 200, 180, 200.f, 80.f, 200.f, 40.f);
    OH_Drawing_PathClose(Path);
    const float penWidth2 = 8.0f;
    OH_Drawing_Pen *cPen2 = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(cPen2, OH_Drawing_ColorSetArgb(0xFF, 0x00, 0x00, 0xFF));
    OH_Drawing_PenSetWidth(cPen2, penWidth2);
    OH_Drawing_Brush *qBrush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(qBrush, OH_Drawing_ColorSetArgb(0xFF, 0x00, 0xFF, 0xFF));
    OH_Drawing_CanvasAttachBrush(canvas_, qBrush);
    OH_Drawing_CanvasAttachPen(canvas_, cPen2);
    OH_Drawing_CanvasDrawPath(canvas_, Path);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_PenDestroy(cPen2);
    OH_Drawing_BrushDestroy(qBrush);
    OH_Drawing_PathDestroy(Path);

    // 曲线未闭合
    const float startX4 = 350.f;
    const float startY4 = 360.0f;
    OH_Drawing_Font *font4 = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font4, textSize_);
    OH_Drawing_TextBlob *startBlob4 = OH_Drawing_TextBlobCreateFromString("曲线未闭合", font4, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob4, startX4, startY4);
    OH_Drawing_TextBlobDestroy(startBlob4);
    OH_Drawing_FontDestroy(font4);

    OH_Drawing_Path *Path2 = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(Path2, 400.f, 400.f);
    OH_Drawing_PathCubicTo(Path2, 400.f, 400.f, 550.f, 450.f, 450.f, 500.f);
    const float penWidth3 = 5.0f;
    OH_Drawing_Pen *cPen3 = OH_Drawing_PenCreate();
    OH_Drawing_PenSetAntiAlias(cPen3, true);
    OH_Drawing_PenSetColor(cPen3, OH_Drawing_ColorSetArgb(0xFF, 0x00, 0x00, 0xFF));
    OH_Drawing_PenSetWidth(cPen3, penWidth3);
    OH_Drawing_CanvasAttachPen(canvas_, cPen3);
    OH_Drawing_CanvasDrawPath(canvas_, Path2);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_PenDestroy(cPen3);
    OH_Drawing_PathDestroy(Path2);

    const float startX5 = 300.f;
    const float startY5 = 560.0f;
    OH_Drawing_Font *font5 = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font5, textSize_);
    OH_Drawing_TextBlob *startBlob5 = OH_Drawing_TextBlobCreateFromString("复杂路径", font5, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob5, startX5, startY5);
    OH_Drawing_FontDestroy(font5);
    OH_Drawing_TextBlobDestroy(startBlob5);

    // 小猫的脸
    const float catPenWidth = 10.0f;
    OH_Drawing_Pen *pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(0xFF, 0xFF, 0xCC, 0x00));
    OH_Drawing_PenSetWidth(pen, catPenWidth);
    OH_Drawing_Path *path = OH_Drawing_PathCreate();
    OH_Drawing_PathAddCircle(path, 380.f, 750.f, 100.f, PATH_DIRECTION_CW);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_CanvasDrawPath(canvas_, path);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_PathDestroy(path);

    // 小猫耳朵
    float earX1 = 280.0f;
    float earY1 = 560.0f;
    OH_Drawing_Path *ePath = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(ePath, earX1, earY1);
    OH_Drawing_PathLineTo(ePath, earX1 + 10.0f, earY1 + 150.0f);
    OH_Drawing_PathMoveTo(ePath, earX1, earY1);
    OH_Drawing_PathLineTo(ePath, earX1 + 80.f, earY1 + 90.0f);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_CanvasDrawPath(canvas_, ePath);
    OH_Drawing_PathDestroy(ePath);

    float earX2 = 480.0f;
    float earY2 = 550.0f;
    OH_Drawing_Path *ePath2 = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(ePath2, earX2, earY2);
    OH_Drawing_PathLineTo(ePath2, earX2 - 80.f, earY2 + 100.0f);
    OH_Drawing_PathMoveTo(ePath2, earX2, earY2);
    OH_Drawing_PathLineTo(ePath2, earX2 - 10.0f, earY2 + 150.0f);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_CanvasDrawPath(canvas_, ePath2);
    OH_Drawing_PathDestroy(ePath2);

    // 小猫胡须
    float clen = 150.0f;
    float musLX1 = 330.0f;
    float musLY1 = 750.0f;
    OH_Drawing_Path *mLPath = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(mLPath, musLX1, musLY1);
    OH_Drawing_PathLineTo(mLPath, musLX1 - clen, musLY1 - 20.0f);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_CanvasDrawPath(canvas_, mLPath);
    OH_Drawing_PathDestroy(mLPath);

    float musLX2 = 330.0f;
    float musLY2 = 770.0f;
    OH_Drawing_Path *mLPath2 = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(mLPath2, musLX2, musLY2);
    OH_Drawing_PathLineTo(mLPath2, musLX2 - clen, musLY2);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_CanvasDrawPath(canvas_, mLPath2);
    OH_Drawing_PathDestroy(mLPath2);

    float musLX3 = 330.0f;
    float musLY3 = 790.0f;
    OH_Drawing_Path *mLPath3 = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(mLPath3, musLX3, musLY3);
    OH_Drawing_PathLineTo(mLPath3, musLX3 - clen, musLY3 + 20.0f);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_CanvasDrawPath(canvas_, mLPath3);
    OH_Drawing_PathDestroy(mLPath3);

    float musRX1 = 420.0f;
    float musRY1 = 750.0f;
    OH_Drawing_Path *mRPath = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(mRPath, musRX1, musRY1);
    OH_Drawing_PathLineTo(mRPath, musRX1 + clen, musRY1 - 20.0f);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_CanvasDrawPath(canvas_, mRPath);
    OH_Drawing_PathDestroy(mRPath);

    float musRX2 = 420.0f;
    float musRY2 = 770.0f;
    OH_Drawing_Path *mRPath2 = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(mRPath2, musRX2, musRY2);
    OH_Drawing_PathLineTo(mRPath2, musRX2 + clen, musRY2);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_CanvasDrawPath(canvas_, mRPath2);
    OH_Drawing_PathDestroy(mRPath2);

    float musRX3 = 420.0f;
    float musRY3 = 790.0f;
    OH_Drawing_Path *mRPath3 = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(mRPath3, musRX3, musRY3);
    OH_Drawing_PathLineTo(mRPath3, musRX3 + clen, musRY3 + 20.0f);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_CanvasDrawPath(canvas_, mRPath3);
    OH_Drawing_PathDestroy(mRPath3);
    OH_Drawing_PenDestroy(pen);

    // 小猫眼睛
    const float ePenWidth = 8.0f;
    OH_Drawing_Pen *ePen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(ePen, OH_Drawing_ColorSetArgb(0xFF, 0xFF, 0xCC, 0x00));
    OH_Drawing_PenSetWidth(ePen, ePenWidth);
    OH_Drawing_Path *ovalPath = OH_Drawing_PathCreate();
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(320.f, 700.f, 360.f, 720.f);
    OH_Drawing_PathAddArc(ovalPath, rect, 180.f, 360.f);
    OH_Drawing_PathAddArc(ovalPath, rect, 0, 180.f);

    OH_Drawing_CanvasAttachPen(canvas_, ePen);
    OH_Drawing_CanvasDrawPath(canvas_, ovalPath);
    OH_Drawing_RectDestroy(rect);

    OH_Drawing_Rect *rect2 = OH_Drawing_RectCreate(400.f, 700.f, 440.f, 720.f);
    OH_Drawing_PathAddOval(ovalPath, rect2, PATH_DIRECTION_CCW);
    OH_Drawing_CanvasAttachPen(canvas_, ePen);
    OH_Drawing_CanvasDrawPath(canvas_, ovalPath);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_RectDestroy(rect2);
    OH_Drawing_PathDestroy(ovalPath);
    OH_Drawing_PenDestroy(ePen);
}

/**
 * Path填充绘制矢量图元
 */
void NativeDraw::DrawPathBrush()
{
    // title
    const float startX = 150.f;
    const float startY = 1160.f;
    int32_t w = width_ / 6;
    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *stringPathBrush =
        OH_Drawing_TextBlobCreateFromString("Path填充绘制矢量图元", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringPathBrush, startX, startY);
    OH_Drawing_TextBlobDestroy(stringPathBrush);
    OH_Drawing_FontDestroy(font);
    // set brush
    OH_Drawing_Brush *brush = OH_Drawing_BrushCreate();
    uint32_t color = 0xff4472c3;
    OH_Drawing_BrushSetColor(brush, color);
    OH_Drawing_CanvasAttachBrush(canvas_, brush);
    // rect
    OH_Drawing_Path *pathRect = OH_Drawing_PathCreate();
    // w * 2 - 10.f Indicates the top coordinate of the upper top corner of the rectangle.
    OH_Drawing_PathAddRect(pathRect, w + 10.f, startY + 40, w * 2 - 10.f, startY + 100, PATH_DIRECTION_CCW);
    OH_Drawing_CanvasDrawPath(canvas_, pathRect);
    OH_Drawing_PathDestroy(pathRect);
    // oval
    OH_Drawing_Path *pathOval = OH_Drawing_PathCreate();
    OH_Drawing_Rect *rectOval = OH_Drawing_RectCreate(w * 2 + 10.f, startY + 40, w * 3 - 10.f, startY + 100);
    OH_Drawing_PathAddOval(pathOval, rectOval, OH_Drawing_PathDirection::PATH_DIRECTION_CW);
    OH_Drawing_CanvasDrawPath(canvas_, pathOval);
    OH_Drawing_RectDestroy(rectOval);
    OH_Drawing_PathDestroy(pathOval);
    // roundrect
    OH_Drawing_Path *pathRoundRect = OH_Drawing_PathCreate();
    OH_Drawing_Rect *rectRoundRect = OH_Drawing_RectCreate(w * 3 + 10.f, startY + 40, w * 4 - 10.f, startY + 100);
    OH_Drawing_RoundRect *roundRect = OH_Drawing_RoundRectCreate(rectRoundRect, 20, 20);
    OH_Drawing_PathAddRoundRect(pathRoundRect, roundRect, PATH_DIRECTION_CCW);
    OH_Drawing_CanvasDrawPath(canvas_, pathRoundRect);
    OH_Drawing_RectDestroy(rectRoundRect);
    OH_Drawing_PathDestroy(pathRoundRect);
    OH_Drawing_RoundRectDestroy(roundRect);
    // polygon
    OH_Drawing_Path *pathPolygon = OH_Drawing_PathCreate();
    float leftPointX = w * 4 + 10;
    float rightPointX = w * 5 - 10;
    float middlePointX = (leftPointX + rightPointX) / 2;
    OH_Drawing_Point2D points[] = {{middlePointX, startY + 40}, {leftPointX, startY + 100}, {rightPointX, startY + 100}};
    OH_Drawing_PathAddPolygon(pathPolygon, points, 3, true); // 3 is the size of point array
    OH_Drawing_CanvasDrawPath(canvas_, pathPolygon);
    OH_Drawing_PathDestroy(pathPolygon);
    // arc
    OH_Drawing_Rect *rectArc = OH_Drawing_RectCreate(w * 5 - 50.f, startY + 40, w * 6 - 10.f, startY + 160);
    OH_Drawing_Path *pathArc = OH_Drawing_PathCreate();
    OH_Drawing_PathAddArc(pathArc, rectArc, 0, -90.f);
    OH_Drawing_CanvasDrawPath(canvas_, pathArc);
    OH_Drawing_RectDestroy(rectArc);
    OH_Drawing_PathDestroy(pathArc);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_BrushDestroy(brush);
}

/**
 * Path描边绘制矢量图元
 */
void NativeDraw::DrawPathLine()
{
    // title
    const float startX = 150.f;
    const float startY = 1330.f;
    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *stringPathLine =
        OH_Drawing_TextBlobCreateFromString("Path描边绘制矢量图元", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringPathLine, startX, startY);
    OH_Drawing_TextBlobDestroy(stringPathLine);
    OH_Drawing_FontDestroy(font);
    // pen
    OH_Drawing_Pen *pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(0xFF, 0x45, 0x71, 0xC4));
    OH_Drawing_PenSetAntiAlias(pen, true);
    float penWidth = 3.f;
    OH_Drawing_PenSetWidth(pen, penWidth);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    int32_t w = width_ / 6;
    // lineto
    OH_Drawing_Path *pathLine = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(pathLine, 20.f, startY + 60);
    OH_Drawing_PathLineTo(pathLine, w - 20, startY + 60); // w - 20 is the x coordinate of the target point.
    OH_Drawing_CanvasDrawPath(canvas_, pathLine);
    OH_Drawing_PathDestroy(pathLine);
    // rect
    OH_Drawing_Path *pathRect = OH_Drawing_PathCreate();
    // w * 2 - 10.f Indicates the top coordinate of the upper top corner of the rectangle.
    OH_Drawing_PathAddRect(pathRect, w + 10.f, startY + 30, w * 2 - 10.f, startY + 90, PATH_DIRECTION_CCW);
    OH_Drawing_CanvasDrawPath(canvas_, pathRect);
    OH_Drawing_PathDestroy(pathRect);
    // oval
    OH_Drawing_Path *pathOval = OH_Drawing_PathCreate();
    OH_Drawing_Rect *rectOval = OH_Drawing_RectCreate(w * 2 + 10.f, startY + 30, w * 3 - 10.f, startY + 60);
    OH_Drawing_PathAddOval(pathOval, rectOval, OH_Drawing_PathDirection::PATH_DIRECTION_CW);
    OH_Drawing_CanvasDrawPath(canvas_, pathOval);
    OH_Drawing_RectDestroy(rectOval);
    OH_Drawing_PathDestroy(pathOval);
    // roundrect
    OH_Drawing_Path *pathRoundRect = OH_Drawing_PathCreate();
    OH_Drawing_Rect *rectRoundRect = OH_Drawing_RectCreate(w * 3 + 10.f, startY + 30, w * 4 - 10.f, startY + 60);
    OH_Drawing_RoundRect *roundRect = OH_Drawing_RoundRectCreate(rectRoundRect, 20.f, 20.f);
    OH_Drawing_PathAddRoundRect(pathRoundRect, roundRect, PATH_DIRECTION_CCW);
    OH_Drawing_CanvasDrawPath(canvas_, pathRoundRect);
    OH_Drawing_RectDestroy(rectRoundRect);
    OH_Drawing_PathDestroy(pathRoundRect);
    OH_Drawing_RoundRectDestroy(roundRect);
    // polygon
    OH_Drawing_Path *pathPolygon = OH_Drawing_PathCreate();
    float leftPointX = w * 4 + 10;
    float rightPointX = w * 5 - 10;
    float middlePointX = (leftPointX + rightPointX) / 2;
    OH_Drawing_Point2D points[] = {{middlePointX, startY + 30}, {leftPointX, startY + 60}, {rightPointX, startY + 60}};
    OH_Drawing_PathAddPolygon(pathPolygon, points, 3, true); // 3 is the size of point array
    OH_Drawing_CanvasDrawPath(canvas_, pathPolygon);
    OH_Drawing_PathDestroy(pathPolygon);
    // arc
    OH_Drawing_Rect *rectArc = OH_Drawing_RectCreate(w * 5 - 50.f, startY + 30, w * 6 - 10.f, startY + 150);
    OH_Drawing_Path *pathArc = OH_Drawing_PathCreate();
    OH_Drawing_PathAddArc(pathArc, rectArc, 0, -90.f);
    OH_Drawing_CanvasDrawPath(canvas_, pathArc);
    OH_Drawing_RectDestroy(rectArc);
    OH_Drawing_PathDestroy(pathArc);
    // destory
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_PenDestroy(pen);
}

/**
 * Path渐变绘制矢量图元
 */
void NativeDraw::DrawPathShade()
{
    int32_t w = width_ / 6;
    // title
    const float startX = 150.f;
    const float startY = 1480.f;
    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *stringPathShade =
        OH_Drawing_TextBlobCreateFromString("Path渐变绘制矢量图元", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringPathShade, startX, startY);
    OH_Drawing_TextBlobDestroy(stringPathShade);
    OH_Drawing_FontDestroy(font);
    // create brush
    uint32_t colors[] = {0xFFf8fa12, 0xFFacc3dd};
    float pos[] = {0.0f, 1.0f};

    // rect
    OH_Drawing_Brush *brushRect = OH_Drawing_BrushCreate();
    OH_Drawing_Point *startPt1 = OH_Drawing_PointCreate(w * 3 / 2, startY + 30);
    OH_Drawing_Point *endPt1 = OH_Drawing_PointCreate(w * 3 / 2, startY + 90);
    OH_Drawing_ShaderEffect *shaderEffectRect =
        OH_Drawing_ShaderEffectCreateLinearGradient(startPt1, endPt1, colors, pos, 2, CLAMP);
    OH_Drawing_BrushSetShaderEffect(brushRect, shaderEffectRect);
    OH_Drawing_CanvasAttachBrush(canvas_, brushRect);
    OH_Drawing_Path *pathRect = OH_Drawing_PathCreate();
    // w * 2 - 10.f Indicates the top coordinate of the upper top corner of the rectangle.
    OH_Drawing_PathAddRect(pathRect, w + 10.f, startY + 30, w * 2 - 10.f, startY + 90, PATH_DIRECTION_CCW);
    OH_Drawing_CanvasDrawPath(canvas_, pathRect);
    OH_Drawing_PathDestroy(pathRect);
    OH_Drawing_PointDestroy(startPt1);
    OH_Drawing_PointDestroy(endPt1);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_BrushDestroy(brushRect);
    OH_Drawing_ShaderEffectDestroy(shaderEffectRect);

    // oval
    OH_Drawing_Brush *brushOval = OH_Drawing_BrushCreate();
    OH_Drawing_Point *startPt2 = OH_Drawing_PointCreate(w * 5 / 2, startY + 30);
    OH_Drawing_Point *endPt2 = OH_Drawing_PointCreate(w * 5 / 2, startY + 90);
    OH_Drawing_Path *pathOval = OH_Drawing_PathCreate();
    OH_Drawing_Rect *rectOval = OH_Drawing_RectCreate(w * 2 + 10.f, startY + 30, w * 3 - 10.f, startY + 90);
    OH_Drawing_ShaderEffect *shaderEffectOval =
        OH_Drawing_ShaderEffectCreateLinearGradient(startPt2, endPt2, colors, pos, 2, CLAMP);
    OH_Drawing_BrushSetShaderEffect(brushOval, shaderEffectOval);
    OH_Drawing_CanvasAttachBrush(canvas_, brushOval);
    OH_Drawing_PathAddOval(pathOval, rectOval, OH_Drawing_PathDirection::PATH_DIRECTION_CW);
    OH_Drawing_CanvasDrawPath(canvas_, pathOval);
    OH_Drawing_RectDestroy(rectOval);
    OH_Drawing_PathDestroy(pathOval);
    OH_Drawing_PointDestroy(startPt2);
    OH_Drawing_PointDestroy(endPt2);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_BrushDestroy(brushOval);
    OH_Drawing_ShaderEffectDestroy(shaderEffectOval);

    // roundrect
    OH_Drawing_Brush *brushRoundRect = OH_Drawing_BrushCreate();
    OH_Drawing_Point *startPt3 = OH_Drawing_PointCreate(w * 7 / 2, startY + 30);
    OH_Drawing_Point *endPt3 = OH_Drawing_PointCreate(w * 7 / 2, startY + 90);
    OH_Drawing_Path *pathRoundRect = OH_Drawing_PathCreate();
    OH_Drawing_Rect *rectRoundRect = OH_Drawing_RectCreate(w * 3 + 10.f, startY + 30, w * 4 - 10.f, startY + 90);
    OH_Drawing_RoundRect *roundRect = OH_Drawing_RoundRectCreate(rectRoundRect, 20.f, 20.f);
    OH_Drawing_PathAddRoundRect(pathRoundRect, roundRect, PATH_DIRECTION_CCW);
    OH_Drawing_ShaderEffect *shaderEffectRoundRect =
        OH_Drawing_ShaderEffectCreateLinearGradient(startPt3, endPt3, colors, pos, 2, CLAMP);
    OH_Drawing_BrushSetShaderEffect(brushRoundRect, shaderEffectRoundRect);
    OH_Drawing_CanvasAttachBrush(canvas_, brushRoundRect);
    OH_Drawing_CanvasDrawPath(canvas_, pathRoundRect);
    OH_Drawing_RectDestroy(rectRoundRect);
    OH_Drawing_PathDestroy(pathRoundRect);
    OH_Drawing_RoundRectDestroy(roundRect);
    OH_Drawing_PointDestroy(startPt3);
    OH_Drawing_PointDestroy(endPt3);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_BrushDestroy(brushRoundRect);
    OH_Drawing_ShaderEffectDestroy(shaderEffectRoundRect);

    // polygon
    OH_Drawing_Brush *brushPolygon = OH_Drawing_BrushCreate();
    OH_Drawing_Point *startPt4 = OH_Drawing_PointCreate(w * 9 / 2, startY + 30);
    OH_Drawing_Point *endPt4 = OH_Drawing_PointCreate(w * 9 / 2, startY + 90);
    OH_Drawing_ShaderEffect *shaderEffectPolygon =
        OH_Drawing_ShaderEffectCreateLinearGradient(startPt4, endPt4, colors, pos, 2, CLAMP);
    OH_Drawing_BrushSetShaderEffect(brushPolygon, shaderEffectPolygon);
    OH_Drawing_CanvasAttachBrush(canvas_, brushPolygon);
    OH_Drawing_Path *pathPolygon = OH_Drawing_PathCreate();
    float leftPointX = w * 4 + 10;
    float rightPointX = w * 5 - 10;
    float middlePointX = (leftPointX + rightPointX) / 2;
    OH_Drawing_Point2D points[] = {{middlePointX, startY + 30}, {leftPointX, startY + 90}, {rightPointX, startY + 90}};
    OH_Drawing_PathAddPolygon(pathPolygon, points, 3, true); // 3 is the size of point array
    OH_Drawing_CanvasDrawPath(canvas_, pathPolygon);
    OH_Drawing_PathDestroy(pathPolygon);
    OH_Drawing_PointDestroy(startPt4);
    OH_Drawing_PointDestroy(endPt4);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_BrushDestroy(brushPolygon);
    OH_Drawing_ShaderEffectDestroy(shaderEffectPolygon);

    // arc
    OH_Drawing_Brush *brushArc = OH_Drawing_BrushCreate();
    OH_Drawing_Point *startPt5 = OH_Drawing_PointCreate(w * 11 / 2, startY + 30);
    OH_Drawing_Point *endPt5 = OH_Drawing_PointCreate(w * 6 - 10.f, startY + 90);
    OH_Drawing_ShaderEffect *shaderEffectArc =
        OH_Drawing_ShaderEffectCreateLinearGradient(startPt5, endPt5, colors, pos, 2, CLAMP);
    OH_Drawing_BrushSetShaderEffect(brushArc, shaderEffectArc);
    OH_Drawing_CanvasAttachBrush(canvas_, brushArc);
    OH_Drawing_Rect *rectArc = OH_Drawing_RectCreate(w * 5 - 50.f, startY + 30, w * 6 - 10.f, startY + 150);
    OH_Drawing_Path *pathArc = OH_Drawing_PathCreate();
    OH_Drawing_PathAddArc(pathArc, rectArc, 0, -90.f);
    OH_Drawing_CanvasDrawPath(canvas_, pathArc);
    OH_Drawing_RectDestroy(rectArc);
    OH_Drawing_PathDestroy(pathArc);
    OH_Drawing_PointDestroy(startPt5);
    OH_Drawing_PointDestroy(endPt5);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_BrushDestroy(brushArc);
    OH_Drawing_ShaderEffectDestroy(shaderEffectArc);
}