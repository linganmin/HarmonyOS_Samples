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


void NativeDraw::DrawImageRect()
{
    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font, textSize_ + 20);
    OH_Drawing_TextBlob *stringTextBlob =
        OH_Drawing_TextBlobCreateFromString("图片绘制", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringTextBlob, 200, textSize_ + 40);

    const float startX = 20.f;
    const float startY = 160.0f;
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *stringTextBlob1 =
        OH_Drawing_TextBlobCreateFromString("DrawImageRectWithSrc", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringTextBlob1, startX, startY);
    OH_Drawing_Brush *brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush, 0xff4472c3);
    OH_Drawing_CanvasAttachBrush(canvas_, brush);

    // CanvasDrawImageRectWithSrc图形
    OH_Drawing_Image *image = OH_Drawing_ImageCreate();
    OH_Drawing_Bitmap *bm = OH_Drawing_BitmapCreate();
    OH_Drawing_BitmapFormat format = {COLOR_FORMAT_BGRA_8888, ALPHA_FORMAT_OPAQUE};
    // 110 Indicates the width and height of the bitmap to be initialized.
    OH_Drawing_BitmapBuild(bm, 110, 110, &format);
    OH_Drawing_ImageBuildFromBitmap(image, bm);
    OH_Drawing_Canvas *bitmapCanvas1 = OH_Drawing_CanvasCreate();
    OH_Drawing_CanvasClear(bitmapCanvas1, 0xff4472c3);
    OH_Drawing_FilterMode filterMode = FILTER_MODE_LINEAR;
    OH_Drawing_MipmapMode mipmapMode = MIPMAP_MODE_NEAREST;
    OH_Drawing_SamplingOptions *samplingOptions = OH_Drawing_SamplingOptionsCreate(filterMode, mipmapMode);
    OH_Drawing_Rect *recty = OH_Drawing_RectCreate(0, 0, 0, 0);
    OH_Drawing_Rect *rectm = OH_Drawing_RectCreate(startX + 10, startY + 40, startX + 120, startY + 150);
    OH_Drawing_CanvasDrawImageRectWithSrc(canvas_, image, recty, rectm, samplingOptions, FAST_SRC_RECT_CONSTRAINT);
    OH_Drawing_CanvasDrawRect(canvas_, recty);
    OH_Drawing_CanvasDrawRect(canvas_, rectm);
    // 销毁
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_TextBlobDestroy(stringTextBlob1);
    OH_Drawing_BitmapDestroy(bm);
    OH_Drawing_ImageDestroy(image);
    OH_Drawing_SamplingOptionsDestroy(samplingOptions);
    OH_Drawing_RectDestroy(recty);
    OH_Drawing_RectDestroy(rectm);
    OH_Drawing_BrushDestroy(brush);

    // CanvasDrawImageRect图形
    const float startX2 = 500.f;
    const float startY2 = startY;
    OH_Drawing_TextBlob *stringTextBlob2 =
        OH_Drawing_TextBlobCreateFromString("DrawImageRect", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringTextBlob2, startX2, startY2);
    OH_Drawing_Brush *brush1 = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush1, 0xff4472c3);
    OH_Drawing_CanvasAttachBrush(canvas_, brush1);

    OH_Drawing_Bitmap *bitmapRect = OH_Drawing_BitmapCreate();
    OH_Drawing_BitmapFormat formatRect = {COLOR_FORMAT_BGRA_8888, ALPHA_FORMAT_OPAQUE};
    // 100 Indicates the width and height of the bitmap to be initialized.
    OH_Drawing_BitmapBuild(bitmapRect, 100, 100, &formatRect);
    OH_Drawing_Image *imageRect = OH_Drawing_ImageCreate();
    OH_Drawing_ImageBuildFromBitmap(imageRect, bitmapRect);
    OH_Drawing_SamplingOptions *samplingOptionsRect =
        OH_Drawing_SamplingOptionsCreate(FILTER_MODE_LINEAR, MIPMAP_MODE_NEAREST);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(startX2 + 20.f, startY2 + 40.f, startX2 + 135.f, startY2 + 155.f);
    OH_Drawing_CanvasDrawImageRect(canvas_, imageRect, rect, samplingOptionsRect);

    OH_Drawing_CanvasDrawRect(canvas_, rect);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_BitmapDestroy(bitmapRect);
    OH_Drawing_ImageDestroy(imageRect);
    OH_Drawing_SamplingOptionsDestroy(samplingOptionsRect);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_BrushDestroy(brush1);
    OH_Drawing_TextBlobDestroy(stringTextBlob2);
    OH_Drawing_FontDestroy(font);
}

void NativeDraw::DrawPixelMapBrush(NativePixelMap *native)
{
    // DrawVertices
    const float startX = 20.f;
    const float startY = 410.0f;
    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *startBlob = OH_Drawing_TextBlobCreateFromString("DrawVertices", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob, startX, startY);

    OH_Drawing_Point2D positions[] = {{startX, startY + 30.f}, {startX + 120.f, startY + 30.f}, {startX, startY + 130.f}};
    OH_Drawing_Point2D texs[] = {{0.0f, 0.0f}, {2.0f, 0.0f}, {1.0f, 1.0f}};
    const uint16_t indices[] = {0, 1, 2};
    uint32_t colors[] = {0xFFFF0000, 0xFF0000FF, 0xFF00FF00};
    int32_t indexCount = sizeof(indices) / sizeof(indices[0]);
    int32_t vertexCount = sizeof(positions) / sizeof(positions[0]);
    OH_Drawing_CanvasDrawVertices(canvas_, VERTEX_MODE_TRIANGLES, vertexCount, positions, texs, colors, indexCount,
                                  indices, BLEND_MODE_SRC);
    OH_Drawing_FontDestroy(font);
    OH_Drawing_TextBlobDestroy(startBlob);

    // DrawPixelMapRect
    const float startX2 = 500.f;
    const float startY2 = startY;
    OH_Drawing_Font *font2 = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font2, textSize_);
    OH_Drawing_TextBlob *startBlob2 =
        OH_Drawing_TextBlobCreateFromString("DrawPixelMapRect", font2, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, startBlob2, startX2, startY2);
    OH_Drawing_FontDestroy(font2);
    OH_Drawing_TextBlobDestroy(startBlob2);

    OH_Drawing_PixelMap *pixelMap = OH_Drawing_PixelMapGetFromNativePixelMap(native);
    OH_Drawing_SamplingOptions *sampling = OH_Drawing_SamplingOptionsCreate(FILTER_MODE_LINEAR, MIPMAP_MODE_NONE);
    OH_Drawing_Rect *src = OH_Drawing_RectCreate(0, 0, 650.f, 664.f);
    OH_Drawing_Rect *dst = OH_Drawing_RectCreate(startX2 + 20.f, startY2 + 50, startX2 + 400.f, startY2 + 430.f);
    OH_Drawing_Brush *brush = OH_Drawing_BrushCreate();
    OH_Drawing_CanvasAttachBrush(canvas_, brush);
    OH_Drawing_CanvasDrawPixelMapRect(canvas_, pixelMap, src, dst, sampling);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_PixelMapDissolve(pixelMap);
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_CanvasRestore(canvas_);
    OH_Drawing_SamplingOptionsDestroy(sampling);
    OH_Drawing_RectDestroy(src);
    OH_Drawing_RectDestroy(dst);
}


void NativeDraw::DrawTextBlob()
{
    const float startY = 660.0f;

    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font, textSize_ + 20);
    OH_Drawing_TextBlob *stringTextBlob =
        OH_Drawing_TextBlobCreateFromString("字块绘制", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringTextBlob, 200, startY);
    OH_Drawing_TextBlobDestroy(stringTextBlob);

    // 基本字块绘制
    const float startX1 = 20.f;
    const float startY1 = startY + 100;
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *stringTextBlob1 =
        OH_Drawing_TextBlobCreateFromString("基本字块绘制", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringTextBlob1, startX1, startY1);
    OH_Drawing_TextBlobDestroy(stringTextBlob1);

    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_Font *font_basic = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font_basic, 100);
    const char *str = "Hello world";
    OH_Drawing_TextBlob *textBlob =
        OH_Drawing_TextBlobCreateFromString(str, font_basic, OH_Drawing_TextEncoding::TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, textBlob, 100, startY1 + 100); 
    OH_Drawing_TextBlobDestroy(textBlob);
    OH_Drawing_FontDestroy(font_basic);

    // 文字描边
    const float startX2 = startX1;
    const float startY2 = startY1 + 200;
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *stringTextBlob2 =
        OH_Drawing_TextBlobCreateFromString("文字描边", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringTextBlob2, startX2, startY2);
    OH_Drawing_TextBlobDestroy(stringTextBlob2);

    OH_Drawing_Pen *pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(0xFF, 0xFF, 0x00, 0x00));
    OH_Drawing_PenSetWidth(pen, 3);
    OH_Drawing_CanvasAttachPen(canvas_, pen);
    OH_Drawing_Font *font_line = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font_line, 150);
    OH_Drawing_TextBlob *textBlob3 =
        OH_Drawing_TextBlobCreateFromString(str, font_line, OH_Drawing_TextEncoding::TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, textBlob3, 100, startY2 + 140);
    OH_Drawing_CanvasDetachPen(canvas_);
    OH_Drawing_TextBlobDestroy(textBlob3);
    OH_Drawing_FontDestroy(font_line);

    // 文字渐变
    const float startX3 = startX1;
    const float startY3 = startY2 + 250;
    OH_Drawing_FontSetTextSize(font, textSize_);
    OH_Drawing_TextBlob *stringTextBlob3 =
        OH_Drawing_TextBlobCreateFromString("文字渐变", font, TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, stringTextBlob3, startX3, startY3);
    OH_Drawing_TextBlobDestroy(stringTextBlob3);

    OH_Drawing_Point *startPt = OH_Drawing_PointCreate(startX3, startY3);
    OH_Drawing_Point *endPt = OH_Drawing_PointCreate(startX3 + 800, startY3 + 800);
    uint32_t colors[] = {0xFFFFFF00, 0xFFFF0000, 0xFF0000FF};
    float pos[] = {0.0f, 0.5f, 1.0f};
    OH_Drawing_ShaderEffect *colorShaderEffect =
        OH_Drawing_ShaderEffectCreateLinearGradient(startPt, endPt, colors, pos, 3, OH_Drawing_TileMode::CLAMP);
    OH_Drawing_Brush *brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetShaderEffect(brush, colorShaderEffect);
    OH_Drawing_CanvasAttachBrush(canvas_, brush);
    OH_Drawing_Font *font_shader = OH_Drawing_FontCreate();
    OH_Drawing_FontSetTextSize(font_shader, 150);
    OH_Drawing_TextBlob *textBlob4 =
        OH_Drawing_TextBlobCreateFromString(str, font_shader, OH_Drawing_TextEncoding::TEXT_ENCODING_UTF8);
    OH_Drawing_CanvasDrawTextBlob(canvas_, textBlob4, 100, startY3 + 140);
    OH_Drawing_CanvasDetachBrush(canvas_);
    OH_Drawing_TextBlobDestroy(textBlob4);
    OH_Drawing_FontDestroy(font_shader);
    OH_Drawing_BrushDestroy(brush);
    
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_FontDestroy(font);
}