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
#include <arkui/native_node_napi.h>
#include <arkui/native_type.h>
#include <hilog/log.h>
#include <js_native_api.h>

#include "BuildingADialogBox.h"
#include "AppearDisappearTransitions.h"
#include "UsingPropertyAnimations.h"

namespace NativeModule {

napi_value CreateAttributeAnimationNativeRoot(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    // Get parameters passed in from JS.
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // Get NodeContent
    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);

    ArkUI_ContextHandle context = nullptr;
    OH_ArkUI_GetContextFromNapiValue(env, args[1], &context);

    // Load animation page.
    CreateAttributeAnimation(contentHandle, context);
    return nullptr;
}

// Create and set up Stack nodes.
ArkUI_NodeHandle CreateAndSetupStack(ArkUI_NativeNodeAPI_1* nodeAPI)
{
    ArkUI_NumberValue widthValue[] = {300};
    ArkUI_AttributeItem widthItem = {widthValue, 1};
    ArkUI_NumberValue heightValue[] = {400};
    ArkUI_AttributeItem heightItem = {heightValue, 1};
    ArkUI_NumberValue colorValue[] = {{.u32 = 0xFFFFFF00}};
    ArkUI_AttributeItem colorItem = {colorValue, 1};
    auto stack = nodeAPI->createNode(ARKUI_NODE_COLUMN);
    nodeAPI->setAttribute(stack, NODE_WIDTH, &widthItem);
    nodeAPI->setAttribute(stack, NODE_HEIGHT, &heightItem);
    nodeAPI->setAttribute(stack, NODE_BACKGROUND_COLOR, &colorItem);
    return stack;
}

// Create and set button nodes.
ArkUI_NodeHandle CreateAndSetupButton(ArkUI_NativeNodeAPI_1* nodeAPI)
{
    ArkUI_NodeHandle buttonShow = nodeAPI->createNode(ARKUI_NODE_BUTTON);
    ArkUI_AttributeItem labelItem = {.string = "play"};
    nodeAPI->setAttribute(buttonShow, NODE_BUTTON_LABEL, &labelItem);
    nodeAPI->registerNodeEvent(buttonShow, NODE_ON_CLICK, BUTTON_CLICK_ID2, nullptr);
    nodeAPI->addNodeEventReceiver(buttonShow, OnButtonShowClicked2);
    return buttonShow;
}

// Set animation options.
void SetupAnimationOptions(ArkUI_AnimateOption* option)
{
    OH_ArkUI_AnimateOption_SetDuration(option, ANIMATION_DURATION);
    OH_ArkUI_AnimateOption_SetTempo(option, ANIMATION_TEMPO);
    OH_ArkUI_AnimateOption_SetCurve(option, ARKUI_CURVE_EASE);
    OH_ArkUI_AnimateOption_SetDelay(option, ANIMATION_DELAY);
    OH_ArkUI_AnimateOption_SetIterations(option, ANIMATION_ITERATIONS);
    OH_ArkUI_AnimateOption_SetPlayMode(option, ARKUI_ANIMATION_PLAY_MODE_NORMAL);
    ArkUI_ExpectedFrameRateRange *range = new ArkUI_ExpectedFrameRateRange;
    range->min = MIN_FRAME_RATE;
    range->max = MAX_FRAME_RATE;
    range->expected = EXPECTED_FRAME_RATE;
    OH_ArkUI_AnimateOption_SetExpectedFrameRateRange(option, range);
}

void CreateAttributeAnimation(ArkUI_NodeContentHandle handle, ArkUI_ContextHandle context1)
{
    context = context1;

    ArkUI_NativeNodeAPI_1 *nodeAPI = reinterpret_cast<ArkUI_NativeNodeAPI_1 *>(
        OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_NODE, "ArkUI_NativeNodeAPI_1"));
    
    auto stack = CreateAndSetupStack(nodeAPI);
    auto buttonShow = CreateAndSetupButton(nodeAPI);
    nodeAPI->addChild(stack, buttonShow);

    static ArkUI_NodeHandle textInput = nodeAPI->createNode(ARKUI_NODE_TEXT_INPUT);
    OH_ArkUI_GetModuleInterface(ARKUI_NATIVE_ANIMATE, ArkUI_NativeAnimateAPI_1, animateApi);

    option = OH_ArkUI_AnimateOption_Create();
    SetupAnimationOptions(option);

    UserData *onFinishUser = new UserData;
    onFinishUser->data = F_DATA;

    completeCallback = new ArkUI_AnimateCompleteCallback;
    completeCallback->userData = onFinishUser;
    completeCallback->type = ARKUI_FINISH_CALLBACK_REMOVED;
    completeCallback->callback = [](void *userData) {
        OH_LOG_INFO(LOG_APP, "CreateNativeNode onFinishCallback %{public}d",
                    reinterpret_cast<UserData *>(userData)->data);
    };

    UserData *eventUser = new UserData;
    eventUser->data = E_DATA;

    update = new ArkUI_ContextCallback;
    update->userData = eventUser;
    update->callback = [](void *userData) {
        ArkUI_NativeNodeAPI_1 *nodeAPI = reinterpret_cast<ArkUI_NativeNodeAPI_1 *>(
            OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_NODE, "ArkUI_NativeNodeAPI_1"));
        OH_LOG_INFO(LOG_APP, "CreateNativeNode animateTo %{public}d", reinterpret_cast<UserData *>(userData)->data);

        if (isback) {
            ArkUI_NumberValue custom_widthValue[] = {200};
            ArkUI_AttributeItem custom_widthItem = {custom_widthValue, 1};
            ArkUI_NumberValue custom_heightValue1[] = {80};
            ArkUI_AttributeItem custom_heightItem1 = {custom_heightValue1, 1};
            nodeAPI->setAttribute(textInput, NODE_WIDTH, &custom_widthItem);
            nodeAPI->setAttribute(textInput, NODE_HEIGHT, &custom_heightItem1);
        } else {
            ArkUI_NumberValue custom_widthValue[] = {100};
            ArkUI_AttributeItem custom_widthItem = {custom_widthValue, 1};
            ArkUI_NumberValue custom_heightValue1[] = {40};
            ArkUI_AttributeItem custom_heightItem1 = {custom_heightValue1, 1};
            nodeAPI->setAttribute(textInput, NODE_WIDTH, &custom_widthItem);
            nodeAPI->setAttribute(textInput, NODE_HEIGHT, &custom_heightItem1);
        }
    };

    nodeAPI->addChild(stack, textInput);
    OH_ArkUI_NodeContent_AddNode(handle, stack);
}

void OnButtonShowClicked2(ArkUI_NodeEvent *event)
{
    if (!event) {
        return;
    }
    if (isback) {
        isback = false;
    } else {
        isback = true;
    }
    animateApi->animateTo(context, option, update, completeCallback);
}

napi_value DestroyAttributeAnimationNativeRoot(napi_env env, napi_callback_info info)
{
    CloseDialog();
    return nullptr;
}
} // namespace NativeModule