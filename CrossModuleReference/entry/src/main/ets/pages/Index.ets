/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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

import napi from 'libentry.so';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Text($r('app.string.title'))
        .width('100%')
        .fontColor('#E6000000')
        .fontSize(30)
        .fontWeight(700)
        .lineHeight(40)
        .textAlign(TextAlign.Start)
        .margin({ top: 64 })

      Blank()

      Button($r('app.string.call_native_method'))
        .fontSize(16)
        .width('100%')
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({ message: 'Native method call succeed, result is ' + napi.add(2, 3).toString() });
        })

      // [Start call_har_native_start]
      Button($r('app.string.call_har_native_method'))
        .fontSize(16)
        .width('100%')
        .margin({ top: 12 })
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({
            message: 'HarNative method call succeed, result is ' + napi.invokeHarNative(2, 3).toString()
          });
        })
      // [End call_har_native_start]

      // [Start call_har_ArkTS_start]
      Button($r('app.string.call_har_ArkTS_method'))
        .fontSize(16)
        .width('100%')
        .margin({ top: 12 })
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({ message: 'HarArkTS method call succeed, result is '
            + napi.invokeHarArkTS(2, 3).toString() });
        })
      // [End call_har_ArkTS_start]

      Button($r('app.string.call_hsp_native_method'))
        .fontSize(16)
        .width('100%')
        .margin({ top: 12 })
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({
            message: 'HspNative method call succeed, result is ' + napi.invokeHspNative(2, 3).toString()
          });
        })

      Button($r('app.string.call_hsp_ArkTS_method'))
        .fontSize(16)
        .width('100%')
        .margin({ top: 12 })
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({ message: 'HspArkTS method call succeed, result is '
            + napi.invokeHspArkTS(2, 3).toString() });
        })
    }
    .padding({
      bottom: 16,
      left: 16,
      right: 16
    })
    .justifyContent(FlexAlign.End)
    .width('100%')
    .height('100%')
  }
}
