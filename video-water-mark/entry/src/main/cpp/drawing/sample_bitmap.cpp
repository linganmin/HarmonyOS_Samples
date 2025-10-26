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

#include <native_drawing/drawing_shadow_layer.h>
#include <native_drawing/drawing_text_typography.h>
#include "sample_bitmap.h"

SampleBitMap::~SampleBitMap()
{
    Destroy();
}

void SampleBitMap::SetWidth(uint64_t width)
{
    width_ = width;
}

void SampleBitMap::SetHeight(uint64_t height)
{
    height_ = height;
}

void* SampleBitMap::GetText(void)
{
    // After drawing, obtain the pixel address, which points to the memory containing the pixel data of the canvas painting
    void *bitmapAddr = OH_Drawing_BitmapGetPixels(cBitmap_);
    return bitmapAddr;
}

void SampleBitMap::Create(void)
{
    // Create a bitmap object
    cBitmap_ = OH_Drawing_BitmapCreate();
    
    // Define the pixel format of a bitmap
    OH_Drawing_BitmapFormat cFormat {COLOR_FORMAT_RGBA_8888, ALPHA_FORMAT_PREMUL};//ALPHA_FORMAT_OPAQUE};
    
    // Construct a bitmap in the corresponding format
    OH_Drawing_BitmapBuild(cBitmap_, width_, height_, &cFormat);

    // Create a canvas object
    cCanvas_ = OH_Drawing_CanvasCreate();
    
    // Bind the canvas with a bitmap, and the content of the canvas painting will be output to the memory of the bound bitmap
    OH_Drawing_CanvasBind(cCanvas_, cBitmap_);
    
    // Use white to clear canvas content
    OH_Drawing_CanvasClear(cCanvas_, OH_Drawing_ColorSetArgb(0x0, 0x0, 0x0, 0x0));
}

void SampleBitMap::Destroy(void)
{
    // Destroy Canvas Object
    OH_Drawing_CanvasDestroy(cCanvas_);
    cCanvas_ = nullptr;
    
    // Destroy bitmap object
    OH_Drawing_BitmapDestroy(cBitmap_);
}

void SampleBitMap::DrawText(void)
{
    // Create font object
    OH_Drawing_Font *font = OH_Drawing_FontCreate();
    
    // Set font size
    OH_Drawing_FontSetTextSize(font, 50);
    
    // Get the current time
    struct timespec now;
    if (clock_gettime(CLOCK_REALTIME, &now) != 0) {
        OH_Drawing_FontDestroy(font);
        return;
    }
    time_t seconds = now.tv_sec;

    // Convert time to a string
    char timeStr[126];
    if (ctime_r(&seconds, timeStr) == nullptr) {
        OH_Drawing_FontDestroy(font);
        return;
    }

    // Create text block
    OH_Drawing_TextBlob *textBlob = OH_Drawing_TextBlobCreateFromString(
        timeStr, font, OH_Drawing_TextEncoding::TEXT_ENCODING_UTF8);
    if (textBlob == nullptr) {
        OH_Drawing_FontDestroy(font);
        return;
    }

    // Draw blocks
    OH_Drawing_CanvasDrawTextBlob(cCanvas_, textBlob, 220, 960);
    
    // Release block object
    OH_Drawing_TextBlobDestroy(textBlob);
    
    // Release font object
    OH_Drawing_FontDestroy(font);
}
