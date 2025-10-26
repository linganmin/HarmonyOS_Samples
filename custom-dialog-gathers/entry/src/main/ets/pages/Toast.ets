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
import { CommonConstants } from '../common/constants/CommonConstants';

@CustomDialog
struct CustomDialogExample {
  controller?: CustomDialogController;

  build() {
    Column() {
      Text($r('app.string.login'))
        .fontSize($r('app.float.font_size1'))
        .fontColor(Color.Black)
        .height($r('app.float.toast_height'))
    }
    .backgroundColor($r('app.color.start_window_background'))
    .borderRadius($r('app.float.border_radius2'))
    .width($r('app.float.toast_width'))
  }
}

@Entry
@Component
struct CustomDialogUser {
  @State textValue: string = '';
  @State inputValue: ResourceStr = $r('app.string.click');
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample(),
    openAnimation: {
      duration: CommonConstants.DURATION,
      curve: Curve.Friction,
      delay: CommonConstants.DELAY,
      playMode: PlayMode.Alternate
    },
    closeAnimation: {
      duration: CommonConstants.DURATION,
      curve: Curve.Friction,
      delay: CommonConstants.DELAY,
      playMode: PlayMode.Alternate
    },
    alignment: DialogAlignment.Bottom,
    offset: { dx: CommonConstants.ZERO, dy: $r('app.float.offset_dy') },
    customStyle: true,
    cornerRadius: $r('app.float.corner_radius'),
    isModal: false
  })

  aboutToDisappear() {
    this.dialogController = null;
  }

  build() {
    Navigation() {
      Column() {
        Button(this.inputValue)
          .onClick(() => {
            if (this.dialogController != null) {
              this.dialogController.open();
              setTimeout(() => {
                this.dialogController?.close();
              }, 3000)
            }
          })
          .backgroundColor($r('app.color.color_warning'))
          .margin({ bottom: $r('app.float.bottom_margin') })
      }
      .height(CommonConstants.ONE_HUNDRED_ELEVEN_PERCENT)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
      .justifyContent(FlexAlign.End)
      .backgroundColor($r('app.color.color_background'))
    }
    .title($r('app.string.toast_dialog'))
    .titleMode(NavigationTitleMode.Mini)
  }
}