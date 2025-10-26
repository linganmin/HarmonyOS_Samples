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

// [Start sourcecode_start]
@Entry
@Component
struct Index {
  private customDialogComponentId: number = 0;
  private promptAction = this.getUIContext().getPromptAction();

  @Builder
  customDialogPositiveExample() {
    Column() {
      Text('授权成功')
        .fontColor($r('app.color.text_color'))
        // [StartExclude sourcecode_start]
        .fontSize(20)
        .fontWeight(700)
        .lineHeight(27)
      // [EndExclude sourcecode_start]
      Text('授权码：441132')
        .fontColor($r('app.color.text_color'))

      Row({ space: 8 }) {
        Button('复制', { buttonStyle: ButtonStyleMode.TEXTUAL })
          .fontColor($r('app.color.text_color'))
          // [StartExclude sourcecode_start]
          .width(144)
          .height(40)
          .borderRadius(20)
          .onClick(() => {
            this.promptAction.closeCustomDialog(this.customDialogComponentId);
          })
        // [EndExclude sourcecode_start]
        Button('确定', { buttonStyle: ButtonStyleMode.TEXTUAL })
        // [StartExclude sourcecode_start]
          .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
          .width(144)
          .height(40)
          .borderRadius(20)
          .onClick(() => {
            this.promptAction.closeCustomDialog(this.customDialogComponentId);
          })
        // [EndExclude sourcecode_start]
      }
      // [StartExclude sourcecode_start]
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      // [EndExclude sourcecode_start]
    }
    // [StartExclude sourcecode_start]
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
    .height(216)
    .alignItems(HorizontalAlign.Center)

    // [EndExclude sourcecode_start]
  }

  build() {
    // [StartExclude sourcecode_start]
    Row() {
      Column({ space: 20 }) {
        Text('组件内弹窗')
          .fontSize(30)
          .onClick(() => {
            this.promptAction.openCustomDialog({
              builder: () => {
                this.customDialogPositiveExample();
              }
            }).then((dialogId: number) => {
              this.customDialogComponentId = dialogId;
            })
          })
      }
      .width('100%')
    }
    .height('100%')
    // [EndExclude sourcecode_start]
  }
}
// [End sourcecode_start]