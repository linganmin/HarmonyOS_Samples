/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { CommonConstants } from '../common/CommonConstants';

@CustomDialog
@Component
export struct SavePicker {
  controller?: CustomDialogController;
  @Link saveFormat: string;
  confirmBtn: () => void = () => {
  };
  confirmCancle: () => void = () => {
  };
  private codedFormat = ['aac', 'm4a', 'mp3', 'wav', 'amr'];

  aboutToAppear() {
    this.saveFormat = 'aac';
  }

  build() {
    Column() {
      Text($r('app.string.target_save_format'))
        .fontSize(CommonConstants.BUTTON_TEXT_STYLE_FONT_SIZE)
        .fontColor($r('sys.color.black'))
        .fontSize(20)
        .height(56)
        .fontWeight(FontWeight.Bold)
      TextPicker({ range: this.codedFormat })
        .onChange((value: string | string[]) => {
          this.saveFormat = value as string;
        })
        .canLoop(false)
        .margin({ bottom: $r('app.float.common_image') })

      Row() {
        Button($r('app.string.picker_btn_cancel'), { buttonStyle: ButtonStyleMode.TEXTUAL, role: ButtonRole.NORMAL, stateEffect: false })
          .fontSize(CommonConstants.BUTTON_TEXT_STYLE_FONT_SIZE)
          .fontColor('#0A59F7')
          .onClick(() => {
            this.confirmCancle();
          })
        Divider()
          .vertical(true)
          .height(22)
          .color($r('sys.color.mask_fourth'))
          .opacity(0.6)
          .margin({ left: 50, right: 50 })
        Button($r('app.string.picker_btn_confirm'), { buttonStyle: ButtonStyleMode.TEXTUAL, role: ButtonRole.NORMAL, stateEffect: false })
          .fontSize(CommonConstants.BUTTON_TEXT_STYLE_FONT_SIZE)
          .fontColor('#0A59F7')
          .onClick(() => {
            this.confirmBtn()
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: $r('app.float.button_margin_bottom') })
    }
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.audio_border_raduis'))
    .padding({ left: $r('app.float.common_height'), right: $r('app.float.common_height') })
  }
}