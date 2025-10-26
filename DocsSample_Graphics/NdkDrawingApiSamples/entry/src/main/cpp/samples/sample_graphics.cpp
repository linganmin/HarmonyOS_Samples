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

#include <multimedia/image_framework/image/pixelmap_native.h>
#include <native_drawing/drawing_image.h>
#include <native_drawing/drawing_text_typography.h>
#include <native_display_soloist/native_display_soloist.h>
#include <native_drawing/drawing_rect.h>
#include <native_drawing/drawing_point.h>
#include <native_drawing/drawing_region.h>
#include <native_drawing/drawing_round_rect.h>
#include <native_drawing/drawing_sampling_options.h>
#include <native_drawing/drawing_pixel_map.h>
#include <native_drawing/drawing_text_blob.h>
#include <native_drawing/drawing_shader_effect.h>
#include <native_drawing/drawing_gpu_context.h>
#include <native_drawing/drawing_surface.h>
#include <native_drawing/drawing_path_effect.h>
#include <native_drawing/drawing_color_filter.h>
#include <native_drawing/drawing_filter.h>
#include <native_drawing/drawing_image_filter.h>
#include <native_drawing/drawing_mask_filter.h>
#include <native_drawing/drawing_matrix.h>
#include <map>
#include <sys/mman.h>
#include "common/log_common.h"
#include "sample_graphics.h"
#include "utils/adaptation_util.h"

#include <native_drawing/drawing_surface.h>
#include <native_drawing/drawing_gpu_context.h>

const uint16_t RGBA_MIN = 0x00;
const uint16_t RGBA_MAX = 0xFF;
const uint16_t RGBA_SIZE = 4;

static std::unordered_map<std::string, OH_DisplaySoloist *> g_displaySync;
// 多设备适配工具类,按设备宽度等比例缩放适配
AdaptationUtil* adaptationUtil = AdaptationUtil::GetInstance();
float SampleGraphics::value100_ = adaptationUtil->GetWidth(100.f);
float SampleGraphics::value150_ = adaptationUtil->GetWidth(150.f);
float SampleGraphics::value200_ = adaptationUtil->GetWidth(200.f);
float SampleGraphics::value300_ = adaptationUtil->GetWidth(300.f);
float SampleGraphics::value400_ = adaptationUtil->GetWidth(400.f);
float SampleGraphics::value500_ = adaptationUtil->GetWidth(500.f);
float SampleGraphics::value551_ = adaptationUtil->GetWidth(551.f);
float SampleGraphics::value600_ = adaptationUtil->GetWidth(600.f);
float SampleGraphics::value630_ = adaptationUtil->GetWidth(630.f);
float SampleGraphics::value700_ = adaptationUtil->GetWidth(700.f);
float SampleGraphics::value800_ = adaptationUtil->GetWidth(800.f);
float SampleGraphics::value900_ = adaptationUtil->GetWidth(900.f);
float SampleGraphics::value1000_ = adaptationUtil->GetWidth(1000.f);
float SampleGraphics::value1100_ = adaptationUtil->GetWidth(1100.f);
float SampleGraphics::value1200_ = adaptationUtil->GetWidth(1200.f);

EGLConfig getConfig(int version, EGLDisplay eglDisplay)
{
    int attribList[] = {EGL_SURFACE_TYPE,
                        EGL_WINDOW_BIT,
                        EGL_RED_SIZE,
                        8,
                        EGL_GREEN_SIZE,
                        8,
                        EGL_BLUE_SIZE,
                        8,
                        EGL_ALPHA_SIZE,
                        8,
                        EGL_RENDERABLE_TYPE,
                        EGL_OPENGL_ES2_BIT,
                        EGL_NONE};
    EGLConfig configs = NULL;
    int configsNum;

    if (!eglChooseConfig(eglDisplay, attribList, &configs, 1, &configsNum)) {
        SAMPLE_LOGE("eglChooseConfig ERROR");
        return NULL;
    }

    return configs;
}

int32_t SampleGraphics::InitializeEglContext()
{
    EGLDisplay_ = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (EGLDisplay_ == EGL_NO_DISPLAY) {
        SAMPLE_LOGE("unable to get EGL display.");
        return -1;
    }

    EGLint eglMajVers;
    EGLint eglMinVers;
    if (!eglInitialize(EGLDisplay_, &eglMajVers, &eglMinVers)) {
        EGLDisplay_ = EGL_NO_DISPLAY;
        SAMPLE_LOGE("unable to initialize display");
        return -1;
    }

    int version = 3;
    EGLConfig_ = getConfig(version, EGLDisplay_);
    if (EGLConfig_ == nullptr) {
        SAMPLE_LOGE("GLContextInit config ERROR");
        return -1;
    }

    /* Create EGLContext from */
    int attribList[] = {EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE}; // 2 size

    EGLContext_ = eglCreateContext(EGLDisplay_, EGLConfig_, EGL_NO_CONTEXT, attribList);

    EGLint attribs[] = {EGL_WIDTH, 1, EGL_HEIGHT, 1, EGL_NONE};
    EGLSurface_ = eglCreatePbufferSurface(EGLDisplay_, EGLConfig_, attribs);
    if (!eglMakeCurrent(EGLDisplay_, EGLSurface_, EGLSurface_, EGLContext_)) {
        SAMPLE_LOGE("eglMakeCurrent error = %{public}d", eglGetError());
        return -1;
    }

    SAMPLE_LOGE("Init success.");
    return 0;
}

void SampleGraphics::DeInitializeEglContext()
{
    EGLBoolean ret = eglDestroySurface(EGLDisplay_, EGLSurface_);
    if (!ret) {
        SAMPLE_LOGE("eglDestroySurface failure.");
    }

    ret = eglDestroyContext(EGLDisplay_, EGLContext_);
    if (!ret) {
        SAMPLE_LOGE("eglDestroyContext failure.");
    }

    ret = eglTerminate(EGLDisplay_);
    if (!ret) {
        SAMPLE_LOGE("eglTerminate failure.");
    }

    EGLSurface_ = NULL;
    EGLContext_ = NULL;
    EGLDisplay_ = NULL;
}

static void OnSurfaceCreatedCB(OH_NativeXComponent *component, void *window)
{
    SAMPLE_LOGI("OnSurfaceCreatedCB");
    if ((component == nullptr) || (window == nullptr)) {
        SAMPLE_LOGE("OnSurfaceCreatedCB: component or window is null");
        return;
    }
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(component, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        SAMPLE_LOGE("OnSurfaceCreatedCB: Unable to get XComponent id");
        return;
    }
    std::string id(idStr);
    auto render = SampleGraphics::GetInstance(id);
    OHNativeWindow *nativeWindow = static_cast<OHNativeWindow *>(window);
    render->SetNativeWindow(nativeWindow);

    uint64_t width;
    uint64_t height;
    int32_t xSize = OH_NativeXComponent_GetXComponentSize(component, window, &width, &height);
    if ((xSize == OH_NATIVEXCOMPONENT_RESULT_SUCCESS) && (render != nullptr)) {
        render->SetHeight(height);
        render->SetWidth(width);
        SAMPLE_LOGI("xComponent width = %{public}llu, height = %{public}llu", width, height);
    }
}

static void OnSurfaceDestroyedCB(OH_NativeXComponent *component, void *window)
{
    SAMPLE_LOGI("OnSurfaceDestroyedCB");
    if ((component == nullptr) || (window == nullptr)) {
        SAMPLE_LOGE("OnSurfaceDestroyedCB: component or window is null");
        return;
    }
    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(component, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        SAMPLE_LOGE("OnSurfaceDestroyedCB: Unable to get XComponent id");
        return;
    }
    std::string id(idStr);
    SampleGraphics::Release(id);
}

static std::unordered_map<std::string, SampleGraphics *> g_instance;

void SampleGraphics::SetWidth(uint64_t width) { width_ = width; }

void SampleGraphics::SetHeight(uint64_t height) { height_ = height; }

void SampleGraphics::SetNativeWindow(OHNativeWindow *nativeWindow) { nativeWindow_ = nativeWindow; }

void SampleGraphics::Prepare()
{
    if (nativeWindow_ == nullptr) {
        SAMPLE_LOGE("nativeWindow_ is nullptr");
        return;
    }
    // 这里的nativeWindow是从上一步骤中的回调函数中获得的
    // 通过 OH_NativeWindow_NativeWindowRequestBuffer 获取 OHNativeWindowBuffer 实例
    int ret = OH_NativeWindow_NativeWindowRequestBuffer(nativeWindow_, &buffer_, &fenceFd_);
    SAMPLE_LOGI("request buffer ret = %{public}d", ret);
    // 通过 OH_NativeWindow_GetBufferHandleFromNative 获取 buffer 的 handle
    bufferHandle_ = OH_NativeWindow_GetBufferHandleFromNative(buffer_);
    // 使用系统mmap接口拿到bufferHandle的内存虚拟地址
    mappedAddr_ = static_cast<uint32_t *>(
        mmap(bufferHandle_->virAddr, bufferHandle_->size, PROT_READ | PROT_WRITE, MAP_SHARED, bufferHandle_->fd, 0));
    if (mappedAddr_ == MAP_FAILED) {
        SAMPLE_LOGE("mmap failed");
    }
}

void SampleGraphics::Create()
{
    uint32_t width = static_cast<uint32_t>(bufferHandle_->stride / 4);
    // 创建一个bitmap对象
    cScreenBitmap_ = OH_Drawing_BitmapCreate();
    // 定义bitmap的像素格式
    OH_Drawing_BitmapFormat cFormat{COLOR_FORMAT_RGBA_8888, ALPHA_FORMAT_OPAQUE};
    // 构造对应格式的bitmap
    OH_Drawing_BitmapBuild(cScreenBitmap_, width, height_, &cFormat);

    // 创建一个canvas对象
    cScreenCanvas_ = OH_Drawing_CanvasCreate();
    // 将画布与bitmap绑定，画布画的内容会输出到绑定的bitmap内存中
    OH_Drawing_CanvasBind(cScreenCanvas_, cScreenBitmap_);
    // 使用白色清除画布内容
    OH_Drawing_CanvasClear(cScreenCanvas_, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MAX, 0xFF));
}

void SampleGraphics::CreateByCPU()
{
    // 创建一个离屏位图对象
    cOffScreenBitmap_ = OH_Drawing_BitmapCreate();
    // 设置位图属性
    OH_Drawing_BitmapFormat cFormat{COLOR_FORMAT_RGBA_8888, ALPHA_FORMAT_PREMUL};
    // 设置位图长宽（按需设置）
    uint32_t width = 800;
    uint32_t height = 800;
    // 初始化位图
    OH_Drawing_BitmapBuild(cOffScreenBitmap_, width, height, &cFormat);
    // 创建一个离屏Canvas对象
    cCPUCanvas_ = OH_Drawing_CanvasCreate();
    // 将离屏Canvas与离屏bitmap绑定，离屏Canvas绘制的内容会输出到绑定的离屏bitmap内存中
    OH_Drawing_CanvasBind(cCPUCanvas_, cOffScreenBitmap_);
    // 将背景设置为白色
    OH_Drawing_CanvasClear(cCPUCanvas_, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MAX, 0xFF));
    
    // 创建一个bitmap对象
    cScreenBitmap_ = OH_Drawing_BitmapCreate();
    // 构造对应格式的bitmap
    OH_Drawing_BitmapBuild(cScreenBitmap_, width_, height_, &cFormat);
    // 创建一个canvas对象
    cScreenCanvas_ = OH_Drawing_CanvasCreate();
    // 将Canvas与bitmap绑定，Canvas绘制的内容会输出到绑定的bitmap内存中
    OH_Drawing_CanvasBind(cScreenCanvas_, cScreenBitmap_);
}

void SampleGraphics::CreateByGPU()
{
    // 创建一个bitmap对象
    cScreenBitmap_ = OH_Drawing_BitmapCreate();
    // 定义bitmap的像素格式
    OH_Drawing_BitmapFormat cFormat{COLOR_FORMAT_RGBA_8888, ALPHA_FORMAT_OPAQUE};
    // 构造对应格式的bitmap
    OH_Drawing_BitmapBuild(cScreenBitmap_, width_, height_, &cFormat);
    // 创建一个canvas对象
    cScreenCanvas_ = OH_Drawing_CanvasCreate();
    // 将画布与bitmap绑定，画布画的内容会输出到绑定的bitmap内存中
    OH_Drawing_CanvasBind(cScreenCanvas_, cScreenBitmap_);
    
    // 设置宽高（按需设定）
    int32_t cWidth = 800;
    int32_t cHeight = 800;
    // 设置图像，包括宽度、高度、颜色格式和透明度格式
    OH_Drawing_Image_Info imageInfo = {cWidth, cHeight, COLOR_FORMAT_RGBA_8888, ALPHA_FORMAT_PREMUL};
    // GPU上下文的选项
    OH_Drawing_GpuContextOptions options{true};
    
    // 创建一个使用OpenGL（GL）作为其GPU后端的绘图上下文
    OH_Drawing_GpuContext *gpuContext = OH_Drawing_GpuContextCreateFromGL(options);
    // 创建surface对象
    OH_Drawing_Surface *surface = OH_Drawing_SurfaceCreateFromGpuContext(gpuContext, true, imageInfo);
    // 创建一个canvas对象
    cGPUCanvas_ = OH_Drawing_SurfaceGetCanvas(surface);
    // 将背景设置为白色
    OH_Drawing_CanvasClear(cGPUCanvas_, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MAX, 0xFF));
}

void SampleGraphics::DisPlay()
{
    // 画完后获取像素地址，地址指向的内存包含画布画的像素数据
    void *bitmapAddr = OH_Drawing_BitmapGetPixels(cScreenBitmap_);
    uint32_t *value = static_cast<uint32_t *>(bitmapAddr);

    uint32_t *pixel = static_cast<uint32_t *>(mappedAddr_); // 使用mmap获取到的地址来访问内存
    if (pixel == nullptr) {
        SAMPLE_LOGE("pixel is null");
        return;
    }
    if (value == nullptr) {
        SAMPLE_LOGE("value is null");
        return;
    }
    for (uint32_t x = 0; x < width_; x++) {
        for (uint32_t y = 0; y < height_; y++) {
            *pixel++ = *value++;
        }
    }
    // 设置刷新区域，如果Region中的Rect为nullptr,或者rectNumber为0，则认为OHNativeWindowBuffer全部有内容更改。
    Region region{nullptr, 0};
    // 通过OH_NativeWindow_NativeWindowFlushBuffer 提交给消费者使用，例如：显示在屏幕上。
    OH_NativeWindow_NativeWindowFlushBuffer(nativeWindow_, buffer_, fenceFd_, region);
    // 内存使用完记得去掉内存映射
    int result = munmap(mappedAddr_, bufferHandle_->size);
    if (result == -1) {
        SAMPLE_LOGE("munmap failed!");
    }
}

void SampleGraphics::DisPlayCPU()
{
    // 将离屏bitmap中的内容绘制到屏幕画布，实现上屏操作
    OH_Drawing_CanvasDrawBitmap(cScreenCanvas_, cOffScreenBitmap_, 0, 0);
    DisPlay();
}

void SampleGraphics::DisPlayGPU()
{
    // 设置宽高（按需设定）
    int32_t cWidth = 800;
    int32_t cHeight = 800;
    // 设置图像，包括宽度、高度、颜色格式和透明度格式
    OH_Drawing_Image_Info imageInfo = {cWidth, cHeight, COLOR_FORMAT_RGBA_8888, ALPHA_FORMAT_PREMUL};
    void* dstPixels = malloc(cWidth * cHeight * RGBA_SIZE); // 4 for rgba
    OH_Drawing_CanvasReadPixels(cGPUCanvas_, &imageInfo, dstPixels, RGBA_SIZE * cWidth, 0, 0);
    OH_Drawing_Bitmap* cOffScreenBitmap_ = OH_Drawing_BitmapCreateFromPixels(&imageInfo, dstPixels,
        RGBA_SIZE * cWidth);
    OH_Drawing_CanvasDrawBitmap(cScreenCanvas_, cOffScreenBitmap_, 0, 0);
    DisPlay();
}

void SampleGraphics::DrawClipOperation(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Brush *brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush, 0xff0000ff);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value200_, value200_, value1000_, value1000_);
    // 裁剪矩形区域
    OH_Drawing_CanvasClipRect(canvas, rect, OH_Drawing_CanvasClipOp::INTERSECT, true);
    OH_Drawing_Rect* rect2 = OH_Drawing_RectCreate(0, 0, 0, 0);
    OH_Drawing_CanvasGetLocalClipBounds(canvas, rect2);
    SAMPLE_LOGI("Canvas-->ClipBounds:top=%{public}f,left=%{public}f,right=%{public}f,bottom=%{public}f",
        OH_Drawing_RectGetTop(rect2), OH_Drawing_RectGetLeft(rect2), OH_Drawing_RectGetRight(rect2),
        OH_Drawing_RectGetBottom(rect2));
    OH_Drawing_Path *path = OH_Drawing_PathCreate();
    OH_Drawing_PathAddCircle(path, value200_, value200_, value400_, PATH_DIRECTION_CCW);
    // 裁剪圆形区域
    OH_Drawing_CanvasClipPath(canvas, path, OH_Drawing_CanvasClipOp::DIFFERENCE, true);
    // 绘制背景
    OH_Drawing_CanvasDrawBackground(canvas, brush);
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_PathDestroy(path);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_RectDestroy(rect2);
}

void SampleGraphics::DrawMatrixBasic(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value500_);
    // 绘制原始矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    // 创建矩阵对象
    OH_Drawing_Matrix *matrix = OH_Drawing_MatrixCreate();
    // 设置矩阵(平移)
    OH_Drawing_MatrixSetMatrix(matrix, 1, 0, value300_, 0, 1, value300_, 0, 0, 1);
    // 获取矩阵的值
    SAMPLE_LOGI("DrawMatrixBasic-->GetValue-matrix(%{public}f,%{public}f,%{public}f,%{public}f,%{public}f,%{public}f,%{public}f,%{public}f,%{public}f)",
        OH_Drawing_MatrixGetValue(matrix, 0), OH_Drawing_MatrixGetValue(matrix, 1),
        OH_Drawing_MatrixGetValue(matrix, 2), OH_Drawing_MatrixGetValue(matrix, 3),
        OH_Drawing_MatrixGetValue(matrix, 4), OH_Drawing_MatrixGetValue(matrix, 5),
        OH_Drawing_MatrixGetValue(matrix, 6), OH_Drawing_MatrixGetValue(matrix, 7),
        OH_Drawing_MatrixGetValue(matrix, 8));
    OH_Drawing_Point2D src{value300_, value300_};
    OH_Drawing_Point2D dst;
    // 源点坐标变换为目标点坐标
    OH_Drawing_MatrixMapPoints(matrix, &src, &dst, 1);
    SAMPLE_LOGI("DrawMatrixBasic-->point(src) x=%{public}f,y=%{public}f", src.x, src.y);
    SAMPLE_LOGI("DrawMatrixBasic-->point(dst) x=%{public}f,y=%{public}f", dst.x, dst.y);
    OH_Drawing_Rect *rect2 = OH_Drawing_RectCreate(0, 0, 0, 0);
    // 源矩形变换为目标矩形
    OH_Drawing_MatrixMapRect(matrix, rect, rect2);
    SAMPLE_LOGI("DrawMatrixBasic-->rect(src) left=%{public}f,top=%{public}f,right=%{public}f,bottom=%{public}f", 
        OH_Drawing_RectGetLeft(rect), OH_Drawing_RectGetTop(rect), OH_Drawing_RectGetRight(rect),
        OH_Drawing_RectGetBottom(rect));
    SAMPLE_LOGI("DrawMatrixBasic-->rect(dst) left=%{public}f,top=%{public}f,right=%{public}f,bottom=%{public}f", 
        OH_Drawing_RectGetLeft(rect2), OH_Drawing_RectGetTop(rect2), OH_Drawing_RectGetRight(rect2),
        OH_Drawing_RectGetBottom(rect2));
    OH_Drawing_CanvasConcatMatrix(canvas, matrix);
    // 绘制变换后的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_Matrix *matrix2 = OH_Drawing_MatrixCreate();
    // 逆矩阵
    OH_Drawing_MatrixInvert(matrix2, matrix);
    SAMPLE_LOGI("DrawMatrixBasic-->GetValue-matrix2(%{public}f,%{public}f,%{public}f,%{public}f,%{public}f,%{public}f,%{public}f,%{public}f,%{public}f)",
        OH_Drawing_MatrixGetValue(matrix2, 0), OH_Drawing_MatrixGetValue(matrix2, 1),
        OH_Drawing_MatrixGetValue(matrix2, 2), OH_Drawing_MatrixGetValue(matrix2, 3),
        OH_Drawing_MatrixGetValue(matrix2, 4), OH_Drawing_MatrixGetValue(matrix2, 5),
        OH_Drawing_MatrixGetValue(matrix2, 6), OH_Drawing_MatrixGetValue(matrix2, 7),
        OH_Drawing_MatrixGetValue(matrix2, 8));
    // 重置矩阵
    OH_Drawing_MatrixReset(matrix);
    // 获取矩阵的值
    SAMPLE_LOGI("DrawMatrixBasic-->GetValue-matrix-reset(%{public}f,%{public}f,%{public}f,%{public}f,%{public}f,%{public}f,%{public}f,%{public}f,%{public}f)",
        OH_Drawing_MatrixGetValue(matrix, 0), OH_Drawing_MatrixGetValue(matrix, 1),
        OH_Drawing_MatrixGetValue(matrix, 2), OH_Drawing_MatrixGetValue(matrix, 3),
        OH_Drawing_MatrixGetValue(matrix, 4), OH_Drawing_MatrixGetValue(matrix, 5),
        OH_Drawing_MatrixGetValue(matrix, 6), OH_Drawing_MatrixGetValue(matrix, 7),
        OH_Drawing_MatrixGetValue(matrix, 8));
    OH_Drawing_CanvasDetachBrush(canvas);
    // 释放对象
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_RectDestroy(rect2);
    OH_Drawing_MatrixDestroy(matrix);
    OH_Drawing_MatrixDestroy(matrix2);
    OH_Drawing_PenDestroy(pen);
}

void SampleGraphics::DrawTranslationOperation(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value500_);
    // 绘制原始矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    // 创建在水平和垂直方向分别平移300px的矩阵对象
    OH_Drawing_Matrix *matrix = OH_Drawing_MatrixCreateTranslation(value300_, value300_);
    OH_Drawing_CanvasConcatMatrix(canvas, matrix);
    // 绘制变换后的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_MatrixDestroy(matrix);
    OH_Drawing_PenDestroy(pen);
}

void SampleGraphics::DrawPreTranslationOperation(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value500_);
    // 绘制原始矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_Matrix *matrix = OH_Drawing_MatrixCreate();
    // 旋转
    OH_Drawing_MatrixRotate(matrix, 45.f, value300_, value300_);
    // 左乘平移（先平移后旋转）
    OH_Drawing_MatrixPreTranslate(matrix, value200_, value200_);
    OH_Drawing_CanvasConcatMatrix(canvas, matrix);
    // 绘制变换后的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_MatrixDestroy(matrix);
    OH_Drawing_PenDestroy(pen);
}

void SampleGraphics::DrawPostTranslationOperation(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value500_);
    // 绘制原始矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_Matrix *matrix = OH_Drawing_MatrixCreate();
    // 旋转
    OH_Drawing_MatrixRotate(matrix, 45.f, value300_, value300_);
    // 右乘平移（先旋转后平移）
    OH_Drawing_MatrixPostTranslate(matrix, value200_, value200_);
    OH_Drawing_CanvasConcatMatrix(canvas, matrix);
    // 绘制变换后的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_MatrixDestroy(matrix);
    OH_Drawing_PenDestroy(pen);
}

void SampleGraphics::DrawRotationOperation(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value500_);
    // 绘制原始矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    // 创建旋转的矩阵对象
    OH_Drawing_Matrix* matrix = OH_Drawing_MatrixCreateRotation(45, value300_, value300_);
    OH_Drawing_CanvasConcatMatrix(canvas, matrix);
    // 绘制变换后的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_MatrixDestroy(matrix);
    OH_Drawing_PenDestroy(pen);
}

void SampleGraphics::DrawPreRotationOperation(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value500_);
    // 绘制原始矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_Matrix* matrix = OH_Drawing_MatrixCreate();
    // 平移
    OH_Drawing_MatrixTranslate(matrix, value200_, value200_);
    // 左乘旋转（先旋转后平移）
    OH_Drawing_MatrixPreRotate(matrix, 45, value300_, value300_);
    OH_Drawing_CanvasConcatMatrix(canvas, matrix);
    // 绘制变换后的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_MatrixDestroy(matrix);
    OH_Drawing_PenDestroy(pen);
}

void SampleGraphics::DrawPostRotationOperation(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value500_);
    // 绘制原始矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_Matrix* matrix = OH_Drawing_MatrixCreate();
    // 平移
    OH_Drawing_MatrixTranslate(matrix, value200_, value200_);
    // 右乘旋转（先平移后旋转）
    OH_Drawing_MatrixPostRotate(matrix, 45, value300_, value300_);
    OH_Drawing_CanvasConcatMatrix(canvas, matrix);
    // 绘制变换后的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_MatrixDestroy(matrix);
    OH_Drawing_PenDestroy(pen);
}

void SampleGraphics::DrawScaleOperation(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value500_);
    // 绘制原始矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    // 创建缩放的矩阵对象
    OH_Drawing_Matrix* matrix = OH_Drawing_MatrixCreateScale(2, 2, value300_, value300_);
    OH_Drawing_CanvasConcatMatrix(canvas, matrix);
    // 绘制变换后的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachPen(canvas);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_MatrixDestroy(matrix);
}

void SampleGraphics::DrawPreScaleOperation(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value500_);
    // 绘制原始矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_Matrix* matrix = OH_Drawing_MatrixCreateTranslation(value100_, value100_);
    // 左乘缩放（先缩放后平移）
    OH_Drawing_MatrixPreScale(matrix, 2, 2, value300_, value300_);
    OH_Drawing_CanvasConcatMatrix(canvas, matrix);
    // 绘制变换后的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachPen(canvas);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_MatrixDestroy(matrix);
}

void SampleGraphics::DrawPostScaleOperation(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value500_);
    // 绘制原始矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_Matrix* matrix = OH_Drawing_MatrixCreateTranslation(value100_, value100_);
    // 右乘缩放（先平移后缩放）
    OH_Drawing_MatrixPostScale(matrix, 2, 2, value300_, value300_);
    OH_Drawing_CanvasConcatMatrix(canvas, matrix);
    // 绘制变换后的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachPen(canvas);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_MatrixDestroy(matrix);
}

void SampleGraphics::DrawConcatOperation(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value500_);
    // 绘制原始矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_Matrix* matrix1 = OH_Drawing_MatrixCreateTranslation(value100_, value100_);
    OH_Drawing_Matrix* matrix2 = OH_Drawing_MatrixCreate();
    OH_Drawing_Matrix* matrix3 = OH_Drawing_MatrixCreate();
    OH_Drawing_MatrixScale(matrix2, 2, 2, value300_, value300_);
    OH_Drawing_MatrixConcat(matrix3, matrix2, matrix1);
    OH_Drawing_CanvasConcatMatrix(canvas, matrix3);
    // 绘制变换后的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachPen(canvas);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_MatrixDestroy(matrix1);
    OH_Drawing_MatrixDestroy(matrix2);
    OH_Drawing_MatrixDestroy(matrix3);
}

void SampleGraphics::CanvasSaveOperation(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10.f);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    // 保存当前画布状态
    OH_Drawing_CanvasSave(canvas);
    // 平移
    OH_Drawing_CanvasTranslate(canvas, 0.f, value200_);
    // 保存当前画布状态
    OH_Drawing_CanvasSave(canvas);
    // 获取画布状态数量
    SAMPLE_LOGI("Canvas-->saveCount=%{public}d", OH_Drawing_CanvasGetSaveCount(canvas));
    // 放大
    OH_Drawing_CanvasScale(canvas, 2.f, 2.f);
    OH_Drawing_Point* point = OH_Drawing_PointCreate(value300_, value300_);
    // 绘制圆形（经过放大和移动）
    OH_Drawing_CanvasDrawCircle(canvas, point, value100_);
    // 恢复操作
    OH_Drawing_CanvasRestore(canvas);
    // 绘制圆形（仅经过移动）
    OH_Drawing_CanvasDrawCircle(canvas, point, value100_);
    // 恢复操作至最初状态
    OH_Drawing_CanvasRestoreToCount(canvas, 0);
    // 绘制圆形（原始状态）
    OH_Drawing_CanvasDrawCircle(canvas, point, value100_);
    OH_Drawing_CanvasDetachPen(canvas);
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_PointDestroy(point);
}

void SampleGraphics::CanvasSaveLayerOperation(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Brush* brush1 = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush1, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_CanvasAttachBrush(canvas, brush1);
    OH_Drawing_Brush* brush2 = OH_Drawing_BrushCreate();
    // 创建图像滤波器实现模糊效果
    OH_Drawing_ImageFilter *imageFilter =
        OH_Drawing_ImageFilterCreateBlur(30.0f, 30.0f, OH_Drawing_TileMode::CLAMP, nullptr);
    OH_Drawing_Filter *filter = OH_Drawing_FilterCreate();
    OH_Drawing_FilterSetImageFilter(filter, imageFilter);
    OH_Drawing_BrushSetFilter(brush2, filter);
    OH_Drawing_Rect* rect = OH_Drawing_RectCreate(0.f, 0.f, width_, height_);
    // 保存当前画布状态
    OH_Drawing_CanvasSaveLayer(canvas, rect, brush2);
    OH_Drawing_Point* point1 = OH_Drawing_PointCreate(value300_, value300_);
    // 绘制圆形（经过模糊操作）
    OH_Drawing_CanvasDrawCircle(canvas, point1, value100_);
    // 恢复操作
    OH_Drawing_CanvasRestore(canvas);
    OH_Drawing_Point* point2 = OH_Drawing_PointCreate(value300_, value700_);
    // 绘制圆形
    OH_Drawing_CanvasDrawCircle(canvas, point2, value100_);
    OH_Drawing_CanvasDetachBrush(canvas);
    // 释放对象
    OH_Drawing_ImageFilterDestroy(imageFilter);
    OH_Drawing_BrushDestroy(brush1);
    OH_Drawing_BrushDestroy(brush2);
    OH_Drawing_PointDestroy(point1);
    OH_Drawing_PointDestroy(point2);
    OH_Drawing_RectDestroy(rect);
}

void SampleGraphics::DrawStroke(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    uint32_t color = 0xffff0000;
    OH_Drawing_PenSetColor(pen, color);
    float width = 50.0;
    OH_Drawing_PenSetWidth(pen, width);
    OH_Drawing_PenSetAntiAlias(pen, true);
    // 设置画笔线帽样式
    OH_Drawing_PenSetCap(pen, OH_Drawing_PenLineCapStyle::LINE_ROUND_CAP);
    // 设置画笔转角样式
    OH_Drawing_PenSetJoin(pen, OH_Drawing_PenLineJoinStyle::LINE_BEVEL_JOIN);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    // 创建路径
    OH_Drawing_Path* path = OH_Drawing_PathCreate();
    float aX = value100_;
    float aY = value100_;
    float bX = value100_;
    float bY = value800_;
    float cX = value800_;
    float cY = value800_;
    float dX = value800_;
    float dY = value100_;
    // 到起始点
    OH_Drawing_PathMoveTo(path, aX, aY);
    // 绘制直线
    OH_Drawing_PathLineTo(path, bX, bY);
    OH_Drawing_PathLineTo(path, cX, cY);
    OH_Drawing_PathLineTo(path, dX, dY);
    OH_Drawing_CanvasDrawPath(canvas, path);
    OH_Drawing_CanvasDetachPen(canvas);
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_PathDestroy(path);
}

void SampleGraphics::DrawMixedMode(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_CanvasClear(canvas, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MIN, RGBA_MIN, RGBA_MIN));
    OH_Drawing_Brush* brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value100_, value100_, value600_, value600_);
    // 绘制矩形（目标像素）
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_BrushSetColor(brush, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MIN, RGBA_MIN, 0xFF));
    // 设置混合模式为叠加模式
    OH_Drawing_BrushSetBlendMode(brush, OH_Drawing_BlendMode::BLEND_MODE_PLUS);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    OH_Drawing_Point *point = OH_Drawing_PointCreate(value600_, value600_);
    // 绘制圆（源像素）
    OH_Drawing_CanvasDrawCircle(canvas, point, value300_);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_PointDestroy(point);
}

void SampleGraphics::DrawPathEffect(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen *pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, 0xffff0000);
    OH_Drawing_PenSetWidth(pen, 10);
    // 表示10px的实线，5px的间隔，2px的实线，5px的间隔，以此循环
    float intervals[] = {10, 5, 2, 5};
    // 创建虚线路径效果
    OH_Drawing_PathEffect *pathEffect = OH_Drawing_CreateDashPathEffect(intervals, 4, 0.0);
    OH_Drawing_PenSetPathEffect(pen, pathEffect);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value900_, value900_);
    // 绘制矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachPen(canvas);
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_PathEffectDestroy(pathEffect);
}

void SampleGraphics::DrawShaderEffect(OH_Drawing_Canvas *canvas)
{
    // 线性渐变着色器
    OH_Drawing_Point *startPt = OH_Drawing_PointCreate(value100_, value100_);
    OH_Drawing_Point *endPt = OH_Drawing_PointCreate(value300_, value300_);
    uint32_t colors[] = {0xFFFFFF00, 0xFFFF0000, 0xFF0000FF};
    float pos[] = {0.0f, 0.5f, 1.0f};
    OH_Drawing_ShaderEffect *linearShaderEffect1 =
        OH_Drawing_ShaderEffectCreateLinearGradient(startPt, endPt, colors, pos, 3, OH_Drawing_TileMode::CLAMP);
    OH_Drawing_Brush* brush = OH_Drawing_BrushCreate();
    // 基于画刷设置着色器
    OH_Drawing_BrushSetShaderEffect(brush, linearShaderEffect1);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value100_, value100_, value300_, value300_);
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    
    // 使用矩阵创建线性渐变着色器
    OH_Drawing_CanvasTranslate(canvas, value300_, 0.f);
    OH_Drawing_Matrix* matrix = OH_Drawing_MatrixCreate();
    OH_Drawing_MatrixScale(matrix, 2.0f, 1.0f, value200_, value200_);
    OH_Drawing_Point2D startPt2{value100_, value100_};
    OH_Drawing_Point2D endPt2{value300_, value300_};
    OH_Drawing_ShaderEffect *linearShaderEffect2 = OH_Drawing_ShaderEffectCreateLinearGradientWithLocalMatrix(
        &startPt2, &endPt2, colors, pos, 3, OH_Drawing_TileMode::CLAMP, matrix);
    OH_Drawing_BrushSetShaderEffect(brush, linearShaderEffect2);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    
    // 径向渐变着色器
    OH_Drawing_CanvasTranslate(canvas, 0.f, value300_);
    OH_Drawing_Point *centerPt = OH_Drawing_PointCreate(value200_, value200_);
    OH_Drawing_ShaderEffect *radialShaderEffect =
        OH_Drawing_ShaderEffectCreateRadialGradient(centerPt, value200_, colors, pos, 3, OH_Drawing_TileMode::REPEAT);
    OH_Drawing_BrushSetShaderEffect(brush, radialShaderEffect);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    
    // 扇形渐变着色器
    OH_Drawing_CanvasTranslate(canvas, value300_, 0.f);
    OH_Drawing_ShaderEffect* sweepShaderEffect =
        OH_Drawing_ShaderEffectCreateSweepGradient(centerPt, colors, pos, 3, OH_Drawing_TileMode::CLAMP);
    OH_Drawing_BrushSetShaderEffect(brush, sweepShaderEffect);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    
    // 双圆锥渐变着色器
    OH_Drawing_CanvasTranslate(canvas, 0.f, value300_);
    OH_Drawing_Point2D pt3{value200_, value200_};
    OH_Drawing_ShaderEffect *twoPointShaderEffect = OH_Drawing_ShaderEffectCreateTwoPointConicalGradient(
        &pt3, 30.0f, &pt3, 100.0f, colors, pos, 3, OH_Drawing_TileMode::CLAMP, nullptr);
    OH_Drawing_BrushSetShaderEffect(brush, twoPointShaderEffect);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    
    // 销毁各类对象
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_ShaderEffectDestroy(linearShaderEffect1);
    OH_Drawing_ShaderEffectDestroy(linearShaderEffect2);
    OH_Drawing_ShaderEffectDestroy(radialShaderEffect);
    OH_Drawing_ShaderEffectDestroy(sweepShaderEffect);
    OH_Drawing_ShaderEffectDestroy(twoPointShaderEffect);
    OH_Drawing_PointDestroy(startPt);
    OH_Drawing_PointDestroy(endPt);
    OH_Drawing_MatrixDestroy(matrix);
}

void SampleGraphics::DrawColorFilter(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Brush *brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetAntiAlias(brush, true);
    OH_Drawing_BrushSetColor(brush, 0xffff0000);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value100_, value100_, value300_, value300_);
    // 绘制原始矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    
    OH_Drawing_CanvasTranslate(canvas, 0.f, value300_);
    // 创建luma亮度颜色滤波器
    OH_Drawing_ColorFilter* lumaColorFilter = OH_Drawing_ColorFilterCreateLuma();
    OH_Drawing_Filter *filter = OH_Drawing_FilterCreate();
    OH_Drawing_FilterSetColorFilter(filter, lumaColorFilter);
    OH_Drawing_BrushSetFilter(brush, filter);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    // 绘制经过luma亮度颜色滤波器效果的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    
    OH_Drawing_CanvasTranslate(canvas, 0.f, value300_);
    const float matrix[20] = {
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 0.5f, 0.5f, 0,
    0, 0, 0.5f, 0.5f, 0
    };
    // 创建5*4矩阵颜色滤波器
    OH_Drawing_ColorFilter* matrixColorFilter = OH_Drawing_ColorFilterCreateMatrix(matrix);
    // 创建从SRGB转换到线性颜色空间的颜色滤波器
    OH_Drawing_ColorFilter* s2lColorFilter = OH_Drawing_ColorFilterCreateSrgbGammaToLinear();
    // 创建从线性颜色空间转换到SRGB的颜色滤波器
    OH_Drawing_ColorFilter* l2sColorFilter = OH_Drawing_ColorFilterCreateLinearToSrgbGamma();
    // 创建合成滤波器
    OH_Drawing_ColorFilter* composeColorFilter1 = OH_Drawing_ColorFilterCreateCompose(matrixColorFilter, s2lColorFilter);
    OH_Drawing_ColorFilter* composeColorFilter2 = OH_Drawing_ColorFilterCreateCompose(composeColorFilter1, l2sColorFilter);
    OH_Drawing_FilterSetColorFilter(filter, composeColorFilter1);
    OH_Drawing_BrushSetFilter(brush, filter);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    // 绘制经过合成颜色滤波器效果的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    
    // 销毁各类对象
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_ColorFilterDestroy(matrixColorFilter);
    OH_Drawing_ColorFilterDestroy(lumaColorFilter);
    OH_Drawing_ColorFilterDestroy(s2lColorFilter);
    OH_Drawing_ColorFilterDestroy(l2sColorFilter);
    OH_Drawing_ColorFilterDestroy(composeColorFilter1);
    OH_Drawing_ColorFilterDestroy(composeColorFilter2);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_FilterDestroy(filter);
}

void SampleGraphics::DrawImageFilter(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen *pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetAntiAlias(pen, true);
    OH_Drawing_PenSetColor(pen, 0xffff0000);
    OH_Drawing_PenSetWidth(pen, 20);
    // 创建图像滤波器实现模糊效果
    OH_Drawing_ImageFilter *imageFilter =
        OH_Drawing_ImageFilterCreateBlur(20.0f, 20.0f, OH_Drawing_TileMode::CLAMP, nullptr);
    OH_Drawing_Filter *filter = OH_Drawing_FilterCreate();
    // 为滤波器对象设置图像滤波器
    OH_Drawing_FilterSetImageFilter(filter, imageFilter);
    // 设置画笔的滤波器效果
    OH_Drawing_PenSetFilter(pen, filter);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value900_, value900_);
    // 绘制矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachPen(canvas);
    // 销毁各类对象
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_ImageFilterDestroy(imageFilter);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_FilterDestroy(filter);
}

void SampleGraphics::DrawMaskFilterPen(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen *pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetAntiAlias(pen, true);
    OH_Drawing_PenSetColor(pen, 0xffff0000);
    OH_Drawing_PenSetWidth(pen, 20);
    // 创建蒙版滤波器
    OH_Drawing_MaskFilter *maskFilter = OH_Drawing_MaskFilterCreateBlur(OH_Drawing_BlurType::NORMAL, 20, true);
    OH_Drawing_Filter *filter = OH_Drawing_FilterCreate();
    OH_Drawing_FilterSetMaskFilter(filter, maskFilter);
    // 设置画笔的滤波器效果
    OH_Drawing_PenSetFilter(pen, filter);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value600_);
    // 绘制矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachPen(canvas);
    // 销毁各类对象
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_MaskFilterDestroy(maskFilter);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_FilterDestroy(filter);
}

void SampleGraphics::DrawMaskFilterBrush(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Brush *brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetAntiAlias(brush, true);
    OH_Drawing_BrushSetColor(brush, 0xffff0000);
    // 创建模糊蒙版滤波器
    OH_Drawing_MaskFilter *maskFilter = OH_Drawing_MaskFilterCreateBlur(OH_Drawing_BlurType::NORMAL, 20, true);
    OH_Drawing_Filter *filter = OH_Drawing_FilterCreate();
    OH_Drawing_FilterSetMaskFilter(filter, maskFilter);
    // 设置画刷的滤波器效果
    OH_Drawing_BrushSetFilter(brush, filter);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value600_);
    // 绘制矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachBrush(canvas);
    // 销毁各类对象
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_MaskFilterDestroy(maskFilter);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_FilterDestroy(filter);
}

void SampleGraphics::DrawStar(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10);
    OH_Drawing_PenSetJoin(pen, LINE_ROUND_JOIN);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Brush *brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MIN, RGBA_MAX, RGBA_MIN));
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    int len = value551_;
    float aX = value630_;
    float aY = value551_;
    float dX = aX - len * std::sin(18.0f);
    float dY = aY + len * std::cos(18.0f);
    float cX = aX + len * std::sin(18.0f);
    float cY = dY;
    float bX = aX + (len / 2.0);
    float bY = aY + std::sqrt((cX - dX) * (cX - dX) + (len / 2.0) * (len / 2.0));
    float eX = aX - (len / 2.0);
    float eY = bY;
    // 创建路径
    OH_Drawing_Path* path = OH_Drawing_PathCreate();
    // 到起始点
    OH_Drawing_PathMoveTo(path, aX, aY);
    // 绘制直线
    OH_Drawing_PathLineTo(path, bX, bY);
    OH_Drawing_PathLineTo(path, cX, cY);
    OH_Drawing_PathLineTo(path, dX, dY);
    OH_Drawing_PathLineTo(path, eX, eY);
    // 直线闭合，形成五角星
    OH_Drawing_PathClose(path);
    // 绘制闭合路径
    OH_Drawing_CanvasDrawPath(canvas, path);
    OH_Drawing_CanvasDetachPen(canvas);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_PathDestroy(path);
}

void SampleGraphics::DrawRegion(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Brush* brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    // 矩形区域1
    OH_Drawing_Region *region1 = OH_Drawing_RegionCreate();
    OH_Drawing_Rect *rect1 = OH_Drawing_RectCreate(value100_, value100_, value600_, value600_);
    OH_Drawing_RegionSetRect(region1, rect1);
    // 矩形区域2
    OH_Drawing_Region *region2 = OH_Drawing_RegionCreate();
    OH_Drawing_Rect *rect2 = OH_Drawing_RectCreate(value300_, value300_, value900_, value900_);
    OH_Drawing_RegionSetRect(region2, rect2);
    // 两个矩形区域组合
    OH_Drawing_RegionOp(region1, region2, OH_Drawing_RegionOpMode::REGION_OP_MODE_XOR);
    OH_Drawing_CanvasDrawRegion(canvas, region1);
    OH_Drawing_CanvasDetachBrush(canvas);
    // 销毁各类对象
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_RegionDestroy(region1);
    OH_Drawing_RegionDestroy(region2);
    OH_Drawing_RectDestroy(rect1);
    OH_Drawing_RectDestroy(rect2);
}

void SampleGraphics::DrawRoundRect(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Brush *brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush, 0xffff0000);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    // 创建矩形
    OH_Drawing_Rect* rect = OH_Drawing_RectCreate(value100_, value100_, value900_, value600_);
    // 创建圆角矩形
    OH_Drawing_RoundRect* roundRect = OH_Drawing_RoundRectCreate(rect, 30, 30);
    OH_Drawing_RoundRectSetCorner(roundRect, OH_Drawing_CornerPos::CORNER_POS_TOP_LEFT, {50, 50});
    OH_Drawing_Corner_Radii p = OH_Drawing_RoundRectGetCorner(roundRect, OH_Drawing_CornerPos::CORNER_POS_TOP_LEFT);
    SAMPLE_LOGI("top-left-corner:x=%{public}f, y:%{public}f", p.x, p.y);
    // 绘制圆角矩形
    OH_Drawing_CanvasDrawRoundRect(canvas, roundRect);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_RoundRectDestroy(roundRect);
}

void SampleGraphics::DrawCustomPixelMap(OH_Drawing_Canvas *canvas)
{
    uint32_t width = 600;
    uint32_t height = 400;
    // 字节长度，RGBA_8888每个像素占4字节
    size_t bufferSize = width * height * 4;
    uint8_t *pixels = new uint8_t[bufferSize];
    for (uint32_t i = 0; i < width * height; ++i) {
        // 遍历并编辑每个像素，从而形成红绿蓝相间的条纹
        uint32_t n = i / 20 % 3;
        pixels[i * RGBA_SIZE] = RGBA_MIN;
        pixels[i * RGBA_SIZE + 1] = RGBA_MIN;
        pixels[i * RGBA_SIZE + 2] = RGBA_MIN;
        pixels[i * RGBA_SIZE + 3] = 0xFF;
        if (n == 0) {
            pixels[i * RGBA_SIZE] = 0xFF;
        } else if (n == 1) {
            pixels[i * RGBA_SIZE + 1] = 0xFF;
        } else {
            pixels[i * RGBA_SIZE + 2] = 0xFF;
        }
    }
    // 设置位图格式（长、宽、颜色类型、透明度类型）
    OH_Pixelmap_InitializationOptions *createOps = nullptr;
    OH_PixelmapInitializationOptions_Create(&createOps);
    OH_PixelmapInitializationOptions_SetWidth(createOps, width);
    OH_PixelmapInitializationOptions_SetHeight(createOps, height);
    OH_PixelmapInitializationOptions_SetPixelFormat(createOps, PIXEL_FORMAT_RGBA_8888);
    OH_PixelmapInitializationOptions_SetAlphaType(createOps, PIXELMAP_ALPHA_TYPE_UNKNOWN);
    // 创建OH_PixelmapNative对象
    OH_PixelmapNative *pixelMapNative = nullptr;
    OH_PixelmapNative_CreatePixelmap(pixels, bufferSize, createOps, &pixelMapNative);
    // 利用OH_PixelmapNative对象创建PixelMap对象
    OH_Drawing_PixelMap *pixelMap = OH_Drawing_PixelMapGetFromOhPixelMapNative(pixelMapNative);
    OH_Drawing_Rect *src = OH_Drawing_RectCreate(0, 0, 600, 400);
    OH_Drawing_Rect *dst = OH_Drawing_RectCreate(value200_, value200_, value800_, value600_);
    OH_Drawing_SamplingOptions* samplingOptions = OH_Drawing_SamplingOptionsCreate(
        OH_Drawing_FilterMode::FILTER_MODE_LINEAR, OH_Drawing_MipmapMode::MIPMAP_MODE_LINEAR);
    // 绘制PixelMap
    OH_Drawing_CanvasDrawPixelMapRect(canvas, pixelMap, src, dst, samplingOptions);
    OH_PixelmapNative_Release(pixelMapNative);
    OH_Drawing_PixelMapDissolve(pixelMap);
    OH_Drawing_RectDestroy(src);
    OH_Drawing_RectDestroy(dst);
    OH_Drawing_SamplingOptionsDestroy(samplingOptions);
    delete[] pixels;
}

void SampleGraphics::DrawBrushBasic(OH_Drawing_Canvas *canvas)
{
    // 创建画刷
    OH_Drawing_Brush* brush = OH_Drawing_BrushCreate();
    // 设置填充颜色为红色
    OH_Drawing_BrushSetColor(brush, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    // 开启抗锯齿效果
    OH_Drawing_BrushSetAntiAlias(brush, true);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    OH_Drawing_Rect* rect1 = OH_Drawing_RectCreate(0, 0, value300_, value300_);
    // 绘制矩形1
    OH_Drawing_CanvasDrawRect(canvas, rect1);
    OH_Drawing_CanvasDetachBrush(canvas);
    // 复制画刷
    OH_Drawing_Brush* brush_copy = OH_Drawing_BrushCopy(brush);
    
    // 画刷重置
    OH_Drawing_BrushReset(brush);
    // 设置透明度
    OH_Drawing_BrushSetAlpha(brush, 0x40);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    OH_Drawing_Rect* rect2 = OH_Drawing_RectCreate(value400_, value400_, value700_, value700_);
    // 绘制矩形2
    OH_Drawing_CanvasDrawRect(canvas, rect2);
    OH_Drawing_CanvasDetachBrush(canvas);
    
    OH_Drawing_CanvasAttachBrush(canvas, brush_copy);
    OH_Drawing_Rect* rect3 = OH_Drawing_RectCreate(value800_, value800_, value1100_, value1100_);
    // 绘制矩形3
    OH_Drawing_CanvasDrawRect(canvas, rect3);
    OH_Drawing_CanvasDetachBrush(canvas);
    
    // 销毁各类对象
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_BrushDestroy(brush_copy);
    OH_Drawing_RectDestroy(rect1);
    OH_Drawing_RectDestroy(rect2);
    OH_Drawing_RectDestroy(rect3);
}

void SampleGraphics::DrawPenBasic(OH_Drawing_Canvas *canvas)
{
    // 创建画笔对象
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    // 设置画笔描边颜色为红色
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    // 设置画笔线宽为20
    OH_Drawing_PenSetWidth(pen, 20);
    // 设置抗锯齿
    OH_Drawing_PenSetAntiAlias(pen, true);
    // 在画布中设置画笔
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect* rect1 = OH_Drawing_RectCreate(0, 0, value300_, value300_);
    // 绘制矩形1
    OH_Drawing_CanvasDrawRect(canvas, rect1);
    OH_Drawing_CanvasDetachPen(canvas);
    // 复制画笔
    OH_Drawing_Pen* pen_copy = OH_Drawing_PenCopy(pen);
    
    // 画刷重置
    OH_Drawing_PenReset(pen);
    // 设置画笔线宽为20
    OH_Drawing_PenSetWidth(pen, 20);
    // 设置透明度
    OH_Drawing_PenSetAlpha(pen, 0x40);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect* rect2 = OH_Drawing_RectCreate(value400_, value400_, value700_, value700_);
    // 绘制矩形2
    OH_Drawing_CanvasDrawRect(canvas, rect2);
    OH_Drawing_CanvasDetachPen(canvas);
    
    OH_Drawing_CanvasAttachPen(canvas, pen_copy);
    OH_Drawing_Rect* rect3 = OH_Drawing_RectCreate(value800_, value800_, value1100_, value1100_);
    // 绘制矩形3
    OH_Drawing_CanvasDrawRect(canvas, rect3);
    OH_Drawing_CanvasDetachBrush(canvas);
    
    // 销毁各类对象
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_PenDestroy(pen_copy);
    OH_Drawing_RectDestroy(rect1);
    OH_Drawing_RectDestroy(rect2);
    OH_Drawing_RectDestroy(rect3);
}

void SampleGraphics::DrawPenLinearGradient(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Point *startPt = OH_Drawing_PointCreate(20, 20);
    OH_Drawing_Point *endPt = OH_Drawing_PointCreate(value900_, value900_);
    uint32_t colors[] = {0xFFFFFF00, 0xFFFF0000, 0xFF0000FF};
    float pos[] = {0.0f, 0.5f, 1.0f};
    // 创建线性渐变着色器效果
    OH_Drawing_ShaderEffect *shaderEffect =
        OH_Drawing_ShaderEffectCreateLinearGradient(startPt, endPt, colors, pos, 3, OH_Drawing_TileMode::CLAMP);
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetWidth(pen, 40);
    // 基于画笔设置着色器效果
    OH_Drawing_PenSetShaderEffect(pen, shaderEffect);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value100_, value100_, value900_, value900_);
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDetachPen(canvas);
    // 销毁各类对象
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_ShaderEffectDestroy(shaderEffect);
    OH_Drawing_PointDestroy(startPt);
    OH_Drawing_PointDestroy(endPt);
}

void SampleGraphics::DrawMiterLimit(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    uint32_t color = 0xffff0000;
    OH_Drawing_PenSetColor(pen, color);
    float width = 50.0;
    OH_Drawing_PenSetWidth(pen, width);
    OH_Drawing_PenSetAntiAlias(pen, true);
    // 设置画笔转角样式
    OH_Drawing_PenSetJoin(pen, OH_Drawing_PenLineJoinStyle::LINE_MITER_JOIN);
    // 设置折角尖角的限制值
    OH_Drawing_PenSetMiterLimit(pen, 15.0f);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Path* path = OH_Drawing_PathCreate();
    float aX = value100_;
    float aY = value100_;
    float bX = value100_;
    float bY = value800_;
    float cX = value200_;
    float cY = value100_;
    OH_Drawing_PathMoveTo(path, aX, aY);
    OH_Drawing_PathLineTo(path, bX, bY);
    OH_Drawing_PathLineTo(path, cX, cY);
    OH_Drawing_CanvasDrawPath(canvas, path);
    OH_Drawing_CanvasDetachPen(canvas);
    OH_Drawing_PenDestroy(pen);
    OH_Drawing_PathDestroy(path);
}

void SampleGraphics::DrawRectBasic(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Brush* brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_BrushSetAntiAlias(brush, true);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    // 创建矩形对象
    OH_Drawing_Rect* rect = OH_Drawing_RectCreate(0, 0, value300_, value300_);
    OH_Drawing_Rect* rect_copy = OH_Drawing_RectCreate(0, 0, 0, 0);
    OH_Drawing_RectCopy(rect, rect_copy);
    // 设置矩形left,right,top,bottom
    OH_Drawing_RectSetLeft(rect, value100_);
    OH_Drawing_RectSetTop(rect, value100_);
    OH_Drawing_RectSetRight(rect, value400_);
    OH_Drawing_RectSetBottom(rect, value400_);
    // 获取矩形left,right,top,bottom,width,height
    SAMPLE_LOGI("rect info-->left:%{public}f, right:%{public}f, top:%{public}f, bottom:%{public}f, width:%{public}f, height: %{public}f",
        OH_Drawing_RectGetLeft(rect), OH_Drawing_RectGetRight(rect), OH_Drawing_RectGetTop(rect),
        OH_Drawing_RectGetBottom(rect), OH_Drawing_RectGetWidth(rect), OH_Drawing_RectGetHeight(rect));
    SAMPLE_LOGI("rect_copy info-->left:%{public}f, right:%{public}f, top:%{public}f, bottom:%{public}f, width:%{public}f, height: %{public}f",
        OH_Drawing_RectGetLeft(rect_copy), OH_Drawing_RectGetRight(rect_copy), OH_Drawing_RectGetTop(rect_copy),
        OH_Drawing_RectGetBottom(rect_copy), OH_Drawing_RectGetWidth(rect_copy), OH_Drawing_RectGetHeight(rect_copy));
    // 绘制矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_CanvasDrawRect(canvas, rect_copy);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_RectDestroy(rect_copy);
}

void SampleGraphics::DrawRectIntersect(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Brush* brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_BrushSetAntiAlias(brush, true);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    // 创建矩形对象
    OH_Drawing_Rect* rect1 = OH_Drawing_RectCreate(0, 0, value300_, value300_);
    OH_Drawing_Rect* rect2 = OH_Drawing_RectCreate(value100_, value100_, value400_, value400_);
    // 取交集
    OH_Drawing_RectIntersect(rect1, rect2);
    // 绘制矩形
    OH_Drawing_CanvasDrawRect(canvas, rect1);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_RectDestroy(rect1);
    OH_Drawing_RectDestroy(rect2);
}

void SampleGraphics::DrawRectJoin(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Brush* brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_BrushSetAntiAlias(brush, true);
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    // 创建矩形对象
    OH_Drawing_Rect* rect1 = OH_Drawing_RectCreate(0, 0, value300_, value300_);
    OH_Drawing_Rect* rect2 = OH_Drawing_RectCreate(value100_, value100_, value400_, value400_);
    // 取并集
    OH_Drawing_RectJoin(rect1, rect2);
    // 绘制矩形
    OH_Drawing_CanvasDrawRect(canvas, rect1);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_RectDestroy(rect1);
    OH_Drawing_RectDestroy(rect2);
}

void SampleGraphics::DrawPathBasic(OH_Drawing_Canvas *canvas)
{
    int32_t w = width_ / 5;
    float startX = 0;
    float startY = 100.f;
    OH_Drawing_Pen *pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(0xFF, 0x45, 0x71, 0xC4));
    OH_Drawing_PenSetAntiAlias(pen, true);
    float penWidth = 3.f;
    OH_Drawing_PenSetWidth(pen, penWidth);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    
    // 三角形1
    // 创建路径对象
    OH_Drawing_Path *path = OH_Drawing_PathCreate();
    // 设置填充路径规则
    OH_Drawing_PathSetFillType(path, OH_Drawing_PathFillType::PATH_FILL_TYPE_EVEN_ODD);
    // 移动到起始点
    OH_Drawing_PathMoveTo(path, startX + 15.f, startY);
    // 添加线段
    OH_Drawing_PathLineTo(path, startX + 15.f, startY + 150.f);
    OH_Drawing_PathLineTo(path, startX + w - 15.f, startY + 150.f);
    // 闭合路径
    OH_Drawing_PathClose(path);
    // 判断路径是否包含坐标点
    SAMPLE_LOGI("PathBasic-->contains:%{public}d", OH_Drawing_PathContains(path, startX + 50.f, startY + 150.f) ? 1 : 0);
    // 判断路径是否闭合
    SAMPLE_LOGI("PathBasic-->isClosed:%{public}d", OH_Drawing_PathIsClosed(path, false) ? 1 : 0);
    // 获取路径长度
    SAMPLE_LOGI("PathBasic-->getLength:%{public}f", OH_Drawing_PathGetLength(path, false));
    OH_Drawing_Rect* rect = OH_Drawing_RectCreate(0, 0, 0, 0);
    // 获取边界
    OH_Drawing_PathGetBounds(path, rect);
    SAMPLE_LOGI("PathBasic-->getBounds:left=%{public}f,top=%{public}f,right=%{public}f,bottom=%{public}f",
        OH_Drawing_RectGetLeft(rect), OH_Drawing_RectGetTop(rect), OH_Drawing_RectGetRight(rect),
        OH_Drawing_RectGetBottom(rect));
    OH_Drawing_Matrix *matrix = OH_Drawing_MatrixCreate();
    // 获取变换矩阵
    OH_Drawing_PathGetMatrix(path, false, 50, matrix, OH_Drawing_PathMeasureMatrixFlags::GET_POSITION_MATRIX);
    OH_Drawing_Point2D point{startX + 50.f, startY + 150.f};
    OH_Drawing_Point2D tangent{0, 0};
    // 获取坐标点和切线
    OH_Drawing_PathGetPositionTangent(path, false, 1, &point, &tangent);
    SAMPLE_LOGI("PathBasic-->tangent.x=%{public}f,tangent.y=%{public}f", tangent.x, tangent.y);
    OH_Drawing_CanvasDrawPath(canvas, path);
    
    // 三角形2
    // 复制路径
    OH_Drawing_Path *path_copy = OH_Drawing_PathCopy(path);
    OH_Drawing_Matrix *matrix_translate = OH_Drawing_MatrixCreateTranslation(w, 0);
    // 对路径进行矩阵变换
    OH_Drawing_PathTransform(path_copy, matrix_translate);
    OH_Drawing_CanvasDrawPath(canvas, path_copy);
    
    // 三角形3
    OH_Drawing_Path *path_third = OH_Drawing_PathCreate();
    // 对路径进行矩阵变换
    OH_Drawing_PathTransformWithPerspectiveClip(path_copy, matrix_translate, path_third, false);
    OH_Drawing_CanvasDrawPath(canvas, path_third);
    
    // 三角形4
    OH_Drawing_Path *path_fourth = OH_Drawing_PathCreate();
    OH_Drawing_PathOffset(path, path_fourth, w * 3, 0);
    OH_Drawing_CanvasDrawPath(canvas, path_fourth);
    
    // 梯形
    startX += 4 * w;
    OH_Drawing_Path *path_fifth = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(path_fifth, startX + 15.f, startY);
    OH_Drawing_PathLineTo(path_fifth, startX + 15.f, startY + 100.f);
    OH_Drawing_PathLineTo(path_fifth, startX + w - 15.f, startY + 100.f);
    OH_Drawing_PathTransform(path_fourth, matrix_translate);
    // 将两个路径合并（取差集）
    OH_Drawing_PathOp(path_fifth, path_fourth, OH_Drawing_PathOpMode::PATH_OP_MODE_REVERSE_DIFFERENCE);
    OH_Drawing_CanvasDrawPath(canvas, path_fifth);
    
    OH_Drawing_CanvasDetachPen(canvas);
    OH_Drawing_PathDestroy(path);
    OH_Drawing_PathDestroy(path_copy);
    OH_Drawing_PathDestroy(path_third);
    OH_Drawing_PathDestroy(path_fourth);
    OH_Drawing_PathDestroy(path_fifth);
    OH_Drawing_MatrixDestroy(matrix);
    OH_Drawing_MatrixDestroy(matrix_translate);
    OH_Drawing_PenDestroy(pen);
}

void SampleGraphics::DrawPathTo(OH_Drawing_Canvas *canvas)
{
    int32_t w = width_ / 5;
    float startX = 0;
    float startY = 100.f;
    OH_Drawing_Pen *pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(0xFF, 0x45, 0x71, 0xC4));
    OH_Drawing_PenSetAntiAlias(pen, true);
    float penWidth = 3.f;
    OH_Drawing_PenSetWidth(pen, penWidth);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    
    // 线段
    OH_Drawing_Path *path = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(path, startX + 15.f, startY + 70);
    OH_Drawing_PathLineTo(path, startX + w - 15.f, startY + 70.f);
    OH_Drawing_CanvasDrawPath(canvas, path);
    
    // 弧线
    startX += w;
    OH_Drawing_PathReset(path);
    OH_Drawing_PathArcTo(path, startX + 15.f, startY + 30.f, startX + w - 15.f, startY + 150, 60, -240);
    OH_Drawing_CanvasDrawPath(canvas, path);
    
    // 二阶贝塞尔曲线
    startX += w;
    OH_Drawing_PathReset(path);
    OH_Drawing_PathMoveTo(path, startX + 15.f, startY);
    OH_Drawing_PathQuadTo(path, startX + 50.f, startY + 100, startX + w - 15.f, startY + 150);
    OH_Drawing_CanvasDrawPath(canvas, path);
    
    // 二阶贝塞尔曲线(带权重)
    startX += w;
    OH_Drawing_PathReset(path);
    OH_Drawing_PathMoveTo(path, startX + 15.f, startY);
    OH_Drawing_PathConicTo(path, startX + 50.f, startY + 100, startX + w - 15.f, startY + 150, 5.f);
    OH_Drawing_CanvasDrawPath(canvas, path);
    
    // 三阶贝塞尔曲线
    startX += w;
    OH_Drawing_PathReset(path);
    OH_Drawing_PathMoveTo(path, startX + 15.f, startY);
    OH_Drawing_PathCubicTo(path, startX + 30.f, startY + 120, startX + w - 30.f, startY + 30, startX + w - 15.f, startY + 150);
    OH_Drawing_CanvasDrawPath(canvas, path);
    
    // 线段
    startX = 0;
    startY += 200;
    OH_Drawing_PathReset(path);
    OH_Drawing_PathMoveTo(path, startX, startY);
    OH_Drawing_PathRMoveTo(path, 15.f, 70.f);
    OH_Drawing_PathRLineTo(path, w - 30.f, 0);
    OH_Drawing_CanvasDrawPath(canvas, path);
    
    // 二阶贝塞尔曲线
    startX += w;
    OH_Drawing_PathReset(path);
    OH_Drawing_PathMoveTo(path, startX + 15.f, startY);
    OH_Drawing_PathRQuadTo(path, 50.f, 100.f, w - 10.f, 150.f);
    OH_Drawing_CanvasDrawPath(canvas, path);
    
    // 二阶贝塞尔曲线(带权重)
    startX += w;
    OH_Drawing_PathReset(path);
    OH_Drawing_PathMoveTo(path, startX + 15.f, startY);
    OH_Drawing_PathRConicTo(path, 50.f, 100.f, w - 15.f, 150, 5.f);
    OH_Drawing_CanvasDrawPath(canvas, path);
    
    // 三阶贝塞尔曲线
    startX += w;
    OH_Drawing_PathReset(path);
    OH_Drawing_PathMoveTo(path, startX + 15.f, startY);
    OH_Drawing_PathRCubicTo(path, 30.f, 120.f, w - 30.f, 30.f, w - 10.f, 150);
    OH_Drawing_CanvasDrawPath(canvas, path);
    
    OH_Drawing_CanvasDetachPen(canvas);
    OH_Drawing_PathDestroy(path);
    OH_Drawing_PenDestroy(pen);
}

void SampleGraphics::DrawPathAdd(OH_Drawing_Canvas *canvas)
{
    int32_t w = width_ / 6;
    float startX = 0;
    float startY = 100.f;
    OH_Drawing_Pen *pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(0xFF, 0x45, 0x71, 0xC4));
    OH_Drawing_PenSetAntiAlias(pen, true);
    float penWidth = 3.f;
    OH_Drawing_PenSetWidth(pen, penWidth);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    // 圆
    OH_Drawing_Path *pathCircle = OH_Drawing_PathCreate();
    OH_Drawing_PathAddCircle(pathCircle, startX + w / 2, startY + 60, 40, PATH_DIRECTION_CCW);
    OH_Drawing_CanvasDrawPath(canvas, pathCircle);
    OH_Drawing_PathDestroy(pathCircle);
    // 矩形
    startX += w;
    OH_Drawing_Path *pathRect = OH_Drawing_PathCreate();
    OH_Drawing_PathAddRect(pathRect, startX + 10.f, startY + 30, startX + w - 10.f, startY + 90, PATH_DIRECTION_CCW);
    OH_Drawing_CanvasDrawPath(canvas, pathRect);
    OH_Drawing_PathDestroy(pathRect);
    // 椭圆
    startX += w;
    OH_Drawing_Path *pathOval = OH_Drawing_PathCreate();
    OH_Drawing_Rect *rectOval = OH_Drawing_RectCreate(startX + 10.f, startY + 30, startX + w - 10.f, startY + 90);
    OH_Drawing_PathAddOval(pathOval, rectOval, OH_Drawing_PathDirection::PATH_DIRECTION_CW);
    OH_Drawing_CanvasDrawPath(canvas, pathOval);
    OH_Drawing_RectDestroy(rectOval);
    OH_Drawing_PathDestroy(pathOval);
    // 圆角矩形
    startX += w;
    OH_Drawing_Path *pathRoundRect = OH_Drawing_PathCreate();
    OH_Drawing_Rect *rectRoundRect = OH_Drawing_RectCreate(startX + 10.f, startY + 30, startX + w - 10.f, startY + 90);
    OH_Drawing_RoundRect *roundRect = OH_Drawing_RoundRectCreate(rectRoundRect, 20.f, 20.f);
    OH_Drawing_PathAddRoundRect(pathRoundRect, roundRect, PATH_DIRECTION_CCW);
    OH_Drawing_CanvasDrawPath(canvas, pathRoundRect);
    OH_Drawing_RectDestroy(rectRoundRect);
    OH_Drawing_PathDestroy(pathRoundRect);
    OH_Drawing_RoundRectDestroy(roundRect);
    // 多边形
    startX += w;
    OH_Drawing_Path *pathPolygon = OH_Drawing_PathCreate();
    float leftPointX = startX + 10;
    float rightPointX = startX + w - 10;
    float middlePointX = (leftPointX + rightPointX) / 2;
    OH_Drawing_Point2D points[] = {{middlePointX, startY + 30}, {leftPointX, startY + 90}, {rightPointX, startY + 90}};
    OH_Drawing_PathAddPolygon(pathPolygon, points, 3, true); // 3 is the size of point array
    OH_Drawing_CanvasDrawPath(canvas, pathPolygon);
    OH_Drawing_PathDestroy(pathPolygon);
    // 曲线
    startX += w;
    OH_Drawing_Rect *rectArc = OH_Drawing_RectCreate(startX - 50.f, startY + 30, startX + w - 10.f, startY + 150);
    OH_Drawing_Path *pathArc = OH_Drawing_PathCreate();
    OH_Drawing_PathAddArc(pathArc, rectArc, 0, -90.f);
    OH_Drawing_CanvasDrawPath(canvas, pathArc);
    OH_Drawing_RectDestroy(rectArc);
    OH_Drawing_PathDestroy(pathArc);
    // 线段1
    startX = 0;
    startY += 200;
    OH_Drawing_Path *pathOuter1 = OH_Drawing_PathCreate();
    OH_Drawing_Path *pathInner1 = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(pathInner1, startX + 10, startY);
    OH_Drawing_PathLineTo(pathInner1, startX + w - 10, startY);
    OH_Drawing_Matrix *matrix1 = OH_Drawing_MatrixCreateTranslation(0, 50);
    OH_Drawing_PathAddPath(pathOuter1, pathInner1, matrix1);
    OH_Drawing_CanvasDrawPath(canvas, pathOuter1);
    OH_Drawing_PathDestroy(pathOuter1);
    OH_Drawing_PathDestroy(pathInner1);
    OH_Drawing_MatrixDestroy(matrix1);
    // 线段2
    startX += w;
    OH_Drawing_Path *pathOuter2 = OH_Drawing_PathCreate();
    OH_Drawing_Path *pathInner2 = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(pathInner2, startX + 10, startY + 50);
    OH_Drawing_PathLineTo(pathInner2, startX + w - 10, startY + 50);
    OH_Drawing_PathAddPathWithMode(pathOuter2, pathInner2, OH_Drawing_PathAddMode::PATH_ADD_MODE_APPEND);
    OH_Drawing_CanvasDrawPath(canvas, pathOuter2);
    OH_Drawing_PathDestroy(pathOuter2);
    OH_Drawing_PathDestroy(pathInner2);
    // 线段3
    startX += w;
    OH_Drawing_Path *pathOuter3 = OH_Drawing_PathCreate();
    OH_Drawing_Path *pathInner3 = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(pathInner3, startX + 10, startY);
    OH_Drawing_PathLineTo(pathInner3, startX + w - 10, startY);
    OH_Drawing_PathAddPathWithOffsetAndMode(pathOuter3, pathInner3, 0, 50, OH_Drawing_PathAddMode::PATH_ADD_MODE_APPEND);
    OH_Drawing_CanvasDrawPath(canvas, pathOuter3);
    OH_Drawing_PathDestroy(pathOuter3);
    OH_Drawing_PathDestroy(pathInner3);
    // 线段4
    startX += w;
    OH_Drawing_Path *pathOuter4 = OH_Drawing_PathCreate();
    OH_Drawing_Path *pathInner4 = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(pathInner4, startX + 10, startY);
    OH_Drawing_PathLineTo(pathInner4, startX + w - 10, startY);
    OH_Drawing_Matrix *matrix2 = OH_Drawing_MatrixCreateTranslation(0, 50);
    OH_Drawing_PathAddPathWithMatrixAndMode(pathOuter4, pathInner4, matrix2, OH_Drawing_PathAddMode::PATH_ADD_MODE_APPEND);
    OH_Drawing_CanvasDrawPath(canvas, pathOuter4);
    OH_Drawing_PathDestroy(pathOuter4);
    OH_Drawing_PathDestroy(pathInner4);
    OH_Drawing_MatrixDestroy(matrix2);
    // 椭圆
    startX += w;
    OH_Drawing_Path *pathOval2 = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(pathOval2, startX + 10, startY);
    OH_Drawing_Rect *rectOval2 = OH_Drawing_RectCreate(startX + 10.f, startY + 30, startX + w - 10.f, startY + 90);
    OH_Drawing_PathAddOvalWithInitialPoint(pathOval2, rectOval2, 1, OH_Drawing_PathDirection::PATH_DIRECTION_CW);
    OH_Drawing_CanvasDrawPath(canvas, pathOval2);
    OH_Drawing_RectDestroy(rectOval2);
    OH_Drawing_PathDestroy(pathOval2);
    // 矩形
    startX += w;
    OH_Drawing_Path *pathRect2 = OH_Drawing_PathCreate();
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(startX + 10.f, startY + 30, startX + w - 10.f, startY + 90);
    OH_Drawing_PathAddRectWithInitialCorner(pathRect2, rect, PATH_DIRECTION_CCW, 1);
    OH_Drawing_CanvasDrawPath(canvas, pathRect2);
    OH_Drawing_PathDestroy(pathRect2);
    OH_Drawing_RectDestroy(rect);
    
    OH_Drawing_CanvasDetachPen(canvas);
    OH_Drawing_PenDestroy(pen);
}

void SampleGraphics::BuildFromSvgString(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Brush* brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_CanvasAttachBrush(canvas, brush);
    char* str = "M150 30L30 300L270 300Z";
    OH_Drawing_Path* path = OH_Drawing_PathCreate();
    // 通过svg构建path
    OH_Drawing_PathBuildFromSvgString(path, str);
    OH_Drawing_CanvasDrawPath(canvas, path);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_PathDestroy(path);
}

void SampleGraphics::DrawCreateCanvas(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Bitmap* bitmap = OH_Drawing_BitmapCreate();
    OH_Drawing_BitmapFormat cFormat{COLOR_FORMAT_RGBA_8888, ALPHA_FORMAT_OPAQUE};
    uint64_t width = width_ / 2;
    uint64_t height = height_ / 2;
    OH_Drawing_BitmapBuild(bitmap, width, height, &cFormat);
    // 创建一个canvas对象
    OH_Drawing_Canvas* newCanvas = OH_Drawing_CanvasCreate();
    // 将画布与bitmap绑定，画布画的内容会输出到绑定的bitmap内存中
    OH_Drawing_CanvasBind(newCanvas, bitmap);
    // 使用红色清除画布内容
    OH_Drawing_CanvasClear(newCanvas, OH_Drawing_ColorSetArgb(0x50, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    // 获取画布宽高
    SAMPLE_LOGI("Canvas-->width=%{public}d,height=%{public}d", OH_Drawing_CanvasGetWidth(newCanvas),
        OH_Drawing_CanvasGetHeight(newCanvas));
    OH_Drawing_CanvasDrawBitmap(canvas, bitmap, 0, 0);
    OH_Drawing_CanvasDestroy(newCanvas);
    OH_Drawing_BitmapDestroy(bitmap);
}

void SampleGraphics::DrawCanvasConcatMatrix(OH_Drawing_Canvas *canvas)
{
    OH_Drawing_Pen* pen = OH_Drawing_PenCreate();
    OH_Drawing_PenSetColor(pen, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    OH_Drawing_PenSetWidth(pen, 10);
    OH_Drawing_CanvasAttachPen(canvas, pen);
    OH_Drawing_Rect *rect = OH_Drawing_RectCreate(value300_, value300_, value600_, value500_);
    // 绘制原始矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_Matrix *matrix1 = OH_Drawing_MatrixCreateTranslation(value300_, value300_);
    // 对画布进行矩阵操作
    OH_Drawing_CanvasConcatMatrix(canvas, matrix1);
    // 绘制变换后的矩形
    OH_Drawing_CanvasDrawRect(canvas, rect);
    OH_Drawing_Matrix *matrix2 = OH_Drawing_MatrixCreate();
    OH_Drawing_CanvasGetTotalMatrix(canvas, matrix2);
    SAMPLE_LOGI("Canvas-->MatrixIsEqual=%{public}d", OH_Drawing_MatrixIsEqual(matrix1, matrix2) ? 1 : 0);
    OH_Drawing_CanvasDetachBrush(canvas);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_MatrixDestroy(matrix1);
    OH_Drawing_MatrixDestroy(matrix2);
    OH_Drawing_PenDestroy(pen);
}

void SampleGraphics::DrawPixelMapRect(OH_Drawing_Canvas *canvas)
{
    // 从NativePixelMap中获取PixelMap对象
    OH_Drawing_PixelMap *pixelMap = OH_Drawing_PixelMapGetFromNativePixelMap(nativePixelMap_);
    OH_Drawing_SamplingOptions *sampling = OH_Drawing_SamplingOptionsCreate(FILTER_MODE_LINEAR, MIPMAP_MODE_NONE);
    float width = 650.f;
    float height = 664.f;
    OH_Drawing_Rect *src = OH_Drawing_RectCreate(0, 0, width, height);
    OH_Drawing_Rect *dst = OH_Drawing_RectCreate(value100_, value100_, value700_, value700_);
    // 绘制PixelMap
    OH_Drawing_CanvasDrawPixelMapRect(canvas, pixelMap, src, dst, sampling);
    // 解除NativePixelMap和PixelMap的关联
    OH_Drawing_PixelMapDissolve(pixelMap);
    OH_Drawing_SamplingOptionsDestroy(sampling);
    OH_Drawing_RectDestroy(src);
    OH_Drawing_RectDestroy(dst);
}

void SampleGraphics::DrawBitmap(OH_Drawing_Canvas *canvas)
{
    // 创建一个bitmap对象
    OH_Drawing_Bitmap* bitmap1 = OH_Drawing_BitmapCreate();
    OH_Drawing_BitmapFormat cFormat{COLOR_FORMAT_RGBA_8888, ALPHA_FORMAT_OPAQUE};
    uint64_t width = width_ / 2;
    uint64_t height = height_ / 2;
    // 构建bitmap对象
    OH_Drawing_BitmapBuild(bitmap1, width, height, &cFormat);
    OH_Drawing_Canvas* newCanvas = OH_Drawing_CanvasCreate();
    OH_Drawing_CanvasBind(newCanvas, bitmap1);
    OH_Drawing_CanvasClear(newCanvas, OH_Drawing_ColorSetArgb(0x50, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    // 获取位图宽高
    SAMPLE_LOGI("Bitmap-->width=%{public}d,height=%{public}d", OH_Drawing_BitmapGetWidth(bitmap1),
        OH_Drawing_BitmapGetHeight(bitmap1));
    // 获取像素
    void *pixels = OH_Drawing_BitmapGetPixels(bitmap1);
    OH_Drawing_Image_Info imageInfo;
    imageInfo.width = width;
    imageInfo.height = height;
    imageInfo.colorType = COLOR_FORMAT_RGBA_8888;
    imageInfo.alphaType = ALPHA_FORMAT_OPAQUE;
    // 通过像素创建一个bitmap对象
    OH_Drawing_Bitmap* bitmap2 = OH_Drawing_BitmapCreateFromPixels(&imageInfo, pixels, width * 4);
    OH_Drawing_CanvasDrawBitmap(canvas, bitmap1, 0, 0);
    OH_Drawing_CanvasDrawBitmap(canvas, bitmap2, width, height);
    OH_Drawing_CanvasDestroy(newCanvas);
    OH_Drawing_BitmapDestroy(bitmap1);
    OH_Drawing_BitmapDestroy(bitmap2);
}

void SampleGraphics::DrawImage(OH_Drawing_Canvas *canvas)
{
    // 创建一个bitmap对象
    OH_Drawing_Bitmap* bitmap = OH_Drawing_BitmapCreate();
    OH_Drawing_BitmapFormat cFormat{COLOR_FORMAT_RGBA_8888, ALPHA_FORMAT_OPAQUE};
    uint64_t width = width_ / 2;
    uint64_t height = height_ / 2;
    OH_Drawing_BitmapBuild(bitmap, width, height, &cFormat);
    OH_Drawing_Canvas* newCanvas = OH_Drawing_CanvasCreate();
    OH_Drawing_CanvasBind(newCanvas, bitmap);
    OH_Drawing_CanvasClear(newCanvas, OH_Drawing_ColorSetArgb(RGBA_MAX, RGBA_MAX, RGBA_MIN, RGBA_MIN));
    // 创建image对象
    OH_Drawing_Image* image = OH_Drawing_ImageCreate();
    // 从bitmap构建image
    OH_Drawing_ImageBuildFromBitmap(image, bitmap);
    // 获取Image宽高
    SAMPLE_LOGI("Image-->width=%{public}d,height=%{public}d", OH_Drawing_ImageGetWidth(image),
        OH_Drawing_ImageGetHeight(image));
    OH_Drawing_Rect* rect = OH_Drawing_RectCreate(0, 0, width / 2, height / 2);
    OH_Drawing_SamplingOptions* options = OH_Drawing_SamplingOptionsCreate(
        OH_Drawing_FilterMode::FILTER_MODE_LINEAR, OH_Drawing_MipmapMode::MIPMAP_MODE_LINEAR);
    OH_Drawing_CanvasDrawImageRect(canvas, image, rect, options);
    // 销毁对象
    OH_Drawing_CanvasDestroy(newCanvas);
    OH_Drawing_BitmapDestroy(bitmap);
    OH_Drawing_ImageDestroy(image);
    OH_Drawing_RectDestroy(rect);
    OH_Drawing_SamplingOptionsDestroy(options);
}

void SampleGraphics::InitDrawFunction(std::string id)
{
    this->drawFunctionMap_.insert({"BrushBasic", &SampleGraphics::DrawBrushBasic});
    this->drawFunctionMap_.insert({"MixedMode", &SampleGraphics::DrawMixedMode});
    this->drawFunctionMap_.insert({"LinearGradient", &SampleGraphics::DrawShaderEffect});
    this->drawFunctionMap_.insert({"ColorFilter", &SampleGraphics::DrawColorFilter});
    this->drawFunctionMap_.insert({"MaskFilterBrush", &SampleGraphics::DrawMaskFilterBrush});
    
    this->drawFunctionMap_.insert({"PenBasic", &SampleGraphics::DrawPenBasic});
    this->drawFunctionMap_.insert({"Stroke", &SampleGraphics::DrawStroke});
    this->drawFunctionMap_.insert({"MiterLimit", &SampleGraphics::DrawMiterLimit});
    this->drawFunctionMap_.insert({"ImageFilter", &SampleGraphics::DrawImageFilter});
    this->drawFunctionMap_.insert({"PathEffect", &SampleGraphics::DrawPathEffect});
    this->drawFunctionMap_.insert({"PenLinearGradient", &SampleGraphics::DrawPenLinearGradient});
    this->drawFunctionMap_.insert({"MaskFilterPen", &SampleGraphics::DrawMaskFilterPen});
    
    this->drawFunctionMap_.insert({"RectBasic", &SampleGraphics::DrawRectBasic});
    this->drawFunctionMap_.insert({"RectIntersect", &SampleGraphics::DrawRectIntersect});
    this->drawFunctionMap_.insert({"RectJoin", &SampleGraphics::DrawRectJoin});
    this->drawFunctionMap_.insert({"RoundRect", &SampleGraphics::DrawRoundRect});
    
    this->drawFunctionMap_.insert({"PathBasic", &SampleGraphics::DrawPathBasic});
    this->drawFunctionMap_.insert({"PathTo", &SampleGraphics::DrawPathTo});
    this->drawFunctionMap_.insert({"PathAdd", &SampleGraphics::DrawPathAdd});
    this->drawFunctionMap_.insert({"PathStar", &SampleGraphics::DrawStar});
    this->drawFunctionMap_.insert({"BuildFromSvgString", &SampleGraphics::BuildFromSvgString});
    
    this->drawFunctionMap_.insert({"MatrixBasic", &SampleGraphics::DrawMatrixBasic});
    this->drawFunctionMap_.insert({"TranslationOperation", &SampleGraphics::DrawTranslationOperation});
    this->drawFunctionMap_.insert({"PreTranslationOperation", &SampleGraphics::DrawPreTranslationOperation});
    this->drawFunctionMap_.insert({"PostTranslationOperation", &SampleGraphics::DrawPostTranslationOperation});
    this->drawFunctionMap_.insert({"RotationOperation", &SampleGraphics::DrawRotationOperation});
    this->drawFunctionMap_.insert({"PreRotationOperation", &SampleGraphics::DrawPreRotationOperation});
    this->drawFunctionMap_.insert({"PostRotationOperation", &SampleGraphics::DrawPostRotationOperation});
    this->drawFunctionMap_.insert({"ScaleOperation", &SampleGraphics::DrawScaleOperation});
    this->drawFunctionMap_.insert({"PreScaleOperation", &SampleGraphics::DrawPreScaleOperation});
    this->drawFunctionMap_.insert({"PostScaleOperation", &SampleGraphics::DrawPostScaleOperation});
    this->drawFunctionMap_.insert({"ConcatOperation", &SampleGraphics::DrawConcatOperation});
    
    this->drawFunctionMap_.insert({"CanvasCreate", &SampleGraphics::DrawCreateCanvas});
    this->drawFunctionMap_.insert({"ClipOperation", &SampleGraphics::DrawClipOperation});
    this->drawFunctionMap_.insert({"SaveOperation", &SampleGraphics::CanvasSaveOperation});
    this->drawFunctionMap_.insert({"SaveLayerOperation", &SampleGraphics::CanvasSaveLayerOperation});
    this->drawFunctionMap_.insert({"ConcatMatrix", &SampleGraphics::DrawCanvasConcatMatrix});
    this->drawFunctionMap_.insert({"DrawRegion", &SampleGraphics::DrawRegion});
    
    this->drawFunctionMap_.insert({"LocalPixelMap", &SampleGraphics::DrawPixelMapRect});
    this->drawFunctionMap_.insert({"CustomPixelMap", &SampleGraphics::DrawCustomPixelMap});
    this->drawFunctionMap_.insert({"DrawBitmap", &SampleGraphics::DrawBitmap});
    this->drawFunctionMap_.insert({"DrawImage", &SampleGraphics::DrawImage});
}

void SampleGraphics::DoRender(SampleGraphics *render, char* canvasType, char* shapeType)
{
    SAMPLE_LOGI("DoRender");
    render->Prepare();
    // 不同画布
    if (strcmp(canvasType, "CanvasGet") == 0) {
            SAMPLE_LOGI("CanvasGet");
        render->Create();
        // 绘制图案
        auto it = render->drawFunctionMap_.find(shapeType);
        if (it != render->drawFunctionMap_.end()) {
            (render->*(it->second))(render->cScreenCanvas_);
        } else {
            SAMPLE_LOGI("Unsupported shape type: %{public}s", shapeType);
        }
        render->DisPlay();
    } else if (strcmp(canvasType, "CanvasGetByCPU") == 0) {
        render->CreateByCPU();
        // 绘制图案
        auto it = render->drawFunctionMap_.find(shapeType);
        if (it != render->drawFunctionMap_.end()) {
            (render->*(it->second))(render->cCPUCanvas_);
        } else {
            SAMPLE_LOGI("Unsupported shape type: %{public}s", shapeType);
        }
        render->DisPlayCPU();
    } else if (strcmp(canvasType, "CanvasGetByGPU") == 0) {
        render->CreateByGPU();
         // 绘制图案
        auto it = render->drawFunctionMap_.find(shapeType);
        if (it != render->drawFunctionMap_.end()) {
            (render->*(it->second))(render->cGPUCanvas_);
        } else {
            SAMPLE_LOGI("Unsupported shape type: %{public}s", shapeType);
        }
        render->DisPlayGPU();
    }
    render->Destroy();
}

napi_value SampleGraphics::Draw(napi_env env, napi_callback_info info)
{
    SAMPLE_LOGI("Draw");
    if ((env == nullptr) || (info == nullptr)) {
        SAMPLE_LOGE("NapiRegister: env or info is null");
        return nullptr;
    }

    napi_value thisArg;
    size_t argc = 2;
    napi_value args[2];
    if (napi_get_cb_info(env, info, &argc, args, &thisArg, nullptr) != napi_ok) {
        SAMPLE_LOGE("NapiRegister: napi_get_cb_info fail");
        return nullptr;
    }

    napi_value exportInstance;
    if (napi_get_named_property(env, thisArg, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance) != napi_ok) {
        SAMPLE_LOGE("NapiRegister: napi_get_named_property fail");
        return nullptr;
    }

    OH_NativeXComponent *nativeXComponent = nullptr;
    if (napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent)) != napi_ok) {
        SAMPLE_LOGE("NapiRegister: napi_unwrap fail");
        return nullptr;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        SAMPLE_LOGE("NapiRegister: Unable to get XComponent id");
        return nullptr;
    }
    SAMPLE_LOGI("RegisterID = %{public}s", idStr);
    std::string id(idStr);
    
    // 获取形状参数
    char canvasType[32] = {0};
    napi_get_value_string_utf8(env, args[0], canvasType, sizeof(canvasType), nullptr);
    
    // 获取形状参数
    char shapeType[32] = {0};
    napi_get_value_string_utf8(env, args[1], shapeType, sizeof(shapeType), nullptr);
    
    SampleGraphics *render = SampleGraphics().GetInstance(id);
    if (render != nullptr) {
        render->DoRender(render, canvasType, shapeType);
    }
    return nullptr;
}

napi_value SampleGraphics::DrawImage(napi_env env, napi_callback_info info)
{
    SAMPLE_LOGI("DrawImage");
    if ((env == nullptr) || (info == nullptr)) {
        SAMPLE_LOGE("NapiRegister: env or info is null");
        return nullptr;
    }

    napi_value thisArg;
    size_t argc = 3;
    napi_value args[3];
    if (napi_get_cb_info(env, info, &argc, args, &thisArg, nullptr) != napi_ok) {
        SAMPLE_LOGE("NapiRegister: napi_get_cb_info fail");
        return nullptr;
    }

    napi_value exportInstance;
    if (napi_get_named_property(env, thisArg, OH_NATIVE_XCOMPONENT_OBJ, &exportInstance) != napi_ok) {
        SAMPLE_LOGE("NapiRegister: napi_get_named_property fail");
        return nullptr;
    }

    OH_NativeXComponent *nativeXComponent = nullptr;
    if (napi_unwrap(env, exportInstance, reinterpret_cast<void **>(&nativeXComponent)) != napi_ok) {
        SAMPLE_LOGE("NapiRegister: napi_unwrap fail");
        return nullptr;
    }

    char idStr[OH_XCOMPONENT_ID_LEN_MAX + 1] = {'\0'};
    uint64_t idSize = OH_XCOMPONENT_ID_LEN_MAX + 1;
    if (OH_NativeXComponent_GetXComponentId(nativeXComponent, idStr, &idSize) != OH_NATIVEXCOMPONENT_RESULT_SUCCESS) {
        SAMPLE_LOGE("NapiRegister: Unable to get XComponent id");
        return nullptr;
    }
    SAMPLE_LOGI("RegisterID = %{public}s", idStr);
    std::string id(idStr);
    
    // 获取形状参数
    char canvasType[32] = {0};
    napi_get_value_string_utf8(env, args[0], canvasType, sizeof(canvasType), nullptr);
    
    // 获取形状参数
    char shapeType[32] = {0};
    napi_get_value_string_utf8(env, args[1], shapeType, sizeof(shapeType), nullptr);
    
    NativePixelMap *nativePixelMap = OH_PixelMap_InitNativePixelMap(env, args[2]);
    SampleGraphics *render = SampleGraphics().GetInstance(id);
    if (render != nullptr) {
        render->nativePixelMap_ = nativePixelMap;
        render->DoRender(render, canvasType, shapeType);
    }
    return nullptr;
}

SampleGraphics::~SampleGraphics()
{
    // 销毁canvas对象
    OH_Drawing_CanvasDestroy(cScreenCanvas_);
    cScreenCanvas_ = nullptr;
    OH_Drawing_CanvasDestroy(cCPUCanvas_);
    cCPUCanvas_ = nullptr;
    // 销毁bitmap对象
    OH_Drawing_BitmapDestroy(cScreenBitmap_);
    cScreenBitmap_ = nullptr;
    OH_Drawing_BitmapDestroy(cOffScreenBitmap_);
    cOffScreenBitmap_ = nullptr;
    
    buffer_ = nullptr;
    bufferHandle_ = nullptr;
    nativeWindow_ = nullptr;
    mappedAddr_ = nullptr;
    DeInitializeEglContext();
}

void SampleGraphics::Destroy()
{
    // 销毁canvas对象
    OH_Drawing_CanvasDestroy(cScreenCanvas_);
    cScreenCanvas_ = nullptr;
    OH_Drawing_CanvasDestroy(cCPUCanvas_);
    cCPUCanvas_ = nullptr;
    // 销毁bitmap对象
    OH_Drawing_BitmapDestroy(cScreenBitmap_);
    cScreenBitmap_ = nullptr;
    OH_Drawing_BitmapDestroy(cOffScreenBitmap_);
    cOffScreenBitmap_ = nullptr;
    DeInitializeEglContext();
}

void SampleGraphics::Release(std::string &id)
{
    SampleGraphics *render = SampleGraphics::GetInstance(id);
    if (render != nullptr) {
        delete render;
        render = nullptr;
        g_instance.erase(g_instance.find(id));
    }
}

void SampleGraphics::Export(napi_env env, napi_value exports)
{
    if ((env == nullptr) || (exports == nullptr)) {
        SAMPLE_LOGE("Export: env or exports is null");
        return;
    }
    napi_property_descriptor desc[] = {
        {"draw", nullptr, SampleGraphics::Draw, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"drawImage", nullptr, SampleGraphics::DrawImage, nullptr, nullptr, nullptr, napi_default, nullptr}
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    if (napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc) != napi_ok) {
        SAMPLE_LOGE("Export: napi_define_properties failed");
    }
}

void SampleGraphics::RegisterCallback(OH_NativeXComponent *nativeXComponent)
{
    SAMPLE_LOGI("register callback");
    renderCallback_.OnSurfaceCreated = OnSurfaceCreatedCB;
    renderCallback_.OnSurfaceDestroyed = OnSurfaceDestroyedCB;
    // Callback must be initialized
    renderCallback_.DispatchTouchEvent = nullptr;
    renderCallback_.OnSurfaceChanged = nullptr;
    OH_NativeXComponent_RegisterCallback(nativeXComponent, &renderCallback_);
}

SampleGraphics *SampleGraphics::GetInstance(std::string &id)
{
    if (g_instance.find(id) == g_instance.end()) {
        SampleGraphics *render = new SampleGraphics(id);
        g_instance[id] = render;
        render->InitDrawFunction(id);
        return render;
    } else {
        return g_instance[id];
    }
}