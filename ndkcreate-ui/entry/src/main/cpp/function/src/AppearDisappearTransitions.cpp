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

#include <arkui/native_interface.h>
#include <arkui/native_node.h>
#include <arkui/native_node_napi.h>
#include <arkui/native_type.h>
#include <js_native_api.h>

#include "BuildingADialogBox.h"
#include "AppearDisappearTransitions.h"

namespace NativeModule {
ArkUI_NodeHandle parentNode;
ArkUI_NodeHandle childNode;
ArkUI_NodeHandle buttonNode2;

napi_value CreateAnimationViewNativeRoot(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    // Get parameters passed in from JS.
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // Get NodeContent.
    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);

    // Load animation page.
    mainAnimationViewMethod(contentHandle);
    return nullptr;
}

void mainAnimationViewMethod(ArkUI_NodeContentHandle handle)
{
    ArkUI_NativeNodeAPI_1 *nodeAPI = reinterpret_cast<ArkUI_NativeNodeAPI_1 *>(
        OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_NODE, "ArkUI_NativeNodeAPI_1"));
    ArkUI_NodeHandle column = nodeAPI->createNode(ARKUI_NODE_COLUMN);
    ArkUI_NumberValue widthValue[] = {{.f32 = 300}};
    ArkUI_AttributeItem widthItem = {.value = widthValue, .size = sizeof(widthValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(column, NODE_WIDTH, &widthItem);
    ArkUI_NumberValue heightValue[] = {{.f32 = 600}};
    ArkUI_AttributeItem heightItem = {.value = heightValue, .size = sizeof(heightValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(column, NODE_HEIGHT, &heightItem);
    ArkUI_NodeHandle buttonShow = nodeAPI->createNode(ARKUI_NODE_BUTTON);
    ArkUI_NumberValue buttonWidthValue[] = {{.f32 = 200}};
    ArkUI_AttributeItem buttonWidthItem = {.value = buttonWidthValue,
                                           .size = sizeof(buttonWidthValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(buttonShow, NODE_WIDTH, &buttonWidthItem);
    ArkUI_NumberValue buttonHeightValue[] = {{.f32 = 50}};
    ArkUI_AttributeItem buttonHeightItem = {.value = buttonHeightValue,
                                            .size = sizeof(buttonHeightValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(buttonShow, NODE_HEIGHT, &buttonHeightItem);
    ArkUI_AttributeItem labelItem = {.string = "show"};
    nodeAPI->setAttribute(buttonShow, NODE_BUTTON_LABEL, &labelItem);
    ArkUI_NumberValue buttonOpenTypeValue[] = {{.i32 = static_cast<int32_t>(ARKUI_BUTTON_TYPE_CAPSULE)}};
    ArkUI_AttributeItem buttonOpenTypeItem = {.value = buttonOpenTypeValue,
                                              .size = sizeof(buttonOpenTypeValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(buttonShow, NODE_BUTTON_TYPE, &buttonOpenTypeItem);
    ArkUI_NumberValue buttonShowMarginValue[] = {{.f32 = 20}};
    ArkUI_AttributeItem buttonShowMarginItem = {.value = buttonShowMarginValue,
                                                .size = sizeof(buttonShowMarginValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(buttonShow, NODE_MARGIN, &buttonShowMarginItem);
    nodeAPI->registerNodeEvent(buttonShow, NODE_ON_CLICK, BUTTON_CLICK_ID2, nullptr);
    nodeAPI->addNodeEventReceiver(buttonShow, OnButtonShowClicked);
    parentNode = column;
    buttonNode2 = buttonShow;
    nodeAPI->addChild(column, buttonShow);
    OH_ArkUI_NodeContent_AddNode(handle, column);
}

void OnButtonShowClicked(ArkUI_NodeEvent *event)
{
    if (!event) {
        return;
    }
    if (!childNode) {
        childNode = CreateChildNode();
    }
    ArkUI_NativeNodeAPI_1 *nodeAPI = reinterpret_cast<ArkUI_NativeNodeAPI_1 *>(
        OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_NODE, "ArkUI_NativeNodeAPI_1"));
    if (flag2) {
        flag2 = false;
        ArkUI_AttributeItem labelItem = {.string = "show"};
        nodeAPI->setAttribute(buttonNode2, NODE_BUTTON_LABEL, &labelItem);
        nodeAPI->removeChild(parentNode, childNode);
    } else {
        flag2 = true;
        ArkUI_AttributeItem labelItem = {.string = "hide"};
        nodeAPI->setAttribute(buttonNode2, NODE_BUTTON_LABEL, &labelItem);
        nodeAPI->addChild(parentNode, childNode);
    }
}

ArkUI_NodeHandle CreateChildNode()
{
    ArkUI_NativeNodeAPI_1 *nodeAPI = reinterpret_cast<ArkUI_NativeNodeAPI_1 *>(
        OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_NODE, "ArkUI_NativeNodeAPI_1"));
    ArkUI_NodeHandle image = nodeAPI->createNode(ARKUI_NODE_IMAGE);
    ArkUI_AttributeItem imageSrcItem = {.string = "/pages/common/scenery.PNG"};
    nodeAPI->setAttribute(image, NODE_IMAGE_SRC, &imageSrcItem);
    ArkUI_NumberValue textWidthValue[] = {{.f32 = 300}};
    ArkUI_AttributeItem textWidthItem = {.value = textWidthValue,
                                         .size = sizeof(textWidthValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(image, NODE_WIDTH, &textWidthItem);
    ArkUI_NumberValue textHeightValue[] = {{.f32 = 300}};
    ArkUI_AttributeItem textHeightItem = {.value = textHeightValue,
                                          .size = sizeof(textHeightValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(image, NODE_HEIGHT, &textHeightItem);
    ArkUI_NumberValue transformCenterValue[] = {0.0f, 0.0f, 0.0f, 0.5f, 0.5f};
    ArkUI_AttributeItem transformCenterItem = {.value = transformCenterValue,
                                               .size = sizeof(transformCenterValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(image, NODE_TRANSFORM_CENTER, &transformCenterItem);
    ArkUI_NumberValue rotateAnimationValue[] = {
        0.0f, 0.0f, 1.0f, 360.0f, 0.0f, {.i32 = 500}, {.i32 = static_cast<int32_t>(ARKUI_CURVE_SHARP)}};
    ArkUI_AttributeItem rotateAnimationItem = {.value = rotateAnimationValue,
                                               .size = sizeof(rotateAnimationValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(image, NODE_ROTATE_TRANSITION, &rotateAnimationItem);
    ArkUI_NumberValue scaleAnimationValue[] = {
        0.0f, 0.0f, 0.0f, {.i32 = 500}, {.i32 = static_cast<int32_t>(ARKUI_CURVE_SHARP)}};
    ArkUI_AttributeItem scaleAnimationItem = {.value = scaleAnimationValue,
                                              .size = sizeof(scaleAnimationValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(image, NODE_SCALE_TRANSITION, &scaleAnimationItem);
    ArkUI_NumberValue translateAnimationValue[] = {
        200, 200, 0.0f, {.i32 = 500}, {.i32 = static_cast<int32_t>(ARKUI_CURVE_SHARP)}};
    ArkUI_AttributeItem translateAnimationItem = {.value = translateAnimationValue,
                                                  .size = sizeof(translateAnimationValue) / sizeof(ArkUI_NumberValue)};
    nodeAPI->setAttribute(image, NODE_TRANSLATE_TRANSITION, &translateAnimationItem);
    return image;
}

napi_value DestroyAnimationViewNativeRoot(napi_env env, napi_callback_info info)
{
    CloseDialog();
    return nullptr;
}
} // namespace NativeModule

