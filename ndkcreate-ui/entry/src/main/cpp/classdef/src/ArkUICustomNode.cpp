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

#include <native_drawing/drawing_brush.h>
#include <native_drawing/drawing_canvas.h>
#include <native_drawing/drawing_path.h>
#include <native_drawing/drawing_types.h>
#include "ArkUICustomNode.h"

namespace NativeModule {
void ArkUICustomNode::SetRectColor(uint32_t color)
{
    color_ = color;
    // Custom drawing attribute changes require proactive notification to the framework.
    nativeModule_->markDirty(handle_, NODE_NEED_RENDER);
}

void ArkUICustomNode::OnStaticCustomEvent(ArkUI_NodeCustomEvent *event)
{
    // Retrieve component instance objects and call relevant instance methods.
    auto customNode = reinterpret_cast<ArkUICustomNode *>(OH_ArkUI_NodeCustomEvent_GetUserData(event));
    auto type = OH_ArkUI_NodeCustomEvent_GetEventType(event);
    switch (type) {
        case ARKUI_NODE_CUSTOM_EVENT_ON_DRAW:
            customNode->OnDraw(event);
            break;
        default:
            break;
    }
}

// Define and draw logic.
void ArkUICustomNode::OnDraw(ArkUI_NodeCustomEvent *event)
{
    auto drawContext = OH_ArkUI_NodeCustomEvent_GetDrawContextInDraw(event);
    // Get graphic drawing objects.
    auto drawCanvas = reinterpret_cast<OH_Drawing_Canvas *>(OH_ArkUI_DrawContext_GetCanvas(drawContext));
    // Get component size.
    auto size = OH_ArkUI_DrawContext_GetSize(drawContext);
    // Draw custom content.
    auto path = OH_Drawing_PathCreate();
    OH_Drawing_PathMoveTo(path, size.width * ONE_FOURTH, size.height * ONE_FOURTH);
    OH_Drawing_PathLineTo(path, size.width * THREE_FOURTHS, size.height * ONE_FOURTH);
    OH_Drawing_PathLineTo(path, size.width * THREE_FOURTHS, size.height * THREE_FOURTHS);
    OH_Drawing_PathLineTo(path, size.width * ONE_FOURTH, size.height * THREE_FOURTHS);
    OH_Drawing_PathLineTo(path, size.width * ONE_FOURTH, size.height * ONE_FOURTH);
    OH_Drawing_PathClose(path);
    auto brush = OH_Drawing_BrushCreate();
    OH_Drawing_BrushSetColor(brush, color_);
    OH_Drawing_CanvasAttachBrush(drawCanvas, brush);
    OH_Drawing_CanvasDrawPath(drawCanvas, path);
    // Release resources.
    OH_Drawing_BrushDestroy(brush);
    OH_Drawing_PathDestroy(path);
}
} // namespace NativeModule