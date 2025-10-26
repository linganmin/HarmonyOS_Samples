/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
import testNapi from 'libentry.so';
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct Index {
  @State message: ResourceStr = $r('app.string.result_description');
  // [Start work_function]
  @State value: number = 0;
  work: Function = (param: number) => {
    param += 30;
    this.value = param;
    return param;
  }
  // [End work_function]

  build() {
    Row() {
      Column() {
        Text($r('app.string.title_description'))
          .textAlign(TextAlign.Start)
          .width('100%')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 56 })
        Column() {
          Text(this.message)
            .fontSize(14)
            .width('100%')
            .textAlign(TextAlign.Start)
            .fontColor(Color.Black)
            .opacity(0.6)
            .fontWeight(500)
          TextArea({ text: JSON.stringify(this.value) })
            .fontSize(16)
            .focusable(false)
            .fontColor(Color.Black)
            .opacity(0.6)
            .fontWeight(FontWeight.Normal)
            .margin({ top: 12 })
        }
        .height(80)
        .margin({ top: 24 })

        Blank();
        Button($r('app.string.threadSafe_Case'))
          .width('100%')
          .onClick(() => {
            // [Start testNapi_thread_safe_case]
            //Call Native side function and pass ArkTS side function to Native side.
            testNapi.threadSafeCase(this.work);
            // [End testNapi_thread_safe_case]
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.threadSafe_message'),
              duration: 2000
            })
          })
        Button($r('app.string.libUV_Case'))
          .width('100%')
          .margin({ top: 12 })
          .onClick(() => {
            // [Start lib_case]
            //Call Native side function and pass ArkTS side function to Native side.
            testNapi.libUvCase(this.work);
            // [End lib_case]
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.libUV_message'),
              duration: 2000
            })
          })
      }
      .justifyContent(FlexAlign.End)
      .padding({ left: 16, right: 16, bottom: 16 })
      .width('100%')
      .height('100%')
    }
    .height('100%')
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
