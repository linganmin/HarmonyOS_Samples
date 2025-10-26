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

import { CommonConstants } from '../common/CommonConstants';
import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
export struct Logout {
  private customDialogComponentId: number = CommonConstants.CUSTOM_DIALOG_COMPONENT_ID;
  @Consume isShowSheet: boolean;

  @Builder
  customDialogComponent() {
    Column() {
      Text($r('app.string.confirmed_logout'))
        .fontSize($r('app.float.normal_text_size'))
        .padding({ top: $r('app.float.padding') })

      Row() {
        Text($r('app.string.cancel'))
          .fontSize($r('app.float.normal_text_size'))
          .fontColor(Color.Blue)
          .layoutWeight(CommonConstants.CUSTOM_DIALOG_ROW_LAYOUT_WEIGHT)
          .textAlign(TextAlign.Center)
          .width($r('app.float.customDialog_bottom_row_width'))
          .height($r('app.float.customDialog_bottom_row_height'))
          .lineHeight($r('app.float.line_height'))
          .onClick(() => {
            this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId);
          })

        Text($r('app.string.confirmed'))
          .fontSize($r('app.float.normal_text_size'))
          .fontColor(Color.Blue)
          .layoutWeight(CommonConstants.CUSTOM_DIALOG_ROW_LAYOUT_WEIGHT)
          .textAlign(TextAlign.Center)
          .width($r('app.float.customDialog_bottom_row_width'))
          .height($r('app.float.customDialog_bottom_row_height'))
          .lineHeight($r('app.float.line_height'))
          .onClick(() => {
            this.isShowSheet = false;
            AppStorage.setOrCreate('isLogin', false);
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/Index'
            });
            this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogComponentId);
          })
      }
      .height($r('app.float.customDialog_bottom_row_height'))
      .width(CommonConstants.FULL_SCREEN)
    }
    .justifyContent(FlexAlign.SpaceAround)
    .height($r('app.float.customDialog_column_height'))
    .width(CommonConstants.FULL_SCREEN)
    .padding($r('app.float.padding'))
  }

  build() {
    Button({
      type: ButtonType.Normal,
      stateEffect: true
    }) {
      Row() {
        Text($r('app.string.logout'))
          .fontSize($r('app.float.login_text_font_size'))
          .fontColor($r('app.color.text_font_color'))
          .textAlign(TextAlign.Center)
          .width(CommonConstants.FULL_SCREEN)
          .onClick(() => {
            this.getUIContext().getPromptAction().openCustomDialog({
              builder: () => {
                this.customDialogComponent();
              },
              autoCancel: true,
              showInSubWindow: false,
              offset: { dx: CommonConstants.PROMPT_ACTION_X, dy: CommonConstants.PROMPT_ACTION_Y },
              cornerRadius: CommonConstants.CORNER_RADIUS,
              width: $r('app.float.promptAction_width'),
              height: $r('app.float.promptAction_height'),
              shadow: ({
                radius: CommonConstants.SHADOW_RADIUS,
                color: Color.Gray,
                offsetX: CommonConstants.SHADOW_X,
                offsetY: CommonConstants.SHADOW_Y
              }),
              backgroundColor: Color.White
            }).then((dialogId: number) => {
              this.customDialogComponentId = dialogId;
            })
          })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .width(CommonConstants.FULL_SCREEN)
    .height($r('app.float.button_height'))
    .borderRadius($r('app.float.button_border_radius'))
    .backgroundColor($r('app.color.tabContent_row_background'))
  }
}