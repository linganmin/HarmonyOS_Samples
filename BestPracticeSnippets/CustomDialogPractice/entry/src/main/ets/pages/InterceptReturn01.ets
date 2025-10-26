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

// [Start InterceptReturn01_start]
import { PromptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct InterceptReturn01 {
  private context: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.getUIContext().getPromptAction();
  private customDialogComponentId: number = 0;
  @Consume('NavPathStack') pageStack: NavPathStack;

  @Builder
  customDialogComponent() {
    Column() {
      Row() {
        Text('Title')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)

      Text('This is a dialog content.')
        .fontSize(14)

      Button('CONFIRM')
        .fontSize(16)
        .fontColor('#0A59F7')
        .backgroundColor(Color.White)
        .onClick(() => {
          this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId);
        })
        .width('100%')
        .margin({
          top: 8,
          bottom: 16
        })
    }
    .padding({
      left: 24,
      right: 24
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(32)
    .margin({
      left: 16,
      right: 16
    })
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Button('OPEN')
            .fontSize(16)
            .width('100%')
            .borderRadius(20)
            .margin({ bottom: 16 })
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.getUIContext().getPromptAction().openCustomDialog({
                builder: () => {
                  this.customDialogComponent()
                },
                alignment: DialogAlignment.Center,
                maskColor: 'rgba(0, 0, 0, 0.2)',
                onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
                  hilog.info(0xFF00, 'testTag', JSON.stringify(dismissDialogAction.reason));
                }
              }).then((dialogId: number) => {
                this.customDialogComponentId = dialogId
              })
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16
      })
      .justifyContent(FlexAlign.End)
    }
  }
}
// [End InterceptReturn01_start]