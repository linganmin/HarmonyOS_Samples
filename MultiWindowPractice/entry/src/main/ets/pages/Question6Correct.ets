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

@Builder
export function Question6CorrectBuilder() {
  Question6Correct()
}

// [Start Custom_dialog_comp]
@CustomDialog
struct CustomDialogComp {
  controller: CustomDialogController = new CustomDialogController({ 'builder': '' });

  build() {
    Column() {
      Text($r('app.string.welcome'))
        // [StartExclude Custom_dialog_comp]
        .fontColor($r('sys.color.font_primary'))
        .height(56)
        .fontSize(20)
        .textAlign(TextAlign.Center)
        .fontWeight(700)
      // [EndExclude Custom_dialog_comp]

      Column() {
        Scroll() {
          Text($r('app.string.dialog_content'))
            // [StartExclude Custom_dialog_comp]
            .fontSize(18)
            .lineHeight(25)
            .width('100%')
          // [EndExclude Custom_dialog_comp]
        }
      }
      .layoutWeight(1)

      Row({ space: 12 }) {
        Button($r('app.string.disagree'))
          // [StartExclude Custom_dialog_comp]
          .backgroundColor('rgba(0,0,0,0.05)')
          .fontColor('#0A59F7')
          .layoutWeight(1)
          .height(40)
        // [EndExclude Custom_dialog_comp]
        Button($r('app.string.agree'))
          // [StartExclude Custom_dialog_comp]
          .layoutWeight(1)
          .height(40)
        // [EndExclude Custom_dialog_comp]
      }
      .height(56)
      .alignItems(VerticalAlign.Top)
    }
    .constraintSize({
      maxHeight: '80%'
    })
    .height(400)
    // [StartExclude Custom_dialog_comp]
    .width('calc(100% - 32vp)')
    .padding({
      left: 16,
      right: 16
    })
    .borderRadius(24)
    .backgroundColor(Color.White)
    // [EndExclude Custom_dialog_comp]
  }
}
// [End Custom_dialog_comp]

@Component
export struct Question6Correct {
  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogComp(),
    alignment: DialogAlignment.Center,
    customStyle: true,
    autoCancel: false
  });

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        Button('Show dialog')
          .height(40)
          .width('100%')
          .onClick(() => {
            this.dialogController.open();
          })
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding(16)
    }
    .hideTitleBar(true)
    .padding({
      top: AppStorage.get<number>('statusBarHeight') ?? 0,
      bottom: AppStorage.get<number>('naviIndicatorHeight') ?? 0
    })
  }
}
