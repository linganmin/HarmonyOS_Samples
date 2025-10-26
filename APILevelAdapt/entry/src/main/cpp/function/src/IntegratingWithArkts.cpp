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

#include <arkui/native_node_napi.h>
#include <string>
#include "ArkUIButtonNode.h"
#include "NativeEntry.h"
#include "IntegratingWithArkts.h"
#include <deviceinfo.h>

namespace NativeModule {
NativeEntry nativeEntry;

napi_value CreateButtonNativeRoot(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    // Get parameters passed in from JS.
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    // Get NodeContent.
    ArkUI_NodeContentHandle contentHandle;
    OH_ArkUI_GetNodeContentFromNapiValue(env, args[0], &contentHandle);
    nativeEntry.SetContentHandle(contentHandle);

    // Create a text list.
    auto list = CreateButtonExample();
    // Keep the Native side objects in the management class and maintain their lifecycle.
    nativeEntry.SetRootNode(list);

    return nullptr;
}
// [Start button_api]
std::shared_ptr<ArkUIBaseNode> CreateButtonExample()
{
    auto textNode = std::make_shared<ArkUIButtonNode>();
    textNode->SetTextContent(std::string("Hello World"));
    // [StartExclude button_api]
    textNode->SetFontSize(TEXT_FONTSIZE);
    textNode->SetPercentWidth(1);
    textNode->SetHeight(40);
    textNode->SetTextAlign(ARKUI_TEXT_ALIGNMENT_CENTER);
    // [EndExclude button_api]
    // Regarding the proprietary interfaces of HarmonyOS, specifically the interfaces marked as since M.F.S(N).
    // Compatibility judgment, the value corresponding to version 5.1.1(19) is 50101,
    // which is derived from the new interface's since field 5*10000 + 1*100 + 1.
    if (OH_GetDistributionOSApiVersion() >= 50101) {
        textNode->SetButtonType(ARKUI_BUTTON_ROUNDED_RECTANGLE);
    } else {
        textNode->SetButtonType(ARKUI_BUTTON_TYPE_CAPSULE);
    }
    return textNode;
}
// [End button_api]

napi_value DestroyButtonNativeRoot(napi_env env, napi_callback_info info)
{
    nativeEntry.DisposeRootNode();
    return nullptr;
}
} // namespace NativeModule