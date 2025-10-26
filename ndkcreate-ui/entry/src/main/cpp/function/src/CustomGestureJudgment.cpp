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

#include <arkui/native_gesture.h>
#include <arkui/native_interface.h>
#include <arkui/native_node_napi.h>
#include <arkui/native_type.h>
#include <hilog/log.h>
#include <js_native_api.h>
#include "BuildingADialogBox.h"
#include "CustomGestureJudgment.h"

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200 // Global domain macro, identifying the business domain
#define LOG_TAG "MY_TAG"  // Global tag macro, identifying module log tags

namespace NativeModule {
napi_value CreateCustomGestureViewNativeRoot(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    // Get parameters passed in from JS.
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // Get NodeContent.
    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);

    // Load custom gestures.
    CustomGestureViewMethod(contentHandle);
    return nullptr;
}

void CustomGestureViewMethod(ArkUI_NodeContentHandle handle)
{
    ArkUI_NativeNodeAPI_1 *nodeAPI = reinterpret_cast<ArkUI_NativeNodeAPI_1 *>(
        OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_NODE, "ArkUI_NativeNodeAPI_1"));
    // Create Column Node.
    auto column = nodeAPI->createNode(ARKUI_NODE_COLUMN);
    // Set Background Color.
    ArkUI_NumberValue value[] = {{.u32 = 0xff112233}};
    ArkUI_AttributeItem item = {value, 1};
    nodeAPI->setAttribute(column, NODE_BACKGROUND_COLOR, &item);
    // Set width.
    ArkUI_NumberValue widthValue[] = {{400}};
    ArkUI_AttributeItem width = {widthValue, 1};
    nodeAPI->setAttribute(column, NODE_WIDTH, &width);
    // Set height
    ArkUI_NumberValue heightValue[] = {{400}};
    ArkUI_AttributeItem height = {heightValue, 1};
    nodeAPI->setAttribute(column, NODE_HEIGHT, &height);

    // Get the collection of gesture native interfaces.
    auto gestureApi = reinterpret_cast<ArkUI_NativeGestureAPI_1 *>(
        OH_ArkUI_QueryModuleInterfaceByName(ARKUI_NATIVE_GESTURE, "ArkUI_NativeGestureAPI_1"));
    // Create long press gesture.
    auto longPressGesture = gestureApi->createLongPressGesture(1, true, 1000);

    // Set callback.
    auto onActionCallBack = [](ArkUI_GestureEvent *event, void *extraParam) {
        // Callback content.
        OH_LOG_INFO(LOG_APP, "Long press gesture triggere");
    };

    // Set gestures to components.
    gestureApi->setGestureEventTarget(
        longPressGesture, GESTURE_EVENT_ACTION_ACCEPT | GESTURE_EVENT_ACTION_UPDATE | GESTURE_EVENT_ACTION_END, column,
        onActionCallBack);

    gestureApi->addGestureToNode(column, longPressGesture, PARALLEL, NORMAL_GESTURE_MASK);

    auto onInterruptCallback = [](ArkUI_GestureInterruptInfo *info) -> ArkUI_GestureInterruptResult {
        // Obtain whether there is a system gesture.
        auto systag = OH_ArkUI_GestureInterruptInfo_GetSystemFlag(info);
        // Obtain intercepted gesture pointer.
        auto recognizer = OH_ArkUI_GestureInterruptInfo_GetRecognizer(info);
        // Obtain system gesture types.
        auto systemRecognizerType = OH_ArkUI_GestureInterruptInfo_GetSystemRecognizerType(info);
        // Get gesture events.
        auto gestureEvent = OH_ArkUI_GestureInterruptInfo_GetGestureEvent(info);
        auto inputevent = OH_ArkUI_GestureEvent_GetRawInputEvent(gestureEvent);

        if (systag) {
            // If it is a system gesture, do not intercept it.
            OH_LOG_INFO(LOG_APP, "it's a system gesture, not intercepting.");
            return GESTURE_INTERRUPT_RESULT_CONTINUE;
        } else {
            // Refuse if it's a system gesture.
            OH_LOG_INFO(LOG_APP, "it's not a system gesture, rejecting.");
            return GESTURE_INTERRUPT_RESULT_REJECT;
        }
    };

    gestureApi->setGestureInterrupterToNode(column, onInterruptCallback);
    OH_ArkUI_NodeContent_AddNode(handle, column);
}

napi_value DestroyCustomGestureViewNativeRoot(napi_env env, napi_callback_info info)
{
    CloseDialog();
    return nullptr;
}
} // namespace NativeModule