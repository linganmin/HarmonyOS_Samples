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

import { ComponentContent, LevelMode } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PromptActionClass } from '../utils/PromptActionClass';

let getUIContext: UIContext;
let privacyContentNode: ComponentContent<Object>;

@Builder
function buildActionTips() {
  Stack({ alignContent: Alignment.Center }) {
    Column() {
      Text($r('app.string.agreement_tips'))
        .fontSize(20)
        .fontWeight(700)
      Row({ space: 4 }) {
        Text() {
          Span($r('app.string.sign_in_and_agree'))
          Span($r('app.string.user_authentication_protocol'))
            .fontColor('#0A59F7')
            .onClick(() => {
              let pathStack = AppStorage.get('NavPathStack') as NavPathStack;
              pathStack.pushPathByName('AgreementPage', '');
            })
        }

      }
      .width('100%')
      .margin({
        top: 24,
        bottom: 16
      })
      .justifyContent(FlexAlign.Start)
      .padding({ left: 12 })

      Row() {
        Text($r('app.string.rejected'))
          .fontSize(16)
          .fontColor('#0A59F7')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .width(140)
          .height(40)
          .lineHeight(24)
          .onClick(() => {
            PromptActionClass.closeDialog(privacyContentNode);
          })

        Text($r('app.string.confirm_login'))
          .fontSize(16)
          .fontColor('#0A59F7')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .width(140)
          .height(40)
          .lineHeight(24)
          .onClick(() => {
            PromptActionClass.closeDialog(privacyContentNode);
          })
      }
      .width('100%')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(32)
    .padding(16)
  }
  .padding(16)
  .height('100%')
  .width('100%')
}

@Component
export struct PrivacyDialog {
  @State isShowSheet: boolean = false;
  @Consume('NavPathStack') pageStack: NavPathStack;

  aboutToAppear(): void {
    getUIContext = this.getUIContext();
    privacyContentNode = new ComponentContent(getUIContext, wrapBuilder(buildActionTips));
  }

  build() {
    NavDestination() {
      // [Start privacy_dialog]
      Column() {
        Row() {
          Image($r('app.media.chevron_left'))
            .width(16)
            .height(16)
            .margin({ left: 12 })
        }
        .width(40)
        .height(40)
        .borderRadius(48)
        .margin({ top: 42 })
        .backgroundColor('#e6eaeb')
        .onClick(() => {
          this.pageStack.pop();
        })

        Row() {
          Button('OPEN')
            .id('privacyDialog')
            .fontSize(16)
            .width('100%')
            .borderRadius(20)
            .margin({ bottom: 16 })
            .backgroundColor('#0A59F7')
            .onClick(() => {
              const node: FrameNode | null = this.getUIContext().getFrameNodeById('privacyDialog');
              let uiContext = this.getUIContext();
              PromptActionClass.setContext(uiContext);
              PromptActionClass.setContentNode(privacyContentNode);
              // [Start privacy_dialog_setOptions]
              PromptActionClass.setOptions({
                levelMode: LevelMode.EMBEDDED,
                levelUniqueId: node?.getUniqueId(),
                onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
                  hilog.info(0xFF00, 'TAG', JSON.stringify(dismissDialogAction.reason));
                }
              })
              // [End privacy_dialog_setOptions]
              PromptActionClass.openDialog();
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
        bottom: 32
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)

      // [End privacy_dialog]
    }
    .hideToolBar(true)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}