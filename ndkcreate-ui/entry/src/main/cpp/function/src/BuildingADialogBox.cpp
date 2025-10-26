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

#include <arkui/native_dialog.h>
#include <arkui/native_interface.h>
#include <arkui/native_node_napi.h>
#include <arkui/native_type.h>
#include <js_native_api.h>
#include "AppearDisappearTransitions.h"
#include "BuildingADialogBox.h"

namespace NativeModule {
ArkUI_NativeDialogHandle dialogController;
ArkUI_NodeHandle buttonNode;

napi_value CreatePopupNativeRoot(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    // Get parameters passed in from JS.
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // Get NodeContent.
    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);

    // Load pop-up interactive page.
    MainViewMethod(contentHandle);
    return nullptr;
}

void MainViewMethod(ArkUI_NodeContentHandle handle)
{
    ArkUI_NativeNodeAPI_1 *nodeAPI = reinterpret_cast<ArkUI_NativeNodeAPI_1 *>(
        OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_NODE, "ArkUI_NativeNodeAPI_1"));
    ArkUI_NodeHandle column = nodeAPI->createNode(ARKUI_NODE_COLUMN);
    ArkUI_NumberValue widthValue[] = {{.f32 = 300}};
    ArkUI_AttributeItem widthItem = {.value = widthValue, .size = sizeof(widthValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(column, NODE_WIDTH, &widthItem);
    ArkUI_NumberValue heightValue[] = {{.f32 = 300}};
    ArkUI_AttributeItem heightItem = {.value = heightValue, .size = sizeof(heightValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(column, NODE_HEIGHT, &heightItem);
    buttonNode = nodeAPI->createNode(ARKUI_NODE_BUTTON);
    ArkUI_NumberValue buttonWidthValue[] = {{.f32 = 200}};
    ArkUI_AttributeItem buttonWidthItem = {.value = buttonWidthValue,
                                           .size = sizeof(buttonWidthValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(buttonNode, NODE_WIDTH, &buttonWidthItem);
    ArkUI_NumberValue buttonHeightValue[] = {{.f32 = 50}};
    ArkUI_AttributeItem buttonHeightItem = {.value = buttonHeightValue,
                                            .size = sizeof(buttonHeightValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(buttonNode, NODE_HEIGHT, &buttonHeightItem);
    ArkUI_AttributeItem labelItem = {.string = "点击弹窗"};
    nodeAPI->setAttribute(buttonNode, NODE_BUTTON_LABEL, &labelItem);
    ArkUI_NumberValue buttonTypeValue[] = {{.i32 = static_cast<int32_t>(ARKUI_BUTTON_TYPE_CAPSULE)}};
    ArkUI_AttributeItem buttonTypeItem = {.value = buttonTypeValue,
                                          .size = sizeof(buttonTypeValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(buttonNode, NODE_BUTTON_TYPE, &buttonTypeItem);
    nodeAPI->registerNodeEvent(buttonNode, NODE_ON_CLICK, BUTTON_CLICK_ID, nullptr);
    nodeAPI->addNodeEventReceiver(buttonNode, OnButtonClicked);
    nodeAPI->addChild(column, buttonNode);
    OH_ArkUI_NodeContent_AddNode(handle, column);
}

void OnButtonClicked(ArkUI_NodeEvent *event)
{
    if (!event || !buttonNode) {
        return;
    }

    auto eventId = OH_ArkUI_NodeEvent_GetTargetId(event);
    if (eventId == BUTTON_CLICK_ID) {
        ArkUI_NativeNodeAPI_1 *nodeAPI = reinterpret_cast<ArkUI_NativeNodeAPI_1 *>(
            OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_NODE, "ArkUI_NativeNodeAPI_1"));
        if (isShown) {
            isShown = false;
            ArkUI_AttributeItem labelItem = {.string = "显示弹窗"};
            nodeAPI->setAttribute(buttonNode, NODE_BUTTON_LABEL, &labelItem);
            nodeAPI->setAttribute(buttonNode, NODE_BACKGROUND_COLOR, &labelItem);
            CloseDialog();
        } else {
            isShown = true;
            ArkUI_AttributeItem labelItem = {.string = "关闭弹窗"};
            nodeAPI->setAttribute(buttonNode, NODE_BUTTON_LABEL, &labelItem);
            nodeAPI->setAttribute(buttonNode, NODE_BACKGROUND_COLOR, &labelItem);
            ShowDialog();
        }
    }
}

void ShowDialog()
{
    ArkUI_NativeDialogAPI_1 *dialogAPI = reinterpret_cast<ArkUI_NativeDialogAPI_1 *>(
        OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_DIALOG, "ArkUI_NativeDialogAPI_1"));
    if (!dialogController) {
        dialogController = dialogAPI->create();
    }
    auto contentNode = CreateDialogContent();
    dialogAPI->setContent(dialogController, contentNode);
    dialogAPI->setContentAlignment(dialogController, static_cast<int32_t>(ARKUI_ALIGNMENT_BOTTOM), 0, 0);
    dialogAPI->setBackgroundColor(dialogController, 0xffffffff);
    dialogAPI->setCornerRadius(dialogController, DIALOG_CORNER_RADIUS, DIALOG_CORNER_RADIUS, DIALOG_CORNER_RADIUS,
                               DIALOG_CORNER_RADIUS);
    dialogAPI->setModalMode(dialogController, false);
    dialogAPI->setAutoCancel(dialogController, true);
    dialogAPI->show(dialogController, false);
}

ArkUI_NodeHandle CreateDialogContent()
{
    ArkUI_NativeNodeAPI_1 *nodeAPI = reinterpret_cast<ArkUI_NativeNodeAPI_1 *>(
        OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_NODE, "ArkUI_NativeNodeAPI_1"));
    ArkUI_NodeHandle text = nodeAPI->createNode(ARKUI_NODE_TEXT);
    ArkUI_NumberValue textWidthValue[] = {{.f32 = 300}};
    ArkUI_AttributeItem textWidthItem = {.value = textWidthValue,
                                         .size = sizeof(textWidthValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(text, NODE_WIDTH, &textWidthItem);
    ArkUI_NumberValue textHeightValue[] = {{.f32 = 300}};
    ArkUI_AttributeItem textHeightItem = {.value = textHeightValue,
                                          .size = sizeof(textWidthValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(text, NODE_HEIGHT, &textHeightItem);
    ArkUI_NodeHandle span = nodeAPI->createNode(ARKUI_NODE_SPAN);
    ArkUI_AttributeItem spanItem = {.string = "这是一个弹窗"};
    nodeAPI->setAttribute(span, NODE_SPAN_CONTENT, &spanItem);
    ArkUI_NodeHandle imageSpan = nodeAPI->createNode(ARKUI_NODE_IMAGE_SPAN);
    ArkUI_AttributeItem imageSpanItem = {.string = "/pages/common/sky.PNG"};
    nodeAPI->setAttribute(imageSpan, NODE_IMAGE_SPAN_SRC, &imageSpanItem);
    ArkUI_NumberValue imageSpanWidthValue[] = {{.f32 = 300}};
    ArkUI_AttributeItem imageSpanWidthItem = {.value = imageSpanWidthValue,
                                              .size = sizeof(textWidthValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(imageSpan, NODE_WIDTH, &imageSpanWidthItem);
    ArkUI_NumberValue imageSpanHeightValue[] = {{.f32 = 200}};
    ArkUI_AttributeItem imageSpanHeightItem = {.value = imageSpanHeightValue,
                                               .size = sizeof(textWidthValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(imageSpan, NODE_HEIGHT, &imageSpanHeightItem);
    nodeAPI->addChild(text, span);
    nodeAPI->addChild(text, imageSpan);
    return text;
}

void CloseDialog()
{
    ArkUI_NativeDialogAPI_1 *dialogAPI = reinterpret_cast<ArkUI_NativeDialogAPI_1 *>(
        OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_DIALOG, "ArkUI_NativeDialogAPI_1"));
    dialogAPI->close(dialogController);
    flag2 = false;
    isShown = false;
}

napi_value DestroyPopupNativeRoot(napi_env env, napi_callback_info info)
{
    CloseDialog();
    return nullptr;
}
} // namespace NativeModule